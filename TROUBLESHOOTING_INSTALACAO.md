# 🔧 Guia de Solução de Problemas - Instalação

Este guia ajuda a resolver problemas comuns durante a instalação do projeto.

## 📋 Índice

1. [Erros Comuns de Python](#erros-comuns-de-python)
2. [Erros Comuns de Node.js](#erros-comuns-de-nodejs)
3. [Problemas de Permissão](#problemas-de-permissão)
4. [Instalação Manual](#instalação-manual)

---

## 🐍 Erros Comuns de Python

### Erro: "No module named '_ctypes'"

**Causa**: Faltam bibliotecas de desenvolvimento do sistema.

**Solução Ubuntu/Debian**:
```bash
sudo apt-get update
sudo apt-get install -y build-essential libssl-dev libffi-dev python3-dev
```

**Solução Fedora/RHEL**:
```bash
sudo dnf install gcc openssl-devel libffi-devel python3-devel
```

### Erro ao instalar numpy/pandas

**Causa**: Faltam ferramentas de compilação ou BLAS/LAPACK.

**Solução Ubuntu/Debian**:
```bash
sudo apt-get install -y build-essential python3-dev libblas-dev liblapack-dev gfortran
```

**Solução alternativa**: Instale versões pré-compiladas:
```bash
source venv/bin/activate
pip install --upgrade pip
pip install numpy --only-binary :all:
pip install pandas --only-binary :all:
```

### Erro: "pip: command not found"

**Solução**:
```bash
python3 -m ensurepip --default-pip
python3 -m pip install --upgrade pip
```

### Erro de timeout ao instalar pacotes

**Solução**:
```bash
source venv/bin/activate
pip install --default-timeout=100 -r api/requirements.txt
```

---

## 📦 Erros Comuns de Node.js

### Erro: "ERESOLVE unable to resolve dependency tree"

**Causa**: Conflitos de versão entre dependências.

**Solução 1** (Recomendada):
```bash
npm install --legacy-peer-deps
```

**Solução 2**:
```bash
npm install --force
```

### Erro: "gyp ERR! stack Error: EACCES: permission denied"

**Causa**: Permissões incorretas no diretório npm global.

**Solução**:
```bash
# Limpar cache npm
npm cache clean --force

# Instalar com permissões de usuário
npm config set prefix ~/.npm-global
export PATH=~/.npm-global/bin:$PATH

# Tentar novamente
npm install
```

### Erro: "node-gyp rebuild failed"

**Causa**: Faltam ferramentas de build.

**Solução Ubuntu/Debian**:
```bash
sudo apt-get install -y build-essential
```

**Solução macOS**:
```bash
xcode-select --install
```

---

## 🔐 Problemas de Permissão

### Erro: "Permission denied" ao executar script

**Solução**:
```bash
chmod +x install.sh
chmod +x install-fix.sh
./install.sh
```

### Erro ao criar ambiente virtual

**Solução**:
```bash
# Verificar se python3-venv está instalado
sudo apt-get install python3-venv

# Criar ambiente virtual
python3 -m venv venv
```

---

## 🔨 Instalação Manual (Passo a Passo)

Se os scripts automáticos falharem, tente a instalação manual:

### Passo 1: Verificar Pré-requisitos

```bash
# Verificar Python (deve ser 3.8+)
python3 --version

# Verificar Node.js (deve ser 16+)
node --version
npm --version

# Verificar pip
python3 -m pip --version
```

### Passo 2: Criar Ambiente Virtual Python

```bash
# Remover ambiente antigo se existir
rm -rf venv

# Criar novo ambiente
python3 -m venv venv

# Ativar
source venv/bin/activate

# Verificar ativação
which python  # Deve mostrar caminho em venv/
```

### Passo 3: Instalar Dependências Python

```bash
# Atualizar ferramentas
pip install --upgrade pip setuptools wheel

# Instalar dependências uma por uma
cd api

pip install fastapi==0.109.2
pip install uvicorn[standard]==0.27.1
pip install pydantic==2.6.1
pip install python-dotenv==1.0.1
pip install python-multipart==0.0.9
pip install aiofiles==23.2.1
pip install requests==2.31.0
pip install pymongo==4.6.1
pip install groq==0.4.2

# Estas podem demorar mais
pip install numpy==1.26.4
pip install pandas==2.2.0

cd ..
```

### Passo 4: Instalar Dependências Node.js

```bash
# Limpar cache
npm cache clean --force

# Remover instalação antiga
rm -rf node_modules package-lock.json

# Instalar
npm install --legacy-peer-deps
```

### Passo 5: Configurar Ambiente

```bash
# Copiar configuração
cp config.env .env

# Editar .env e adicionar sua GROQ_API_KEY
nano .env
# ou
vim .env
```

### Passo 6: Testar Instalação

```bash
# Terminal 1 - Backend
source venv/bin/activate
cd api
python -m uvicorn index:app --host 0.0.0.0 --port 8000

# Terminal 2 - Frontend
npm start

# Acessar http://localhost:3000
```

---

## 🆘 Soluções Rápidas por Erro Específico

### "ModuleNotFoundError: No module named 'X'"

```bash
source venv/bin/activate
pip install X
```

### "Error: Cannot find module 'X'"

```bash
npm install X --legacy-peer-deps
```

### "Command not found: uvicorn"

```bash
source venv/bin/activate
pip install uvicorn
```

### "Port 3000 already in use"

```bash
# Matar processo na porta 3000
lsof -ti:3000 | xargs kill -9

# Ou usar outra porta
PORT=3001 npm start
```

### "Port 8000 already in use"

```bash
# Matar processo na porta 8000
lsof -ti:8000 | xargs kill -9

# Ou usar outra porta
cd api
uvicorn index:app --port 8001
```

---

## 💡 Dicas Gerais

1. **Sempre ative o ambiente virtual** antes de executar comandos Python:
   ```bash
   source venv/bin/activate
   ```

2. **Use o script alternativo** se o padrão falhar:
   ```bash
   chmod +x install-fix.sh
   ./install-fix.sh
   ```

3. **Verifique logs completos** para identificar o erro específico.

4. **Limpe instalações anteriores** antes de tentar novamente:
   ```bash
   rm -rf venv node_modules package-lock.json
   ```

5. **Atualize ferramentas de sistema**:
   ```bash
   sudo apt-get update
   sudo apt-get upgrade
   ```

---

## 📞 Precisa de Mais Ajuda?

Se o problema persistir, forneça:

1. Sistema operacional e versão
2. Versão do Python (`python3 --version`)
3. Versão do Node.js (`node --version`)
4. Mensagem de erro completa
5. Comando que causou o erro

Isso ajudará a diagnosticar o problema específico.

