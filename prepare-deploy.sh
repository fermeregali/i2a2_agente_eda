#!/bin/bash
# Script para preparar o projeto para deploy na Vercel

echo "🚀 Preparando projeto para deploy na Vercel..."
echo ""

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 1. Verificar se está na raiz do projeto
if [ ! -f "vercel.json" ]; then
    echo -e "${RED}❌ Erro: vercel.json não encontrado. Execute este script na raiz do projeto.${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Arquivo vercel.json encontrado"

# 2. Verificar dependências do Node
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}⚠${NC} node_modules não encontrado. Instalando dependências..."
    npm install
else
    echo -e "${GREEN}✓${NC} node_modules encontrado"
fi

# 3. Build do frontend
echo ""
echo "📦 Buildando o frontend..."
npm run build

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Build do frontend concluído com sucesso"
else
    echo -e "${RED}❌ Erro no build do frontend${NC}"
    exit 1
fi

# 4. Verificar se build/ existe
if [ -d "build" ] && [ "$(ls -A build)" ]; then
    echo -e "${GREEN}✓${NC} Pasta build/ criada e populada"
else
    echo -e "${RED}❌ Erro: Pasta build/ vazia ou não encontrada${NC}"
    exit 1
fi

# 5. Verificar arquivos Python essenciais
if [ ! -f "api/index.py" ]; then
    echo -e "${RED}❌ Erro: api/index.py não encontrado${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} api/index.py encontrado"

if [ ! -f "api/requirements.txt" ]; then
    echo -e "${RED}❌ Erro: api/requirements.txt não encontrado${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} api/requirements.txt encontrado"

# 6. Verificar runtime.txt
if [ ! -f "runtime.txt" ]; then
    echo -e "${YELLOW}⚠${NC} runtime.txt não encontrado. Criando..."
    echo "python-3.12.0" > runtime.txt
fi
echo -e "${GREEN}✓${NC} runtime.txt configurado"

# 7. Limpar cache da Vercel se existir
if [ -d ".vercel" ]; then
    echo ""
    echo "🧹 Limpando cache da Vercel..."
    rm -rf .vercel
    echo -e "${GREEN}✓${NC} Cache da Vercel limpo"
fi

# 8. Mostrar resumo
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Projeto preparado para deploy!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Checklist:"
echo -e "${GREEN}✓${NC} Frontend buildado (build/)"
echo -e "${GREEN}✓${NC} API configurada (api/index.py)"
echo -e "${GREEN}✓${NC} Dependências atualizadas (api/requirements.txt)"
echo -e "${GREEN}✓${NC} Runtime Python configurado (runtime.txt)"
echo -e "${GREEN}✓${NC} Configuração Vercel (vercel.json)"
echo ""
echo "⚠️  IMPORTANTE: Verifique se as variáveis de ambiente estão configuradas na Vercel:"
echo "   - GROQ_API_KEY"
echo "   - CORS_ORIGINS"
echo ""
echo "Para fazer o deploy, execute:"
echo -e "${YELLOW}vercel${NC}                  # Deploy de preview"
echo -e "${YELLOW}vercel --prod${NC}           # Deploy de produção"
echo ""
echo "Ou faça commit e push para o GitHub para deploy automático:"
echo -e "${YELLOW}git add .${NC}"
echo -e "${YELLOW}git commit -m 'fix: preparar para deploy'${NC}"
echo -e "${YELLOW}git push origin main${NC}"
echo ""

