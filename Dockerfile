# Dockerfile para Railway - Backend Python/FastAPI APENAS
# Ignora completamente o frontend React

FROM python:3.11-slim

# Definir diretório de trabalho
WORKDIR /app

# Copiar apenas arquivos do backend
COPY api/ ./api/
COPY requirements.txt .

# Instalar dependências
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Expor porta (Railway define $PORT dinamicamente)
EXPOSE 8000

# Comando de start
CMD uvicorn api.index:app --host 0.0.0.0 --port $PORT
