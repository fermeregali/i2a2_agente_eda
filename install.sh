#!/bin/bash

# Script de instalação do Agente de Análise Exploratória de Dados
# Desenvolvido para atividade acadêmica de Agentes Autônomos

echo "🤖 Instalando Agente de Análise Exploratória de Dados..."
echo "=============================================="

# Verificar se Python está instalado
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 não está instalado. Por favor, instale Python 3.8+ primeiro."
    exit 1
fi

# Verificar se Node.js está instalado
if ! command -v node &> /dev/null; then
    echo "❌ Node.js não está instalado. Por favor, instale Node.js 16+ primeiro."
    exit 1
fi

echo "✅ Pré-requisitos verificados"

# Criar ambiente virtual Python
echo "📦 Criando ambiente virtual Python..."
python3 -m venv venv

# Ativar ambiente virtual
echo "🔧 Ativando ambiente virtual..."
source venv/bin/activate

# Instalar dependências Python
echo "📚 Instalando dependências Python..."
pip install --upgrade pip
pip install -r requirements.txt

# Instalar dependências Node.js
echo "📚 Instalando dependências Node.js..."
npm install

# Criar arquivo .env se não existir
if [ ! -f .env ]; then
    echo "⚙️ Criando arquivo de configuração..."
    cp config.env .env
    echo "✅ Arquivo .env criado com configurações padrão"
fi

echo ""
echo "🎉 Instalação concluída com sucesso!"
echo ""
echo "Para executar o sistema:"
echo "1. Backend (Terminal 1):"
echo "   source venv/bin/activate"
echo "   python main.py"
echo ""
echo "2. Frontend (Terminal 2):"
echo "   npm start"
echo ""
echo "3. Acesse: http://localhost:3000"
echo ""
echo "📊 Sistema pronto para análise de dados!"
