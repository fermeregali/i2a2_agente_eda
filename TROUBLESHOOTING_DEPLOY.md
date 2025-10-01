# Troubleshooting - Deploy Vercel

## Problema Resolvido: Erro de Instalação de Dependências

### ❌ Erro Original
```
Command failed: pip3.12 install --disable-pip-version-check --no-compile --no-cache-dir --target _vendor --upgrade -r /vercel/path0/api/requirements.txt
ERROR: Exception: Traceback (most recent call last)...
```

### ✅ Solução Aplicada

#### 1. Atualizadas as Dependências (api/requirements.txt)
Versões antigas que causavam conflitos foram atualizadas para versões compatíveis com Python 3.12:

**Antes:**
- pandas==2.0.3 → **Agora:** pandas==2.2.0
- numpy==1.24.3 → **Agora:** numpy==1.26.4
- fastapi==0.104.1 → **Agora:** fastapi==0.109.2
- uvicorn[standard]==0.24.0 → **Agora:** uvicorn==0.27.1
- pydantic==2.5.0 → **Agora:** pydantic==2.6.1
- groq==0.4.1 → **Agora:** groq==0.4.2

#### 2. Adicionado runtime.txt
Arquivo criado na raiz do projeto especificando a versão do Python:
```
python-3.12.0
```

#### 3. Atualizado vercel.json
Adicionadas configurações otimizadas:
```json
{
  "version": 2,
  "builds": [
    {
      "src": "api/index.py",
      "use": "@vercel/python",
      "config": {
        "maxLambdaSize": "50mb"
      }
    }
  ]
}
```

**Nota:** Removida a propriedade `functions` pois não pode ser usada junto com `builds`.

#### 4. Criado requirements-minimal.txt (Plano B)
Caso ainda tenha problemas, você pode usar versões mais flexíveis.

---

## Como Fazer o Deploy Agora

### Opção 1: Deploy via CLI (Recomendado)

```bash
# 1. Limpar cache local se houver
rm -rf .vercel

# 2. Fazer o deploy
vercel

# 3. Se funcionar, fazer deploy de produção
vercel --prod
```

### Opção 2: Deploy via GitHub

1. **Commit as mudanças:**
```bash
git add .
git commit -m "fix: atualizar dependências para compatibilidade com Vercel"
git push origin main
```

2. **A Vercel fará o deploy automaticamente**
   - O webhook do GitHub acionará o build
   - Você pode acompanhar em: https://vercel.com/dashboard

### Opção 3: Deploy Manual no Dashboard

1. Acesse https://vercel.com/dashboard
2. Selecione seu projeto
3. Vá em "Deployments"
4. Clique em "Redeploy" no último deployment

---

## Problemas Conhecidos e Soluções

### ❌ Erro: "functions property cannot be used with builds property"

**Causa:** A Vercel não permite usar `functions` e `builds` juntos no `vercel.json`.

**Solução:** ✅ **JÁ CORRIGIDO** - Removida a propriedade `functions` do `vercel.json`.

Se você editou manualmente o arquivo, certifique-se de que ele **não** contenha a propriedade `functions` quando usar `builds`.

---

## Se Ainda Houver Problemas

### Alternativa 1: Usar Versões Flexíveis
Se o erro persistir, substitua o conteúdo de `api/requirements.txt` pelo conteúdo de `api/requirements-minimal.txt`:

```bash
cp api/requirements-minimal.txt api/requirements.txt
```

### Alternativa 2: Versões Simplificadas
Use o `api/requirements-simple.txt` (sem versões fixas):

```bash
cp api/requirements-simple.txt api/requirements.txt
```

### Alternativa 3: Verificar Logs Detalhados
```bash
# Ver logs do último deploy
vercel logs

# Ver logs em tempo real
vercel logs --follow
```

### Alternativa 4: Build Local para Testar
```bash
# Testar se as dependências instalam localmente
cd api
python3.12 -m venv test_env
source test_env/bin/activate  # No Linux/Mac
# ou: test_env\Scripts\activate  # No Windows
pip install -r requirements.txt

# Se funcionar localmente, o problema pode ser específico da Vercel
```

---

## Checklist de Verificação

Antes de fazer deploy, verifique:

- [ ] ✅ Versões das dependências atualizadas
- [ ] ✅ runtime.txt criado
- [ ] ✅ vercel.json configurado
- [ ] ✅ Variáveis de ambiente configuradas na Vercel:
  - `GROQ_API_KEY`
  - `CORS_ORIGINS`
  - `MONGO_URL` (opcional)
  - `DB_NAME` (opcional)
- [ ] ✅ Build do frontend executado: `npm run build`
- [ ] ✅ Pasta `build/` existe e tem conteúdo

---

## Variáveis de Ambiente na Vercel

Configure no Dashboard da Vercel (Settings → Environment Variables):

```env
GROQ_API_KEY=sua_chave_aqui
CORS_ORIGINS=https://seu-projeto.vercel.app
MONGO_URL=sua_conexão_mongodb (opcional)
DB_NAME=agente_eda_db (opcional)
```

⚠️ **IMPORTANTE:** Após adicionar/modificar variáveis de ambiente, é necessário fazer um novo deploy!

---

## Recursos Úteis

- [Vercel Python Runtime Docs](https://vercel.com/docs/functions/serverless-functions/runtimes/python)
- [Vercel Build Configuration](https://vercel.com/docs/build-step)
- [FastAPI on Vercel](https://vercel.com/guides/deploying-fastapi-with-vercel)

---

## Contato e Suporte

Se o problema persistir após seguir este guia:

1. Verifique os logs detalhados do deploy na Vercel
2. Copie a mensagem de erro completa
3. Verifique se todas as variáveis de ambiente estão configuradas
4. Teste o build localmente

**Data da Última Atualização:** 01/10/2025

