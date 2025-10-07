#!/bin/bash
# Script para iniciar a aplicação no Render.com

echo "🚀 Iniciando Agente EDA API..."

# Carregar variáveis de ambiente do config.env se existir
if [ -f config.env ]; then
    export $(cat config.env | grep -v '^#' | xargs)
fi

# Iniciar servidor com uvicorn
cd api
exec uvicorn index:app --host 0.0.0.0 --port ${PORT:-8000}



