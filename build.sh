#!/bin/bash
# Build script para Render.com

echo "🚀 Iniciando build do backend..."
cd api
pip install -r requirements.txt
cd ..

echo "✅ Build concluído!"



