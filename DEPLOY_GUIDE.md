# 🚀 Guia de Deploy - Agente EDA

Este guia mostra como criar um link de teste para seu projeto.

## 📋 Pré-requisitos

- Conta no Railway ou Render (gratuitas)
- Chave da API Groq (já configurada no config.env)
- Git configurado

## 🎯 Opção 1: Railway (Recomendado)

### Passo 1: Instalar Railway CLI
```bash
# Linux/Mac
curl -fsSL https://railway.app/install.sh | sh

# Ou via npm
npm install -g @railway/cli
```

### Passo 2: Deploy Automático
```bash
# Execute o script de deploy
./deploy-simple.sh
```

### Passo 3: Deploy Manual (Alternativo)
```bash
# Login
railway login

# Criar projeto
railway init

# Configurar variáveis
railway variables set GROQ_API_KEY="sua_chave_aqui"
railway variables set PORT=8000
railway variables set CORS_ORIGINS="*"

# Deploy
railway up
```

## 🎯 Opção 2: Render

### Passo 1: Conectar Repositório
1. Acesse [render.com](https://render.com)
2. Conecte sua conta GitHub
3. Selecione este repositório

### Passo 2: Configurar Serviço
1. Escolha "Web Service"
2. Use as configurações do `render.yaml`
3. Configure a variável `GROQ_API_KEY` no dashboard

### Passo 3: Deploy
- Render fará deploy automático
- URL será gerada automaticamente

## 🎯 Opção 3: Heroku

### Passo 1: Instalar Heroku CLI
```bash
# Ubuntu/Debian
curl https://cli-assets.heroku.com/install.sh | sh

# Ou via snap
sudo snap install heroku --classic
```

### Passo 2: Deploy
```bash
# Login
heroku login

# Criar app
heroku create agente-eda-$(date +%s)

# Configurar variáveis
heroku config:set GROQ_API_KEY="sua_chave_aqui"
heroku config:set PORT=8000

# Deploy
git add .
git commit -m "Deploy para Heroku"
git push heroku main
```

## 🧪 Testando o Deploy

Após o deploy, teste com:

```bash
# Health check
curl https://sua-url.com/api/health

# Listar arquivos de exemplo
curl https://sua-url.com/api/sample-files

# Carregar exemplo
curl -X POST https://sua-url.com/api/load-sample/creditcard_sample.csv
```

## 📊 Endpoints Disponíveis

- `GET /` - Informações da API
- `GET /api/health` - Status do serviço
- `GET /api/sample-files` - Lista arquivos de exemplo
- `POST /api/load-sample/{filename}` - Carrega arquivo de exemplo
- `POST /api/upload-csv` - Upload de CSV
- `POST /api/chat` - Chat com IA
- `GET /docs` - Documentação interativa

## 🔧 Configurações Importantes

### Variáveis de Ambiente Necessárias:
- `GROQ_API_KEY` - Sua chave da Groq (obrigatória)
- `PORT` - Porta do servidor (8000)
- `CORS_ORIGINS` - Origens permitidas (* para teste)

### Variáveis Opcionais:
- `MONGO_URL` - URL do MongoDB (Railway/Render fornecem automaticamente)
- `DB_NAME` - Nome do banco (agente_eda_db)

## 🎉 Resultado Final

Após o deploy, você terá:
- ✅ URL pública da API
- ✅ Endpoints funcionais
- ✅ Documentação automática
- ✅ Health check
- ✅ Suporte a upload de CSV
- ✅ Chat com IA

## 📝 Para o Trabalho Acadêmico

**URL para enviar:** `https://sua-url-aqui.com`

**Exemplo de teste:**
```bash
# 1. Verificar se está online
curl https://sua-url.com/api/health

# 2. Carregar dataset de exemplo
curl -X POST https://sua-url.com/api/load-sample/creditcard_sample.csv

# 3. Testar chat (exemplo)
curl -X POST https://sua-url.com/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Faça uma análise geral", "session_id": "sua-session-id"}'
```

## 🆘 Solução de Problemas

### Erro de CORS
- Configure `CORS_ORIGINS` corretamente
- Use `*` para teste (não recomendado para produção)

### Erro de API Key
- Verifique se `GROQ_API_KEY` está configurada
- Teste a chave localmente primeiro

### Erro de Dependências
- Verifique se `requirements.txt` está correto
- Teste localmente com `pip install -r requirements.txt`

### Timeout
- Aumente o timeout no serviço
- Verifique se o código não tem loops infinitos

## 📞 Suporte

Se tiver problemas:
1. Verifique os logs do serviço
2. Teste localmente primeiro
3. Verifique as variáveis de ambiente
4. Consulte a documentação da plataforma escolhida
