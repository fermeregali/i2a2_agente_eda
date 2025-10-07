# 🚀 Guia de Deploy na AWS Amplify

## Pré-requisitos

- [ ] Conta AWS ativa
- [ ] Repositório Git (GitHub, GitLab ou Bitbucket)
- [ ] Chave API do Groq ([console.groq.com](https://console.groq.com))
- [ ] MongoDB Atlas configurado (opcional, mas recomendado)

## 📋 Passo a Passo

### 1. Preparar o Repositório

```bash
# Inicializar Git (se ainda não foi feito)
git init

# Adicionar todos os arquivos
git add .

# Fazer commit
git commit -m "Preparado para deploy na AWS Amplify"

# Adicionar repositório remoto
git remote add origin https://github.com/seu-usuario/seu-repo.git

# Push para repositório
git push -u origin main
```

### 2. Configurar MongoDB Atlas (Recomendado)

1. Acesse [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Crie um cluster gratuito
3. Configure Network Access:
   - Adicione IP: `0.0.0.0/0` (permitir todos - produção ajuste conforme necessário)
4. Crie um usuário no Database Access
5. Copie a Connection String no formato:
   ```
   mongodb+srv://<username>:<password>@cluster.mongodb.net/?retryWrites=true&w=majority
   ```

### 3. Obter Chave API da Groq

1. Acesse [console.groq.com](https://console.groq.com)
2. Faça login ou crie uma conta
3. Vá para "API Keys"
4. Crie uma nova chave
5. Copie e guarde em local seguro

### 4. Deploy na AWS Amplify

#### 4.1. Criar Aplicação

1. Acesse o [AWS Amplify Console](https://console.aws.amazon.com/amplify/)
2. Clique em **"New app"** > **"Host web app"**
3. Selecione seu provedor Git (GitHub, GitLab, etc.)
4. Autorize o acesso ao repositório
5. Selecione o repositório e a branch (geralmente `main`)

#### 4.2. Configurar Build

1. O Amplify detectará automaticamente o `amplify.yml`
2. Verifique se as configurações estão corretas:
   - **App name**: nome da sua aplicação
   - **Environment**: `production`
   - **Branch**: `main`

#### 4.3. Configurar Variáveis de Ambiente

No console do Amplify, vá para **"Environment variables"** e adicione:

| Variável | Valor | Descrição |
|----------|-------|-----------|
| `USE_MONGODB` | `true` | Habilitar MongoDB |
| `MONGO_URL` | `mongodb+srv://...` | URL de conexão do MongoDB Atlas |
| `DB_NAME` | `agente_eda_db` | Nome do banco de dados |
| `CORS_ORIGINS` | `*` | Permitir todos (ajuste em produção) |
| `GROQ_API_KEY` | `gsk_...` | Sua chave API da Groq |

**Importante**: Marque `GROQ_API_KEY` e `MONGO_URL` como **secret** para maior segurança.

#### 4.4. Revisar e Deploy

1. Revise todas as configurações
2. Clique em **"Save and deploy"**
3. Aguarde o build (pode levar 5-10 minutos)
4. Após o deploy, você receberá uma URL no formato:
   ```
   https://main.d1234567890.amplifyapp.com
   ```

### 5. Verificar Deploy

1. Acesse a URL fornecida
2. Teste o upload de um CSV
3. Teste o chat com a IA
4. Verifique se as visualizações estão funcionando

## 🔧 Configurações Avançadas

### Custom Domain

1. No console do Amplify, vá para **"Domain management"**
2. Clique em **"Add domain"**
3. Siga as instruções para configurar seu domínio

### Monitoramento

1. **CloudWatch Logs**: Acompanhe logs da aplicação
2. **Metrics**: Monitore uso e performance
3. **Alarms**: Configure alertas

### CI/CD Automático

O Amplify configura automaticamente CI/CD:
- Push para `main` → Deploy automático
- Pull requests → Preview deployments

## 🐛 Troubleshooting

### Erro: Build failed

**Problema**: Build falha durante instalação de dependências

**Solução**:
```yaml
# Verifique o amplify.yml
# Certifique-se de que todos os comandos estão corretos
```

### Erro: CORS

**Problema**: Frontend não consegue acessar API

**Solução**:
1. Verifique `CORS_ORIGINS` nas variáveis de ambiente
2. Ou use `*` para permitir todas as origens (desenvolvimento)
3. Em produção, configure com domínio específico:
   ```
   CORS_ORIGINS=https://main.d1234567890.amplifyapp.com
   ```

### Erro: MongoDB Connection

**Problema**: Não consegue conectar ao MongoDB

**Solução**:
1. Verifique a string de conexão `MONGO_URL`
2. Confirme que o IP `0.0.0.0/0` está permitido no Network Access
3. Verifique usuário e senha do banco
4. Teste a conexão localmente primeiro

### Erro: Groq API

**Problema**: Análises da IA não funcionam

**Solução**:
1. Verifique se `GROQ_API_KEY` está correta
2. Confirme que a chave está ativa no console Groq
3. Verifique limites de uso da API

## 📊 Monitoramento de Custos

### AWS Amplify

- **Tier Gratuito**: 1000 minutos de build/mês
- **Hosting**: 15 GB armazenado/mês
- **Data Transfer**: 15 GB servidos/mês

### MongoDB Atlas

- **Tier Gratuito**: 512 MB de armazenamento
- Suficiente para testes e uso moderado

### Groq API

- Verifique limites no console Groq
- Configure rate limiting se necessário

## 🔐 Segurança

### Boas Práticas

1. **Nunca commitar** `config.env` com credenciais
2. Use variáveis de ambiente do Amplify para secrets
3. Configure CORS adequadamente em produção
4. Rotacione chaves API periodicamente
5. Configure Network Access do MongoDB com IPs específicos em produção

### Checklist de Segurança

- [ ] `config.env` está no `.gitignore`
- [ ] Variáveis sensíveis marcadas como secret no Amplify
- [ ] CORS configurado adequadamente
- [ ] MongoDB com autenticação habilitada
- [ ] Rate limiting configurado (se aplicável)

## 📚 Recursos Adicionais

- [Documentação AWS Amplify](https://docs.amplify.aws/)
- [Documentação MongoDB Atlas](https://docs.atlas.mongodb.com/)
- [Documentação Groq API](https://console.groq.com/docs)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [React Documentation](https://react.dev/)

## 🆘 Suporte

Se encontrar problemas:

1. Verifique os logs no AWS Amplify Console
2. Consulte a documentação oficial
3. Abra uma issue no repositório
4. Entre em contato com o suporte AWS

---

**Boa sorte com seu deploy! 🚀**

