# 🗄️ Guia de Instalação e Configuração do MongoDB

Este guia ajuda você a configurar o MongoDB para o projeto.

---

## 📋 Opções Disponíveis

Você tem 3 opções para usar o sistema:

1. **[Sem MongoDB](#opção-1-sem-mongodb-recomendado-para-desenvolvimento)** - Mais simples (recomendado para testar)
2. **[MongoDB Local](#opção-2-instalar-mongodb-local)** - Dados persistem no seu computador
3. **[MongoDB Cloud](#opção-3-mongodb-atlas-cloud-gratuito)** - Dados na nuvem (melhor para produção)

---

## Opção 1: Sem MongoDB (Recomendado para Desenvolvimento)

Esta é a opção **mais simples**. O sistema usa a memória RAM para armazenar dados temporariamente.

### ✅ Vantagens
- Não precisa instalar nada
- Funciona imediatamente
- Ideal para desenvolvimento e testes

### ⚠️ Desvantagens
- Dados são perdidos quando o servidor para
- Não adequado para produção

### ⚙️ Como usar

No arquivo `.env`, configure:
```env
USE_MONGODB=false
MONGO_URL=mongodb://localhost:27017
DB_NAME=agente_eda_db
```

**Pronto!** É só isso. O sistema funcionará normalmente.

---

## Opção 2: Instalar MongoDB Local

Se você quer que os dados persistam entre reinicializações, instale o MongoDB localmente.

### 📦 Instalação no Ubuntu/Debian

```bash
# 1. Importar chave pública
wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo apt-key add -

# 2. Adicionar repositório MongoDB
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -sc)/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# 3. Atualizar pacotes
sudo apt-get update

# 4. Instalar MongoDB
sudo apt-get install -y mongodb-org

# 5. Iniciar serviço
sudo systemctl start mongod

# 6. Habilitar para iniciar automaticamente
sudo systemctl enable mongod

# 7. Verificar status
sudo systemctl status mongod
```

### 📦 Instalação no WSL2 (Windows Subsystem for Linux)

O MongoDB não funciona bem com systemd no WSL2. Use Docker ou MongoDB manual:

#### Método 1: Docker (Recomendado para WSL2)
```bash
# 1. Instalar Docker Desktop for Windows
# https://docs.docker.com/desktop/install/windows-install/

# 2. Rodar MongoDB no Docker
docker run -d \
  --name mongodb \
  -p 27017:27017 \
  -v mongodb_data:/data/db \
  mongo:latest

# 3. Verificar se está rodando
docker ps
```

#### Método 2: MongoDB Manual no WSL2
```bash
# 1. Instalar MongoDB
wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org

# 2. Criar diretório de dados
sudo mkdir -p /data/db
sudo chown -R $(whoami) /data/db

# 3. Iniciar MongoDB manualmente
mongod --dbpath /data/db --fork --logpath /var/log/mongodb.log

# 4. Para parar
mongod --shutdown --dbpath /data/db
```

### 📦 Instalação no macOS

```bash
# Usando Homebrew
brew tap mongodb/brew
brew install mongodb-community

# Iniciar serviço
brew services start mongodb-community

# Verificar
brew services list
```

### 📦 Instalação no Fedora/RHEL/CentOS

```bash
# 1. Adicionar repositório
sudo cat <<EOF > /etc/yum.repos.d/mongodb-org-7.0.repo
[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/7.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-7.0.asc
EOF

# 2. Instalar
sudo dnf install -y mongodb-org

# 3. Iniciar
sudo systemctl start mongod
sudo systemctl enable mongod
```

### ⚙️ Configurar no projeto

Depois de instalar e iniciar o MongoDB, configure no `.env`:

```env
USE_MONGODB=true
MONGO_URL=mongodb://localhost:27017
DB_NAME=agente_eda_db
```

### 🧪 Testar conexão

```bash
# Método 1: Usando mongosh (MongoDB Shell)
mongosh

# Método 2: Testar pelo Python
python3 << 'EOF'
from pymongo import MongoClient
try:
    client = MongoClient('mongodb://localhost:27017', serverSelectionTimeoutMS=5000)
    client.admin.command('ping')
    print("✅ MongoDB conectado com sucesso!")
except Exception as e:
    print(f"❌ Erro: {e}")
EOF
```

---

## Opção 3: MongoDB Atlas (Cloud - Gratuito)

MongoDB Atlas oferece um tier gratuito com 512MB de armazenamento.

### 🌐 Como configurar

1. **Criar conta:**
   - Acesse: https://www.mongodb.com/cloud/atlas/register
   - Crie uma conta gratuita

2. **Criar Cluster:**
   - Escolha "FREE" (M0 Sandbox)
   - Selecione a região mais próxima
   - Clique em "Create Cluster"

3. **Configurar acesso:**
   - Vá em "Database Access" → "Add New Database User"
   - Crie um usuário com senha
   - Anote: usuário e senha

4. **Configurar IP:**
   - Vá em "Network Access" → "Add IP Address"
   - Clique em "Allow Access from Anywhere" (0.0.0.0/0)
   - Salve

5. **Obter Connection String:**
   - Vá em "Database" → "Connect"
   - Escolha "Connect your application"
   - Copie a string de conexão:
   ```
   mongodb+srv://<usuario>:<senha>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
   ```

6. **Configurar no projeto:**

Edite o `.env`:
```env
USE_MONGODB=true
MONGO_URL=mongodb+srv://seu_usuario:sua_senha@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
DB_NAME=agente_eda_db
```

### ✅ Vantagens do Atlas
- Gratuito até 512MB
- Dados persistem na nuvem
- Backups automáticos
- Acessível de qualquer lugar
- Não precisa instalar nada localmente

---

## 🔧 Scripts Auxiliares

### Script para testar MongoDB

Crie ou use: `./test-mongodb.sh`

```bash
#!/bin/bash
source venv/bin/activate
python3 << 'EOF'
import os
from dotenv import load_dotenv
from pymongo import MongoClient

load_dotenv()

mongo_url = os.getenv("MONGO_URL", "mongodb://localhost:27017")
print(f"🔌 Testando conexão: {mongo_url}")

try:
    client = MongoClient(mongo_url, serverSelectionTimeoutMS=5000)
    client.admin.command('ping')
    print("✅ MongoDB conectado com sucesso!")
    print(f"📊 Databases: {client.list_database_names()}")
except Exception as e:
    print(f"❌ Erro ao conectar: {e}")
    print("\n💡 Dica: Verifique se o MongoDB está rodando")
    print("   sudo systemctl status mongod")
EOF
```

---

## 🐛 Resolução de Problemas

### Erro: "Connection refused"

**Causa:** MongoDB não está rodando

**Solução:**
```bash
# Ubuntu/Debian
sudo systemctl start mongod
sudo systemctl status mongod

# Docker
docker start mongodb

# WSL2 manual
mongod --dbpath /data/db --fork --logpath /var/log/mongodb.log
```

### Erro: "Authentication failed"

**Causa:** Credenciais incorretas

**Solução:**
- Verifique usuário e senha no `.env`
- Certifique-se de que o usuário foi criado no MongoDB

### Erro: "Server selection timeout"

**Causa:** MongoDB não acessível ou URL incorreta

**Solução:**
1. Verifique se MongoDB está rodando: `sudo systemctl status mongod`
2. Verifique a URL no `.env`
3. Teste a conexão: `mongosh`

### MongoDB não inicia no WSL2

**Causa:** systemd não funciona bem no WSL2

**Solução:** Use Docker ou inicie manualmente:
```bash
mongod --dbpath /data/db --fork --logpath /var/log/mongodb.log
```

### Porta 27017 em uso

**Causa:** Outra instância do MongoDB rodando

**Solução:**
```bash
# Ver o que está usando a porta
sudo lsof -i :27017

# Parar MongoDB
sudo systemctl stop mongod

# Ou matar o processo
sudo kill $(sudo lsof -t -i:27017)
```

---

## 📊 Comparação das Opções

| Característica | Sem MongoDB | MongoDB Local | MongoDB Atlas |
|----------------|-------------|---------------|---------------|
| Instalação | ✅ Nenhuma | ⚠️ Requer instalação | ✅ Só cadastro |
| Persistência | ❌ Temporário | ✅ Permanente | ✅ Permanente |
| Internet | ❌ Não precisa | ❌ Não precisa | ✅ Precisa |
| Custo | 💰 Gratuito | 💰 Gratuito | 💰 Gratuito* |
| Configuração | ⚡ Imediata | 🔧 Média | 🔧 Média |
| Produção | ❌ Não | ✅ Sim | ✅✅ Ideal |

*512MB gratuito

---

## 🎯 Recomendação

### Para Desenvolvimento/Testes
**Use SEM MongoDB** (mais simples):
```env
USE_MONGODB=false
```

### Para Produção Local
**Use MongoDB Local** ou **Docker**

### Para Deploy Cloud (Vercel, etc)
**Use MongoDB Atlas** (cloud gratuito)

---

## 🚀 Próximos Passos

1. Escolha uma das 3 opções acima
2. Configure o arquivo `.env`
3. Reinicie o backend
4. Teste a aplicação

---

**Dúvidas?** Consulte também:
- `TROUBLESHOOTING_INSTALACAO.md`
- `INSTALACAO_RAPIDA.md`

