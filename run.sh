#!/bin/bash

# Script para executar o Agente de Análise de Dados
# Uso: ./run.sh

echo "🤖 Iniciando Agente de Análise de Dados..."
echo "=========================================="

# Verificar se o ambiente virtual existe
if [ ! -d "venv" ]; then
    echo "❌ Ambiente virtual não encontrado. Execute ./install.sh primeiro."
    exit 1
fi

# Ativar ambiente virtual
echo "🔧 Ativando ambiente virtual..."
source venv/bin/activate

# Verificar se as dependências estão instaladas
if [ ! -f "api/requirements.txt" ]; then
    echo "❌ Arquivo de dependências não encontrado."
    exit 1
fi

echo "🚀 Iniciando servidor backend..."
echo "📍 Backend rodando em: http://localhost:8000"
echo "📍 Frontend rodando em: http://localhost:3000"
echo ""
echo "💡 Para parar o servidor, pressione Ctrl+C"
echo ""

# Executar o backend
cd api
python -m uvicorn index:app --reload --host 0.0.0.0 --port 8000
