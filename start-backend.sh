#!/bin/bash

# Script para iniciar o backend rapidamente

echo "🚀 Iniciando Backend..."
echo ""

# Verificar se venv existe
if [ ! -d "venv" ]; then
    echo "❌ Ambiente virtual não encontrado!"
    echo "Execute primeiro: ./install.sh"
    exit 1
fi

# Verificar se .env existe
if [ ! -f ".env" ]; then
    echo "⚠️  Arquivo .env não encontrado. Criando com configurações padrão..."
    cat > .env << 'EOF'
MONGO_URL=mongodb://localhost:27017
DB_NAME=agente_eda_db
CORS_ORIGINS=*
GROQ_API_KEY=sua_chave_groq_aqui
USE_MONGODB=false
EOF
    echo "✅ Arquivo .env criado"
    echo "⚠️  IMPORTANTE: Configure sua GROQ_API_KEY no arquivo .env"
    echo ""
fi

# Ativar ambiente virtual
source venv/bin/activate

# Ir para diretório da API
cd api

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 Backend rodando em: http://localhost:8000"
echo "📚 Documentação API: http://localhost:8000/docs"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Pressione Ctrl+C para parar o servidor"
echo ""

# Iniciar servidor
python -m uvicorn index:app --reload --host 0.0.0.0 --port 8000

