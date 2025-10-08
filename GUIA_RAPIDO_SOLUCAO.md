# 🚨 SOLUÇÃO RÁPIDA: Backend Separado

## ❌ Problema Atual

```
AWS Amplify (Frontend)
      ↓
   [X] Tenta acessar /api/upload-csv
      ↓
   ❌ API não existe (Amplify não roda Python/FastAPI)
```

## ✅ Solução

```
AWS Amplify (Frontend) ──────→ Railway.app (Backend FastAPI)
     React                      Python + MongoDB + Groq
```

---

## 🚀 Passo a Passo RÁPIDO (10 minutos)

### 1️⃣ **Deploy Backend no Railway** (5 min)

1. Acesse: https://railway.app
2. Login com GitHub
3. **"New Project"** > **"Deploy from GitHub"**
4. Selecione seu repositório
5. Aguarde deploy automático
6. **Copie a URL**: `https://seu-projeto.railway.app`

### 2️⃣ **Configurar Variáveis no Railway** (2 min)

No Railway, vá em **Variables** e adicione:

```bash
USE_MONGODB=true
MONGO_URL=mongodb+srv://username:password@cluster.mongodb.net/?retryWrites=true&w=majority
DB_NAME=agente_eda_db
CORS_ORIGINS=*
GROQ_API_KEY=sua_chave_groq_aqui
PORT=8000
```

> ⚠️ **IMPORTANTE**: Use suas próprias credenciais! Substitua:
> - `MONGO_URL` com sua URL do MongoDB Atlas
> - `GROQ_API_KEY` com sua chave da Groq (console.groq.com)

### 3️⃣ **Conectar Frontend no Amplify** (2 min)

No AWS Amplify:

1. Acesse sua aplicação
2. **Environment variables**
3. Adicione nova variável:
   - **Key**: `REACT_APP_BACKEND_URL`
   - **Value**: `https://seu-projeto.railway.app` ← URL do Railway

4. Salve e aguarde redeploy automático

### 4️⃣ **Testar** (1 min)

1. Acesse sua URL do Amplify
2. Faça upload de um CSV
3. ✅ Deve funcionar!

---

## 📊 Arquitetura Final

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  Usuário acessa: https://xxx.amplifyapp.com        │
│                                                     │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │   AWS Amplify        │
        │   (Frontend React)   │
        └──────────┬───────────┘
                   │
                   │ REACT_APP_BACKEND_URL
                   │
                   ▼
        ┌──────────────────────┐
        │   Railway.app        │
        │   (Backend FastAPI)  │
        └──────────┬───────────┘
                   │
         ┌─────────┴─────────┐
         │                   │
         ▼                   ▼
    ┌─────────┐       ┌──────────┐
    │ MongoDB │       │ Groq API │
    │ Atlas   │       │   (IA)   │
    └─────────┘       └──────────┘
```

---

## 🔧 Arquivos Criados

- ✅ `Procfile` - Comando de start para Railway
- ✅ `railway.json` - Configuração Railway
- ✅ `runtime.txt` - Versão Python
- ✅ `src/App.js` - Atualizado para usar backend separado
- ✅ `SOLUCAO_BACKEND.md` - Guia completo

---

## ⚡ Alternativas ao Railway

### Render.com
- Também gratuito
- Similar ao Railway
- https://render.com

### Fly.io
- Gratuito até certo limite
- Mais configuração
- https://fly.io

---

## 🆘 Problemas?

### "Network Error" no console

**Causa**: Frontend não consegue acessar backend

**Solução**:
1. Verifique se Railway está rodando: `curl https://seu-projeto.railway.app/api/health`
2. Verifique variável `REACT_APP_BACKEND_URL` no Amplify
3. Force redeploy no Amplify

### "CORS Error"

**Causa**: Backend bloqueando requisições do frontend

**Solução**:
- No Railway, configure: `CORS_ORIGINS=*`
- Ou use URL específica: `CORS_ORIGINS=https://xxx.amplifyapp.com`

### Backend não inicia no Railway

**Causa**: Erro nas dependências ou variáveis

**Solução**:
1. Verifique logs no Railway
2. Confirme que todas as variáveis estão configuradas
3. Verifique `api/requirements.txt`

---

## 📝 Checklist

- [ ] Código commitado e pushed no GitHub
- [ ] Backend deployado no Railway
- [ ] Variáveis configuradas no Railway
- [ ] URL do Railway copiada
- [ ] `REACT_APP_BACKEND_URL` configurada no Amplify
- [ ] Amplify fez redeploy automático
- [ ] Teste de upload funcionando ✅

---

**Tempo total: ~10-15 minutos** ⏱️

**Resultado**: Aplicação fullstack funcionando! 🎉



