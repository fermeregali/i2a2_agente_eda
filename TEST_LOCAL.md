# 🧪 Guia de Teste Local

## 📋 Pré-requisitos

Antes de começar, você precisa ter instalado:

- ✅ **Python 3.8+** ([Download](https://www.python.org/downloads/))
- ✅ **Node.js 16+** ([Download](https://nodejs.org/))
- ✅ **Git** ([Download](https://git-scm.com/))

**Credenciais necessárias:**
- 🔑 **Groq API Key** ([console.groq.com](https://console.groq.com))
- 🔑 **MongoDB Atlas** (opcional - funciona sem, mas recomendado)

---

## 🚀 Início Rápido

### **Opção 1: Scripts Automatizados** (Recomendado)

```bash
# Terminal 1 - Backend
chmod +x start-backend.sh
./start-backend.sh

# Terminal 2 - Frontend (em outra aba)
chmod +x start-frontend.sh
./start-frontend.sh
```

### **Opção 2: Manual**

Veja instruções detalhadas abaixo.

---

## 🔧 Configuração Detalhada

### **1. Clonar Repositório**

```bash
git clone https://github.com/seu-usuario/i2a2_agente_eda.git
cd i2a2_agente_eda
```

### **2. Configurar Backend (Python)**

#### 2.1. Criar Virtual Environment

```bash
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows
```

#### 2.2. Instalar Dependências

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

#### 2.3. Configurar Variáveis de Ambiente

Copie o template:
```bash
cp config.env.example config.env
```

Edite `config.env`:
```bash
# Obrigatório
GROQ_API_KEY=sua_chave_groq_aqui

# Opcional (funciona sem)
USE_MONGODB=true
MONGO_URL=mongodb+srv://username:password@cluster.mongodb.net/
DB_NAME=agente_eda_db

# Configurações
CORS_ORIGINS=*
```

**Como obter Groq API Key:**
1. Acesse [console.groq.com](https://console.groq.com)
2. Faça login/cadastro
3. Vá em "API Keys"
4. Crie uma nova chave
5. Copie e cole no `config.env`

#### 2.4. Iniciar Backend

```bash
cd api
uvicorn index:app --reload --host 0.0.0.0 --port 8000
```

**Servidor rodando em:**
- 🌐 API: http://localhost:8000
- 📚 Documentação: http://localhost:8000/docs
- ❤️ Health Check: http://localhost:8000/api/health

---

### **3. Configurar Frontend (React)**

#### 3.1. Instalar Dependências

```bash
npm install
```

#### 3.2. Configurar Backend URL

Criar arquivo `.env.local`:
```bash
echo "REACT_APP_BACKEND_URL=http://localhost:8000" > .env.local
```

#### 3.3. Iniciar Frontend

```bash
npm start
```

**Aplicação rodando em:**
- 🌐 Frontend: http://localhost:3000

---

## ✅ Verificar Instalação

### **Backend**

```bash
# Health Check
curl http://localhost:8000/api/health

# Deve retornar:
{
  "status": "ok",
  "timestamp": "...",
  "active_sessions": 0,
  "mongodb_connected": false  # true se MongoDB configurado
}
```

### **Frontend**

Abra o navegador em `http://localhost:3000`

Você deve ver:
- ✅ Interface de upload
- ✅ "Agente de Análise Exploratória de Dados"

---

## 🧪 Testes

### **1. Teste de Upload de CSV**

1. Acesse http://localhost:3000
2. Arraste um arquivo CSV ou clique para selecionar
3. Aguarde análise inicial
4. ✅ Deve mostrar estatísticas e insights

**Arquivos de teste disponíveis:**
- `sample_data/creditcard_sample.csv` (dataset de exemplo)

### **2. Teste de Chat com IA**

Após carregar CSV, pergunte:
- "Faça uma análise geral do dataset"
- "Existem outliers nos dados?"
- "Mostre a correlação entre as variáveis"

✅ Deve receber respostas da IA

### **3. Teste de Visualizações**

Pergunte:
- "Mostre a distribuição das variáveis"
- "Crie um heatmap de correlação"

✅ Deve gerar gráficos interativos (Plotly)

---

## 🐛 Troubleshooting

### **Erro: "ModuleNotFoundError"**

**Problema:** Dependências não instaladas

**Solução:**
```bash
source venv/bin/activate
pip install -r requirements.txt
```

### **Erro: "GROQ_API_KEY not found"**

**Problema:** Variável de ambiente não configurada

**Solução:**
```bash
# Edite config.env e adicione sua chave
GROQ_API_KEY=sua_chave_aqui
```

### **Erro: "Network Error" no Frontend**

**Problema:** Backend não está rodando ou URL incorreta

**Solução:**
```bash
# Verifique se backend está rodando
curl http://localhost:8000/api/health

# Verifique .env.local
cat .env.local
# Deve conter: REACT_APP_BACKEND_URL=http://localhost:8000
```

### **Erro: "Port 3000 already in use"**

**Problema:** Porta já está em uso

**Solução:**
```bash
# Mate processo na porta 3000
lsof -ti:3000 | xargs kill -9

# Ou use porta diferente
PORT=3001 npm start
```

### **Erro: "Port 8000 already in use"**

**Problema:** Porta já está em uso

**Solução:**
```bash
# Mate processo na porta 8000
lsof -ti:8000 | xargs kill -9

# Ou use porta diferente
uvicorn index:app --reload --port 8001
```

---

## 📊 Estrutura para Testes

```
Terminal 1 (Backend):
┌─────────────────────────────────────┐
│ $ cd api                            │
│ $ uvicorn index:app --reload        │
│                                     │
│ INFO: Uvicorn running on            │
│       http://0.0.0.0:8000          │
│ INFO: Started reloader process     │
└─────────────────────────────────────┘

Terminal 2 (Frontend):
┌─────────────────────────────────────┐
│ $ npm start                         │
│                                     │
│ Compiled successfully!              │
│                                     │
│ You can now view agente-eda in      │
│ the browser.                        │
│                                     │
│   Local: http://localhost:3000     │
└─────────────────────────────────────┘

Navegador:
┌─────────────────────────────────────┐
│  http://localhost:3000              │
│  ┌─────────────────────────────┐   │
│  │ 🤖 Agente EDA               │   │
│  │                             │   │
│  │  [Upload CSV]               │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

---

## 🔄 Comandos Úteis

### **Backend**

```bash
# Instalar nova dependência
pip install nome-pacote
pip freeze > requirements.txt

# Ver logs detalhados
uvicorn index:app --reload --log-level debug

# Rodar sem reload (produção)
uvicorn index:app --host 0.0.0.0 --port 8000
```

### **Frontend**

```bash
# Instalar nova dependência
npm install --save nome-pacote

# Build para produção
npm run build

# Testar build de produção
npx serve -s build
```

### **Git**

```bash
# Ver status
git status

# Commit
git add .
git commit -m "Sua mensagem"

# Push
git push origin branch-name
```

---

## 📝 Checklist de Teste

Antes de fazer deploy, teste localmente:

- [ ] Backend inicia sem erros
- [ ] Health check retorna status ok
- [ ] Frontend inicia sem erros
- [ ] Upload de CSV funciona
- [ ] Análise inicial aparece
- [ ] Chat responde perguntas
- [ ] Gráficos são gerados
- [ ] Sem erros no console do navegador
- [ ] Sem erros no terminal do backend

---

## 🎯 Próximos Passos

Depois de testar localmente:

1. ✅ **Backend funcionando?** → Deploy no Railway
2. ✅ **Frontend funcionando?** → Deploy no Amplify
3. ✅ **Tudo integrado?** → Conectar frontend com backend
4. 🎉 **Aplicação completa em produção!**

---

## 📚 Referências

- [FastAPI Docs](https://fastapi.tiangolo.com/)
- [React Docs](https://react.dev/)
- [Groq API Docs](https://console.groq.com/docs)
- [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)

---

**Dúvidas?** Consulte o `README.md` ou abra uma issue no GitHub!

**Boa sorte com os testes! 🚀**

