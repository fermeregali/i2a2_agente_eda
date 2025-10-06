# ⚡ Instalação Rápida

## 🚀 Método 1: Instalação Automática (Recomendado)

### Opção A: Script Padrão
```bash
chmod +x install.sh
./install.sh
```

### Opção B: Script Robusto (se o padrão falhar)
```bash
chmod +x install-fix.sh
./install-fix.sh
```

---

## 🧪 Testar Instalação

```bash
chmod +x test-install.sh
./test-install.sh
```

---

## 🔧 Método 2: Instalação Manual

### 1. Instalar Dependências Python

```bash
# Criar ambiente virtual
python3 -m venv venv

# Ativar
source venv/bin/activate

# Atualizar pip
pip install --upgrade pip setuptools wheel

# Instalar dependências
cd api
pip install -r requirements.txt
cd ..
```

### 2. Instalar Dependências Node.js

```bash
# Limpar cache (opcional)
npm cache clean --force

# Instalar
npm install --legacy-peer-deps
```

### 3. Configurar Variáveis de Ambiente

```bash
# Copiar configuração
cp config.env .env

# Editar e adicionar sua GROQ_API_KEY
nano .env
```

---

## ▶️ Executar o Sistema

### Terminal 1 - Backend
```bash
source venv/bin/activate
cd api
python -m uvicorn index:app --reload --host 0.0.0.0 --port 8000
```

### Terminal 2 - Frontend
```bash
npm start
```

### Acessar
Abra o navegador em: **http://localhost:3000**

---

## 🆘 Problemas Comuns

### Erro: "No module named '_ctypes'" (Linux)
```bash
sudo apt-get install -y build-essential python3-dev libssl-dev libffi-dev
```

### Erro: "ERESOLVE unable to resolve dependency tree"
```bash
npm install --legacy-peer-deps
```

### Erro ao instalar numpy/pandas
```bash
sudo apt-get install -y build-essential python3-dev libblas-dev liblapack-dev
```

### Porta já em uso
```bash
# Backend (porta 8000)
lsof -ti:8000 | xargs kill -9

# Frontend (porta 3000)
lsof -ti:3000 | xargs kill -9
```

---

## 📚 Mais Ajuda

Consulte o guia completo: **[TROUBLESHOOTING_INSTALACAO.md](TROUBLESHOOTING_INSTALACAO.md)**

---

## ✅ Checklist Pré-Instalação

Antes de instalar, verifique:

- [ ] Python 3.8+ instalado (`python3 --version`)
- [ ] Node.js 16+ instalado (`node --version`)
- [ ] pip instalado (`python3 -m pip --version`)
- [ ] Ferramentas de build instaladas (Linux: `build-essential`)
- [ ] Acesso à internet

### Instalar Ferramentas de Build

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y build-essential python3-dev python3-venv
```

**Fedora/RHEL:**
```bash
sudo dnf install gcc python3-devel
```

**macOS:**
```bash
xcode-select --install
```

---

## 📊 Estrutura Esperada Após Instalação

```
projeto/
├── venv/                 ✅ Ambiente virtual Python
├── node_modules/         ✅ Dependências Node.js
├── .env                  ✅ Variáveis de ambiente
├── api/
│   └── ...              ✅ Backend FastAPI
├── src/
│   └── ...              ✅ Frontend React
└── ...
```

---

## 🎯 Próximos Passos Após Instalação

1. ✅ Instalar dependências
2. ⚙️ Configurar GROQ_API_KEY em `.env`
3. 🚀 Executar backend e frontend
4. 📊 Upload de arquivo CSV
5. 🤖 Análise exploratória automática

---

## 💡 Dicas

- **Sempre ative o ambiente virtual** antes de executar comandos Python
- **Use duas janelas de terminal** (uma para backend, outra para frontend)
- **Configure sua GROQ_API_KEY** antes de usar o sistema
- **Consulte logs** para diagnosticar problemas

---

**Desenvolvido para atividade acadêmica de Agentes Autônomos**

