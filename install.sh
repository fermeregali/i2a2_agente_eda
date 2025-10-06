#!/bin/bash

# Script de instalação do Agente de Análise Exploratória de Dados
# Desenvolvido para atividade acadêmica de Agentes Autônomos

set -e  # Parar em caso de erro

echo "🤖 Instalando Agente de Análise Exploratória de Dados..."
echo "=============================================="

# Verificar se Python está instalado
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 não está instalado. Por favor, instale Python 3.8+ primeiro."
    exit 1
fi

# Verificar versão do Python
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
echo "🐍 Python detectado: $(python3 --version)"

# Verificar se Node.js está instalado
if ! command -v node &> /dev/null; then
    echo "❌ Node.js não está instalado. Por favor, instale Node.js 16+ primeiro."
    exit 1
fi

echo "📦 Node.js detectado: $(node --version)"
echo "✅ Pré-requisitos verificados"
echo ""

# Remover ambiente virtual antigo se existir
if [ -d "venv" ]; then
    echo "🗑️  Removendo ambiente virtual antigo..."
    rm -rf venv
fi

# Criar ambiente virtual Python
echo "📦 Criando ambiente virtual Python..."
python3 -m venv venv

# Ativar ambiente virtual
echo "🔧 Ativando ambiente virtual..."
source venv/bin/activate

# Atualizar pip, setuptools e wheel
echo "⬆️  Atualizando ferramentas de instalação..."
pip install --upgrade pip setuptools wheel

# Instalar dependências Python uma por uma para melhor diagnóstico
echo "📚 Instalando dependências Python..."
echo "   Isto pode levar alguns minutos..."
echo ""

if [ -f "api/requirements.txt" ]; then
    # Tentar instalar todas de uma vez primeiro
    if pip install -r api/requirements.txt; then
        echo "✅ Todas as dependências Python instaladas com sucesso!"
    else
        echo "⚠️  Erro ao instalar dependências. Tentando instalação individual..."
        # Instalar uma por uma em caso de erro
        while IFS= read -r package || [ -n "$package" ]; do
            # Ignorar linhas vazias e comentários
            if [[ -n "$package" && ! "$package" =~ ^[[:space:]]*# ]]; then
                echo "   Instalando $package..."
                pip install "$package" || echo "   ⚠️  Aviso: Falha ao instalar $package"
            fi
        done < api/requirements.txt
    fi
else
    echo "❌ Arquivo api/requirements.txt não encontrado!"
    exit 1
fi

echo ""

# Instalar dependências Node.js
echo "📚 Instalando dependências Node.js..."
if npm install; then
    echo "✅ Dependências Node.js instaladas com sucesso!"
else
    echo "⚠️  Erro ao instalar dependências Node.js"
    echo "   Tente executar manualmente: npm install --legacy-peer-deps"
fi

echo ""

# Criar arquivo .env se não existir
if [ ! -f .env ]; then
    echo "⚙️  Criando arquivo de configuração..."
    if [ -f config.env ]; then
        cp config.env .env
        echo "✅ Arquivo .env criado com configurações padrão"
    else
        echo "📝 Criando arquivo .env com configurações básicas..."
        cat > .env << 'EOF'
MONGO_URL=mongodb://localhost:27017
DB_NAME=agente_eda_db
CORS_ORIGINS=http://localhost:3000,http://127.0.0.1:3000
GROQ_API_KEY=sua_chave_groq_aqui
EOF
        echo "✅ Arquivo .env criado"
    fi
    echo "⚠️  IMPORTANTE: Configure sua GROQ_API_KEY no arquivo .env"
else
    echo "✅ Arquivo .env já existe"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Instalação concluída com sucesso!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Para executar o sistema:"
echo ""
echo "1️⃣  Backend (Terminal 1):"
echo "   source venv/bin/activate"
echo "   cd api"
echo "   python -m uvicorn index:app --reload --host 0.0.0.0 --port 8000"
echo ""
echo "2️⃣  Frontend (Terminal 2):"
echo "   npm start"
echo ""
echo "3️⃣  Acesse: http://localhost:3000"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Sistema pronto para análise de dados!"
echo ""
echo "💡 Para deploy na Vercel: vercel --prod"
echo ""
