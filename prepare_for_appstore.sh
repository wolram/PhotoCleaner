#!/bin/bash

# Script para preparar Snap Sieve para publicação na App Store
# Autor: Claude Code
# Data: 2026-01-19

set -e

echo "🚀 Preparando Snap Sieve para App Store..."
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para verificar requisitos
check_requirement() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 encontrado"
        return 0
    else
        echo -e "${RED}✗${NC} $1 não encontrado"
        return 1
    fi
}

# Verificar requisitos
echo -e "${BLUE}Verificando requisitos...${NC}"
check_requirement xcodebuild
check_requirement plutil
echo ""

# Verificar se tem Team ID configurado
echo -e "${BLUE}Verificando configuração...${NC}"
TEAM_ID=$(grep "DEVELOPMENT_TEAM:" project.yml | cut -d'"' -f2)

if [ -z "$TEAM_ID" ] || [ "$TEAM_ID" = "" ]; then
    echo -e "${YELLOW}⚠${NC} Team ID não configurado!"
    echo ""
    echo "Para publicar na App Store, você precisa:"
    echo "1. Ter uma conta Apple Developer ativa (\$99/ano)"
    echo "2. Adicionar seu Team ID no arquivo project.yml"
    echo ""
    echo "Como encontrar seu Team ID:"
    echo "1. Abra Xcode > Settings > Accounts"
    echo "2. Selecione sua conta Apple Developer"
    echo "3. Copie o Team ID (ex: ABC123XYZ4)"
    echo "4. Edite project.yml e substitua DEVELOPMENT_TEAM: \"\" por DEVELOPMENT_TEAM: \"SEU_TEAM_ID\""
    echo ""
    echo -e "${RED}Encerrando. Configure o Team ID e execute novamente.${NC}"
    exit 1
else
    echo -e "${GREEN}✓${NC} Team ID configurado: $TEAM_ID"
fi

# Verificar Info.plist
echo ""
echo -e "${BLUE}Verificando Info.plist...${NC}"
if plutil -lint PhotoCleaner/Info.plist > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Info.plist válido"

    # Verificar permissões
    if grep -q "NSPhotoLibraryUsageDescription" PhotoCleaner/Info.plist; then
        echo -e "${GREEN}✓${NC} Permissão NSPhotoLibraryUsageDescription presente"
    else
        echo -e "${RED}✗${NC} Faltando NSPhotoLibraryUsageDescription"
    fi

    if grep -q "NSPhotoLibraryAddUsageDescription" PhotoCleaner/Info.plist; then
        echo -e "${GREEN}✓${NC} Permissão NSPhotoLibraryAddUsageDescription presente"
    else
        echo -e "${RED}✗${NC} Faltando NSPhotoLibraryAddUsageDescription"
    fi
else
    echo -e "${RED}✗${NC} Info.plist inválido"
    exit 1
fi

# Verificar entitlements
echo ""
echo -e "${BLUE}Verificando entitlements...${NC}"
if plutil -lint PhotoCleaner/SnapSieve.entitlements > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Entitlements válido"
else
    echo -e "${RED}✗${NC} Entitlements inválido"
    exit 1
fi

# Verificar ícone
echo ""
echo -e "${BLUE}Verificando ícone do app...${NC}"
ICON_COUNT=$(find PhotoCleaner/Resources/Assets.xcassets/AppIcon.appiconset -name "*.png" | wc -l | tr -d ' ')
if [ "$ICON_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} $ICON_COUNT arquivos de ícone encontrados"
else
    echo -e "${YELLOW}⚠${NC} Nenhum ícone encontrado"
    echo "  Você precisa adicionar ícones do app antes de publicar"
fi

# Verificar versão
echo ""
echo -e "${BLUE}Verificando versão...${NC}"
VERSION=$(grep "CFBundleShortVersionString" PhotoCleaner/Info.plist -A1 | grep string | sed 's/.*<string>\(.*\)<\/string>/\1/')
BUILD=$(grep "CFBundleVersion" PhotoCleaner/Info.plist -A1 | grep string | sed 's/.*<string>\(.*\)<\/string>/\1/')
echo -e "${GREEN}✓${NC} Versão: $VERSION (Build $BUILD)"

# Checklist
echo ""
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}    CHECKLIST PRÉ-PUBLICAÇÃO${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo ""
echo "Antes de fazer o archive, verifique:"
echo ""
echo "[ ] Tenho Apple Developer Account ativo (\$99/ano)"
echo "[ ] Team ID configurado no project.yml"
echo "[ ] App testado completamente e funcionando"
echo "[ ] Tenho 3-5 screenshots em 2560x1600px"
echo "[ ] Hospedei a Privacy Policy online (URL disponível)"
echo "[ ] Tenho URL de suporte (site/GitHub)"
echo "[ ] Li o guia completo: GUIA_PUBLICACAO_APP_STORE.md"
echo ""
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo ""

# Opção para criar archive
echo -e "${YELLOW}Deseja criar o archive agora? (y/n)${NC}"
read -r response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo ""
    echo -e "${BLUE}Regenerando projeto...${NC}"
    ./generate_project.sh

    echo ""
    echo -e "${BLUE}Limpando build anterior...${NC}"
    rm -rf build/
    mkdir -p build

    echo ""
    echo -e "${BLUE}Criando archive...${NC}"
    echo "Isso pode levar alguns minutos..."

    xcodebuild -scheme SnapSieve \
        -configuration Release \
        -archivePath ./build/SnapSieve.xcarchive \
        archive \
        | grep -E "^\*\*|error:|warning:|succeeded|failed" || true

    if [ -d "./build/SnapSieve.xcarchive" ]; then
        echo ""
        echo -e "${GREEN}✓ Archive criado com sucesso!${NC}"
        echo ""
        echo "Próximos passos:"
        echo "1. Abra o Xcode Organizer:"
        echo "   Window > Organizer (⌘⌥⇧O)"
        echo ""
        echo "2. Selecione o archive 'SnapSieve'"
        echo ""
        echo "3. Clique em 'Distribute App'"
        echo ""
        echo "4. Siga o assistente para fazer upload"
        echo ""
        echo "Consulte: GUIA_PUBLICACAO_APP_STORE.md para detalhes"

        # Abrir Organizer automaticamente
        echo ""
        echo -e "${YELLOW}Deseja abrir o Xcode Organizer agora? (y/n)${NC}"
        read -r open_response

        if [[ "$open_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            open -a Xcode
            sleep 2
            osascript -e 'tell application "System Events" to keystroke "o" using {command down, option down, shift down}'
        fi
    else
        echo ""
        echo -e "${RED}✗ Falha ao criar archive${NC}"
        echo "Verifique os erros acima e tente novamente"
        exit 1
    fi
else
    echo ""
    echo "Ok! Quando estiver pronto, você pode:"
    echo ""
    echo "1. Executar este script novamente, ou"
    echo "2. Criar o archive manualmente:"
    echo "   - Abra SnapSieve.xcodeproj no Xcode"
    echo "   - Product > Archive"
    echo ""
    echo "Consulte: GUIA_PUBLICACAO_APP_STORE.md"
fi

echo ""
echo -e "${GREEN}✓ Preparação concluída!${NC}"
echo ""
