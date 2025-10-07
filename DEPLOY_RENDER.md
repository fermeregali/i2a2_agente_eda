# 🚀 Guia Rápido de Deploy no Render.com

Este guia mostra como fazer deploy do Agente EDA no Render.com de forma rápida e gratuita.

## ✅ Pré-requisitos

- [ ] Conta no [Render.com](https://render.com) (gratuita)
- [ ] Conta no [MongoDB Atlas](https://www.mongodb.com/cloud/atlas) (tier gratuito)
- [ ] API Key do [Groq](https://console.groq.com) (gratuita)
- [ ] Repositório Git (GitHub, GitLab ou Bitbucket)

## 📋 Checklist de Deploy

### 1️⃣ Configurar MongoDB Atlas (5 minutos)

```bash
1. Acesse: https://www.mongodb.com/cloud/atlas
2. Crie um cluster M0 (gratuito)
3. Database Access → Add New Database User
   - Username: agente_eda_db
   - Password: [gerar senha segura]
   - Database User Privileges: Read and write to any database
4. Network Access → Add IP Address
   - Access List Entry: 0.0.0.0/0
   - Comment: Allow from anywhere (Render)
5. Clusters → Connect → Connect your application
   - Copie a connection string
   - Substitua <password> pela sua senha
```

**Sua connection string será algo como:**
```
mongodb+srv://agente_eda_db:SUA_SENHA@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0
```

### 2️⃣ Obter API Key do Groq (2 minutos)

```bash
1. Acesse: https://console.groq.com
2. Faça login ou crie uma conta
3. Vá em "API Keys"
4. Click em "Create API Key"
5. Copie a chave (formato: gsk_...)
```

### 3️⃣ Deploy do Backend (10 minutos)

1. **Acesse Render.com** → Dashboard

2. **New +** → **Web Service**

3. **Conectar Repositório**:
   - Autorize acesso ao GitHub/GitLab
   - Selecione seu repositório

4. **Configurar Service**:
   ```
   Name: agente-eda-api
   Region: Oregon (US West) ou mais próxima
   Branch: main
   Root Directory: (deixe vazio)
   Runtime: Python 3
   Build Command: cd api && pip install -r requirements.txt
   Start Command: cd api && uvicorn index:app --host 0.0.0.0 --port $PORT
   ```

5. **Environment Variables** (click em "Add Environment Variable"):
   ```
   USE_MONGODB = true
   MONGO_URL = [sua_connection_string_mongodb]
   DB_NAME = agente_eda_db
   CORS_ORIGINS = *
   GROQ_API_KEY = [sua_chave_groq]
   PYTHON_VERSION = 3.11.0
   ```

6. **Instance Type**: Free

7. **Create Web Service**

8. **Aguarde o deploy** (3-5 minutos)
   - Você verá os logs de build em tempo real
   - Quando aparecer "Your service is live 🎉", está pronto!

9. **Anote a URL**: `https://agente-eda-api.onrender.com`

### 4️⃣ Deploy do Frontend (10 minutos)

1. **Render Dashboard** → **New +** → **Static Site**

2. **Conectar o mesmo repositório**

3. **Configurar Static Site**:
   ```
   Name: agente-eda-frontend
   Branch: main
   Build Command: npm install && npm run build
   Publish Directory: build
   ```

4. **Environment Variables**:
   ```
   REACT_APP_API_URL = https://agente-eda-api.onrender.com
   ```
   ⚠️ **IMPORTANTE**: Substitua pela URL real do seu backend!

5. **Create Static Site**

6. **Aguarde o deploy** (5-7 minutos)

7. **Anote a URL**: `https://agente-eda-frontend.onrender.com`

### 5️⃣ Configurar CORS (2 minutos)

1. Volte ao **Backend Service** no Render

2. **Environment** → Edite `CORS_ORIGINS`:
   ```
   CORS_ORIGINS = https://agente-eda-frontend.onrender.com
   ```

3. **Save Changes** (vai fazer redeploy automático)

### 6️⃣ Testar a Aplicação (3 minutos)

1. **Acesse o Frontend**: `https://agente-eda-frontend.onrender.com`

2. **Teste Upload**:
   - Click em "Upload CSV" ou "Carregar Exemplo"
   - Faça upload de um CSV pequeno
   - Aguarde a análise inicial

3. **Teste Chat**:
   - Digite: "Faça uma análise geral do dataset"
   - Aguarde a resposta da IA

4. **Verificar Backend**:
   - Acesse: `https://agente-eda-api.onrender.com/api/health`
   - Deve retornar: `{"status":"ok","mongodb_connected":true}`

## 🎉 Pronto! Sua aplicação está no ar!

**URLs da sua aplicação:**
- **Frontend**: `https://agente-eda-frontend.onrender.com`
- **Backend**: `https://agente-eda-api.onrender.com`
- **API Docs**: `https://agente-eda-api.onrender.com/docs`

## 📌 Notas Importantes

### ⚡ Sobre o Plano Gratuito do Render

- ✅ **Grátis para sempre** (com limitações)
- ⚠️ **Serviços adormecem após 15 min** de inatividade
- 🐌 **Primeiro acesso pode ser lento** (cold start ~30-60s)
- 🔄 **Auto-deploy** quando você faz push no Git
- 💾 **750 horas/mês** de runtime (suficiente para projetos pessoais)

### 🔥 Dicas para Melhor Performance

1. **Manter serviço ativo**:
   - Use [UptimeRobot](https://uptimerobot.com) para pingar seu backend a cada 5 minutos
   - Configure um ping para: `https://agente-eda-api.onrender.com/api/health`

2. **Upgrade para plano pago** ($7/mês):
   - Sem cold starts
   - Sempre ativo
   - Melhor performance

## 🐛 Troubleshooting

### ❌ Backend não inicia

```bash
Verifique:
1. Logs do Render (aba "Logs")
2. Todas as environment variables estão preenchidas?
3. MONGO_URL está correta?
4. GROQ_API_KEY está correta?
```

### ❌ CORS Error

```bash
Solução:
1. Backend → Environment → CORS_ORIGINS
2. Adicione a URL completa do frontend
3. Ou use "*" temporariamente para testar
```

### ❌ MongoDB Connection Failed

```bash
Verifique:
1. IP 0.0.0.0/0 está na whitelist do Atlas?
2. Usuário e senha corretos na connection string?
3. Cluster está ativo?
4. Teste a conexão localmente primeiro
```

### ❌ Frontend não carrega dados

```bash
Verifique:
1. REACT_APP_API_URL está correto?
2. Backend está respondendo? Teste: /api/health
3. Console do navegador tem erros? (F12)
```

### ❌ Groq API Error

```bash
Verifique:
1. API Key está correta?
2. Tem créditos disponíveis no Groq?
3. Teste a API diretamente
```

## 🔄 Fazer Update/Redeploy

### Deploy Automático (Recomendado)

```bash
# Qualquer push no branch principal faz deploy automático
git add .
git commit -m "Update: nova feature"
git push origin main
```

### Deploy Manual

```bash
1. Acesse seu service no Render
2. Click em "Manual Deploy"
3. Escolha o branch
4. Deploy
```

## 🔐 Segurança

### ⚠️ NUNCA commite seus secrets!

```bash
# Adicione ao .gitignore:
config.env
.env
.env.local
*.key
secrets/
```

### ✅ Use as variáveis de ambiente do Render

- Todas as credenciais devem estar nas Environment Variables
- Nunca hardcode API keys no código
- Use `os.getenv()` para ler variáveis

## 📊 Monitoramento

### Ver Logs em Tempo Real

```bash
1. Render Dashboard → Seu Service
2. Aba "Logs"
3. Veja logs em tempo real
```

### Métricas

```bash
1. Render Dashboard → Seu Service
2. Aba "Metrics"
3. Veja CPU, Memory, Request count
```

## 🎓 Recursos Adicionais

- [Documentação Render](https://render.com/docs)
- [MongoDB Atlas Docs](https://docs.atlas.mongodb.com)
- [Groq API Docs](https://console.groq.com/docs)
- [FastAPI Docs](https://fastapi.tiangolo.com)

## 💬 Suporte

Se tiver problemas:

1. Verifique este guia novamente
2. Veja os logs do Render
3. Teste localmente primeiro
4. Abra uma issue no GitHub

---

**🎉 Boa sorte com seu deploy!**



