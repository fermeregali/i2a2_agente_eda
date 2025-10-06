#!/bin/bash

# Script para atualizar a biblioteca Groq

echo "🔄 Atualizando biblioteca Groq..."
echo "================================="
echo ""

# Verificar se venv existe
if [ ! -d "venv" ]; then
    echo "❌ Ambiente virtual não encontrado!"
    echo "Execute primeiro: ./install.sh"
    exit 1
fi

# Ativar ambiente virtual
source venv/bin/activate

echo "📦 Desinstalando versão antiga do Groq..."
pip uninstall -y groq

echo ""
echo "📦 Instalando versão atualizada do Groq (0.11.0)..."
pip install groq==0.11.0

echo ""
echo "✅ Groq atualizado com sucesso!"
echo ""
echo "Versão instalada:"
pip show groq | grep Version

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Atualização concluída!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Agora você pode testar o chat com a IA."
echo ""

