#!/bin/bash

# Script para testar conexão com MongoDB

echo "🧪 Testando MongoDB..."
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
    echo "⚠️  Arquivo .env não encontrado!"
    echo "Criando com configurações padrão..."
    cat > .env << 'EOF'
USE_MONGODB=false
MONGO_URL=mongodb://localhost:27017
DB_NAME=agente_eda_db
CORS_ORIGINS=*
GROQ_API_KEY=sua_chave_groq_aqui
EOF
fi

# Ler configuração
USE_MONGODB=$(grep "USE_MONGODB" .env | cut -d'=' -f2)
MONGO_URL=$(grep "MONGO_URL" .env | cut -d'=' -f2)

echo "📋 Configuração atual:"
echo "   USE_MONGODB: $USE_MONGODB"
echo "   MONGO_URL: $MONGO_URL"
echo ""

if [ "$USE_MONGODB" = "false" ]; then
    echo "ℹ️  MongoDB está DESABILITADO no .env"
    echo ""
    echo "   O sistema está usando armazenamento em memória."
    echo "   Isso é normal e funciona perfeitamente para desenvolvimento!"
    echo ""
    echo "   Se quiser habilitar MongoDB:"
    echo "   1. Instale MongoDB (consulte GUIA_MONGODB.md)"
    echo "   2. Edite .env e mude USE_MONGODB=true"
    echo ""
    exit 0
fi

echo "🔌 Testando conexão com MongoDB..."
echo ""

python3 << 'PYEOF'
import os
import sys
from dotenv import load_dotenv

try:
    from pymongo import MongoClient
except ImportError:
    print("❌ PyMongo não está instalado!")
    print("   Instale com: pip install pymongo")
    sys.exit(1)

load_dotenv()

mongo_url = os.getenv("MONGO_URL", "mongodb://localhost:27017")
db_name = os.getenv("DB_NAME", "agente_eda_db")

print(f"   URL: {mongo_url}")
print(f"   Database: {db_name}")
print()

try:
    print("⏳ Conectando...")
    client = MongoClient(mongo_url, serverSelectionTimeoutMS=5000, connectTimeoutMS=10000)
    
    # Testar conexão
    client.admin.command('ping')
    
    print("✅ MongoDB conectado com sucesso!")
    print()
    print("📊 Informações:")
    
    # Listar databases
    databases = client.list_database_names()
    print(f"   Databases disponíveis: {len(databases)}")
    for db in databases[:5]:  # Mostrar até 5
        print(f"      - {db}")
    
    # Verificar database do projeto
    if db_name in databases:
        print(f"\n   ✅ Database '{db_name}' já existe")
        db = client[db_name]
        collections = db.list_collection_names()
        print(f"   Collections: {collections if collections else 'nenhuma ainda'}")
    else:
        print(f"\n   ℹ️  Database '{db_name}' será criado automaticamente")
    
    print()
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("🎉 MongoDB configurado corretamente!")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    
except Exception as e:
    error_type = type(e).__name__
    error_msg = str(e)
    
    print(f"❌ Erro ao conectar: {error_type}")
    print(f"   {error_msg}")
    print()
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("💡 Possíveis soluções:")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print()
    
    if "Connection refused" in error_msg or "ServerSelectionTimeoutError" in error_type:
        print("🔍 MongoDB não está rodando ou não está acessível")
        print()
        print("   Verifique se está rodando:")
        print("   $ sudo systemctl status mongod")
        print()
        print("   Se não estiver, inicie:")
        print("   $ sudo systemctl start mongod")
        print()
        print("   No Docker:")
        print("   $ docker start mongodb")
        print()
        print("   No WSL2 (manual):")
        print("   $ mongod --dbpath /data/db --fork --logpath /var/log/mongodb.log")
        print()
        print("   Ou DESABILITE MongoDB no .env:")
        print("   USE_MONGODB=false")
        
    elif "Authentication failed" in error_msg:
        print("🔐 Credenciais incorretas")
        print()
        print("   Verifique usuário e senha no .env")
        print("   Formato correto:")
        print("   MONGO_URL=mongodb://usuario:senha@localhost:27017")
        
    elif "DNS" in error_msg or "getaddrinfo" in error_msg:
        print("🌐 Erro de DNS/URL")
        print()
        print("   Verifique a URL no .env")
        print("   Para localhost use:")
        print("   MONGO_URL=mongodb://localhost:27017")
        print()
        print("   Para Atlas use:")
        print("   MONGO_URL=mongodb+srv://user:pass@cluster.mongodb.net/")
    
    else:
        print("📚 Consulte o guia completo:")
        print("   $ cat GUIA_MONGODB.md")
    
    print()
    sys.exit(1)

PYEOF

exit_code=$?

if [ $exit_code -ne 0 ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "ℹ️  DICA: Use sem MongoDB"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Para desenvolvimento, você pode desabilitar MongoDB:"
    echo ""
    echo "1. Edite o arquivo .env"
    echo "2. Mude para: USE_MONGODB=false"
    echo "3. Reinicie o backend"
    echo ""
    echo "O sistema funcionará perfeitamente usando memória RAM!"
    echo ""
fi

