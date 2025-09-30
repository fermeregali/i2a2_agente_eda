#!/bin/bash

# Script para resolver erro de file watchers (ENOSPC)
# Execute este script se você estiver enfrentando o erro:
# "Error: ENOSPC: System limit for number of file watchers reached"

echo "🔧 Resolvendo problema de file watchers..."
echo "=========================================="

# Verificar limite atual
CURRENT_LIMIT=$(cat /proc/sys/fs/inotify/max_user_watches 2>/dev/null || echo "8192")
echo "📊 Limite atual: $CURRENT_LIMIT"

if [ "$CURRENT_LIMIT" -lt 524288 ]; then
    echo "⚠️ Limite muito baixo! Ajustando..."
    
    # Tentar ajuste temporário
    echo "🔄 Aplicando ajuste temporário..."
    if command -v sudo &> /dev/null; then
        if sudo sysctl fs.inotify.max_user_watches=524288; then
            echo "✅ Ajuste temporário aplicado com sucesso!"
        else
            echo "❌ Falha ao aplicar ajuste temporário"
        fi
    else
        echo "⚠️ sudo não disponível. Execute manualmente:"
        echo "   sudo sysctl fs.inotify.max_user_watches=524288"
    fi
    
    # Configurar permanente
    echo ""
    echo "🔧 Para tornar o ajuste permanente, execute:"
    echo "   echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf"
    echo "   sudo sysctl -p"
    echo ""
    echo "💡 Ou execute os comandos abaixo:"
    echo "   sudo bash -c 'echo fs.inotify.max_user_watches=524288 >> /etc/sysctl.conf'"
    echo "   sudo sysctl -p"
    
else
    echo "✅ Limite já está adequado ($CURRENT_LIMIT)"
fi

echo ""
echo "🎉 Problema resolvido! Agora você pode executar:"
echo "   npm start"
echo ""
echo "📝 Se o problema persistir, reinicie o terminal e tente novamente."
