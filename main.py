"""
Agente Inteligente para Análise de Dados - EDA Automático
Sistema que analisa arquivos CSV e responde perguntas sobre os dados usando IA

Tecnologias: FastAPI (backend), React (frontend), Groq + DeepSeek R1 (IA)
Autor: Fernando Meregali Xavier

"""

# Importações básicas que vou precisar
from fastapi import FastAPI, File, UploadFile, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse, JSONResponse
from pydantic import BaseModel
from typing import List, Dict, Any, Optional
import pandas as pd
import numpy as np

# Configuração para matplotlib funcionar em backend
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import seaborn as sns
import plotly.express as px
import plotly.graph_objects as go

# Outras bibliotecas úteis
import io
import base64
import json
import os
import uuid
import asyncio
from datetime import datetime
import logging
from pathlib import Path

# Banco de dados - MongoDB se estiver disponível
try:
    from motor.motor_asyncio import AsyncIOMotorClient
    from dotenv import load_dotenv
    load_dotenv("config.env")
    MONGODB_AVAILABLE = True
except ImportError:
    MONGODB_AVAILABLE = False
    print("Aviso: MongoDB não disponível, usando armazenamento em memória")

# Configurar logging para ver o que está acontecendo
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Criar a aplicação FastAPI
app = FastAPI(
    title="Analisador Inteligente de Dados CSV",
    description="Faça upload de CSV e converse com seus dados usando IA",
    version="1.0.0"
)

# Configurar CORS para o frontend conseguir acessar
app.add_middleware(
    CORSMiddleware,
    allow_origins=os.getenv("CORS_ORIGINS", "http://localhost:3000").split(","),
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

# Modelos de dados que vou usar
class ChatMessage(BaseModel):
    message: str
    session_id: str

class AnalysisResponse(BaseModel):
    response: str
    charts: Optional[List[Dict]] = []
    statistics: Optional[Dict] = {}

class SessionData(BaseModel):
    session_id: str
    dataset_info: Dict
    conversation_history: List[Dict]
    created_at: datetime

# Inicialização do app
@app.on_event("startup")
async def startup_event():
    """Conectar ao MongoDB quando a aplicação iniciar"""
    global mongo_client, database
    if MONGODB_AVAILABLE:
        try:
            mongo_client = AsyncIOMotorClient(MONGO_URL)
            database = mongo_client[DB_NAME]
            logger.info("✅ Conectado ao MongoDB!")
        except Exception as e:
            logger.warning(f"❌ MongoDB não conectado: {e}. Usando memória.")
            database = None

@app.on_event("shutdown")
async def shutdown_event():
    """Fechar conexões quando a aplicação parar"""
    if mongo_client:
        mongo_client.close()

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
    
    def create_histogram(self, column: str):
        """Cria histograma para uma coluna"""
        if column not in self.df.columns:
            return None
        
        plt.figure(figsize=(10, 6))
        plt.hist(self.df[column].dropna(), bins=30, alpha=0.7, edgecolor='black')
        plt.title(f'Distribuição de {column}')
        plt.xlabel(column)
        plt.ylabel('Frequência')
        plt.grid(True, alpha=0.3)
        
        # Converter para base64 para enviar via API
        img_buffer = io.BytesIO()
        plt.savefig(img_buffer, format='png', dpi=150, bbox_inches='tight')
        img_buffer.seek(0)
        img_base64 = base64.b64encode(img_buffer.read()).decode()
        plt.close()
        
        return img_base64
    
    def create_correlation_heatmap(self):
        """Cria heatmap de correlação"""
        if len(self.numeric_columns) < 2:
            return None
        
        plt.figure(figsize=(12, 8))
        correlation = self.df[self.numeric_columns].corr()
        sns.heatmap(correlation, annot=True, cmap='coolwarm', center=0, 
                   square=True, linewidths=0.5)
        plt.title('Matriz de Correlação')
        plt.tight_layout()
        
        img_buffer = io.BytesIO()
        plt.savefig(img_buffer, format='png', dpi=150, bbox_inches='tight')
        img_buffer.seek(0)
        img_base64 = base64.b64encode(img_buffer.read()).decode()
        plt.close()
        
        return img_base64
    
    def create_scatter_plot(self, x_col: str, y_col: str, color_col: str = None):
        """Cria gráfico de dispersão"""
        if x_col not in self.df.columns or y_col not in self.df.columns:
            return None
        
        plt.figure(figsize=(10, 6))
        
        if color_col and color_col in self.df.columns:
            scatter = plt.scatter(self.df[x_col], self.df[y_col], 
                                c=self.df[color_col], alpha=0.6, cmap='viridis')
            plt.colorbar(scatter, label=color_col)
        else:
            plt.scatter(self.df[x_col], self.df[y_col], alpha=0.6)
        
        plt.xlabel(x_col)
        plt.ylabel(y_col)
        plt.title(f'{y_col} vs {x_col}')
        plt.grid(True, alpha=0.3)
        
        img_buffer = io.BytesIO()
        plt.savefig(img_buffer, format='png', dpi=150, bbox_inches='tight')
        img_buffer.seek(0)
        img_base64 = base64.b64encode(img_buffer.read()).decode()
        plt.close()
        
        return img_base64

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
                - Sugerir visualizações úteis
                - Dar insights baseados nos dados
                - Responder em português de forma clara
                
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
        
        # Salvar dados da sessão
        datasets_storage[session_id] = {
            "dataframe": df,
            "analyzer": analyzer,
            "basic_info": basic_info,
            "descriptive_stats": descriptive_stats,
            "outliers_info": outliers_info,
            "correlation_matrix": correlation_matrix,
            "uploaded_at": datetime.now(),
            "source_file": filename
        }
        
        sessions_storage[session_id] = {
            "conversation_history": [],
            "created_at": datetime.now()
        }
        
        # Análise inicial automática
        initial_analysis = await ask_ai(
            "Faça uma análise inicial deste dataset, destacando pontos importantes",
            basic_info
        )
        
        return {
            "session_id": session_id,
            "basic_info": basic_info,
            "initial_analysis": initial_analysis,
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
        
        datasets_storage[session_id] = {
            "dataframe": df,
            "analyzer": analyzer,
            "basic_info": basic_info,
            "descriptive_stats": descriptive_stats,
            "outliers_info": outliers_info,
            "correlation_matrix": correlation_matrix,
            "uploaded_at": datetime.now()
        }
        
        sessions_storage[session_id] = {
            "conversation_history": [],
            "created_at": datetime.now()
        }
        
        # Análise inicial
        initial_analysis = await ask_ai(
            "Analise este dataset e dê um resumo geral",
            basic_info
        )
        
        return {
            "session_id": session_id,
            "basic_info": basic_info,
            "initial_analysis": initial_analysis,
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
        
        # Gerar gráficos baseados na pergunta
        charts = []
        message_lower = user_message.lower()
        
        # Detectar tipo de gráfico necessário
        if "histograma" in message_lower or "distribuição" in message_lower:
            for col in analyzer.numeric_columns[:3]:
                chart_data = analyzer.create_histogram(col)
                if chart_data:
                    charts.append({
                        "type": "histogram",
                        "title": f"Distribuição de {col}",
                        "data": chart_data
                    })
        
        elif "correlação" in message_lower:
            heatmap_data = analyzer.create_correlation_heatmap()
            if heatmap_data:
                charts.append({
                    "type": "heatmap",
                    "title": "Matriz de Correlação",
                    "data": heatmap_data
                })
        
        elif "dispersão" in message_lower or "scatter" in message_lower:
            if len(analyzer.numeric_columns) >= 2:
                scatter_data = analyzer.create_scatter_plot(
                    analyzer.numeric_columns[0], 
                    analyzer.numeric_columns[1]
                )
                if scatter_data:
                    charts.append({
                        "type": "scatter",
                        "title": f"{analyzer.numeric_columns[1]} vs {analyzer.numeric_columns[0]}",
                        "data": scatter_data
                    })
        
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
            "charts": charts,
            "timestamp": datetime.now()
        })
        
        # Tentar salvar no MongoDB
        if database is not None:
            try:
                await database.conversations.update_one(
                    {"session_id": session_id},
                    {"$set": {"conversation_history": conversation_history}},
                    upsert=True
                )
            except Exception as e:
                logger.warning(f"Erro ao salvar no MongoDB: {e}")
        
        return AnalysisResponse(
            response=ai_response,
            charts=charts,
            statistics=statistics
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

# Rodar o servidor
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)