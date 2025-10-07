# 🤖 Agente de Análise Exploratória de Dados (EDA)

[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.109+-green.svg)](https://fastapi.tiangolo.com)
[![React](https://img.shields.io/badge/React-18.2+-blue.svg)](https://reactjs.org)
[![Groq](https://img.shields.io/badge/Groq-DeepSeek%20R1-green.svg)](https://groq.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Sistema inteligente para análise exploratória de dados em arquivos CSV com interface conversacional e IA integrada.

## 🎯 Sobre o Projeto

Este é um **Agente de IA para Análise Exploratória de Dados (EDA)** desenvolvido para análise inteligente de arquivos CSV. O sistema utiliza inteligência artificial para realizar análises estatísticas completas, detectar padrões, gerar visualizações e fornecer insights através de uma interface conversacional natural.

### ✨ Características Principais

- 🔍 **Análise Automática**: EDA completa com estatísticas descritivas
- 🤖 **Chat Inteligente**: Interface conversacional em português
- 📊 **Visualizações Dinâmicas**: Gráficos gerados automaticamente
- 🔍 **Detecção de Outliers**: Identificação de anomalias nos dados
- 📈 **Análise de Correlações**: Matriz de correlação entre variáveis
- 🧠 **Memória Persistente**: Histórico de análises mantido no MongoDB
- 🎨 **Interface Moderna**: Design responsivo e intuitivo
- ⚡ **Performance**: Análises rápidas e eficientes

## 🏗️ Arquitetura

### Stack Tecnológico

- **Backend**: FastAPI (Python) - API REST moderna e rápida
- **Frontend**: React - Interface de usuário responsiva
- **IA**: Groq (DeepSeek R1) - Análises inteligentes contextualizadas
- **Banco**: MongoDB Atlas - Armazenamento de sessões e histórico
- **Visualizações**: Plotly.js - Gráficos interativos
- **Análise**: Pandas + NumPy - Processamento de dados

### Estrutura do Projeto

```text
agente-eda/
├── api/                      # Backend FastAPI
│   ├── index.py              # API principal
│   └── requirements.txt      # Dependências Python
├── src/                      # Frontend React
│   ├── App.js                # Componente principal
│   ├── App.css               # Estilos
│   └── index.js              # Entry point
├── public/                   # Arquivos estáticos
├── sample_data/              # Datasets de exemplo
├── config.env                # Configurações (não commitado)
├── package.json              # Dependências Node.js
├── render.yaml               # Configuração Render.com
├── build.sh                  # Script de build
├── start.sh                  # Script de inicialização
└── README.md                 # Este arquivo
```

## 🚀 Deploy no Render.com

### Pré-requisitos

1. Conta no [Render.com](https://render.com) (plano gratuito disponível)
2. Conta no [MongoDB Atlas](https://www.mongodb.com/cloud/atlas) (tier gratuito)
3. API Key do [Groq](https://console.groq.com)

### Configuração do MongoDB Atlas

1. Acesse [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Crie um cluster (M0 Sandbox - gratuito)
3. Configure o acesso:
   - Database Access: Crie um usuário com senha
   - Network Access: Adicione `0.0.0.0/0` (permitir de qualquer lugar)
4. Obtenha sua connection string:
   - Cluster → Connect → Connect your application
   - Copie a string: `mongodb+srv://<usuario>:<senha>@cluster0.xxxxx.mongodb.net/`

### Deploy no Render

#### Opção 1: Deploy Automático (Recomendado)

1. **Fork/Clone o repositório** no GitHub

2. **Acesse Render.com** e faça login

3. **Criar Web Service para Backend**:
   - Click em "New +" → "Web Service"
   - Conecte seu repositório GitHub
   - Configure:
     - **Name**: `agente-eda-api`
     - **Region**: Escolha a mais próxima
     - **Branch**: `main` (ou sua branch)
     - **Root Directory**: (deixe vazio)
     - **Runtime**: `Python 3`
     - **Build Command**: `cd api && pip install -r requirements.txt`
     - **Start Command**: `cd api && uvicorn index:app --host 0.0.0.0 --port $PORT`
   
   - **Environment Variables** (adicione todas):
     ```
     USE_MONGODB=true
     MONGO_URL=sua_string_mongodb_atlas_aqui
     DB_NAME=agente_eda_db
     CORS_ORIGINS=*
     GROQ_API_KEY=sua_chave_groq_aqui
     PYTHON_VERSION=3.11.0
     ```
   
   - **Plan**: Free
   - Click "Create Web Service"

4. **Criar Static Site para Frontend**:
   - Click em "New +" → "Static Site"
   - Conecte o mesmo repositório
   - Configure:
     - **Name**: `agente-eda-frontend`
     - **Branch**: `main`
     - **Build Command**: `npm install && npm run build`
     - **Publish Directory**: `build`
   
   - **Environment Variables**:
     ```
     REACT_APP_API_URL=https://agente-eda-api.onrender.com
     ```
     (Substitua pela URL do seu backend)
   
   - **Plan**: Free
   - Click "Create Static Site"

5. **Aguarde o deploy** (pode levar alguns minutos)

6. **Acesse sua aplicação**:
   - Frontend: `https://agente-eda-frontend.onrender.com`
   - Backend: `https://agente-eda-api.onrender.com`

#### Opção 2: Deploy com render.yaml

Se você tiver o arquivo `render.yaml` configurado:

1. No Render.com, vá em "New +" → "Blueprint"
2. Conecte seu repositório
3. Render detectará automaticamente o `render.yaml`
4. Adicione as variáveis de ambiente secretas:
   - `MONGO_URL`
   - `GROQ_API_KEY`
5. Click "Apply"

### Configurar CORS após Deploy

1. Acesse o backend no Render
2. Vá em "Environment"
3. Atualize `CORS_ORIGINS`:
   ```
   CORS_ORIGINS=https://agente-eda-frontend.onrender.com
   ```
4. Salve e aguarde o redeploy automático

## 💻 Desenvolvimento Local

### Instalação Rápida

```bash
# 1. Clonar o repositório
git clone https://github.com/seu-usuario/agente-eda.git
cd agente-eda

# 2. Configurar variáveis de ambiente
# Edite config.env com suas credenciais
cp config.env.example config.env
nano config.env

# 3. Backend - Terminal 1
cd api
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn index:app --reload --port 8000

# 4. Frontend - Terminal 2
npm install
npm start

# 5. Acessar: http://localhost:3000
```

### Variáveis de Ambiente

Crie um arquivo `config.env` na raiz do projeto:

```bash
USE_MONGODB=true
MONGO_URL=mongodb+srv://usuario:senha@cluster.mongodb.net/?retryWrites=true&w=majority
DB_NAME=agente_eda_db
CORS_ORIGINS=http://localhost:3000
GROQ_API_KEY=sua_chave_groq_aqui
```

## 💡 Como Usar

### 1. Upload de Dataset

- Acesse a aplicação
- Arraste e solte seu arquivo CSV ou click em "Upload CSV"
- Aguarde a análise inicial automática

### 2. Chat com IA

Faça perguntas em linguagem natural:

- "Faça uma análise geral do dataset"
- "Quais são as estatísticas básicas?"
- "Existem outliers nos dados?"
- "Mostre a correlação entre as variáveis"
- "Qual a distribuição da variável X?"
- "Me ajude a entender os dados"

### 3. Visualizações Automáticas

O sistema gera gráficos automaticamente:

- **Histogramas**: Para distribuições
- **Heatmaps**: Para correlações
- **Scatter plots**: Para relações entre variáveis
- **Box plots**: Para outliers

## 📊 Exemplo de Dataset

O projeto inclui um dataset de exemplo em `sample_data/`:
- `creditcard_sample.csv`: Dataset de transações de cartão de crédito para detecção de fraude

## 🔧 Configuração Avançada

### Personalização do Frontend

Edite `src/App.js` e `src/App.css` para customizar a interface.

### Ajuste de Análises

Modifique `api/index.py` para adicionar ou ajustar análises estatísticas.

### Integração com Outras IAs

Substitua a integração com Groq por OpenAI, Anthropic ou outra IA de sua preferência no arquivo `api/index.py`.

## 🐛 Troubleshooting

### Backend não inicia no Render

- Verifique os logs no dashboard do Render
- Confirme que todas as variáveis de ambiente estão configuradas
- Verifique se a connection string do MongoDB está correta

### CORS Error

- Atualize `CORS_ORIGINS` no backend com a URL correta do frontend
- Use `*` apenas para desenvolvimento/testes

### MongoDB Connection Error

- Verifique a whitelist de IPs no MongoDB Atlas (`0.0.0.0/0` para aceitar todas)
- Confirme usuário e senha na connection string
- Verifique se o cluster está ativo

### Frontend não carrega dados

- Verifique se `REACT_APP_API_URL` aponta para o backend correto
- Teste o backend diretamente: `https://seu-backend.onrender.com/api/health`

## 🤝 Contribuição

Contribuições são bem-vindas! Para contribuir:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/NovaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona NovaFeature'`)
4. Push para a branch (`git push origin feature/NovaFeature`)
5. Abra um Pull Request

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

## 👨‍💻 Autor

**Fernando Meregali Xavier**
- GitHub: [@fermeregali](https://github.com/fermeregali)

## 🙏 Agradecimentos

- [Groq](https://groq.com) pela API DeepSeek R1 Distill Llama 70B
- [FastAPI](https://fastapi.tiangolo.com) pela framework moderna e rápida
- [React](https://reactjs.org) pela biblioteca de UI
- [Render.com](https://render.com) pela plataforma de deploy gratuita
- [MongoDB Atlas](https://www.mongodb.com/cloud/atlas) pelo banco de dados na nuvem
- Comunidade Python e JavaScript pelos excelentes ecossistemas

## 📚 Documentação Adicional

- **API Docs**: Acesse `/docs` no seu backend para documentação interativa da API
- **Health Check**: `/api/health` para verificar status do backend

## 🔗 Links Úteis

- [Documentação FastAPI](https://fastapi.tiangolo.com)
- [Documentação React](https://reactjs.org/docs/getting-started.html)
- [Groq API Documentation](https://console.groq.com/docs)
- [Render Documentation](https://render.com/docs)
- [MongoDB Atlas Documentation](https://docs.atlas.mongodb.com)

---

**⭐ Se este projeto foi útil, considere dar uma estrela no GitHub!**
