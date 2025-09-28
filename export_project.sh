#!/bin/bash

# Script para exportar o projeto sem arquivos Git
# Cria uma cópia limpa do projeto para versionamento em outro repositório

PROJECT_NAME="agente-EDA"
EXPORT_DIR="../${PROJECT_NAME}-export-$(date +%Y%m%d-%H%M%S)"

echo "🚀 Iniciando exportação do projeto..."
echo "📁 Diretório de destino: $EXPORT_DIR"

# Criar diretório de exportação
mkdir -p "$EXPORT_DIR"

# Copiar todos os arquivos exceto .git e arquivos relacionados
echo "📋 Copiando arquivos do projeto..."

# Usar rsync para excluir arquivos Git
rsync -av --progress \
  --exclude='.git' \
  --exclude='.gitignore' \
  --exclude='.gitattributes' \
  --exclude='node_modules' \
  --exclude='__pycache__' \
  --exclude='*.pyc' \
  --exclude='.pytest_cache' \
  --exclude='.coverage' \
  --exclude='.env' \
  --exclude='*.log' \
  --exclude='.DS_Store' \
  --exclude='Thumbs.db' \
  ./ "$EXPORT_DIR/"

# Criar um novo .gitignore básico para o projeto exportado
echo "📝 Criando .gitignore para o projeto exportado..."
cat > "$EXPORT_DIR/.gitignore" << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Virtual Environment
venv/
env/
ENV/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Node modules (se houver)
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Coverage reports
htmlcov/
.coverage
.coverage.*
coverage.xml
*.cover
.hypothesis/
.pytest_cache/

# Jupyter Notebook
.ipynb_checkpoints

# pyenv
.python-version

# pipenv
Pipfile.lock

# PEP 582
__pypackages__/

# Celery
celerybeat-schedule
celerybeat.pid

# SageMath parsed files
*.sage.py

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Spyder project settings
.spyderproject
.spyproject

# Rope project settings
.ropeproject

# mkdocs documentation
/site

# mypy
.mypy_cache/
.dmypy.json
dmypy.json
EOF

# Criar um README de exportação
echo "📖 Criando README de exportação..."
cat > "$EXPORT_DIR/EXPORT_INFO.md" << EOF
# Informações da Exportação

Este projeto foi exportado em: $(date)

## Como usar este projeto exportado

1. Inicialize um novo repositório Git:
   \`\`\`bash
   git init
   git add .
   git commit -m "Initial commit"
   \`\`\`

2. Conecte a um repositório remoto:
   \`\`\`bash
   git remote add origin <URL_DO_SEU_REPOSITORIO>
   git branch -M main
   git push -u origin main
   \`\`\`

3. Instale as dependências:
   \`\`\`bash
   # Para Python
   pip install -r requirements.txt
   
   # Para Node.js (se aplicável)
   npm install
   \`\`\`

## Arquivos excluídos da exportação

- .git/ (histórico do Git)
- .gitignore (substituído por um novo)
- .gitattributes
- node_modules/
- __pycache__/
- Arquivos temporários e de cache

## Próximos passos

1. Revise o .gitignore criado e ajuste conforme necessário
2. Configure suas variáveis de ambiente
3. Teste a instalação e execução do projeto
4. Faça o commit inicial no novo repositório
EOF

echo "✅ Exportação concluída!"
echo "📁 Projeto exportado para: $EXPORT_DIR"
echo ""
echo "📋 Resumo dos arquivos exportados:"
ls -la "$EXPORT_DIR"

echo ""
echo "🔧 Para usar o projeto exportado:"
echo "1. cd $EXPORT_DIR"
echo "2. git init"
echo "3. git add ."
echo "4. git commit -m 'Initial commit'"
echo "5. Conecte ao seu repositório remoto"
