#!/bin/bash

# Script de Deploy Simples - Apenas Backend (API)
# Para teste rápido do agente EDA

echo "🚀 Deploy Simples do Agente EDA"
echo "==============================="

# Verificar se Railway CLI está instalado
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI não encontrado."
    echo "📥 Instale em: https://docs.railway.app/develop/cli"
    echo "   Ou execute: npm install -g @railway/cli"
    exit 1
fi

echo "✅ Railway CLI encontrado"

# Verificar login
if ! railway whoami &> /dev/null; then
    echo "🔐 Faça login no Railway:"
    railway login
fi

echo "✅ Logado no Railway"

# Criar projeto
echo "📦 Criando projeto Railway..."
railway init --name "agente-eda-$(date +%s)"

# Configurar variáveis
echo "⚙️ Configurando variáveis..."

# Configurações básicas
railway variables set PORT=8000
railway variables set CORS_ORIGINS="*"
railway variables set DB_NAME=agente_eda_db

# Configurar Groq API Key (importante!)
echo "🔑 Configure sua GROQ_API_KEY:"
read -p "Digite sua chave da Groq: " GROQ_KEY
railway variables set GROQ_API_KEY="$GROQ_KEY"

echo "✅ Variáveis configuradas"

# Deploy
echo "🚀 Fazendo deploy..."
railway up

# Obter URL
echo "🌐 Obtendo URL..."
sleep 5
DEPLOY_URL=$(railway domain)

echo ""
echo "🎉 Deploy concluído!"
echo "==================="
echo "🌐 URL da API: https://$DEPLOY_URL"
echo "📊 Health Check: https://$DEPLOY_URL/api/health"
echo "📚 Docs: https://$DEPLOY_URL/docs"
echo ""
echo "🧪 Teste a API:"
echo "   curl https://$DEPLOY_URL/api/health"
echo ""
echo "📝 Esta é a URL para enviar no seu trabalho!"
