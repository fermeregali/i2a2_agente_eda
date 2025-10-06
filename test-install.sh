#!/bin/bash

# Script para testar se a instalação foi bem-sucedida

echo "🧪 Testando Instalação..."
echo "========================"
echo ""

EXIT_CODE=0

# Testar Python
echo "🐍 Testando Python..."
if command -v python3 &> /dev/null; then
    echo "   ✅ Python: $(python3 --version)"
else
    echo "   ❌ Python não encontrado"
    EXIT_CODE=1
fi

# Testar ambiente virtual
echo ""
echo "📦 Testando ambiente virtual..."
if [ -d "venv" ]; then
    echo "   ✅ Diretório venv/ existe"
    
    # Ativar e testar
    source venv/bin/activate
    
    # Testar pacotes Python
    echo "   Testando pacotes Python..."
    
    packages=("fastapi" "uvicorn" "pandas" "numpy" "pymongo" "groq")
    for package in "${packages[@]}"; do
        if python -c "import $package" 2>/dev/null; then
            echo "      ✅ $package"
        else
            echo "      ❌ $package não instalado"
            EXIT_CODE=1
        fi
    done
    
    deactivate
else
    echo "   ❌ Ambiente virtual não encontrado"
    EXIT_CODE=1
fi

# Testar Node.js
echo ""
echo "📦 Testando Node.js..."
if command -v node &> /dev/null; then
    echo "   ✅ Node: $(node --version)"
    echo "   ✅ npm: $(npm --version)"
else
    echo "   ❌ Node.js não encontrado"
    EXIT_CODE=1
fi

# Testar node_modules
echo ""
echo "📚 Testando dependências Node.js..."
if [ -d "node_modules" ]; then
    echo "   ✅ Diretório node_modules/ existe"
    
    # Verificar pacotes essenciais
    packages=("react" "axios" "react-scripts")
    for package in "${packages[@]}"; do
        if [ -d "node_modules/$package" ]; then
            echo "      ✅ $package"
        else
            echo "      ❌ $package não instalado"
            EXIT_CODE=1
        fi
    done
else
    echo "   ❌ node_modules não encontrado"
    EXIT_CODE=1
fi

# Testar .env
echo ""
echo "⚙️  Testando configuração..."
if [ -f ".env" ]; then
    echo "   ✅ Arquivo .env existe"
    
    if grep -q "GROQ_API_KEY=sua_chave_groq_aqui" .env; then
        echo "   ⚠️  GROQ_API_KEY ainda não foi configurada"
    else
        echo "   ✅ GROQ_API_KEY configurada"
    fi
else
    echo "   ❌ Arquivo .env não encontrado"
    EXIT_CODE=1
fi

# Testar estrutura de diretórios
echo ""
echo "📁 Testando estrutura do projeto..."
dirs=("api" "src" "public")
for dir in "${dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo "   ✅ $dir/"
    else
        echo "   ❌ $dir/ não encontrado"
        EXIT_CODE=1
    fi
done

echo ""
echo "========================"
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Todos os testes passaram!"
    echo ""
    echo "🚀 Sistema pronto para uso!"
    echo ""
    echo "Para iniciar:"
    echo "  ./run.sh"
else
    echo "❌ Alguns testes falharam"
    echo ""
    echo "Tente reinstalar:"
    echo "  ./install-fix.sh"
    echo ""
    echo "Ou consulte: TROUBLESHOOTING_INSTALACAO.md"
fi

echo ""
exit $EXIT_CODE

