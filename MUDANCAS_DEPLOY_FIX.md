# 🔧 Correções Aplicadas para Deploy na Vercel

**Data:** 01/10/2025  
**Problema:** Erro de instalação de dependências Python durante deploy na Vercel

---

## 📝 Mudanças Aplicadas

### 1. ✅ Atualizado `api/requirements.txt`

Versões antigas incompatíveis com Python 3.12 foram atualizadas:

| Pacote | Versão Antiga | Versão Nova | Motivo |
|--------|---------------|-------------|--------|
| pandas | 2.0.3 | 2.2.0 | Melhor compatibilidade Python 3.12 |
| numpy | 1.24.3 | 1.26.4 | Compatibilidade com pandas 2.2.0 |
| fastapi | 0.104.1 | 0.109.2 | Correções de bugs e segurança |
| uvicorn | 0.24.0 | 0.27.1 | Melhor suporte para Python 3.12 |
| pydantic | 2.5.0 | 2.6.1 | Compatibilidade com FastAPI 0.109.2 |
| groq | 0.4.1 | 0.4.2 | Versão mais recente |
| python-multipart | 0.0.6 | 0.0.9 | Versão mais estável |
| python-dotenv | 1.0.0 | 1.0.1 | Pequenas correções |

### 2. ✅ Criado `runtime.txt`

Arquivo na raiz do projeto especificando a versão do Python:
```
python-3.12.0
```

### 3. ✅ Atualizado `vercel.json`

Adicionadas configurações otimizadas:
```json
{
  "config": {
    "runtime": "python3.12",      // Especifica versão Python
    "maxLambdaSize": "50mb"        // Aumenta limite de tamanho
  },
  "functions": {
    "api/index.py": {
      "memory": 3008,               // Máxima memória disponível
      "maxDuration": 60             // Timeout de 60 segundos
    }
  }
}
```

### 4. ✅ Criado `api/requirements-minimal.txt`

Versão alternativa com especificações de versão mais flexíveis (>=):
```
fastapi>=0.109.0
uvicorn>=0.27.0
pandas>=2.2.0
numpy>=1.26.0
...
```

### 5. ✅ Criado `prepare-deploy.sh`

Script automatizado para preparar o projeto para deploy:
- Verifica estrutura do projeto
- Instala dependências Node
- Builda o frontend
- Verifica arquivos essenciais
- Limpa cache da Vercel
- Mostra checklist de deploy

### 6. ✅ Criado `TROUBLESHOOTING_DEPLOY.md`

Guia completo de troubleshooting com:
- Explicação do problema original
- Soluções aplicadas
- Como fazer deploy
- Alternativas se ainda houver problemas
- Checklist de verificação
- Recursos úteis

---

## 🚀 Como Proceder Agora

### Opção 1: Script Automatizado (Mais Fácil)
```bash
./prepare-deploy.sh
vercel --prod
```

### Opção 2: Passo a Passo Manual

1. **Build do Frontend:**
```bash
npm install
npm run build
```

2. **Deploy:**
```bash
vercel --prod
```

3. **Ou via Git:**
```bash
git add .
git commit -m "fix: corrigir dependências para deploy Vercel"
git push origin main
```

---

## ⚙️ Configurações Necessárias na Vercel

Certifique-se de que as seguintes variáveis de ambiente estão configuradas no dashboard da Vercel:

1. **GROQ_API_KEY** ⭐ (obrigatória)
   - Sua chave da API Groq
   - Obtenha em: https://console.groq.com/

2. **CORS_ORIGINS**
   - URLs permitidas para CORS
   - Exemplo: `https://seu-projeto.vercel.app,https://www.seu-projeto.vercel.app`

3. **MONGO_URL** (opcional)
   - URL de conexão MongoDB
   - Deixe vazio se não usar banco

4. **DB_NAME** (opcional)
   - Nome do banco de dados
   - Padrão: `agente_eda_db`

### Como Configurar:
1. Acesse: https://vercel.com/dashboard
2. Selecione seu projeto
3. Vá em **Settings** → **Environment Variables**
4. Adicione cada variável
5. Salve e faça um novo deploy

---

## 🔍 Verificação de Sucesso

Após o deploy, verifique:

1. ✅ Build completado sem erros
2. ✅ API respondendo: `https://seu-projeto.vercel.app/api/`
3. ✅ Documentação disponível: `https://seu-projeto.vercel.app/docs`
4. ✅ Frontend carregando: `https://seu-projeto.vercel.app`
5. ✅ Upload de CSV funcionando
6. ✅ Chat com IA respondendo

---

## 🆘 Se Ainda Houver Problemas

### Problema 1: Erro de Dependências Persiste

**Solução A:** Use versões flexíveis
```bash
cp api/requirements-minimal.txt api/requirements.txt
vercel --prod
```

**Solução B:** Use versões sem fixação
```bash
cp api/requirements-simple.txt api/requirements.txt
vercel --prod
```

### Problema 2: Timeout na API

**Solução:** Já configurado `maxDuration: 60` no `vercel.json`.  
Se ainda houver timeout, considere otimizar o código ou usar Vercel Pro.

### Problema 3: Erro de CORS

**Solução:** Configure `CORS_ORIGINS` com todos os domínios:
```env
CORS_ORIGINS=https://seu-projeto.vercel.app,https://seu-projeto-git-main.vercel.app,https://seu-projeto-*.vercel.app
```

### Problema 4: API não encontrada (404)

**Solução:** Verifique se:
- `api/index.py` existe
- `vercel.json` tem as rotas configuradas
- Build foi bem-sucedido

---

## 📚 Arquivos Criados/Modificados

### Modificados:
- ✏️ `api/requirements.txt` - Versões atualizadas
- ✏️ `vercel.json` - Configurações otimizadas

### Criados:
- 📄 `runtime.txt` - Especifica Python 3.12
- 📄 `api/requirements-minimal.txt` - Versões flexíveis (backup)
- 📄 `prepare-deploy.sh` - Script de preparação
- 📄 `TROUBLESHOOTING_DEPLOY.md` - Guia de troubleshooting
- 📄 `MUDANCAS_DEPLOY_FIX.md` - Este arquivo

---

## 📊 Comparação Antes vs Depois

| Aspecto | Antes | Depois |
|---------|-------|--------|
| pandas | 2.0.3 (antiga) | 2.2.0 (atualizada) |
| numpy | 1.24.3 (incompatível Python 3.12) | 1.26.4 (compatível) |
| Runtime Python | Não especificado | 3.12.0 (explícito) |
| Memória Lambda | Padrão (1024MB) | 3008MB (máximo) |
| Timeout | Padrão (10s) | 60s |
| Build Automation | Manual | Script automatizado |
| Documentação Deploy | Básica | Completa + Troubleshooting |

---

## ✅ Checklist Final

Antes de fazer deploy, confirme:

- [ ] ✅ Dependências atualizadas em `api/requirements.txt`
- [ ] ✅ `runtime.txt` criado
- [ ] ✅ `vercel.json` configurado
- [ ] ✅ Frontend buildado (`npm run build`)
- [ ] ✅ Pasta `build/` existe e tem conteúdo
- [ ] ✅ Variáveis de ambiente configuradas na Vercel
- [ ] ✅ `.vercel` cache limpo (se houver)
- [ ] ✅ Testado localmente (opcional mas recomendado)

---

## 🎯 Resultado Esperado

Após seguir estas mudanças, o deploy deve:

1. ✅ Instalar todas as dependências sem erros
2. ✅ Buildar o frontend corretamente
3. ✅ Inicializar a API FastAPI
4. ✅ Responder nas rotas `/api/*`
5. ✅ Servir o frontend em `/`
6. ✅ Funcionar completamente sem erros

---

**✨ Boa sorte com o deploy!**

Se precisar de mais ajuda, consulte:
- `TROUBLESHOOTING_DEPLOY.md` - Guia detalhado de problemas
- `DEPLOY_VERCEL.md` - Guia original de deploy
- [Documentação Vercel Python](https://vercel.com/docs/functions/serverless-functions/runtimes/python)

