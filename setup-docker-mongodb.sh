#!/bin/bash

# Script para rodar MongoDB via Docker (ideal para WSL2)

echo "🐳 Configurando MongoDB via Docker..."
echo "====================================="
echo ""

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não está instalado!"
    echo ""
    echo "📥 Instale Docker:"
    echo "   Ubuntu: https://docs.docker.com/engine/install/ubuntu/"
    echo "   Windows: https://docs.docker.com/desktop/install/windows-install/"
    echo "   Mac: https://docs.docker.com/desktop/install/mac-install/"
    exit 1
fi

echo "✅ Docker detectado: $(docker --version)"
echo ""

# Verificar se container já existe
if docker ps -a | grep -q mongodb; then
    echo "ℹ️  Container 'mongodb' já existe"
    
    # Verificar se está rodando
    if docker ps | grep -q mongodb; then
        echo "✅ MongoDB já está rodando!"
        echo ""
        docker ps | grep mongodb
    else
        echo "🔄 Iniciando container existente..."
        docker start mongodb
        echo "✅ MongoDB iniciado!"
    fi
else
    echo "📦 Criando novo container MongoDB..."
    echo ""
    
    docker run -d \
        --name mongodb \
        -p 27017:27017 \
        -v mongodb_data:/data/db \
        -e MONGO_INITDB_ROOT_USERNAME=admin \
        -e MONGO_INITDB_ROOT_PASSWORD=admin123 \
        mongo:latest
    
    if [ $? -eq 0 ]; then
        echo "✅ MongoDB criado e iniciado com sucesso!"
    else
        echo "❌ Erro ao criar container"
        exit 1
    fi
fi

echo ""
echo "⏳ Aguardando MongoDB inicializar (5 segundos)..."
sleep 5

echo ""
echo "🧪 Testando conexão..."
docker exec mongodb mongosh --eval "db.adminCommand('ping')" --quiet

if [ $? -eq 0 ]; then
    echo "✅ MongoDB respondendo!"
else
    echo "⚠️  MongoDB pode ainda estar inicializando..."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 MongoDB via Docker está pronto!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Informações:"
echo "   Host: localhost"
echo "   Porta: 27017"
echo "   Container: mongodb"
echo ""
echo "⚙️  Configure no .env:"
echo "   USE_MONGODB=true"
echo "   MONGO_URL=mongodb://localhost:27017"
echo "   DB_NAME=agente_eda_db"
echo ""
echo "🛠️  Comandos úteis:"
echo "   Ver status:  docker ps | grep mongodb"
echo "   Ver logs:    docker logs mongodb"
echo "   Parar:       docker stop mongodb"
echo "   Iniciar:     docker start mongodb"
echo "   Remover:     docker rm -f mongodb"
echo "   Acessar:     docker exec -it mongodb mongosh"
echo ""

# Criar/atualizar .env automaticamente
if [ -f ".env" ]; then
    echo "📝 Atualizando .env..."
    
    # Backup
    cp .env .env.backup
    
    # Atualizar configurações
    sed -i 's/USE_MONGODB=.*/USE_MONGODB=true/' .env
    sed -i 's|MONGO_URL=.*|MONGO_URL=mongodb://localhost:27017|' .env
    
    echo "✅ Arquivo .env atualizado (backup em .env.backup)"
else
    echo "📝 Criando .env..."
    cat > .env << 'EOF'
USE_MONGODB=true
MONGO_URL=mongodb://localhost:27017
DB_NAME=agente_eda_db
CORS_ORIGINS=*
GROQ_API_KEY=sua_chave_groq_aqui
EOF
    echo "✅ Arquivo .env criado"
fi

echo ""
echo "🚀 Agora você pode iniciar o backend:"
echo "   ./start-backend.sh"
echo ""

