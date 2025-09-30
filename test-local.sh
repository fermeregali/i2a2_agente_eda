#!/bin/bash

# Script de Teste Local
# Valida se o agente EDA está funcionando corretamente

echo "🧪 Testando Agente EDA Localmente"
echo "================================="

# Verificar se o ambiente virtual existe
if [ ! -d "venv" ]; then
    echo "❌ Ambiente virtual não encontrado. Execute ./install.sh primeiro"
    exit 1
fi

# Ativar ambiente virtual
echo "🔧 Ativando ambiente virtual..."
source venv/bin/activate

# Verificar dependências
echo "📦 Verificando dependências..."
python -c "import fastapi, pandas, numpy, matplotlib, seaborn, groq" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "❌ Dependências não instaladas. Execute: pip install -r requirements.txt"
    exit 1
fi

echo "✅ Dependências OK"

# Verificar arquivo de configuração
if [ ! -f "config.env" ]; then
    echo "❌ Arquivo config.env não encontrado"
    exit 1
fi

echo "✅ Configuração OK"

# Verificar se a API key está configurada
if ! grep -q "GROQ_API_KEY=" config.env || grep -q "GROQ_API_KEY=$" config.env; then
    echo "⚠️ GROQ_API_KEY não configurada no config.env"
    echo "   Configure sua chave da Groq no arquivo config.env"
fi

# Iniciar servidor em background
echo "🚀 Iniciando servidor..."
python main.py &
SERVER_PID=$!

# Aguardar servidor iniciar
echo "⏳ Aguardando servidor iniciar..."
sleep 10

# Testar endpoints
echo "🧪 Testando endpoints..."

# Health check
echo "  - Testando health check..."
curl -s http://localhost:8000/api/health > /dev/null
if [ $? -eq 0 ]; then
    echo "    ✅ Health check OK"
else
    echo "    ❌ Health check falhou"
fi

# Sample files
echo "  - Testando listagem de arquivos..."
curl -s http://localhost:8000/api/sample-files > /dev/null
if [ $? -eq 0 ]; then
    echo "    ✅ Listagem de arquivos OK"
else
    echo "    ❌ Listagem de arquivos falhou"
fi

# Load sample
echo "  - Testando carregamento de exemplo..."
RESPONSE=$(curl -s -X POST http://localhost:8000/api/load-sample/creditcard_sample.csv)
if echo "$RESPONSE" | grep -q "session_id"; then
    echo "    ✅ Carregamento de exemplo OK"
    SESSION_ID=$(echo "$RESPONSE" | grep -o '"session_id":"[^"]*"' | cut -d'"' -f4)
    echo "    📝 Session ID: $SESSION_ID"
else
    echo "    ❌ Carregamento de exemplo falhou"
fi

# Test chat (se session_id foi obtido)
if [ ! -z "$SESSION_ID" ]; then
    echo "  - Testando chat com IA..."
    CHAT_RESPONSE=$(curl -s -X POST http://localhost:8000/api/chat \
        -H "Content-Type: application/json" \
        -d "{\"message\": \"Faça uma análise geral\", \"session_id\": \"$SESSION_ID\"}")
    
    if echo "$CHAT_RESPONSE" | grep -q "response"; then
        echo "    ✅ Chat com IA OK"
    else
        echo "    ❌ Chat com IA falhou"
    fi
fi

# Parar servidor
echo "🛑 Parando servidor..."
kill $SERVER_PID 2>/dev/null

echo ""
echo "🎉 Teste concluído!"
echo "==================="
echo "Se todos os testes passaram, seu agente está pronto para deploy!"
echo ""
echo "📋 Próximos passos:"
echo "1. Configure sua GROQ_API_KEY no config.env"
echo "2. Execute: ./deploy-simple.sh"
echo "3. Use a URL gerada no seu trabalho acadêmico"
