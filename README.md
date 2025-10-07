# 🤖 Agente de Análise Exploratória de Dados (EDA)

[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.104+-green.svg)](https://fastapi.tiangolo.com)
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
- 🧠 **Memória Persistente**: Histórico de análises mantido
- 🎨 **Interface Moderna**: Design responsivo e intuitivo
- ⚡ **Performance**: Análises rápidas e eficientes

## 🏗️ Arquitetura

### Stack Tecnológico

- **Backend**: FastAPI (Python) - API REST moderna e rápida
- **Frontend**: React - Interface de usuário responsiva
- **IA**: Groq (DeepSeek R1) - Análises inteligentes contextualizadas
- **Banco**: MongoDB - Armazenamento de sessões e histórico
- **Visualizações**: Plotly.js - Gráficos interativos
- **Análise**: Pandas + NumPy - Processamento de dados

### Estrutura do Projeto

```text
agente-eda/
├── api/
│   ├── index.py           # API FastAPI principal
│   └── requirements.txt   # Dependências Python
├── src/                   # Frontend React
│   ├── App.js             # Componente React principal
│   ├── App.css            # Estilos
│   ├── index.js           # Entry point
│   └── index.css          # Estilos globais
├── public/                # Arquivos estáticos
│   ├── index.html         # HTML principal
│   └── manifest.json      # Manifesto PWA
├── sample_data/           # Datasets de exemplo
│   └── creditcard_sample.csv
├── package.json           # Dependências Node.js
├── amplify.yml            # Configuração AWS Amplify
├── config.env             # Variáveis de ambiente (não commitar)
├── .gitignore             # Arquivos ignorados
├── LICENSE                # Licença MIT
└── README.md              # Este arquivo
```

## 🚀 Deploy na AWS Amplify

### Pré-requisitos

- Conta AWS
- Repositório Git (GitHub, GitLab ou Bitbucket)
- Chave API do Groq
- MongoDB Atlas ou MongoDB configurado

### Passos para Deploy

1. **Push do código para repositório Git**
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin <seu-repositorio>
git push -u origin main
```

2. **Configurar AWS Amplify**
   - Acesse o console AWS Amplify
   - Clique em "New App" > "Host web app"
   - Conecte seu repositório Git
   - Selecione a branch principal

3. **Configurar Build Settings**
   - O Amplify detectará automaticamente o `amplify.yml`
   - Configuração já está otimizada para React + FastAPI

4. **Configurar Variáveis de Ambiente**
   No console do Amplify, adicione:
   - `USE_MONGODB`: `true` ou `false`
   - `MONGO_URL`: URL do MongoDB Atlas
   - `DB_NAME`: Nome do banco de dados
   - `CORS_ORIGINS`: `*` ou domínios específicos
   - `GROQ_API_KEY`: Sua chave da API Groq

5. **Deploy**
   - Clique em "Save and deploy"
   - Aguarde o build e deploy automático

### Variáveis de Ambiente Necessárias

```bash
USE_MONGODB=true
MONGO_URL=mongodb+srv://user:pass@cluster.mongodb.net/?retryWrites=true&w=majority
DB_NAME=agente_eda_db
CORS_ORIGINS=*
GROQ_API_KEY=sua_chave_groq_aqui
```

## 💻 Desenvolvimento Local

### Pré-requisitos

- Python 3.8+
- Node.js 16+
- MongoDB (opcional)

### Instalação

```bash
# 1. Clonar o repositório
git clone <seu-repositorio>
cd agente-eda

# 2. Backend
cd api
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt

# 3. Frontend
cd ..
npm install

# 4. Configurar variáveis de ambiente
cp config.env.example config.env
# Editar config.env com suas credenciais
```

### Executar Localmente

```bash
# Terminal 1 - Backend
cd api
source venv/bin/activate
uvicorn index:app --reload --port 8000

# Terminal 2 - Frontend
npm start
```

Acesse: http://localhost:3000

## 💡 Como Usar

### 1. Upload de Dataset

- Acesse a aplicação
- Arraste e solte seu arquivo CSV
- Aguarde a análise inicial automática

### 2. Chat com IA

Faça perguntas em linguagem natural:

- "Faça uma análise geral do dataset"
- "Quais são as estatísticas básicas?"
- "Existem outliers nos dados?"
- "Mostre a correlação entre as variáveis"
- "Qual a distribuição da variável X?"

### 3. Visualizações Automáticas

O sistema gera gráficos automaticamente:

- Histogramas para distribuições
- Heatmaps para correlações
- Scatter plots para relações
- Box plots para outliers

## 📊 Exemplos de Uso

### Dataset de Fraude de Cartão

```python
Pergunta: "Faça uma análise geral do dataset"

Resposta: "Baseado na análise do dataset carregado:
- 284,807 transações com 31 variáveis
- 99.83% transações normais vs 0.17% fraudulentas
- Variáveis V1-V28 transformadas por PCA
- Dataset adequado para detecção de fraude"
```

### Análise de Correlações

```python
Pergunta: "Mostre a correlação entre as variáveis"

Resposta: "Identificadas correlações significativas:
- V2 e V5: r = 0.73 (forte positiva)
- V6 e V7: r = -0.78 (forte negativa)
- Amount e V7: r = 0.42 (moderada)"
```

## 📈 Funcionalidades Avançadas

### Análise Estatística

- Estatísticas descritivas completas
- Detecção de outliers (método IQR)
- Análise de distribuições
- Análise de correlações

### Visualizações

- Histogramas interativos
- Matriz de correlação
- Gráficos de dispersão
- Box plots para outliers

## 🤝 Contribuição

Contribuições são bem-vindas! Para contribuir:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

## 👨‍💻 Autor

### Fernando Meregali Xavier

- GitHub: [@fermeregali](https://github.com/fermeregali)

## 🙏 Agradecimentos

- Groq pela API DeepSeek R1 Distill Llama 70B
- FastAPI pela framework moderna
- React pela interface de usuário
- AWS Amplify pela plataforma de hosting
- Comunidade Python pela excelente ecossistema

## 🆘 Suporte

Para problemas ou dúvidas:
- Abra uma issue no GitHub
- Consulte a documentação da [AWS Amplify](https://docs.amplify.aws/)
- Consulte a documentação da [API Groq](https://console.groq.com/docs)

---

**Desenvolvido com ❤️ para análise inteligente de dados**
