# Como Configurar MongoDB na Vercel

## 🎯 Objetivo
Habilitar o MongoDB para persistir dados na Vercel, ao invés de usar armazenamento em memória.

---

## 📋 Passo 1: Obter URL de Conexão do MongoDB

### Opção A: MongoDB Atlas (Recomendado - GRATUITO)

1. **Criar conta no MongoDB Atlas:**
   - Acesse: https://www.mongodb.com/cloud/atlas/register
   - Faça cadastro gratuito

2. **Criar um Cluster:**
   - Escolha o plano **FREE** (M0)
   - Região: escolha a mais próxima (ex: São Paulo, Virginia)
   - Nome do cluster: `agente-eda-cluster`

3. **Configurar Acesso:**
   - Vá em **Database Access** → **Add New Database User**
   - Username: `agente_user`
   - Password: crie uma senha forte (anote!)
   - Database User Privileges: **Read and write to any database**

4. **Configurar Network Access:**
   - Vá em **Network Access** → **Add IP Address**
   - Clique em **ALLOW ACCESS FROM ANYWHERE** (0.0.0.0/0)
   - Isso é necessário para a Vercel acessar

5. **Obter String de Conexão:**
   - Vá em **Database** → **Connect**
   - Escolha **Connect your application**
   - Driver: **Python**, Version: **3.12 or later**
   - Copie a string de conexão que aparece:
   ```
   mongodb+srv://agente_user:<password>@agente-eda-cluster.xxxxx.mongodb.net/?retryWrites=true&w=majority
   ```
   - **IMPORTANTE:** Substitua `<password>` pela senha que você criou

### Opção B: MongoDB Local (Apenas para testes)

Se quiser testar localmente primeiro:
```
mongodb://localhost:27017
```

### Opção C: Outro Serviço

Você pode usar qualquer serviço MongoDB compatível:
- **MongoDB Atlas** (recomendado)
- **DigitalOcean Managed MongoDB**
- **AWS DocumentDB**
- **Azure Cosmos DB**

---

## 📋 Passo 2: Configurar Variáveis de Ambiente na Vercel

### Via Dashboard da Vercel:

1. Acesse: https://vercel.com/dashboard
2. Selecione seu projeto
3. Vá em **Settings** → **Environment Variables**
4. Adicione as seguintes variáveis:

```env
# Sua chave da API Groq (já deve estar configurada)
GROQ_API_KEY=sua_chave_groq_aqui

# CORS - Permite todas as origens (para debug)
CORS_ORIGINS=*

# MongoDB - URL de conexão
MONGO_URL=mongodb+srv://agente_user:SUA_SENHA@agente-eda-cluster.xxxxx.mongodb.net/?retryWrites=true&w=majority

# Nome do banco de dados
DB_NAME=agente_eda_db

# Habilitar MongoDB
USE_MONGODB=true
```

**⚠️ IMPORTANTE:**
- Substitua `SUA_SENHA` pela senha real do MongoDB
- Substitua `xxxxx` pelo seu cluster ID
- Marque todas como **Production**, **Preview** e **Development**
- Após adicionar, você **DEVE** fazer um novo deploy!

### Via CLI (Alternativa):

```bash
# Configurar MONGO_URL
vercel env add MONGO_URL
# Cole a URL completa: mongodb+srv://usuario:senha@cluster.mongodb.net/

# Configurar DB_NAME
vercel env add DB_NAME
# Digite: agente_eda_db

# Habilitar MongoDB
vercel env add USE_MONGODB
# Digite: true
```

---

## 📋 Passo 3: Atualizar Código para Usar MongoDB

O código precisa ser atualizado para realmente usar o MongoDB. Vou fazer isso para você automaticamente.

As mudanças incluem:
1. ✅ Habilitar conexão com MongoDB quando USE_MONGODB=true
2. ✅ Usar PyMongo para conectar
3. ✅ Persistir sessões no MongoDB
4. ✅ Fallback para memória se MongoDB falhar

---

## 📋 Passo 4: Estrutura do Banco de Dados

Quando você usar MongoDB, terá as seguintes coleções:

### Collection: `sessions`
Armazena informações das sessões de upload:
```json
{
  "_id": "uuid-da-sessao",
  "created_at": "2025-10-01T10:30:00",
  "basic_info": {
    "shape": [1000, 10],
    "columns": ["col1", "col2", ...],
    "numeric_columns": [...],
    "categorical_columns": [...]
  },
  "conversation_history": [
    {
      "type": "user",
      "content": "Faça uma análise",
      "timestamp": "2025-10-01T10:31:00"
    }
  ]
}
```

### Collection: `datasets`
Armazena metadados dos datasets (não os dados brutos, pois são grandes):
```json
{
  "_id": "uuid-da-sessao",
  "filename": "arquivo.csv",
  "uploaded_at": "2025-10-01T10:30:00",
  "basic_info": {...},
  "insights": [...]
}
```

**⚠️ NOTA:** Os dados do DataFrame (CSV) **não** são salvos no MongoDB devido ao tamanho. São mantidos em memória durante a sessão.

---

## 🧪 Como Testar

### 1. Testar Conexão Localmente

```python
# Criar arquivo test_mongo.py
from pymongo import MongoClient
import os

MONGO_URL = "sua_url_mongodb_aqui"

try:
    client = MongoClient(MONGO_URL)
    db = client["agente_eda_db"]
    
    # Testar inserção
    test_collection = db["test"]
    result = test_collection.insert_one({"test": "funcionou!"})
    print(f"✅ MongoDB conectado! ID: {result.inserted_id}")
    
    # Limpar teste
    test_collection.delete_one({"_id": result.inserted_id})
    print("✅ Teste completo!")
    
except Exception as e:
    print(f"❌ Erro: {e}")
```

```bash
python test_mongo.py
```

### 2. Testar na Vercel

Após o deploy, abra o console do navegador e:
1. Faça upload de um CSV
2. Verifique os logs no console
3. Procure por mensagens como:
   - `✅ MongoDB conectado!`
   - `📊 Sessão salva no MongoDB`

### 3. Verificar no MongoDB Atlas

1. Acesse: https://cloud.mongodb.com
2. Vá em **Database** → **Browse Collections**
3. Você deve ver o banco `agente_eda_db`
4. E as coleções `sessions` e `datasets`

---

## 🔧 Troubleshooting

### Erro: "Authentication failed"

**Causa:** Senha incorreta ou usuário não configurado

**Solução:**
1. Verifique se a senha está correta na URL
2. Certifique-se de que o usuário tem permissões
3. Não use caracteres especiais na senha (ou encode eles)

### Erro: "Connection timeout"

**Causa:** IP não está na whitelist

**Solução:**
1. No MongoDB Atlas, vá em **Network Access**
2. Adicione 0.0.0.0/0 (permite todos os IPs)
3. Espere 2-3 minutos para propagar

### Erro: "pymongo not found"

**Causa:** Dependência não instalada

**Solução:**
Adicione ao `api/requirements.txt`:
```
pymongo==4.6.1
```

### MongoDB não está sendo usado

**Causa:** Variável USE_MONGODB não configurada

**Solução:**
1. Configure `USE_MONGODB=true` na Vercel
2. Faça novo deploy
3. Verifique os logs

---

## 📊 Vantagens de Usar MongoDB

✅ **Persistência:** Dados não são perdidos entre deploys
✅ **Escalabilidade:** Suporta múltiplos usuários simultâneos
✅ **Histórico:** Mantém histórico de conversas
✅ **Análise:** Pode analisar padrões de uso
✅ **Backup:** MongoDB Atlas faz backup automático

## ⚠️ Limitações

❌ **Plano Free do Atlas:**
- 512 MB de armazenamento
- Cluster compartilhado
- Pode ter latência maior

❌ **Dados do CSV:**
- Não são persistidos (muito grandes)
- Usuário precisa fazer upload novamente

---

## 🔒 Segurança

### Boas Práticas:

1. **Nunca commite a URL do MongoDB no Git**
2. **Use variáveis de ambiente sempre**
3. **Crie senhas fortes**
4. **Restrinja IPs quando possível** (mas 0.0.0.0/0 é necessário para Vercel)
5. **Use SSL/TLS** (mongodb+srv:// já usa)

---

## 💡 Alternativa Sem MongoDB

Se não quiser usar MongoDB, o sistema **funciona perfeitamente em memória**:
- ✅ Mais rápido
- ✅ Sem configuração adicional
- ✅ Gratuito
- ❌ Perde dados quando a função serverless reinicia
- ❌ Cada requisição pode ter sessão diferente

Para usar apenas memória, configure:
```env
USE_MONGODB=false
```

---

**Data:** 01/10/2025
**Status:** ✅ Pronto para uso

