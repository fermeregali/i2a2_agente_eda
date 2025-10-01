# 🔴 Diagnóstico - Erro 500 no Upload

## 📊 O que está acontecendo

**Sintomas:**
- ✅ Arquivo pequeno (5.20 KB) - OK
- ✅ Upload inicia corretamente
- ❌ Erro 500 (Internal Server Error) no backend
- ❌ Erro 401 no manifest.json (secundário)

**Local do erro:** Linha 688 do `api/index.py`
```python
initial_analysis = await ask_ai(
    "Analise este dataset e dê um resumo geral",
    basic_info
)
```

---

## 🔍 Causas Prováveis (em ordem de probabilidade)

### 1️⃣ **GROQ_API_KEY não configurada ou inválida** (90% provável)

**Sintoma:** Erro ao chamar API do Groq

**Como verificar:**
```bash
# Ver logs da Vercel
vercel logs --follow
```

**Solução:**
1. Acesse: https://vercel.com/dashboard
2. Selecione seu projeto
3. Settings → Environment Variables
4. Verifique se `GROQ_API_KEY` está configurada
5. Se não estiver, adicione:
   ```
   GROQ_API_KEY=sua_chave_real_aqui
   ```
6. **IMPORTANTE:** Após adicionar, faça um **REDEPLOY**!

### 2️⃣ **Erro na conexão com Groq API** (5% provável)

**Sintoma:** Timeout ou erro de rede

**Solução:**
- Aumentar timeout no `vercel.json`
- Verificar se a API do Groq está online

### 3️⃣ **MongoDB tentando conectar e falhando** (3% provável)

**Sintoma:** Erro ao inicializar MongoDB

**Solução:**
- Configure `USE_MONGODB=false` na Vercel
- Ou configure corretamente o `MONGO_URL`

### 4️⃣ **Limite de tempo da função serverless** (2% provável)

**Sintoma:** Timeout após 10 segundos (plano free)

**Solução:**
- Otimizar código
- Fazer análise mais rápida

---

## ✅ SOLUÇÃO RÁPIDA - Teste Sem IA

Vamos fazer o upload funcionar SEM chamar a IA primeiro, para confirmar que o resto funciona.

### Passo 1: Modificar o código para tornar a IA opcional

```python
# Em api/index.py, linha 687-691
# ANTES:
initial_analysis = await ask_ai(
    "Analise este dataset e dê um resumo geral",
    basic_info
)

# DEPOIS (com try/catch):
try:
    initial_analysis = await ask_ai(
        "Analise este dataset e dê um resumo geral",
        basic_info
    )
except Exception as ai_error:
    logger.error(f"Erro na IA (não crítico): {ai_error}")
    initial_analysis = "Análise automática temporariamente indisponível. Você pode fazer perguntas sobre seus dados no chat."
```

Isso fará o upload funcionar mesmo se a IA falhar!

---

## 🔧 Como Verificar os Logs na Vercel

### Via CLI (Recomendado):

```bash
# Ver logs em tempo real
vercel logs --follow

# Ver logs das últimas 24h
vercel logs --since 24h

# Ver logs com filtro
vercel logs --output short
```

### Via Dashboard:

1. Acesse: https://vercel.com/dashboard
2. Selecione seu projeto
3. Clique na última função/deployment
4. Veja a aba "Logs" ou "Runtime Logs"

---

## 📋 Checklist de Diagnóstico

Execute na ordem:

### ✅ Passo 1: Verificar Variáveis de Ambiente

```bash
# Listar variáveis configuradas
vercel env ls

# Puxar variáveis (para verificar)
vercel env pull .env.local
cat .env.local
```

**Deve ter pelo menos:**
- `GROQ_API_KEY`
- `CORS_ORIGINS=*`

### ✅ Passo 2: Ver Logs do Erro

```bash
vercel logs --follow
```

Procure por:
- ❌ "Erro na IA"
- ❌ "Authentication failed"
- ❌ "GROQ_API_KEY"
- ❌ "MongoDB"
- ❌ "Timeout"

### ✅ Passo 3: Testar Localmente

```bash
# Ativar ambiente virtual
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate  # Windows

# Rodar backend localmente
cd api
python index.py

# Em outro terminal, rodar frontend
npm start
```

Se funcionar localmente mas não na Vercel = problema de configuração da Vercel!

### ✅ Passo 4: Fazer Deploy de Teste

```bash
# Deploy sem IA (mais rápido para testar)
vercel --prod
```

---

## 🚀 Solução Definitiva

### Opção A: Configurar GROQ_API_KEY (recomendado)

1. **Obter nova chave:**
   - https://console.groq.com/keys
   - Criar nova API key
   - Copiar a chave

2. **Configurar na Vercel:**
   ```bash
   vercel env add GROQ_API_KEY production
   # Cole a chave quando solicitado
   ```

3. **Redeploy:**
   ```bash
   vercel --prod
   ```

### Opção B: Desabilitar IA Temporariamente

Útil para debug e confirmar que o resto funciona.

**Eu posso fazer isso para você agora!**

---

## 🔍 Próximos Passos

Escolha uma opção:

### 🅰️ **Ver os logs da Vercel primeiro**
```bash
vercel logs --follow
```
Me envie o output e eu identifico o erro exato!

### 🅱️ **Modificar código para tornar IA opcional**
Eu faço isso agora e você faz novo deploy.

### 🅲 **Configurar variáveis e tentar novamente**
Te guio passo a passo.

---

## 💡 Dica Profissional

**Sempre teste localmente primeiro!**

```bash
# Terminal 1: Backend
cd api && python index.py

# Terminal 2: Frontend  
npm start

# Terminal 3: Teste de upload
curl -F "file=@sample_data/creditcard_sample.csv" \
     http://localhost:8000/api/upload-csv
```

Se funcionar localmente = problema na Vercel (variáveis ou timeout)
Se não funcionar localmente = problema no código

---

**O que você quer fazer?**
1. Ver logs da Vercel
2. Tornar IA opcional (deploy rápido)
3. Configurar GROQ_API_KEY corretamente

Me diga e eu te ajudo! 🚀

