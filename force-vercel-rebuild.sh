#!/bin/bash

# Script para forçar rebuild limpo na Vercel
# Isso resolve o problema de cache da Vercel usar versão antiga

set -e

echo "🔄 Forçando Rebuild Limpo na Vercel"
echo "===================================="
echo ""

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar se estamos no diretório correto
if [ ! -f "api/index.py" ]; then
    echo -e "${RED}❌ Erro: Execute este script no diretório raiz do projeto!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Diretório correto${NC}"
echo ""

# Verificar branch
CURRENT_BRANCH=$(git branch --show-current)
echo -e "📍 Branch atual: ${YELLOW}$CURRENT_BRANCH${NC}"
echo ""

# Verificar se há mudanças não commitadas
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo -e "${YELLOW}⚠️  Há mudanças não commitadas!${NC}"
    echo "Deseja fazer commit primeiro? (s/n)"
    read -r response
    if [[ "$response" =~ ^[Ss]$ ]]; then
        echo "Digite a mensagem do commit:"
        read -r commit_msg
        git add .
        git commit -m "$commit_msg"
        echo -e "${GREEN}✅ Commit feito${NC}"
    fi
fi
echo ""

# Verificar se Mangum está no requirements
echo -e "🔍 Verificando se Mangum está no requirements.txt..."
if grep -q "mangum" api/requirements.txt; then
    echo -e "${GREEN}✅ Mangum encontrado no requirements.txt${NC}"
else
    echo -e "${RED}❌ Mangum NÃO encontrado no requirements.txt!${NC}"
    echo "Adicionando mangum..."
    echo "mangum==0.17.0" >> api/requirements.txt
    git add api/requirements.txt
    git commit -m "fix: adiciona mangum ao requirements.txt"
    echo -e "${GREEN}✅ Mangum adicionado e commitado${NC}"
fi
echo ""

# Verificar se Mangum está no código
echo -e "🔍 Verificando se Mangum está no código..."
if grep -q "from mangum import Mangum" api/index.py; then
    echo -e "${GREEN}✅ Mangum encontrado no código${NC}"
else
    echo -e "${RED}❌ Mangum NÃO encontrado no código!${NC}"
    echo "Verifique o arquivo api/index.py"
    exit 1
fi
echo ""

# Fazer commit vazio para forçar rebuild
echo -e "${YELLOW}📝 Criando commit vazio para forçar rebuild...${NC}"
git commit --allow-empty -m "chore: force vercel rebuild with mangum handler"
echo -e "${GREEN}✅ Commit vazio criado${NC}"
echo ""

# Push
echo -e "${YELLOW}🚀 Enviando para GitHub...${NC}"
git push origin "$CURRENT_BRANCH"
echo -e "${GREEN}✅ Push concluído!${NC}"
echo ""

# Informações finais
echo "================================================"
echo -e "${GREEN}🎉 Deploy iniciado na Vercel!${NC}"
echo "================================================"
echo ""
echo -e "${YELLOW}⏳ Aguarde 2-3 minutos para o build completar${NC}"
echo ""
echo "📋 Próximos passos:"
echo ""
echo "1. Acesse: https://vercel.com/dashboard"
echo "   - Verifique o status do deployment"
echo "   - Veja os logs de build"
echo ""
echo "2. Verifique as variáveis de ambiente:"
echo "   - Settings → Environment Variables"
echo "   - GROQ_API_KEY = gsk_..."
echo "   - USE_MONGODB = true"
echo "   - MONGO_URL = mongodb+srv://..."
echo "   - DB_NAME = agente_eda_db"
echo "   - CORS_ORIGINS = *"
echo ""
echo "3. Após o deploy, teste:"
echo "   - Acesse sua URL da Vercel"
echo "   - Tente fazer upload de um CSV"
echo "   - Verifique os logs (F12 no browser)"
echo ""
echo "4. Ver logs da Vercel:"
echo "   - Na dashboard: Deployments → Selecione o último → Functions → Logs"
echo ""
echo -e "${GREEN}✅ Script concluído com sucesso!${NC}"
echo ""
echo "⏰ Aguardando deploy... (isso pode levar alguns minutos)"
echo ""

