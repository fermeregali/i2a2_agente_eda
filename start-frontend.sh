#!/bin/bash
# Script para iniciar o frontend React localmente

echo "🚀 Iniciando Frontend React..."
echo ""

# Verificar se está no diretório correto
if [ ! -f "package.json" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

# Verificar Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js não encontrado. Instale Node.js 16+"
    exit 1
fi

# Verificar npm
if ! command -v npm &> /dev/null; then
    echo "❌ npm não encontrado. Instale Node.js 16+"
    exit 1
fi

# Instalar dependências se necessário
if [ ! -d "node_modules" ]; then
    echo "📥 Instalando dependências Node.js..."
    npm install
fi

# Configurar variável de ambiente para backend local
export REACT_APP_BACKEND_URL=http://localhost:8000

echo ""
echo "✅ Frontend pronto!"
echo "🌐 Aplicação rodando em: http://localhost:3000"
echo "🔗 Backend conectado em: http://localhost:8000"
echo ""
echo "Para parar: Ctrl+C"
echo ""

# Iniciar servidor de desenvolvimento
npm start


