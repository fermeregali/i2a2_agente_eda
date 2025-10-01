#!/bin/bash

# Script para corrigir e fazer deploy na Vercel
# Desenvolvido para resolver problemas de CORS e variáveis de ambiente

set -e  # Parar em caso de erro

echo "🚀 Script de Deploy - Agente EDA"
echo "================================"
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para printar com cor
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# 1. Verificar se o Vercel CLI está instalado
print_status "Verificando Vercel CLI..."
if ! command -v vercel &> /dev/null; then
    print_error "Vercel CLI não encontrado!"
    echo "Instale com: npm install -g vercel"
    exit 1
fi
print_success "Vercel CLI instalado"

# 2. Verificar se o Node.js está instalado
print_status "Verificando Node.js..."
if ! command -v node &> /dev/null; then
    print_error "Node.js não encontrado!"
    exit 1
fi
print_success "Node.js $(node --version) instalado"

# 3. Verificar se o npm está instalado
print_status "Verificando npm..."
if ! command -v npm &> /dev/null; then
    print_error "npm não encontrado!"
    exit 1
fi
print_success "npm $(npm --version) instalado"

# 4. Verificar se node_modules existe
print_status "Verificando dependências do frontend..."
if [ ! -d "node_modules" ]; then
    print_warning "node_modules não encontrado. Instalando dependências..."
    npm install
    print_success "Dependências instaladas"
else
    print_success "Dependências do frontend OK"
fi

# 5. Fazer build do frontend
print_status "Fazendo build do frontend..."
if npm run build; then
    print_success "Build do frontend concluído"
else
    print_error "Erro ao fazer build do frontend"
    exit 1
fi

# 6. Verificar se a pasta build foi criada
print_status "Verificando pasta build..."
if [ ! -d "build" ]; then
    print_error "Pasta build não foi criada!"
    exit 1
fi

# Verificar se a pasta build tem conteúdo
if [ -z "$(ls -A build)" ]; then
    print_error "Pasta build está vazia!"
    exit 1
fi
print_success "Pasta build OK ($(du -sh build | cut -f1))"

# 7. Verificar arquivos necessários
print_status "Verificando arquivos necessários..."

required_files=(
    "vercel.json"
    "package.json"
    "api/index.py"
    "runtime.txt"
)

for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        print_error "Arquivo necessário não encontrado: $file"
        exit 1
    fi
done
print_success "Todos os arquivos necessários estão presentes"

# 8. Verificar se há arquivo de requirements
print_status "Verificando requirements do Python..."
if [ ! -f "api/requirements.txt" ]; then
    print_error "api/requirements.txt não encontrado!"
    exit 1
fi
print_success "api/requirements.txt encontrado"

# 9. Limpar cache da Vercel
print_status "Limpando cache da Vercel..."
if [ -d ".vercel" ]; then
    rm -rf .vercel
    print_success "Cache limpo"
else
    print_success "Sem cache para limpar"
fi

# 10. Verificar variáveis de ambiente
print_status "Verificando variáveis de ambiente..."
echo ""
print_warning "IMPORTANTE: Configure as seguintes variáveis na Vercel:"
echo "  1. GROQ_API_KEY"
echo "  2. CORS_ORIGINS (configure como: *)"
echo "  3. MONGO_URL (opcional)"
echo "  4. DB_NAME (opcional)"
echo ""
echo "Configure em: https://vercel.com/dashboard → Seu Projeto → Settings → Environment Variables"
echo ""

read -p "As variáveis de ambiente estão configuradas na Vercel? (s/n): " confirm
if [[ $confirm != [sS] ]]; then
    print_warning "Configure as variáveis de ambiente antes de continuar!"
    echo "Para configurar via CLI:"
    echo "  vercel env add GROQ_API_KEY"
    echo "  vercel env add CORS_ORIGINS"
    exit 0
fi

# 11. Fazer deploy
print_status "Iniciando deploy na Vercel..."
echo ""
print_warning "Escolha o tipo de deploy:"
echo "  1. Deploy de preview (teste)"
echo "  2. Deploy de produção"
echo ""
read -p "Escolha (1 ou 2): " deploy_type

case $deploy_type in
    1)
        print_status "Fazendo deploy de preview..."
        vercel
        ;;
    2)
        print_status "Fazendo deploy de produção..."
        vercel --prod
        ;;
    *)
        print_error "Opção inválida!"
        exit 1
        ;;
esac

echo ""
print_success "Deploy concluído!"
echo ""
print_status "Próximos passos:"
echo "  1. Abra o console do navegador (F12)"
echo "  2. Vá para a aba Console e Network"
echo "  3. Tente fazer upload de um arquivo CSV"
echo "  4. Verifique os logs no console"
echo ""
print_status "Para ver logs da Vercel:"
echo "  vercel logs"
echo "  vercel logs --follow"
echo ""
print_success "✨ Tudo pronto!"

