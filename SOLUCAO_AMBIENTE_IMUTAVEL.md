# 🔧 Solução: Erro de Ambiente Imutável no Railway

## ❌ Erro Encontrado:

```
error: externally-managed-environment

× This environment is externally managed
╰─> This command has been disabled as it tries to modify the immutable
    `/nix/store` filesystem.
```

---

## 🔍 Causa Raiz:

O **Railway usa NixOS/Nixpacks**, onde o sistema de arquivos Python (`/nix/store`) é **imutável** por design. 

Tentávamos fazer:
```bash
pip install -r requirements.txt  # ❌ Não funciona!
```

Isso tentava modificar o filesystem imutável, causando o erro.

---

## ✅ Solução Implementada:

### **Criar Virtual Environment Python**

Em vez de instalar diretamente no sistema, criamos um **ambiente virtual isolado** (`venv`) que é mutável:

```toml
[phases.install]
cmds = [
  "python -m venv /opt/venv",                                    # Criar venv
  ". /opt/venv/bin/activate && pip install --upgrade pip",      # Atualizar pip
  ". /opt/venv/bin/activate && pip install -r requirements.txt" # Instalar deps
]

[start]
cmd = ". /opt/venv/bin/activate && uvicorn api.index:app --host 0.0.0.0 --port $PORT"
```

### **Fluxo do Build:**

```
1. [SETUP] 
   └─> Instala Python 3.11 do Nix

2. [INSTALL]
   ├─> Cria venv em /opt/venv (mutável ✅)
   ├─> Ativa venv
   ├─> Atualiza pip
   └─> Instala todas as dependências no venv

3. [START]
   ├─> Ativa venv
   └─> Inicia uvicorn
```

---

## 📝 Arquivos Modificados:

### 1. **`nixpacks.toml`** ✏️
- Adicionada criação de venv
- Instalação de dependências dentro do venv
- Start command ativa venv antes de executar

### 2. **`Procfile`** ✏️
- Removido `pip install` do comando de start
- Apenas `uvicorn` (venv é ativado pelo nixpacks.toml)

### 3. **`railway.json`** ✏️
- Removido `buildCommand` redundante
- Deixar Nixpacks gerenciar o build automaticamente

---

## 🚀 Próximos Passos:

### 1. **Railway Iniciou Novo Deploy** ✅

O push foi feito com sucesso. Railway está fazendo redeploy agora.

### 2. **Monitorar Build Logs**

No Railway Dashboard, você deve ver:

```bash
✅ [setup] Installing Python 3.11...
✅ [install] Creating virtual environment...
✅ [install] Installing dependencies in venv...
   Successfully installed fastapi-0.109.2 uvicorn-0.27.1 pandas-2.2.0...
✅ [start] Activating venv and starting server...
✅ INFO: Started server process
✅ INFO: Uvicorn running on http://0.0.0.0:XXXX
```

### 3. **Verificar Deploy Bem-Sucedido**

Quando o deploy finalizar:
- Status deve ser: **"Active"** (verde)
- Você receberá uma URL: `https://seu-projeto.railway.app`

### 4. **Testar Backend**

```bash
curl https://seu-projeto.railway.app/api/health

# Resposta esperada:
{
  "status": "ok",
  "timestamp": "...",
  "active_sessions": 0,
  "mongodb_connected": true/false
}
```

---

## 🔗 Conectar com Frontend (Amplify)

Depois do backend funcionando:

1. **Copie a URL do Railway**
   ```
   https://seu-projeto-production.up.railway.app
   ```

2. **AWS Amplify Console**
   - Vá em **Environment variables**
   - Adicione:
     - **Key**: `REACT_APP_BACKEND_URL`
     - **Value**: (URL do Railway)
   - Salve

3. **Aguarde Redeploy do Amplify** (~2 min)

4. **Teste a Aplicação Completa**
   - Acesse o Amplify
   - Faça upload de um CSV
   - ✅ Deve funcionar!

---

## 📊 Histórico de Erros Resolvidos:

| # | Erro | Causa | Solução |
|---|------|-------|---------|
| 1 | `uvicorn: command not found` | Dependências não instaladas | ✅ Criar `requirements.txt` na raiz |
| 2 | `externally-managed-environment` | Tentativa de modificar `/nix/store` | ✅ Usar virtual environment |

---

## 🆘 Se Ainda Der Erro:

### Erro: "Cannot create venv"

**Solução**: Simplificar nixpacks.toml para detecção automática:
```bash
# Deletar nixpacks.toml e deixar Railway detectar automaticamente
rm nixpacks.toml
git commit -m "Remove nixpacks.toml para usar detecção automática"
git push
```

### Erro: "Module not found" em runtime

**Solução**: Verificar se todas as dependências estão em `requirements.txt`:
```bash
cat requirements.txt
# Deve conter: fastapi, uvicorn, pandas, numpy, groq, pymongo, etc.
```

### Erro: "Port binding failed"

**Solução**: O Railway define `$PORT` automaticamente. Não force porta 8000.

---

## 🎯 Status Atual:

- ✅ Push realizado com sucesso
- ⏳ **Railway redeploy em andamento**
- ⏳ Aguardando backend funcionar
- ⏳ Configurar Amplify depois

---

## 📚 Referências:

- [Railway Nixpacks Docs](https://nixpacks.com/docs)
- [Python Virtual Environments](https://docs.python.org/3/library/venv.html)
- [NixOS Philosophy](https://nixos.org/manual/nix/stable/)

---

**Aguarde mais 2-3 minutos para o deploy completar!** 🚀

O erro de ambiente imutável está resolvido. Agora deve funcionar! ✨
