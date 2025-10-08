# 🔧 Solução: Backend FastAPI Separado

## Problema Identificado

AWS Amplify **NÃO suporta backends Python/FastAPI**. Ele é otimizado apenas para frontend estático (React, Vue, Angular).

## ✅ Solução Recomendada: Railway.app (GRATUITO)

### Por que Railway?
- ✅ **Gratuito** para começar
- ✅ Suporta Python/FastAPI nativamente
- ✅ Deploy automático via Git
- ✅ Configuração simples
- ✅ HTTPS automático

---

## 🚀 Passo a Passo: Deploy Backend no Railway

### 1. Criar Conta no Railway

1. Acesse: https://railway.app
2. Clique em "Start a New Project"
3. Faça login com GitHub

### 2. Preparar Backend

Vamos criar uma estrutura separada para o backend:

```bash
cd /home/fernandomx/projects/course-ai/agente-EDA-export-20250928-204101

# Criar branch separada para backend (opcional)
git checkout -b backend-deploy
```

### 3. Criar Arquivo `railway.json`

No diretório raiz do projeto:

```json
{
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "startCommand": "uvicorn api.index:app --host 0.0.0.0 --port $PORT",
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

### 4. Criar `Procfile` (alternativa)

```
web: uvicorn api.index:app --host 0.0.0.0 --port $PORT
```

### 5. Criar `runtime.txt`

```
python-3.11
```

### 6. Ajustar `requirements.txt`

Certifique-se que está em `api/requirements.txt`:

```txt
fastapi==0.109.2
uvicorn[standard]==0.27.1
pandas==2.2.0
numpy==1.26.4
python-multipart==0.0.9
python-dotenv==1.0.1
groq==0.32.0
pydantic==2.6.1
aiofiles==23.2.1
requests==2.31.0
pymongo==4.6.1
```

### 7. Deploy no Railway

1. No Railway, clique em **"New Project"**
2. Selecione **"Deploy from GitHub repo"**
3. Autorize o Railway a acessar seu repositório
4. Selecione o repositório do projeto
5. Railway detectará automaticamente que é um projeto Python

### 8. Configurar Variáveis de Ambiente

No Railway, vá em **Settings** > **Variables** e adicione:

```bash
USE_MONGODB=true
MONGO_URL=mongodb+srv://username:password@cluster.mongodb.net/?retryWrites=true&w=majority
DB_NAME=agente_eda_db
CORS_ORIGINS=*
GROQ_API_KEY=sua_chave_groq
PORT=8000
```

### 9. Obter URL do Backend

Após o deploy, o Railway fornecerá uma URL tipo:
```
https://seu-app.railway.app
```

Copie essa URL!

---

## 🔗 Conectar Frontend com Backend

### 1. Atualizar `.env` Local (para testes)

Criar arquivo `.env` na raiz do projeto:

```bash
REACT_APP_BACKEND_URL=https://seu-app.railway.app
```

### 2. Configurar Variável de Ambiente no AWS Amplify

1. Acesse AWS Amplify Console
2. Selecione sua aplicação
3. Vá em **Environment variables**
4. Adicione:
   - Key: `REACT_APP_BACKEND_URL`
   - Value: `https://seu-app.railway.app`

### 3. Verificar Código do Frontend

O código já está preparado (linha 210-212 do `App.js`):

```javascript
const apiUrl = process.env.NODE_ENV === 'production' 
  ? process.env.REACT_APP_BACKEND_URL || window.location.origin 
  : process.env.REACT_APP_BACKEND_URL || 'http://localhost:8000';
```

**IMPORTANTE**: Precisamos ajustar para priorizar `REACT_APP_BACKEND_URL`:

```javascript
const apiUrl = process.env.REACT_APP_BACKEND_URL || 
  (process.env.NODE_ENV === 'production' 
    ? window.location.origin 
    : 'http://localhost:8000');
```

### 4. Fazer Redeploy no Amplify

Após adicionar a variável de ambiente:
- O Amplify fará rebuild automático
- Ou force um rebuild manualmente

---

## 📊 Alternativas ao Railway

### Render.com (Gratuito)

Similar ao Railway:
1. Acesse https://render.com
2. Crie conta
3. New Web Service > Connect Repository
4. Configure:
   - **Build Command**: `pip install -r api/requirements.txt`
   - **Start Command**: `uvicorn api.index:app --host 0.0.0.0 --port $PORT`

### Fly.io (Gratuito)

1. Acesse https://fly.io
2. Instale Fly CLI
3. Configure Dockerfile
4. Deploy via CLI

### AWS Lambda + API Gateway (Avançado)

Para escala maior:
- Mais complexo de configurar
- Custo baseado em uso
- Melhor para produção em grande escala

---

## 🧪 Testar Tudo

### 1. Testar Backend (Railway)

```bash
curl https://seu-app.railway.app/api/health
```

Deve retornar:
```json
{
  "status": "ok",
  "timestamp": "...",
  "active_sessions": 0,
  "mongodb_connected": true
}
```

### 2. Testar Frontend (Amplify)

1. Acesse sua URL do Amplify
2. Faça upload de um CSV
3. Verifique o console do browser (F12)
4. Deve ver requisições para `https://seu-app.railway.app/api/...`

---

## ⚠️ CORS - Ajuste no Backend

Se tiver erro de CORS, atualize `api/index.py`:

```python
# Linha 61-80
cors_origins_env = os.getenv("CORS_ORIGINS", "*")
if cors_origins_env == "*":
    cors_origins = ["*"]
else:
    cors_origins = [origin.strip() for origin in cors_origins_env.split(",")]
    # Adicionar domínio do Amplify
    amplify_url = "https://main.d3n0dzii1b4u3j1.amplifyapp.com"
    if amplify_url not in cors_origins:
        cors_origins.append(amplify_url)
```

Ou configure `CORS_ORIGINS` no Railway:
```
CORS_ORIGINS=https://main.d3n0dzii1b4u3j1.amplifyapp.com,*
```

---

## 📋 Checklist Final

- [ ] Backend deployed no Railway/Render
- [ ] Variáveis de ambiente configuradas no Railway
- [ ] URL do backend obtida
- [ ] Variável `REACT_APP_BACKEND_URL` adicionada no Amplify
- [ ] Código do frontend atualizado para priorizar `REACT_APP_BACKEND_URL`
- [ ] Redeploy do frontend no Amplify
- [ ] CORS configurado corretamente
- [ ] Teste de upload de CSV funcionando
- [ ] Chat com IA funcionando

---

## 🆘 Troubleshooting

### Erro: "Network Error"
- Verifique se backend está rodando: `curl https://seu-app.railway.app/api/health`
- Verifique CORS no backend
- Verifique variável de ambiente no Amplify

### Erro: "CORS policy"
- Configure `CORS_ORIGINS` no Railway com domínio do Amplify
- Ou use `*` para desenvolvimento

### Erro: "500 Internal Server Error"
- Verifique logs no Railway
- Verifique variáveis de ambiente (MongoDB, Groq API)

---

**Boa sorte! 🚀**



