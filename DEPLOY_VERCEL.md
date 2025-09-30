# Deploy na Vercel - Agente EDA

Este guia explica como fazer o deploy do projeto na Vercel.

## Pré-requisitos

1. Conta na Vercel
2. CLI da Vercel instalada (`npm i -g vercel`)
3. Projeto configurado com as variáveis de ambiente

## Configuração das Variáveis de Ambiente

Na Vercel, você precisa configurar as seguintes variáveis de ambiente:

### 1. Acesse o Dashboard da Vercel
- Vá para [vercel.com](https://vercel.com)
- Faça login na sua conta
- Selecione seu projeto

### 2. Configure as Variáveis
Vá em **Settings** > **Environment Variables** e adicione:

```
GROQ_API_KEY = sua_chave_groq_aqui
MONGO_URL = mongodb://localhost:27017
DB_NAME = agente_eda_db
CORS_ORIGINS = https://seu-dominio.vercel.app
```

**⚠️ IMPORTANTE**: Substitua `sua_chave_groq_aqui` pela sua chave real do Groq API.

## Deploy via CLI

### 1. Instalar Vercel CLI
```bash
npm i -g vercel
```

### 2. Fazer Login
```bash
vercel login
```

### 3. Deploy
```bash
vercel
```

### 4. Deploy de Produção
```bash
vercel --prod
```

## Deploy via GitHub

### 1. Conectar Repositório
- No dashboard da Vercel, clique em "New Project"
- Conecte seu repositório GitHub
- Selecione o repositório do projeto

### 2. Configurar Build Settings
A Vercel detectará automaticamente:
- **Frontend**: React (pasta `src/`)
- **Backend**: Python (arquivo `api.py`)

### 3. Configurar Variáveis de Ambiente
- Adicione as variáveis listadas acima
- Certifique-se de que estão marcadas para "Production"

## Estrutura do Projeto

```
├── api.py                 # Backend FastAPI (otimizado para Vercel)
├── main.py               # Backend original (não usado na Vercel)
├── src/                  # Frontend React
├── build/                # Build do React (gerado automaticamente)
├── vercel.json           # Configuração da Vercel
├── package.json          # Dependências do frontend
├── requirements.txt      # Dependências do Python
└── config.env           # Variáveis locais (não commitado)
```

## Funcionalidades

### Frontend (React)
- Interface para upload de CSV
- Chat com IA para análise de dados
- Visualização de gráficos
- Sugestões de perguntas

### Backend (FastAPI)
- API para upload de arquivos CSV
- Integração com Groq LLM
- Geração de gráficos (matplotlib/seaborn)
- Análise estatística dos dados

## Troubleshooting

### Erro de CORS
- Verifique se `CORS_ORIGINS` está configurado corretamente
- Deve incluir o domínio da Vercel (ex: `https://projeto.vercel.app`)

### Erro de Build
- Verifique se todas as dependências estão no `requirements.txt`
- Teste o build localmente: `npm run build`

### Erro de API
- Verifique se `GROQ_API_KEY` está configurada
- Teste a API localmente: `python api.py`

## Comandos Úteis

```bash
# Build local do frontend
npm run build

# Teste local do backend
python api.py

# Deploy na Vercel
vercel

# Ver logs da Vercel
vercel logs

# Remover deploy
vercel remove
```

## URLs Importantes

- **Frontend**: `https://seu-projeto.vercel.app`
- **API**: `https://seu-projeto.vercel.app/api/`
- **Documentação**: `https://seu-projeto.vercel.app/docs`

## Suporte

Para problemas específicos da Vercel, consulte:
- [Documentação da Vercel](https://vercel.com/docs)
- [Vercel Python Runtime](https://vercel.com/docs/functions/serverless-functions/runtimes/python)