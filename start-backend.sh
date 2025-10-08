#!/bin/bash
# Script para iniciar o backend FastAPI localmente

echo "🚀 Iniciando Backend FastAPI..."
echo ""

# Verificar se está no diretório correto
if [ ! -f "api/index.py" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

# Verificar Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 não encontrado. Instale Python 3.8+"
    exit 1
fi

# Criar/ativar virtual environment
if [ ! -d "venv" ]; then
    echo "📦 Criando virtual environment..."
    python3 -m venv venv
fi

echo "🔄 Ativando virtual environment..."
source venv/bin/activate

# Instalar dependências
echo "📥 Instalando dependências Python..."
pip install -q --upgrade pip
pip install -q -r requirements.txt

# Verificar config.env
if [ ! -f "config.env" ]; then
    echo "⚠️  config.env não encontrado. Criando do template..."
    cp config.env.example config.env
    echo ""
    echo "⚠️  IMPORTANTE: Edite config.env com suas credenciais:"
    echo "   - MONGO_URL (MongoDB Atlas)"
    echo "   - GROQ_API_KEY (console.groq.com)"
    echo ""
    read -p "Pressione ENTER para continuar..."
fi

# Carregar variáveis de ambiente
export $(cat config.env | grep -v '^#' | xargs)

echo ""
echo "✅ Backend pronto!"
echo "🌐 Servidor rodando em: http://localhost:8000"
echo "📚 Documentação API: http://localhost:8000/docs"
echo ""
echo "Para parar: Ctrl+C"
echo ""

# Iniciar servidor
cd api
uvicorn index:app --reload --host 0.0.0.0 --port 8000


