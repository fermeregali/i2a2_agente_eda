#!/bin/bash

# Script de Deploy para Railway
# Agente de Análise Exploratória de Dados

echo "🚀 Deploy do Agente EDA para Railway"
echo "===================================="

# Verificar se Railway CLI está instalado
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI não encontrado. Instalando..."
    
    # Instalar Railway CLI
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        curl -fsSL https://railway.app/install.sh | sh
        export PATH="$HOME/.railway/bin:$PATH"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        curl -fsSL https://railway.app/install.sh | sh
        export PATH="$HOME/.railway/bin:$PATH"
    else
        echo "❌ Sistema operacional não suportado. Instale manualmente: https://docs.railway.app/develop/cli"
        exit 1
    fi
fi

echo "✅ Railway CLI encontrado"

# Verificar se está logado
if ! railway whoami &> /dev/null; then
    echo "🔐 Faça login no Railway:"
    railway login
fi

echo "✅ Logado no Railway"

# Criar projeto se não existir
if [ ! -f ".railway/project.json" ]; then
    echo "📦 Criando novo projeto Railway..."
    railway init
fi

# Configurar variáveis de ambiente
echo "⚙️ Configurando variáveis de ambiente..."

# Ler variáveis do config.env
if [ -f "config.env" ]; then
    echo "📋 Carregando configurações do config.env..."
    
    # Configurar cada variável
    while IFS='=' read -r key value; do
        if [[ ! -z "$key" && ! "$key" =~ ^[[:space:]]*# ]]; then
            echo "  - $key"
            railway variables set "$key=$value"
        fi
    done < config.env
fi

# Configurar variáveis específicas para produção
echo "🔧 Configurando variáveis de produção..."

# CORS para permitir acesso do frontend
railway variables set CORS_ORIGINS="https://$(railway domain)"

# Configurar porta
railway variables set PORT=8000

# Configurar MongoDB (Railway fornece automaticamente)
railway variables set MONGO_URL="mongodb://mongo:27017"

echo "✅ Variáveis configuradas"

# Fazer deploy
echo "🚀 Iniciando deploy..."
railway up

# Obter URL do deploy
echo "🌐 Obtendo URL do deploy..."
DEPLOY_URL=$(railway domain)

echo ""
echo "🎉 Deploy concluído com sucesso!"
echo "================================="
echo "🌐 URL do seu agente: https://$DEPLOY_URL"
echo "📊 API Health Check: https://$DEPLOY_URL/api/health"
echo "📚 Documentação API: https://$DEPLOY_URL/docs"
echo ""
echo "💡 Para acessar o frontend, você precisará:"
echo "   1. Fazer build do React: npm run build"
echo "   2. Servir os arquivos estáticos do frontend"
echo "   3. Ou usar um serviço separado como Vercel/Netlify"
echo ""
echo "📝 Salve esta URL para enviar no seu trabalho!"
