"""
Agente Inteligente para Análise de Dados - EDA Automático
API FastAPI para análise exploratória de dados com IA
"""

from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import List, Dict, Any, Optional
import pandas as pd
import numpy as np

# Outras bibliotecas úteis
import io
import json
import os
import uuid
import asyncio
from datetime import datetime
import logging
from pathlib import Path

# Configurar logging PRIMEIRO (antes de usar logger)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Banco de dados - MongoDB se estiver disponível
try:
    from dotenv import load_dotenv
    load_dotenv()
    
    # Verificar se deve usar MongoDB
    USE_MONGODB = os.getenv("USE_MONGODB", "false").lower() == "true"
    
    if USE_MONGODB:
        try:
            from pymongo import MongoClient
            from pymongo.errors import ConnectionFailure
            MONGODB_AVAILABLE = True
            logger.info("✅ PyMongo disponível - MongoDB habilitado")
        except ImportError:
            MONGODB_AVAILABLE = False
            logger.warning("⚠️ PyMongo não encontrado - usando armazenamento em memória")
    else:
        MONGODB_AVAILABLE = False
        logger.info("ℹ️ MongoDB desabilitado - usando armazenamento em memória")
        
except Exception as e:
    MONGODB_AVAILABLE = False
    logger.warning(f"⚠️ Erro ao configurar MongoDB: {e} - usando armazenamento em memória")

# Criar a aplicação FastAPI
app = FastAPI(
    title="Analisador Inteligente de Dados CSV",
    description="Faça upload de CSV e converse com seus dados usando IA",
    version="1.0.0"
)

# Configurar CORS para o frontend conseguir acessar
cors_origins_env = os.getenv("CORS_ORIGINS", "*")
if cors_origins_env == "*":
    # Permitir todas as origens
    cors_origins = ["*"]
    logger.info("CORS configurado para aceitar todas as origens (*)")
else:
    # Usar origens específicas da variável de ambiente
    cors_origins = [origin.strip() for origin in cors_origins_env.split(",")]
    logger.info(f"CORS configurado com origens: {cors_origins}")

app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configurações do banco de dados
MONGO_URL = os.getenv("MONGO_URL", "mongodb://localhost:27017")
DB_NAME = os.getenv("DB_NAME", "eda_analyzer_db")

# Variáveis globais para armazenamento
mongo_client = None
database = None

# Armazenamento em memória (fallback)
datasets_storage = {}
sessions_storage = {}

# Função para inicializar MongoDB
def init_mongodb():
    """Inicializa conexão com MongoDB"""
    global mongo_client, database
    
    if not MONGODB_AVAILABLE:
        return False
    
    try:
        logger.info(f"🔌 Conectando ao MongoDB...")
        mongo_client = MongoClient(
            MONGO_URL,
            serverSelectionTimeoutMS=5000,  # Timeout de 5 segundos
            connectTimeoutMS=10000
        )
        
        # Testar conexão
        mongo_client.admin.command('ping')
        
        database = mongo_client[DB_NAME]
        logger.info(f"✅ MongoDB conectado! Banco: {DB_NAME}")
        
        # Criar índices se necessário
        database.sessions.create_index("session_id", unique=True)
        database.datasets.create_index("session_id")
        
        return True
        
    except Exception as e:
        logger.error(f"❌ Erro ao conectar MongoDB: {e}")
        logger.info("📦 Usando armazenamento em memória como fallback")
        mongo_client = None
        database = None
        return False

# Inicializar MongoDB se disponível
if MONGODB_AVAILABLE:
    init_mongodb()

# Funções auxiliares para salvar/carregar do MongoDB
def save_session_to_db(session_id: str, session_data: dict):
    """Salva sessão no MongoDB"""
    if database is None:
        return False
    
    try:
        database.sessions.update_one(
            {"session_id": session_id},
            {"$set": {
                "session_id": session_id,
                "created_at": session_data.get("created_at", datetime.now()),
                "conversation_history": session_data.get("conversation_history", []),
                "updated_at": datetime.now()
            }},
            upsert=True
        )
        logger.debug(f"💾 Sessão {session_id} salva no MongoDB")
        return True
    except Exception as e:
        logger.error(f"❌ Erro ao salvar sessão no MongoDB: {e}")
        return False

def save_dataset_to_db(session_id: str, dataset_data: dict):
    """Salva metadados do dataset no MongoDB"""
    if database is None:
        return False
    
    try:
        # Não salvar o DataFrame (muito grande), apenas metadados
        metadata = {
            "session_id": session_id,
            "basic_info": dataset_data.get("basic_info", {}),
            "descriptive_stats": dataset_data.get("descriptive_stats", {}),
            "outliers_info": dataset_data.get("outliers_info", {}),
            "correlation_matrix": dataset_data.get("correlation_matrix", {}),
            "insights": dataset_data.get("insights", []),
            "uploaded_at": dataset_data.get("uploaded_at", datetime.now()),
            "source_file": dataset_data.get("source_file", "upload"),
            "updated_at": datetime.now()
        }
        
        database.datasets.update_one(
            {"session_id": session_id},
            {"$set": metadata},
            upsert=True
        )
        logger.debug(f"💾 Dataset {session_id} salvo no MongoDB")
        return True
    except Exception as e:
        logger.error(f"❌ Erro ao salvar dataset no MongoDB: {e}")
        return False

def load_session_from_db(session_id: str):
    """Carrega sessão do MongoDB"""
    if database is None:
        return None
    
    try:
        session = database.sessions.find_one({"session_id": session_id})
        return session
    except Exception as e:
        logger.error(f"❌ Erro ao carregar sessão do MongoDB: {e}")
        return None

# Modelos de dados
class ChatMessage(BaseModel):
    message: str
    session_id: str

class AnalysisResponse(BaseModel):
    response: str
    statistics: Optional[Dict] = {}
    insights: Optional[List[str]] = []
    charts: Optional[List[Dict]] = []

class SessionData(BaseModel):
    session_id: str
    dataset_info: Dict
    conversation_history: List[Dict]
    created_at: datetime

# Classe principal que faz a análise dos dados
class DataAnalyzer:
    """Analisa datasets e gera insights"""
    
    def __init__(self, df: pd.DataFrame):
        self.df = df
        self.numeric_columns = df.select_dtypes(include=[np.number]).columns.tolist()
        self.categorical_columns = df.select_dtypes(include=['object', 'category']).columns.tolist()
    
    def get_basic_info(self):
        """Pega informações básicas do dataset"""
        return {
            "shape": self.df.shape,
            "columns": self.df.columns.tolist(),
            "dtypes": self.df.dtypes.astype(str).to_dict(),
            "missing_values": self.df.isnull().sum().to_dict(),
            "numeric_columns": self.numeric_columns,
            "categorical_columns": self.categorical_columns,
            "memory_usage": f"{self.df.memory_usage(deep=True).sum() / 1024**2:.2f} MB"
        }
    
    def get_descriptive_stats(self):
        """Calcula estatísticas descritivas"""
        stats = {}
        
        # Para colunas numéricas
        if self.numeric_columns:
            numeric_stats = self.df[self.numeric_columns].describe()
            stats["numeric"] = numeric_stats.to_dict()
        
        # Para colunas categóricas
        if self.categorical_columns:
            categorical_stats = {}
            for col in self.categorical_columns:
                categorical_stats[col] = {
                    "unique_count": self.df[col].nunique(),
                    "most_frequent": self.df[col].mode().iloc[0] if not self.df[col].empty else None,
                    "frequency_top": self.df[col].value_counts().iloc[0] if not self.df[col].empty else 0
                }
            stats["categorical"] = categorical_stats
        
        return stats
    
    def find_outliers(self):
        """Encontra outliers usando método IQR"""
        outliers_info = {}
        
        for col in self.numeric_columns:
            Q1 = self.df[col].quantile(0.25)
            Q3 = self.df[col].quantile(0.75)
            IQR = Q3 - Q1
            lower_bound = Q1 - 1.5 * IQR
            upper_bound = Q3 + 1.5 * IQR
            
            outliers = self.df[(self.df[col] < lower_bound) | (self.df[col] > upper_bound)]
            
            outliers_info[col] = {
                "count": len(outliers),
                "percentage": (len(outliers) / len(self.df)) * 100,
                "bounds": {"lower": lower_bound, "upper": upper_bound}
            }
        
        return outliers_info
    
    def get_correlations(self):
        """Calcula correlações entre variáveis numéricas"""
        if len(self.numeric_columns) > 1:
            correlation = self.df[self.numeric_columns].corr()
            return correlation.to_dict()
        return {}
    
    def generate_insights(self):
        """Gera insights básicos sobre os dados"""
        insights = []
        
        # Insights sobre valores ausentes
        missing_data = self.df.isnull().sum()
        high_missing = missing_data[missing_data > len(self.df) * 0.5]
        if not high_missing.empty:
            insights.append(f"⚠️ Colunas com mais de 50% de valores ausentes: {', '.join(high_missing.index)}")
        
        # Insights sobre outliers
        outliers = self.find_outliers()
        high_outliers = {k: v for k, v in outliers.items() if v['percentage'] > 10}
        if high_outliers:
            insights.append(f"📊 Colunas com muitos outliers (>10%): {', '.join(high_outliers.keys())}")
        
        # Insights sobre correlações
        correlations = self.get_correlations()
        if correlations:
            # Encontrar correlações fortes
            strong_correlations = []
            for col1 in correlations:
                for col2 in correlations[col1]:
                    if col1 != col2 and abs(correlations[col1][col2]) > 0.7:
                        strong_correlations.append(f"{col1} ↔ {col2} ({correlations[col1][col2]:.2f})")
            
            if strong_correlations:
                insights.append(f"🔗 Correlações fortes encontradas: {'; '.join(strong_correlations[:3])}")
        
        # Insights sobre distribuição
        if self.numeric_columns:
            insights.append(f"📈 {len(self.numeric_columns)} colunas numéricas disponíveis para análise")
        
        if self.categorical_columns:
            insights.append(f"📝 {len(self.categorical_columns)} colunas categóricas disponíveis para análise")
        
        return insights
    
    def create_histogram_data(self, column: str):
        """Cria dados para histograma"""
        if column not in self.df.columns:
            return None
        
        data = self.df[column].dropna()
        if data.empty:
            return None
        
        return {
            "type": "histogram",
            "title": f"Distribuição de {column}",
            "data": {
                "x": data.tolist(),
                "type": "histogram",
                "name": column,
                "nbinsx": 30
            },
            "layout": {
                "title": f"Distribuição de {column}",
                "xaxis": {"title": column},
                "yaxis": {"title": "Frequência"}
            }
        }
    
    def create_correlation_heatmap_data(self):
        """Cria dados para heatmap de correlação"""
        if len(self.numeric_columns) < 2:
            return None
        
        correlation = self.df[self.numeric_columns].corr()
        
        return {
            "type": "heatmap",
            "title": "Matriz de Correlação",
            "data": {
                "z": correlation.values.tolist(),
                "x": correlation.columns.tolist(),
                "y": correlation.index.tolist(),
                "type": "heatmap",
                "colorscale": "RdBu",
                "zmid": 0
            },
            "layout": {
                "title": "Matriz de Correlação",
                "xaxis": {"title": ""},
                "yaxis": {"title": ""}
            }
        }
    
    def create_scatter_plot_data(self, x_col: str, y_col: str, color_col: str = None):
        """Cria dados para gráfico de dispersão"""
        if x_col not in self.df.columns or y_col not in self.df.columns:
            return None
        
        data = {
            "type": "scatter",
            "title": f"{y_col} vs {x_col}",
            "data": {
                "x": self.df[x_col].dropna().tolist(),
                "y": self.df[y_col].dropna().tolist(),
                "mode": "markers",
                "name": f"{y_col} vs {x_col}"
            },
            "layout": {
                "title": f"{y_col} vs {x_col}",
                "xaxis": {"title": x_col},
                "yaxis": {"title": y_col}
            }
        }
        
        if color_col and color_col in self.df.columns:
            data["data"]["marker"] = {
                "color": self.df[color_col].dropna().tolist(),
                "colorscale": "Viridis",
                "showscale": True,
                "colorbar": {"title": color_col}
            }
        
        return data
    
    def create_box_plot_data(self, column: str):
        """Cria dados para box plot"""
        if column not in self.df.columns:
            return None
        
        data = self.df[column].dropna()
        if data.empty:
            return None
        
        return {
            "type": "box",
            "title": f"Box Plot de {column}",
            "data": {
                "y": data.tolist(),
                "type": "box",
                "name": column,
                "boxpoints": "outliers"
            },
            "layout": {
                "title": f"Box Plot de {column}",
                "yaxis": {"title": column}
            }
        }

# Função para conversar com a IA
async def ask_ai(question: str, dataset_info: Dict, conversation_history: List = None):
    """Pergunta para a IA sobre os dados"""
    try:
        from groq import Groq
        
        # Configurar cliente da Groq
        client = Groq(api_key=os.getenv("GROQ_API_KEY"))
        
        # Montar contexto com informações do dataset
        context = f"""
        INFORMAÇÕES DO DATASET:
        - Formato: {dataset_info.get('shape', 'N/A')}
        - Colunas: {', '.join(dataset_info.get('columns', []))}
        - Colunas Numéricas: {', '.join(dataset_info.get('numeric_columns', []))}
        - Colunas Categóricas: {', '.join(dataset_info.get('categorical_columns', []))}
        - Valores Ausentes: {dataset_info.get('missing_values', {})}
        
        PERGUNTA: {question}
        """
        
        # Adicionar histórico recente da conversa
        if conversation_history:
            context += "\n\nCONVERSA RECENTE:\n"
            for msg in conversation_history[-3:]:
                context += f"- {msg.get('type', 'user')}: {msg.get('content', '')}\n"
        
        # Preparar mensagens para o modelo
        messages = [
            {
                "role": "system",
                "content": """Você é um analista de dados especializado em EDA.
                
                Sua função:
                - Analisar dados e identificar padrões
                - Detectar anomalias e outliers  
                - Sugerir análises úteis
                - Dar insights baseados nos dados
                - Responder em português de forma clara
                
                IMPORTANTE: Como não temos visualizações disponíveis, foque em:
                - Análises estatísticas
                - Insights sobre correlações
                - Identificação de padrões
                - Sugestões de limpeza de dados
                
                Seja técnico mas acessível."""
            },
            {
                "role": "user",
                "content": context
            }
        ]
        
        # Chamar a API da Groq
        completion = client.chat.completions.create(
            model="deepseek-r1-distill-llama-70b",
            messages=messages,
            temperature=0.6,
            max_completion_tokens=4096,
            top_p=0.95,
            stream=False
        )
        
        # Pegar a resposta
        response = completion.choices[0].message.content
        
        return response
        
    except Exception as e:
        logger.error(f"Erro na IA: {e}")
        return f"Desculpe, tive um problema ao analisar sua pergunta: {str(e)}"

# Endpoints da API

@app.get("/api/sample-files")
async def get_sample_files():
    """Lista arquivos CSV de exemplo"""
    try:
        sample_dir = Path("sample_data")
        if not sample_dir.exists():
            return {"files": [], "message": "Pasta de exemplos não encontrada"}
        
        csv_files = []
        for file_path in sample_dir.glob("*.csv"):
            file_info = {
                "filename": file_path.name,
                "size": file_path.stat().st_size,
                "size_mb": round(file_path.stat().st_size / (1024 * 1024), 2)
            }
            csv_files.append(file_info)
        
        return {"files": csv_files, "count": len(csv_files)}
    except Exception as e:
        logger.error(f"Erro ao listar arquivos: {e}")
        raise HTTPException(status_code=500, detail=f"Erro: {str(e)}")

@app.post("/api/load-sample/{filename}")
async def load_sample_file(filename: str):
    """Carrega um arquivo CSV de exemplo"""
    try:
        if not filename.endswith('.csv'):
            raise HTTPException(status_code=400, detail="Precisa ser arquivo CSV")
        
        file_path = Path("sample_data") / filename
        
        if not file_path.exists():
            raise HTTPException(status_code=404, detail=f"Arquivo {filename} não encontrado")
        
        # Tentar diferentes codificações
        encodings = ['utf-8', 'latin-1', 'cp1252', 'iso-8859-1']
        df = None
        
        for encoding in encodings:
            try:
                df = pd.read_csv(file_path, encoding=encoding)
                logger.info(f"Arquivo carregado com encoding: {encoding}")
                break
            except UnicodeDecodeError:
                continue
            except Exception as e:
                logger.error(f"Erro com {encoding}: {e}")
                continue
        
        if df is None:
            raise HTTPException(status_code=500, detail="Não consegui ler o arquivo com nenhum encoding")
        
        if df.empty:
            raise HTTPException(status_code=400, detail="Arquivo vazio")
        
        # Criar sessão
        session_id = str(uuid.uuid4())
        
        # Analisar dados
        analyzer = DataAnalyzer(df)
        basic_info = analyzer.get_basic_info()
        descriptive_stats = analyzer.get_descriptive_stats()
        outliers_info = analyzer.find_outliers()
        correlation_matrix = analyzer.get_correlations()
        insights = analyzer.generate_insights()
        
        # Salvar dados da sessão
        datasets_storage[session_id] = {
            "dataframe": df,
            "analyzer": analyzer,
            "basic_info": basic_info,
            "descriptive_stats": descriptive_stats,
            "outliers_info": outliers_info,
            "correlation_matrix": correlation_matrix,
            "insights": insights,
            "uploaded_at": datetime.now(),
            "source_file": filename
        }
        
        sessions_storage[session_id] = {
            "conversation_history": [],
            "created_at": datetime.now()
        }
        
        # Salvar no MongoDB se disponível
        if database is not None:
            save_dataset_to_db(session_id, datasets_storage[session_id])
            save_session_to_db(session_id, sessions_storage[session_id])
            logger.info(f"📊 Sessão {session_id} salva no MongoDB")
        
        # Análise inicial automática (opcional - não falha se IA tiver problema)
        try:
            initial_analysis = await ask_ai(
                "Faça uma análise inicial deste dataset, destacando pontos importantes",
                basic_info
            )
            logger.info("✅ Análise da IA concluída")
        except Exception as ai_error:
            logger.error(f"⚠️ Erro na IA (não crítico): {ai_error}")
            initial_analysis = "📊 Dataset carregado com sucesso!\n\n⚠️ Análise automática temporariamente indisponível.\n\nVocê pode fazer perguntas sobre seus dados no chat abaixo."
        
        return {
            "session_id": session_id,
            "basic_info": basic_info,
            "initial_analysis": initial_analysis,
            "insights": insights,
            "message": f"Dataset {filename} carregado! {basic_info['shape'][0]} linhas, {basic_info['shape'][1]} colunas.",
            "source_file": filename
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Erro ao carregar sample: {e}")
        raise HTTPException(status_code=500, detail=f"Erro: {str(e)}")

@app.post("/api/upload-csv")
async def upload_csv(file: UploadFile = File(...)):
    """Faz upload de arquivo CSV"""
    try:
        if not file.filename.endswith('.csv'):
            raise HTTPException(status_code=400, detail="Só aceito CSV")
        
        # Ler arquivo
        contents = await file.read()
        
        # Tentar diferentes encodings
        encodings = ['utf-8', 'latin-1', 'cp1252', 'iso-8859-1']
        df = None
        
        for encoding in encodings:
            try:
                df = pd.read_csv(io.StringIO(contents.decode(encoding)))
                logger.info(f"Upload com encoding: {encoding}")
                break
            except UnicodeDecodeError:
                continue
            except Exception as e:
                logger.error(f"Erro com {encoding}: {e}")
                continue
        
        if df is None:
            raise HTTPException(status_code=500, detail="Não consegui ler o arquivo")
        
        if df.empty:
            raise HTTPException(status_code=400, detail="Arquivo vazio")
        
        # Criar sessão
        session_id = str(uuid.uuid4())
        
        # Analisar
        analyzer = DataAnalyzer(df)
        basic_info = analyzer.get_basic_info()
        descriptive_stats = analyzer.get_descriptive_stats()
        outliers_info = analyzer.find_outliers()
        correlation_matrix = analyzer.get_correlations()
        insights = analyzer.generate_insights()
        
        datasets_storage[session_id] = {
            "dataframe": df,
            "analyzer": analyzer,
            "basic_info": basic_info,
            "descriptive_stats": descriptive_stats,
            "outliers_info": outliers_info,
            "correlation_matrix": correlation_matrix,
            "insights": insights,
            "uploaded_at": datetime.now()
        }
        
        sessions_storage[session_id] = {
            "conversation_history": [],
            "created_at": datetime.now()
        }
        
        # Salvar no MongoDB se disponível
        if database is not None:
            save_dataset_to_db(session_id, datasets_storage[session_id])
            save_session_to_db(session_id, sessions_storage[session_id])
            logger.info(f"📊 Sessão {session_id} salva no MongoDB")
        
        # Análise inicial (opcional - não falha se IA tiver problema)
        try:
            initial_analysis = await ask_ai(
                "Analise este dataset e dê um resumo geral",
                basic_info
            )
            logger.info("✅ Análise da IA concluída")
        except Exception as ai_error:
            logger.error(f"⚠️ Erro na IA (não crítico): {ai_error}")
            initial_analysis = "📊 Dataset carregado com sucesso!\n\n⚠️ Análise automática temporariamente indisponível.\n\nVocê pode fazer perguntas sobre seus dados no chat abaixo."
        
        return {
            "session_id": session_id,
            "basic_info": basic_info,
            "initial_analysis": initial_analysis,
            "insights": insights,
            "message": f"Dataset carregado! {basic_info['shape'][0]} linhas, {basic_info['shape'][1]} colunas."
        }
        
    except Exception as e:
        logger.error(f"Erro no upload: {e}")
        raise HTTPException(status_code=500, detail=f"Erro: {str(e)}")

@app.post("/api/chat", response_model=AnalysisResponse)
async def chat_with_data(message: ChatMessage):
    """Conversa com os dados"""
    try:
        session_id = message.session_id
        user_message = message.message
        
        if session_id not in datasets_storage:
            raise HTTPException(status_code=404, detail="Sessão não encontrada")
        
        # Pegar dados da sessão
        session_data = datasets_storage[session_id]
        conversation_history = sessions_storage[session_id]["conversation_history"]
        
        df = session_data["dataframe"]
        analyzer = session_data["analyzer"]
        basic_info = session_data["basic_info"]
        
        # Adicionar mensagem ao histórico
        conversation_history.append({
            "type": "user",
            "content": user_message,
            "timestamp": datetime.now()
        })
        
        # Perguntar para IA
        ai_response = await ask_ai(user_message, basic_info, conversation_history)
        
        # Gerar gráficos e insights baseados na pergunta
        charts = []
        insights = []
        message_lower = user_message.lower()
        
        # Detectar tipo de análise necessária
        if "histograma" in message_lower or "distribuição" in message_lower:
            for col in analyzer.numeric_columns[:3]:  # Máximo 3 histogramas
                chart_data = analyzer.create_histogram_data(col)
                if chart_data:
                    charts.append(chart_data)
        
        elif "correlação" in message_lower or "heatmap" in message_lower:
            heatmap_data = analyzer.create_correlation_heatmap_data()
            if heatmap_data:
                charts.append(heatmap_data)
            insights.append("Análise de correlação disponível para colunas numéricas")
        
        elif "dispersão" in message_lower or "scatter" in message_lower:
            if len(analyzer.numeric_columns) >= 2:
                scatter_data = analyzer.create_scatter_plot_data(
                    analyzer.numeric_columns[0], 
                    analyzer.numeric_columns[1]
                )
                if scatter_data:
                    charts.append(scatter_data)
        
        elif "box" in message_lower or "quartis" in message_lower:
            for col in analyzer.numeric_columns[:2]:  # Máximo 2 box plots
                box_data = analyzer.create_box_plot_data(col)
                if box_data:
                    charts.append(box_data)
        
        elif "outliers" in message_lower or "anomalias" in message_lower:
            outliers = session_data["outliers_info"]
            for col, info in outliers.items():
                if info["count"] > 0:
                    insights.append(f"Coluna {col}: {info['count']} outliers ({info['percentage']:.1f}%)")
                    # Adicionar box plot para mostrar outliers
                    box_data = analyzer.create_box_plot_data(col)
                    if box_data:
                        charts.append(box_data)
        
        elif "estatísticas" in message_lower or "stats" in message_lower:
            stats = session_data["descriptive_stats"]
            if "numeric" in stats:
                insights.append(f"Estatísticas descritivas para {len(stats['numeric'])} colunas numéricas")
                # Adicionar histogramas para as principais colunas numéricas
                for col in analyzer.numeric_columns[:2]:
                    chart_data = analyzer.create_histogram_data(col)
                    if chart_data:
                        charts.append(chart_data)
        
        # Estatísticas
        statistics = {
            "outliers": session_data["outliers_info"],
            "correlations": session_data["correlation_matrix"],
            "basic_stats": session_data["descriptive_stats"]
        }
        
        # Salvar resposta
        conversation_history.append({
            "type": "assistant",
            "content": ai_response,
            "insights": insights,
            "timestamp": datetime.now()
        })
        
        # Atualizar no MongoDB se disponível
        if database is not None:
            save_session_to_db(session_id, sessions_storage[session_id])
            logger.debug(f"💬 Conversa atualizada no MongoDB")
        
        return AnalysisResponse(
            response=ai_response,
            statistics=statistics,
            insights=insights,
            charts=charts
        )
        
    except Exception as e:
        logger.error(f"Erro no chat: {e}")
        raise HTTPException(status_code=500, detail=f"Erro: {str(e)}")

@app.get("/api/session/{session_id}/info")
async def get_session_info(session_id: str):
    """Pega informações da sessão"""
    if session_id not in datasets_storage:
        raise HTTPException(status_code=404, detail="Sessão não encontrada")
    
    session_data = datasets_storage[session_id]
    return {
        "basic_info": session_data["basic_info"],
        "descriptive_stats": session_data["descriptive_stats"],
        "outliers_info": session_data["outliers_info"],
        "insights": session_data["insights"],
        "uploaded_at": session_data["uploaded_at"]
    }

@app.get("/api/session/{session_id}/history")
async def get_conversation_history(session_id: str):
    """Pega histórico da conversa"""
    if session_id not in sessions_storage:
        raise HTTPException(status_code=404, detail="Sessão não encontrada")
    
    return sessions_storage[session_id]["conversation_history"]

@app.delete("/api/session/{session_id}")
async def delete_session(session_id: str):
    """Deleta sessão"""
    if session_id in datasets_storage:
        del datasets_storage[session_id]
    if session_id in sessions_storage:
        del sessions_storage[session_id]
    
    return {"message": "Sessão deletada"}

@app.get("/api/health")
async def health_check():
    """Verifica se a API está funcionando"""
    return {
        "status": "ok",
        "timestamp": datetime.now(),
        "active_sessions": len(datasets_storage),
        "mongodb_connected": database is not None
    }

@app.get("/api/test-chart")
async def test_chart():
    """Endpoint de teste para verificar geração de gráficos"""
    # Criar dados de teste
    import numpy as np
    test_data = np.random.normal(100, 15, 1000)
    
    # Criar histograma de teste
    chart_data = {
        "type": "histogram",
        "title": "Teste de Histograma",
        "data": {
            "x": test_data.tolist(),
            "type": "histogram",
            "name": "Dados de Teste",
            "nbinsx": 30
        },
        "layout": {
            "title": "Teste de Histograma",
            "xaxis": {"title": "Valores"},
            "yaxis": {"title": "Frequência"}
        }
    }
    
    return {"chart": chart_data}

@app.get("/")
async def root():
    return {
        "message": "Analisador Inteligente de Dados CSV",
        "version": "1.0.0",
        "description": "Converse com seus dados usando IA",
        "endpoints": [
            "/api/upload-csv - Upload de CSV",
            "/api/load-sample/{filename} - Carregar exemplo", 
            "/api/sample-files - Listar exemplos",
            "/api/chat - Conversar com dados",
            "/api/session/{session_id}/info - Info da sessão",
            "/docs - Documentação completa"
        ]
    }

# Handler padrão para a aplicação
handler = app
