#!/bin/bash

# Script final para corrigir o problema do Groq

echo "🔧 Correção Final do Groq"
echo "========================="
echo ""

# Verificar se venv existe
if [ ! -d "venv" ]; then
    echo "❌ Ambiente virtual não encontrado!"
    exit 1
fi

# Ativar ambiente virtual
source venv/bin/activate

echo "🧹 Limpando cache Python..."
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
find . -type f -name "*.pyc" -delete 2>/dev/null

echo "🗑️  Limpando cache pip..."
pip cache purge > /dev/null 2>&1

echo "📦 Desinstalando versão antiga..."
pip uninstall -y groq > /dev/null 2>&1

echo "⬇️  Instalando Groq 0.32.0..."
pip install --no-cache-dir groq==0.32.0

echo ""
echo "✅ Groq 0.32.0 instalado!"
echo ""
echo "🧪 Testando..."
python3 << 'EOF'
try:
    from groq import Groq
    client = Groq(api_key='test')
    print("✅ Groq funcionando corretamente!")
except Exception as e:
    print(f"❌ Erro: {e}")
    exit(1)
EOF

if [ $? -eq 0 ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎉 Problema resolvido!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Agora reinicie o backend:"
    echo "  ./start-backend.sh"
    echo ""
fi

