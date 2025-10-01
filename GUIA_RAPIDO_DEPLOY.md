# 🚀 Guia Rápido - Deploy na Vercel com MongoDB

## ✅ O que foi corrigido

1. **CORS configurado** para aceitar todas as origens (*)
2. **MongoDB integrado** - agora funciona quando configurado
3. **Logs adicionados** no frontend e backend para facilitar debug
4. **PyMongo adicionado** ao requirements.txt
5. **Sistema híbrido**: usa MongoDB se disponível, senão usa memória

---

## 📋 Passo a Passo - FAÇA AGORA

### 1️⃣ Configurar MongoDB Atlas (5 minutos - GRÁTIS)

1. **Criar conta:** https://www.mongodb.com/cloud/atlas/register
2. **Criar cluster FREE (M0)**
3. **Criar usuário do banco:**
   - Username: `agente_user`
   - Password: crie uma senha forte (anote!)
4. **Liberar acesso de qualquer IP:**
   - Network Access → Add IP → **0.0.0.0/0**
5. **Copiar URL de conexão:**
   - Database → Connect → Connect your application
   - Copie algo como:
   ```
   mongodb+srv://agente_user:<password>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
   ```
   - **Troque `<password>` pela sua senha real!**

📖 **Guia detalhado:** Veja `CONFIGURAR_MONGODB_VERCEL.md`

---

### 2️⃣ Configurar Variáveis na Vercel

1. **Acesse:** https://vercel.com/dashboard
2. **Selecione seu projeto**
3. **Settings → Environment Variables**
4. **Adicione estas variáveis:**

```env
GROQ_API_KEY=gsk_SEU_TOKEN_GROQ_AQUI
CORS_ORIGINS=*
USE_MONGODB=true
MONGO_URL=mongodb+srv://agente_user:SUA_SENHA@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
DB_NAME=agente_eda_db
```

**⚠️ IMPORTANTE:**
- Substitua `SUA_SENHA` pela senha real
- Substitua `xxxxx` pelo seu cluster ID
- Marque TODAS como **Production**, **Preview** e **Development**

---

### 3️⃣ Fazer Build e Deploy

```bash
# 1. Instalar dependências (se ainda não fez)
npm install

# 2. Fazer build do frontend
npm run build

# 3. Verificar se build foi criado
ls -la build/

# 4. Fazer deploy na Vercel
vercel --prod
```

---

## 🔍 Como Verificar se Funcionou

### No Console do Navegador (F12):

Quando abrir o app, você deve ver:
```
🔧 Configuração da Aplicação:
  - Ambiente: production
  - API URL: https://seu-projeto.vercel.app
  - Origin: https://seu-projeto.vercel.app
```

Quando fizer upload de um CSV:
```
📤 Iniciando upload do arquivo: arquivo.csv
🚀 Enviando requisição para: https://...
✅ Upload bem-sucedido: {...}
```

### Nos Logs da Vercel:

```bash
# Ver logs em tempo real
vercel logs --follow
```

Você deve ver:
```
✅ PyMongo disponível - MongoDB habilitado
🔌 Conectando ao MongoDB...
✅ MongoDB conectado! Banco: agente_eda_db
📊 Sessão abc-123 salva no MongoDB
```

---

## 🎯 Duas Opções de Deploy

### Opção A: COM MongoDB (Recomendado)

✅ **Vantagens:**
- Persistência de dados
- Histórico de conversas salvo
- Múltiplos usuários simultâneos

❌ **Desvantagens:**
- Precisa configurar MongoDB Atlas
- Mais complexo

**Configure:**
```env
USE_MONGODB=true
MONGO_URL=mongodb+srv://...
```

---

### Opção B: SEM MongoDB (Mais Simples)

✅ **Vantagens:**
- Mais simples
- Sem configuração extra
- Mais rápido

❌ **Desvantagens:**
- Dados perdem quando a função serverless reinicia
- Cada requisição pode ter sessão diferente

**Configure:**
```env
USE_MONGODB=false
```

**OU** simplesmente **não configure** essas variáveis.

---

## 🐛 Problemas Comuns

### Erro 401 (Unauthorized)

**Solução:**
1. Verifique se `CORS_ORIGINS=*` está configurado
2. Faça novo deploy após adicionar variáveis

### Erro de Conexão MongoDB

**Solução:**
1. Verifique se a senha está correta na URL
2. Verifique se liberou 0.0.0.0/0 no Network Access
3. Aguarde 2-3 minutos após configurar
4. Teste a URL localmente:

```python
from pymongo import MongoClient
client = MongoClient("sua_url_aqui")
client.admin.command('ping')
print("✅ Conectado!")
```

### Build falha

**Solução:**
```bash
# Limpar e rebuild
rm -rf node_modules build
npm install
npm run build
```

### Erro "pymongo not found"

**Solução:** Já corrigido! `pymongo==4.6.1` foi adicionado ao `api/requirements.txt`

---

## 📊 Status das Correções

✅ **Concluído:**
- [x] CORS configurado para aceitar todas as origens
- [x] MongoDB integrado ao código
- [x] PyMongo adicionado ao requirements.txt
- [x] Logs detalhados no frontend
- [x] Logs detalhados no backend
- [x] Sistema híbrido (MongoDB ou memória)
- [x] Funções para salvar sessões
- [x] Funções para salvar datasets
- [x] Auto-salvar no upload
- [x] Auto-salvar no chat

🔜 **Próximo passo (VOCÊ):**
- [ ] Configurar MongoDB Atlas
- [ ] Configurar variáveis na Vercel
- [ ] Fazer deploy
- [ ] Testar no browser

---

## 📞 Precisa de Ajuda?

### Ver logs detalhados:
```bash
vercel logs --follow
```

### Testar localmente:
```bash
# Backend
cd api
python3 index.py

# Frontend (outro terminal)
npm start
```

### Verificar variáveis:
```bash
vercel env ls
```

---

## 🎉 Resultado Final

Após seguir todos os passos:
- ✅ Frontend funcionando na Vercel
- ✅ Backend respondendo corretamente
- ✅ CORS configurado
- ✅ MongoDB salvando dados (se habilitado)
- ✅ Logs claros no console
- ✅ Sem erros 401

---

## 📚 Documentação Completa

- **SOLUCAO_ERRO_401.md** - Detalhes do erro 401 e como resolver
- **CONFIGURAR_MONGODB_VERCEL.md** - Guia completo do MongoDB
- **deploy-fix.sh** - Script automatizado de deploy
- **DEPLOY_VERCEL.md** - Guia original de deploy

---

**Data:** 01/10/2025
**Status:** ✅ Pronto para deploy
**Próxima ação:** Configure as variáveis na Vercel e faça o deploy!

