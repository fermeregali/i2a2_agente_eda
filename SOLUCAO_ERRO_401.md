# Solução para Erro 401 (Unauthorized) na Vercel

## 🔍 Diagnóstico do Problema

Pelos erros no console do navegador:
```
GET https://agente-g0k9pn2uz-fernandos-projects-b413208d.vercel.app/manifest.json 401 (Unauthorized)
Failed to load resource: net::ERR_CONNECTION_RESET
```

**Causas principais:**
1. ❌ CORS não está configurado corretamente para permitir o domínio da Vercel
2. ❌ Variáveis de ambiente não estão configuradas na Vercel
3. ❌ O frontend não consegue se comunicar com o backend

---

## ✅ Solução Completa

### 1. Configurar Variáveis de Ambiente na Vercel

#### Via Dashboard da Vercel:

1. Acesse: https://vercel.com/dashboard
2. Selecione seu projeto
3. Vá em **Settings** → **Environment Variables**
4. Adicione as seguintes variáveis:

```env
GROQ_API_KEY=gsk_SEU_TOKEN_GROQ_AQUI
CORS_ORIGINS=*
MONGO_URL=mongodb://localhost:27017
DB_NAME=agente_eda_db
```

**⚠️ IMPORTANTE:**
- Marque todas como **Production** e **Preview**
- Após adicionar as variáveis, você **DEVE** fazer um novo deploy

#### Via CLI (alternativa):

```bash
# Configurar variáveis de ambiente
vercel env add GROQ_API_KEY
# Cole sua chave quando solicitado

vercel env add CORS_ORIGINS
# Digite: *

vercel env add MONGO_URL
# Digite: mongodb://localhost:27017

vercel env add DB_NAME
# Digite: agente_eda_db
```

---

### 2. Corrigir Configuração de CORS no Backend

O problema está em `api/index.py`. Vamos atualizar para aceitar todas as origens durante o debug:

**Localização:** `api/index.py` (linhas 46-58)

**Alteração necessária:**

```python
# ANTES (problemático):
cors_origins = os.getenv("CORS_ORIGINS", "http://localhost:3000").split(",")
if "VERCEL_URL" in os.environ:
    cors_origins.append(f"https://{os.environ['VERCEL_URL']}")
if "VERCEL_BRANCH_URL" in os.environ:
    cors_origins.append(f"https://{os.environ['VERCEL_BRANCH_URL']}")

# DEPOIS (corrigido):
cors_origins_env = os.getenv("CORS_ORIGINS", "*")
if cors_origins_env == "*":
    cors_origins = ["*"]
else:
    cors_origins = cors_origins_env.split(",")
    # Adicionar URLs automáticas da Vercel
    if "VERCEL_URL" in os.environ:
        cors_origins.append(f"https://{os.environ['VERCEL_URL']}")
    if "VERCEL_BRANCH_URL" in os.environ:
        cors_origins.append(f"https://{os.environ['VERCEL_BRANCH_URL']}")
```

---

### 3. Verificar a Configuração do vercel.json

O arquivo `vercel.json` deve estar assim:

```json
{
  "version": 2,
  "builds": [
    {
      "src": "api/index.py",
      "use": "@vercel/python",
      "config": {
        "maxLambdaSize": "50mb"
      }
    },
    {
      "src": "package.json",
      "use": "@vercel/static-build",
      "config": {
        "distDir": "build"
      }
    }
  ],
  "routes": [
    {
      "src": "/api/(.*)",
      "dest": "/api/index.py"
    },
    {
      "src": "/(.*)",
      "dest": "/build/$1"
    }
  ],
  "env": {
    "GROQ_API_KEY": "@groq_api_key",
    "CORS_ORIGINS": "@cors_origins"
  }
}
```

---

### 4. Adicionar Build Script ao package.json

Certifique-se de que o `package.json` tem o script de build:

```json
{
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject",
    "deploy": "vercel --prod",
    "deploy:preview": "vercel"
  }
}
```

---

### 5. Fazer Build Local e Testar

Antes de fazer deploy, teste localmente:

```bash
# 1. Fazer build do frontend
npm run build

# 2. Verificar se a pasta build foi criada
ls -la build/

# 3. Testar o backend localmente
cd api
python3 index.py

# 4. Em outro terminal, servir o frontend
cd build
python3 -m http.server 3000
```

---

### 6. Fazer Novo Deploy

```bash
# Limpar cache da Vercel
rm -rf .vercel

# Fazer deploy de teste
vercel

# Se funcionar, fazer deploy de produção
vercel --prod
```

---

## 🔧 Comandos para Debug na Vercel

### Ver Logs em Tempo Real

```bash
# Ver logs do último deploy
vercel logs

# Ver logs em tempo real
vercel logs --follow

# Ver logs de uma função específica
vercel logs --since 1h
```

### Testar Endpoints da API

```bash
# Testar health check
curl https://seu-projeto.vercel.app/api/health

# Testar CORS
curl -H "Origin: https://seu-projeto.vercel.app" \
     -H "Access-Control-Request-Method: POST" \
     -H "Access-Control-Request-Headers: Content-Type" \
     -X OPTIONS \
     --verbose \
     https://seu-projeto.vercel.app/api/upload-csv
```

---

## 📋 Checklist de Verificação

Antes de fazer deploy, verifique:

- [ ] ✅ Variáveis de ambiente configuradas na Vercel
- [ ] ✅ GROQ_API_KEY configurada corretamente
- [ ] ✅ CORS_ORIGINS configurado como `*` (para debug) ou com domínios específicos
- [ ] ✅ Build do frontend executado: `npm run build`
- [ ] ✅ Pasta `build/` existe e tem conteúdo
- [ ] ✅ Arquivo `vercel.json` está correto
- [ ] ✅ Backend tem a configuração de CORS atualizada

---

## 🚨 Erros Comuns e Soluções

### Erro: "Failed to load resource: 401 (Unauthorized)"

**Causa:** CORS bloqueando as requisições

**Solução:**
1. Configure `CORS_ORIGINS=*` na Vercel (temporariamente)
2. Depois do deploy funcionar, configure com domínios específicos

### Erro: "ERR_CONNECTION_RESET"

**Causa:** Backend não está respondendo ou timeout

**Solução:**
1. Verifique se a função serverless está ativa nos logs da Vercel
2. Aumente o timeout no `vercel.json`:
```json
{
  "functions": {
    "api/index.py": {
      "maxDuration": 60
    }
  }
}
```

### Erro: "manifest.json 401"

**Causa:** Arquivo manifest.json não está acessível ou CORS bloqueando

**Solução:**
1. Verifique se `public/manifest.json` existe
2. Certifique-se de que está sendo copiado para `build/` no npm run build

---

## 🎯 Como Ver Logs Apenas no Browser

Como você mencionou que não consegue ver logs na Vercel, aqui está como ver tudo no browser:

1. **Abra as DevTools**: F12 ou Ctrl+Shift+I
2. **Vá na aba Console**: Veja erros JavaScript
3. **Vá na aba Network**: Veja todas as requisições HTTP
   - Filtrar por "XHR" ou "Fetch" para ver chamadas de API
   - Clique em cada requisição para ver detalhes
   - Veja o status code, headers, e response

4. **Adicionar Logs no Frontend**

Adicione mais logs no `src/App.js`:

```javascript
// No início do componente App
useEffect(() => {
  console.log('🌍 Environment:', process.env.NODE_ENV);
  console.log('🔗 API URL:', apiUrl);
  console.log('📍 Window Origin:', window.location.origin);
}, []);

// Na função handleFileUpload
const handleFileUpload = async (file) => {
  console.log('📤 Uploading file:', file.name);
  console.log('🔗 Request URL:', `${apiUrl}/api/upload-csv`);
  
  setIsUploading(true);
  setError(null);
  
  try {
    const formData = new FormData();
    formData.append('file', file);
    
    console.log('🚀 Sending request...');

    const response = await axios.post('/api/upload-csv', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });

    console.log('✅ Response:', response.data);
    // ... resto do código
  } catch (err) {
    console.error('❌ Error:', err);
    console.error('❌ Error Response:', err.response);
    console.error('❌ Error Status:', err.response?.status);
    console.error('❌ Error Data:', err.response?.data);
    setError(err.response?.data?.detail || 'Erro ao carregar arquivo');
  } finally {
    setIsUploading(false);
  }
};
```

---

## 🔄 Próximos Passos

1. **Configure as variáveis de ambiente na Vercel**
2. **Atualize o código do CORS no `api/index.py`**
3. **Faça um novo deploy**
4. **Teste no browser com DevTools aberto**
5. **Me envie os logs do console se ainda houver erro**

---

## 📞 Precisa de Mais Ajuda?

Se ainda tiver problemas, me envie:
1. Screenshot completo do console (aba Console + Network)
2. URL do seu projeto na Vercel
3. Prints das variáveis de ambiente configuradas
4. Logs do `vercel logs`

**Data da Solução:** 01/10/2025

