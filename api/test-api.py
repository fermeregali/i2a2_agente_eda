"""
Teste simples da API para verificar se as variáveis de ambiente estão funcionando
"""

import os
from dotenv import load_dotenv

# Carregar variáveis de ambiente
load_dotenv()

print("🔍 Testando carregamento de variáveis de ambiente...")
print("=" * 50)

# Verificar se as variáveis estão carregadas
groq_key = os.getenv("GROQ_API_KEY")
mongo_url = os.getenv("MONGO_URL")
db_name = os.getenv("DB_NAME")
cors_origins = os.getenv("CORS_ORIGINS")

print(f"GROQ_API_KEY: {'✅ Carregada' if groq_key else '❌ Não encontrada'}")
if groq_key:
    print(f"  Valor: {groq_key[:10]}...")

print(f"MONGO_URL: {'✅ Carregada' if mongo_url else '❌ Não encontrada'}")
if mongo_url:
    print(f"  Valor: {mongo_url}")

print(f"DB_NAME: {'✅ Carregada' if db_name else '❌ Não encontrada'}")
if db_name:
    print(f"  Valor: {db_name}")

print(f"CORS_ORIGINS: {'✅ Carregada' if cors_origins else '❌ Não encontrada'}")
if cors_origins:
    print(f"  Valor: {cors_origins}")

print("=" * 50)

if groq_key:
    print("🎉 Todas as variáveis estão carregadas corretamente!")
    print("✅ A API deve funcionar sem problemas.")
else:
    print("❌ Problema encontrado! Verifique o arquivo .env")
