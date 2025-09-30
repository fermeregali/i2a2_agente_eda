# 🚀 Como Executar o Agente de Análise de Dados

## 📋 Pré-requisitos

- Python 3.8+
- Node.js 16+
- Git

## 🔧 Instalação

### Opção 1: Instalação Automática
```bash
./install.sh
```

### Opção 2: Instalação Manual

1. **Criar ambiente virtual Python:**
```bash
python3 -m venv venv
source venv/bin/activate
```

2. **Instalar dependências Python:**
```bash
pip install -r api/requirements.txt
```

3. **Instalar dependências Node.js:**
```bash
npm install
```

4. **Configurar variáveis de ambiente:**
```bash
cp config.env .env
```

## 🎯 Execução

### Método 1: Script Automático
```bash
./run.sh
```

### Método 2: Manual

**Terminal 1 - Backend:**
```bash
source venv/bin/activate
cd api
python -m uvicorn index:app --reload --host 0.0.0.0 --port 8000
```

**Terminal 2 - Frontend:**
```bash
npm start
```

## 🌐 Acesso

- **Frontend:** http://localhost:3000
- **Backend API:** http://localhost:8000
- **Documentação API:** http://localhost:8000/docs

## 📊 Funcionalidades

- ✅ Upload de arquivos CSV
- ✅ Análise estatística automática
- ✅ Gráficos interativos (histogramas, correlações, box plots)
- ✅ Conversa com IA sobre os dados
- ✅ Insights automáticos

## 🚀 Deploy na Vercel

```bash
vercel --prod
```

## 🔍 Solução de Problemas

### Erro: "python main.py não encontrado"
- ✅ **Solução:** Use `./run.sh` ou execute manualmente com uvicorn

### Erro: "requirements.txt não encontrado"
- ✅ **Solução:** Use `api/requirements.txt`

### Gráficos não aparecem
- ✅ **Solução:** Verifique o console do navegador para erros
- ✅ **Teste:** Acesse http://localhost:8000/api/test-chart

## 📁 Estrutura do Projeto

```
projeto/
├── api/                    # Backend Python
│   ├── index.py           # API FastAPI
│   └── requirements.txt   # Dependências Python
├── src/                   # Frontend React
├── build/                 # Frontend compilado
├── run.sh                 # Script de execução
├── install.sh             # Script de instalação
└── vercel.json            # Configuração Vercel
```
