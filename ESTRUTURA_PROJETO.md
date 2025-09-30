# 📁 Estrutura do Projeto - Agente EDA

## 🗂️ Organização dos Arquivos

```
projeto/
├── 📁 api/                    # Backend Python (Vercel Functions)
│   ├── index.py              # API FastAPI principal
│   └── requirements.txt      # Dependências Python
├── 📁 src/                   # Frontend React
│   ├── App.js               # Componente principal
│   ├── App.css              # Estilos
│   └── index.js             # Ponto de entrada
├── 📁 build/                 # Frontend compilado (gerado automaticamente)
├── 📁 public/                # Arquivos estáticos do React
├── 📁 sample_data/           # Dados de exemplo CSV
├── 📄 package.json           # Dependências Node.js
├── 📄 vercel.json            # Configuração Vercel
└── 📄 README.md              # Documentação principal
```

## 🔧 Arquivos Removidos (Limpeza)

- ❌ `main.py` - Duplicado, funcionalidade movida para `api/index.py`
- ❌ `requirements.txt` (raiz) - Duplicado, usando `api/requirements.txt`
- ❌ `vercel-requirements.txt` - Duplicado
- ❌ `api/index-original.py` - Backup desnecessário
- ❌ `api/index-optimized.py` - Backup desnecessário
- ❌ `api/requirements-minimal.txt` - Backup desnecessário

## 🚀 Como Funciona

### Backend (API Python)
- **Localização:** `api/index.py`
- **Framework:** FastAPI
- **Dependências:** `api/requirements.txt`
- **Função:** Análise de dados, geração de insights, dados para gráficos

### Frontend (React)
- **Localização:** `src/`
- **Dependências:** `package.json`
- **Função:** Interface do usuário, visualização de gráficos com Plotly.js

### Deploy Vercel
- **Configuração:** `vercel.json`
- **API:** Rota `/api/*` → `api/index.py`
- **Frontend:** Rota `/*` → `build/` (arquivos estáticos)

## 📊 Gráficos e Visualizações

### Tipos Disponíveis:
1. **Histogramas** - Distribuição de dados
2. **Heatmaps de Correlação** - Relações entre variáveis
3. **Gráficos de Dispersão** - Scatter plots
4. **Box Plots** - Visualização de outliers

### Como Funciona:
1. **Usuário faz pergunta** (ex: "mostre histogramas")
2. **API analisa dados** e gera dados estruturados
3. **Frontend renderiza** gráficos interativos com Plotly.js

## 🎯 Vantagens da Estrutura Atual

- ✅ **Organizada** - Separação clara entre frontend e backend
- ✅ **Otimizada** - Sem arquivos duplicados ou desnecessários
- ✅ **Funcional** - Gráficos interativos mantidos
- ✅ **Compatível** - Funciona na Vercel sem problemas de tamanho
- ✅ **Manutenível** - Estrutura clara e fácil de entender
