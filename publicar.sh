#!/bin/bash

# Script de publicação automática do SnapSieve
# Executa todo o processo de build e upload para App Store

set -e

echo "🚀 PUBLICAÇÃO AUTOMÁTICA DO SNAPSIEVE"
echo "======================================"
echo ""

# Verificar se está no diretório correto
if [ ! -f "fastlane/Fastfile" ]; then
    echo "❌ Erro: Execute este script na raiz do projeto"
    exit 1
fi

# Verificar se .env existe
if [ ! -f ".env" ]; then
    echo "❌ Erro: Arquivo .env não encontrado"
    echo "💡 Configure suas credenciais em .env"
    exit 1
fi

# Carregar variáveis do .env
source .env

# Verificar credenciais
if [ -z "$TEAM_ID" ] || [ -z "$FASTLANE_USER" ]; then
    echo "❌ Erro: TEAM_ID ou FASTLANE_USER não configurados no .env"
    exit 1
fi

echo "✅ Credenciais configuradas:"
echo "   Team ID: $TEAM_ID"
echo "   Apple ID: $FASTLANE_USER"
echo ""

# Verificar se o app já foi criado no App Store Connect
echo "⚠️  IMPORTANTE: Antes de publicar, você precisa criar o app no App Store Connect"
echo ""
echo "Já criou o app 'Snap Sieve' no App Store Connect?"
read -p "Digite 's' se já criou, ou 'n' se ainda não criou: " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
    echo ""
    echo "📱 Primeiro, vamos criar o app no App Store Connect"
    echo ""
    echo "Execute este comando:"
    echo ""
    echo "   ./criar_app.sh"
    echo ""
    echo "Depois volte e execute este script novamente."
    exit 0
fi

echo ""
# Perguntar se quer continuar
read -p "🤔 Deseja continuar com a publicação? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Publicação cancelada"
    exit 0
fi

echo ""
echo "📦 Iniciando processo de publicação..."
echo ""

# Executar fastlane
cd fastlane
fastlane mac publish

echo ""
echo "🎉 PROCESSO CONCLUÍDO!"
echo ""
echo "📋 Próximos passos:"
echo "1. Acesse: https://appstoreconnect.apple.com"
echo "2. Aguarde o build processar (15-60 min)"
echo "3. Adicione o build à versão 1.0"
echo "4. Preencha informações restantes (se necessário)"
echo "5. Clique em 'Submit for Review'"
echo ""
