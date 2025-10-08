# 🚀 Como Usar o Agente EDA

## 📖 Guia Rápido

### **Para Testar Localmente**

```bash
# Terminal 1 - Backend
chmod +x start-backend.sh
./start-backend.sh

# Terminal 2 - Frontend  
chmod +x start-frontend.sh
./start-frontend.sh
```

Acesse: **http://localhost:3000**

📚 **Guia completo**: Veja `TEST_LOCAL.md`

---

### **Para Deploy em Produção**

#### **Frontend (AWS Amplify)**
📚 Veja: `DEPLOY_AWS_AMPLIFY.md`

#### **Backend (Railway)**
1. Push código para GitHub
2. Crie projeto no Railway
3. Conecte repositório
4. Configure variáveis de ambiente
5. Deploy automático!

---

## 📁 Arquivos Importantes

| Arquivo | Descrição |
|---------|-----------|
| `start-backend.sh` | Inicia backend local |
| `start-frontend.sh` | Inicia frontend local |
| `TEST_LOCAL.md` | Guia detalhado de testes |
| `DEPLOY_AWS_AMPLIFY.md` | Deploy no Amplify |
| `README.md` | Documentação completa |
| `config.env.example` | Template de configuração |

---

## ⚙️ Configuração Mínima

Crie `config.env`:

```bash
GROQ_API_KEY=sua_chave_aqui    # Obrigatório
USE_MONGODB=false               # Opcional
CORS_ORIGINS=*                  # Desenvolvimento
```

Obtenha a chave em: https://console.groq.com

---

## 🎯 Uso da Aplicação

1. **Upload CSV** - Arraste ou selecione arquivo
2. **Análise Automática** - IA analisa os dados
3. **Chat** - Faça perguntas sobre os dados
4. **Visualizações** - Gráficos interativos automáticos

---

## 🆘 Problemas?

- Backend não inicia → Veja `TEST_LOCAL.md`
- Deploy falhou → Verifique variáveis de ambiente
- Erro de IA → Confirme `GROQ_API_KEY`

---

**Mais informações**: `README.md` e `TEST_LOCAL.md`

