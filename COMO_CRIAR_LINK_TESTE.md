# 🔗 Como Criar Link de Teste para o Trabalho

## 📋 Resumo do Seu Projeto

Você tem um **Agente de Análise Exploratória de Dados (EDA)** que:
- ✅ Analisa arquivos CSV automaticamente
- ✅ Usa IA (Groq) para responder perguntas sobre os dados
- ✅ Gera gráficos e visualizações
- ✅ Detecta outliers e correlações
- ✅ Interface conversacional em português

## 🚀 Opções para Criar Link de Teste

### 🥇 Opção 1: Railway (MAIS FÁCIL)

```bash
# 1. Instalar Railway CLI
curl -fsSL https://railway.app/install.sh | sh

# 2. Deploy automático
./deploy-simple.sh
```

**Vantagens:**
- ✅ Deploy em 2 minutos
- ✅ URL automática
- ✅ Configuração automática de banco
- ✅ Gratuito

### 🥈 Opção 2: Render

1. Acesse [render.com](https://render.com)
2. Conecte sua conta GitHub
3. Selecione este repositório
4. Use as configurações do `render.yaml`
5. Configure `GROQ_API_KEY` no dashboard

### 🥉 Opção 3: Heroku

```bash
# 1. Instalar Heroku CLI
curl https://cli-assets.heroku.com/install.sh | sh

# 2. Deploy
heroku login
heroku create agente-eda-$(date +%s)
heroku config:set GROQ_API_KEY="sua_chave_aqui"
git push heroku main
```

## 🧪 Teste Local Primeiro

Antes de fazer deploy, teste localmente:

```bash
# Testar se tudo funciona
./test-local.sh
```

## 📝 O Que Você Precisa

### 1. Chave da Groq (já tem)
Sua chave está no `config.env`:
```
GROQ_API_KEY=sua_chave_aqui
```

### 2. Deploy (escolha uma opção acima)

### 3. URL para o Trabalho
Após o deploy, você receberá uma URL como:
```
https://agente-eda-production.up.railway.app
```

## 🎯 Exemplo de Teste da URL

Após o deploy, teste com:

```bash
# 1. Verificar se está online
curl https://sua-url.com/api/health

# 2. Carregar dataset de exemplo
curl -X POST https://sua-url.com/api/load-sample/creditcard_sample.csv

# 3. Testar chat
curl -X POST https://sua-url.com/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Faça uma análise geral", "session_id": "sua-session-id"}'
```

## 📊 Endpoints Disponíveis

- `GET /` - Informações da API
- `GET /api/health` - Status do serviço
- `GET /api/sample-files` - Lista arquivos de exemplo
- `POST /api/load-sample/{filename}` - Carrega arquivo de exemplo
- `POST /api/upload-csv` - Upload de CSV
- `POST /api/chat` - Chat com IA
- `GET /docs` - Documentação interativa

## 🎉 Resultado Final

Após o deploy, você terá:
- ✅ **URL pública** para testar
- ✅ **API funcionando** com todos os endpoints
- ✅ **Documentação automática** em `/docs`
- ✅ **Health check** em `/api/health`
- ✅ **Suporte a upload** de CSV
- ✅ **Chat com IA** funcionando

## 📧 Para Enviar no Trabalho

**Email:** challenges@i2a2.academy

**Conteúdo:**
- 📄 Relatório PDF: "Agentes Autônomos – Relatório da Atividade Extra.pdf"
- 💻 Códigos fonte: Este repositório
- 🔗 **Link para teste:** `https://sua-url-aqui.com`

## 🆘 Se Algo Der Errado

1. **Teste local primeiro:** `./test-local.sh`
2. **Verifique a chave Groq** no config.env
3. **Consulte os logs** do serviço
4. **Use o guia completo:** `DEPLOY_GUIDE.md`

## ⚡ Deploy Rápido (Railway)

```bash
# 1. Instalar Railway
curl -fsSL https://railway.app/install.sh | sh

# 2. Login
railway login

# 3. Deploy
./deploy-simple.sh
```

**Pronto!** Você terá sua URL em menos de 5 minutos! 🎉
