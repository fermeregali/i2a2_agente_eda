#!/bin/bash

# Script para iniciar o frontend rapidamente

echo "🚀 Iniciando Frontend..."
echo ""

# Verificar se node_modules existe
if [ ! -d "node_modules" ]; then
    echo "❌ node_modules não encontrado!"
    echo "Execute primeiro: npm install"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 Frontend rodando em: http://localhost:3000"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Pressione Ctrl+C para parar o servidor"
echo ""

# Iniciar React
npm start

