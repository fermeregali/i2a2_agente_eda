#!/bin/bash

# Script para testar o backend rapidamente

echo "🧪 Testando Backend..."
echo "====================="
echo ""

# Verificar se venv existe
if [ ! -d "venv" ]; then
    echo "❌ Ambiente virtual não encontrado!"
    echo "Execute primeiro: ./install.sh"
    exit 1
fi

# Ativar ambiente virtual
source venv/bin/activate

# Verificar se .env existe
if [ ! -f ".env" ]; then
    echo "⚠️  Arquivo .env não encontrado. Criando..."
    cat > .env << 'EOF'
MONGO_URL=mongodb://localhost:27017
DB_NAME=agente_eda_db
CORS_ORIGINS=*
GROQ_API_KEY=sua_chave_groq_aqui
USE_MONGODB=false
EOF
    echo "✅ Arquivo .env criado"
fi

echo "📦 Testando imports Python..."
python3 << 'PYEOF'
import sys
print("Python:", sys.version)

try:
    import fastapi
    print("✅ FastAPI:", fastapi.__version__)
except ImportError as e:
    print("❌ FastAPI não instalado:", e)
    sys.exit(1)

try:
    import uvicorn
    print("✅ Uvicorn instalado")
except ImportError as e:
    print("❌ Uvicorn não instalado:", e)
    sys.exit(1)

try:
    import pandas
    print("✅ Pandas:", pandas.__version__)
except ImportError as e:
    print("❌ Pandas não instalado:", e)
    sys.exit(1)

try:
    import numpy
    print("✅ Numpy:", numpy.__version__)
except ImportError as e:
    print("❌ Numpy não instalado:", e)
    sys.exit(1)

try:
    from dotenv import load_dotenv
    print("✅ python-dotenv instalado")
except ImportError as e:
    print("❌ python-dotenv não instalado:", e)
    sys.exit(1)

print("\n🎉 Todos os imports básicos OK!")
PYEOF

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Erro ao testar imports!"
    echo "Reinstale as dependências:"
    echo "  source venv/bin/activate"
    echo "  pip install -r api/requirements.txt"
    exit 1
fi

echo ""
echo "🚀 Testando carregamento do index.py..."
cd api

python3 << 'PYEOF'
try:
    import index
    print("✅ index.py carregado com sucesso!")
    print("✅ FastAPI app criado:", index.app)
except Exception as e:
    print("❌ Erro ao carregar index.py:")
    print(f"   {type(e).__name__}: {e}")
    import traceback
    traceback.print_exc()
    exit(1)
PYEOF

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Erro ao carregar o backend!"
    exit 1
fi

cd ..

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Backend está OK e pronto para rodar!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Para iniciar o servidor:"
echo "  source venv/bin/activate"
echo "  cd api"
echo "  python -m uvicorn index:app --reload --host 0.0.0.0 --port 8000"
echo ""
echo "Ou use o atalho:"
echo "  ./start-backend.sh"
echo ""

