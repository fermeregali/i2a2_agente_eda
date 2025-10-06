# ✅ Checklist Final - Deploy na Vercel

## 🎯 Status Atual

### ✅ Ações Completadas:
- ✅ Código do Mangum adicionado ao `api/index.py`
- ✅ Mangum adicionado ao `api/requirements.txt`
- ✅ Mangum adicionado ao `api/requirements-vercel.txt`
- ✅ Commit feito: `710900f - chore: force vercel rebuild with mangum handler`
- ✅ Push enviado para GitHub (`b_deploy_vercel`)
- ✅ Deploy automático iniciado na Vercel

### ⏳ Aguardando:
- ⏳ Build da Vercel completar (2-3 minutos)
- ⏳ Deploy em produção

## 📋 Próximos Passos (VOCÊ precisa fazer)

### 1. ⚠️ CONFIGURAR VARIÁVEIS DE AMBIENTE (CRÍTICO!)

**Acesse:** https://vercel.com/dashboard

1. Selecione seu projeto
2. Vá em: **Settings** → **Environment Variables**
3. Adicione estas variáveis:

| Variável | Valor | Environment |
|----------|-------|-------------|
| `GROQ_API_KEY` | Sua chave GROQ (veja config.env) | Production + Preview |
| `USE_MONGODB` | `true` | Production + Preview |
| `MONGO_URL` | Sua URL do MongoDB Atlas | Production + Preview |
| `DB_NAME` | `agente_eda_db` | Production + Preview |
| `CORS_ORIGINS` | `*` | Production + Preview |

⚠️ **IMPORTANTE:** Se não configurar essas variáveis, o app ainda vai dar erro!

### 2. 🔍 Verificar o Deployment

1. Acesse: https://vercel.com/dashboard
2. Vá para: **Deployments**
3. Verifique se o último deployment está:
   - ✅ **Building...** (aguarde)
   - ✅ **Ready** (sucesso!)
   - ❌ **Error** (veja os logs)

### 3. 📊 Verificar Logs de Build

1. Clique no último deployment
2. Vá para: **Building**
3. Procure por:
   ```
   ✅ Installing mangum==0.17.0
   ✅ Successfully installed mangum-0.17.0
   ```

### 4. 🧪 Testar a Aplicação

Após o deployment estar **Ready**:

1. **Acesse sua URL:**
   ```
   https://agente-bxhwa5tvy-fernandos-projects-b413208d.vercel.app
   ```

2. **Abra o Console do Browser (F12)** e verifique:
   ```javascript
   🔧 Configuração da Aplicação:
     - Ambiente: production
     - API URL: https://agente-bxhwa5tvy...vercel.app
     - Origin: https://agente-bxhwa5tvy...vercel.app
     - Backend URL: não definida ← ISSO É NORMAL!
   ```

3. **Tente fazer upload de um CSV**
   - Arraste um arquivo .csv
   - Aguarde o processamento
   - **Se funcionar:** ✅ Sucesso!
   - **Se erro 500:** ❌ Veja os logs da função

### 5. 📋 Ver Logs da Função (se ainda houver erro)

1. Acesse: https://vercel.com/dashboard
2. Vá para: **Deployments** → Último deployment
3. Clique em: **Functions**
4. Selecione: `api/index.py`
5. Veja os logs

**Logs esperados (SUCESSO):**
```
INFO: ✅ PyMongo disponível - MongoDB habilitado
INFO: CORS configurado para aceitar todas as origens (*)
INFO: 🔌 Conectando ao MongoDB...
INFO: ✅ MongoDB conectado! Banco: agente_eda_db
INFO: 📊 Sessão abc-123 salva no MongoDB
INFO: ✅ Análise da IA concluída
```

**Logs de erro comuns:**

❌ **"No module named 'mangum'"**
- Solução: Verificar se `mangum==0.17.0` está no requirements.txt
- Fazer novo commit e push

❌ **"groq.RateLimitError" ou "Invalid API key"**
- Solução: Verificar GROQ_API_KEY nas variáveis de ambiente
- Conferir se a chave está correta

❌ **"pymongo.errors.ServerSelectionTimeoutError"**
- Solução: Verificar MONGO_URL
- Conferir se o IP da Vercel está liberado no MongoDB Atlas (use 0.0.0.0/0)

❌ **"CORS policy"**
- Solução: Adicionar CORS_ORIGINS=* nas variáveis de ambiente

## 🎯 Troubleshooting

### Se ainda der erro 500:

#### Opção A: Redeploy via Dashboard
1. Dashboard Vercel → Deployments
2. Clique nos 3 pontinhos do último deployment
3. Selecione "Redeploy"
4. **DESMARQUE** "Use existing Build Cache"
5. Clique em "Redeploy"

#### Opção B: Verificar se está no branch correto
```bash
cd /home/fernandomx/projects/course-ai/agente-EDA-export-20250928-204101

# Ver branch atual
git branch --show-current

# Se não estiver no b_deploy_vercel:
git checkout b_deploy_vercel
git pull origin b_deploy_vercel
```

#### Opção C: Verificar se Mangum foi instalado
1. Dashboard Vercel → último deployment
2. Building → procure por "Installing mangum"
3. Se não aparecer: requirements.txt pode estar errado

## 📞 Suporte

### Arquivos de Ajuda:
- `SOLUCAO_FINAL_ERRO_500.md` - Guia completo do problema
- `CORRECAO_ERRO_500.md` - Explicação técnica do Mangum
- `CONFIGURAR_MONGODB_VERCEL.md` - Como configurar MongoDB

### Comandos Úteis:
```bash
# Ver último commit
git log -1

# Ver requirements
cat api/requirements.txt | grep mangum

# Ver código do handler
grep -A 5 "Handler para Vercel" api/index.py

# Forçar novo rebuild
./force-vercel-rebuild.sh
```

## ✅ Checklist de Verificação

Execute este checklist AGORA:

- [ ] 1. Variáveis de ambiente configuradas na Vercel
  - [ ] GROQ_API_KEY
  - [ ] USE_MONGODB
  - [ ] MONGO_URL
  - [ ] DB_NAME
  - [ ] CORS_ORIGINS

- [ ] 2. Deployment está "Ready" na Vercel

- [ ] 3. Logs de build mostram "Installing mangum"

- [ ] 4. Acessei a URL e a página carrega

- [ ] 5. Console do browser não mostra erros críticos

- [ ] 6. Upload de CSV funciona sem erro 500

- [ ] 7. Análise da IA é executada

- [ ] 8. Resultados aparecem na tela

## 🎉 Quando Tudo Funcionar

Após confirmar que tudo funciona:

### 1. Fazer merge para main (opcional)
```bash
git checkout main
git merge b_deploy_vercel
git push origin main
```

### 2. Configurar CORS específico
Mude `CORS_ORIGINS` de `*` para sua URL específica:
```
CORS_ORIGINS=https://agente-bxhwa5tvy-fernandos-projects-b413208d.vercel.app
```

### 3. Monitorar uso
- Ver logs: Dashboard Vercel → Functions → Logs
- Ver métricas: Dashboard Vercel → Analytics

### 4. Documentar
- Atualizar README.md com a URL de produção
- Adicionar screenshots do app funcionando

## 📊 Tempo Estimado

- ⏰ Deploy completar: **2-3 minutos**
- ⏰ Configurar variáveis: **5 minutos**
- ⏰ Testes: **5 minutos**
- **TOTAL: ~10-15 minutos**

---

**Data:** 06/10/2025 às 10:43
**Último Commit:** `710900f - chore: force vercel rebuild with mangum handler`
**Branch:** `b_deploy_vercel`
**Status Deploy:** ⏳ Em andamento

**Próxima Ação:** CONFIGURAR VARIÁVEIS DE AMBIENTE NA VERCEL! ⚠️

