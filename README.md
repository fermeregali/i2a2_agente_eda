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
- **Visualizações**: Matplotlib + Seaborn - Gráficos de alta qualidade
- **Análise**: Pandas + NumPy + Scikit-learn - Processamento de dados

### Estrutura do Projeto

```text
agente-eda/
├── main.py                 # API FastAPI principal
├── requirements.txt        # Dependências Python
├── config.env             # Configurações
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
├── package-lock.json      # Lock file das dependências
├── install.sh            # Script de instalação
├── LICENSE               # Licença MIT
└── README.md             # Este arquivo
```

## 🚀 Instalação e Uso

### Pré-requisitos

- Python 3.8+
- Node.js 16+
- MongoDB (opcional - funciona sem)

### Instalação Rápida

```bash
# 1. Clonar o repositório
git clone https://github.com/fermeregali/i2a2_agente_eda

# 2. Instalação automática
./install.sh

# 3. Executar o sistema
# Terminal 1 - Backend
source venv/bin/activate
python main.py

# Terminal 2 - Frontend
npm start

# 4. Acessar: http://localhost:3000
```

### Instalação Manual

```bash
# Backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Frontend
npm install

# Configuração (opcional)
# Edite config.env com suas configurações
```

## 💡 Como Usar

### 1. Upload de Dataset

- Acesse <http://localhost:3000>
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

## 🧪 Testes

```bash
# Testes manuais via API
curl http://localhost:8000/api/health
```

## 📊 Exemplos de Uso

### Dataset de Fraude de Cartão

```python
# Exemplo de análise automática
Pergunta: "Faça uma análise geral do dataset"

Resposta: "Baseado na análise do dataset carregado:
- 284,807 transações com 31 variáveis
- 99.83% transações normais vs 0.17% fraudulentas
- Variáveis V1-V28 transformadas por PCA
- Dataset adequado para detecção de fraude"
```

### Análise de Correlações

```python
# Geração automática de heatmap
Pergunta: "Mostre a correlação entre as variáveis"

Resposta: "Identificadas correlações significativas:
- V2 e V5: r = 0.73 (forte positiva)
- V6 e V7: r = -0.78 (forte negativa)
- Amount e V7: r = 0.42 (moderada)"
```

## 🔧 Configuração

### Variáveis de Ambiente

```bash
# config.env
MONGO_URL=mongodb://localhost:27017
DB_NAME=agente_eda_db
CORS_ORIGINS=http://localhost:3000
GROQ_API_KEY=sua_chave_groq_aqui
```

### Personalização

- Modifique `main.py` para ajustar análises
- Edite `src/App.js` para customizar interface
- Configure `requirements.txt` para dependências Python
- Configure `package.json` para dependências React

## 📈 Funcionalidades Avançadas

### Análise Estatística

- Estatísticas descritivas completas
- Detecção de outliers (método IQR)
- Análise de distribuições
- Testes de normalidade

### Machine Learning

- Análise de correlações
- Detecção de padrões
- Sugestões de features
- Validação de dados

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
- Comunidade Python pela excelente ecossistema

## 📚 Documentação Adicional

- [API Documentation](http://localhost:8000/docs) - Documentação interativa da API

---
