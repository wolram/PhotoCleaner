#!/bin/bash

# Script para criar o app no App Store Connect
# Este é um guia interativo

set -e

echo "📱 CRIAR APP NO APP STORE CONNECT"
echo "================================="
echo ""
echo "Vamos criar o app SnapSieve na App Store!"
echo ""

# Carregar variáveis
if [ -f ".env" ]; then
    source .env
fi

echo "📋 Informações do App:"
echo ""
echo "   Nome: Snap Sieve"
echo "   Bundle ID: com.marlowsousa.snapsieve"
echo "   SKU: snapsieve-001"
echo "   Idioma: Portuguese (Brazil)"
echo "   Plataforma: macOS"
echo ""
echo "   Sua Apple ID: ${FASTLANE_USER:-[configure no .env]}"
echo "   Team ID: ${TEAM_ID:-[configure no .env]}"
echo ""

echo "🌐 Vou abrir o App Store Connect no navegador..."
echo ""
sleep 2

# Abrir App Store Connect
open "https://appstoreconnect.apple.com/apps"

echo "✅ App Store Connect aberto!"
echo ""
echo "📝 SIGA ESTES PASSOS:"
echo ""
echo "1️⃣  Faça login com: ${FASTLANE_USER:-seu Apple ID}"
echo ""
echo "2️⃣  Clique no botão '+' (canto superior esquerdo)"
echo ""
echo "3️⃣  Selecione 'New App'"
echo ""
echo "4️⃣  Preencha o formulário:"
echo "    • Platform: macOS"
echo "    • Name: Snap Sieve"
echo "    • Primary Language: Portuguese (Brazil)"
echo "    • Bundle ID: com.marlowsousa.snapsieve"
echo "    • SKU: snapsieve-001"
echo "    • User Access: Full Access"
echo ""
echo "5️⃣  Clique em 'Create'"
echo ""
echo "6️⃣  Aguarde o app ser criado (alguns segundos)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
read -p "✅ Criou o app? Pressione ENTER quando terminar..."
echo ""
echo "🎉 Ótimo! Agora você pode fazer upload do build."
echo ""
echo "📦 Próximo passo: Execute o script de publicação"
echo ""
echo "   ./publicar.sh"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
