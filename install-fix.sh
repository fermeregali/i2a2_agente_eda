#!/bin/bash

# Script de instalação alternativo com tratamento robusto de erros
# Use este script se o install.sh padrão apresentar problemas

echo "🔧 Script de Instalação Alternativo - Modo Robusto"
echo "=================================================="
echo ""

# Função para verificar comando
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo "❌ $1 não encontrado"
        return 1
    fi
    return 0
}

# Verificar pré-requisitos
echo "🔍 Verificando pré-requisitos..."
if ! check_command python3; then
    echo "Por favor, instale Python 3.8 ou superior"
    exit 1
fi

if ! check_command node; then
    echo "Por favor, instale Node.js 16 ou superior"
    exit 1
fi

echo "✅ Python: $(python3 --version)"
echo "✅ Node: $(node --version)"
echo "✅ pip: $(python3 -m pip --version)"
echo ""

# Limpar instalação anterior
echo "🧹 Limpando instalações anteriores..."
if [ -d "venv" ]; then
    rm -rf venv
    echo "   Removido: venv/"
fi

if [ -d "node_modules" ]; then
    rm -rf node_modules
    echo "   Removido: node_modules/"
fi

if [ -f "package-lock.json" ]; then
    rm -f package-lock.json
    echo "   Removido: package-lock.json"
fi

echo ""

# Criar ambiente virtual
echo "📦 Criando novo ambiente virtual Python..."
python3 -m venv venv

# Ativar ambiente virtual
source venv/bin/activate

# Atualizar ferramentas essenciais
echo "⬆️  Atualizando pip, setuptools e wheel..."
python -m pip install --upgrade pip setuptools wheel --quiet

echo ""
echo "📚 Instalando dependências Python..."
echo "   (Isto pode demorar alguns minutos)"
echo ""

# Instalar dependências Python com fallback
cd api 2>/dev/null || { echo "❌ Diretório api/ não encontrado"; exit 1; }

# Tentar instalar requirements.txt
if python -m pip install -r requirements.txt --no-cache-dir; then
    echo "✅ Dependências Python instaladas!"
else
    echo ""
    echo "⚠️  Falha na instalação padrão. Tentando método alternativo..."
    echo ""
    
    # Instalar uma por uma
    packages=(
        "fastapi==0.109.2"
        "uvicorn[standard]==0.27.1"
        "pydantic==2.6.1"
        "python-dotenv==1.0.1"
        "python-multipart==0.0.9"
        "aiofiles==23.2.1"
        "requests==2.31.0"
        "pymongo==4.6.1"
        "groq==0.4.2"
        "numpy==1.26.4"
        "pandas==2.2.0"
    )
    
    for package in "${packages[@]}"; do
        echo "   📦 Instalando $package"
        python -m pip install "$package" --no-cache-dir || {
            echo "   ⚠️  Falha em $package - continuando..."
        }
    done
fi

cd ..
echo ""

# Instalar dependências Node.js
echo "📚 Instalando dependências Node.js..."
if npm install --legacy-peer-deps; then
    echo "✅ Dependências Node.js instaladas!"
else
    echo "⚠️  Erro ao instalar dependências Node.js"
    echo "   Tente manualmente: npm install --legacy-peer-deps --force"
fi

echo ""

# Criar .env se necessário
if [ ! -f .env ]; then
    echo "⚙️  Criando arquivo .env..."
    if [ -f config.env ]; then
        cp config.env .env
    else
        cat > .env << 'EOF'
MONGO_URL=mongodb://localhost:27017
DB_NAME=agente_eda_db
CORS_ORIGINS=http://localhost:3000,http://127.0.0.1:3000
GROQ_API_KEY=sua_chave_groq_aqui
EOF
    fi
    echo "✅ Arquivo .env criado"
    echo "⚠️  Configure GROQ_API_KEY no arquivo .env"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Instalação concluída!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Próximos passos:"
echo ""
echo "1. Configure sua GROQ_API_KEY em .env"
echo ""
echo "2. Inicie o Backend (Terminal 1):"
echo "   source venv/bin/activate"
echo "   cd api"
echo "   python -m uvicorn index:app --reload --host 0.0.0.0 --port 8000"
echo ""
echo "3. Inicie o Frontend (Terminal 2):"
echo "   npm start"
echo ""
echo "4. Acesse: http://localhost:3000"
echo ""

