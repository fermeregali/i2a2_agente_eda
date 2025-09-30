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

# Verificar e ajustar limite de file watchers (solução para erro ENOSPC)
echo "🔧 Verificando limite de file watchers..."
CURRENT_LIMIT=$(cat /proc/sys/fs/inotify/max_user_watches 2>/dev/null || echo "8192")
if [ "$CURRENT_LIMIT" -lt 524288 ]; then
    echo "⚠️ Limite de file watchers muito baixo ($CURRENT_LIMIT). Ajustando..."
    echo "💡 Para resolver permanentemente, execute:"
    echo "   echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf"
    echo "   sudo sysctl -p"
    echo ""
    echo "🔄 Tentando ajuste temporário..."
    if command -v sudo &> /dev/null; then
        sudo sysctl fs.inotify.max_user_watches=524288 2>/dev/null || echo "⚠️ Não foi possível ajustar automaticamente"
    else
        echo "⚠️ sudo não disponível. Execute manualmente:"
        echo "   sudo sysctl fs.inotify.max_user_watches=524288"
    fi
else
    echo "✅ Limite de file watchers adequado ($CURRENT_LIMIT)"
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
