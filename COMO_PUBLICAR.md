# 🚀 Como Publicar no App Store - Guia Prático

## ✅ Validação Completa

O build está funcionando perfeitamente! Agora vamos publicar.

## 📋 Pré-requisitos

- ✅ Team ID configurado (ZTT8S9QUXR)
- ✅ Apple ID configurado (marlow.dsds@gmail.com)
- ✅ Build validado e funcionando
- ⏳ Screenshots necessários (mínimo 3)
- ⏳ Política de Privacidade hospedada online

## 🎯 Opção 1: Via Xcode (Recomendado)

Esta é a forma mais simples e confiável para primeira publicação.

### Passo 1: Abrir o Projeto

```bash
cd /Users/macbook/Documents/GitHub/PhotoCleaner
fastlane mac archive
```

Ou manualmente:
```bash
open SnapSieve.xcodeproj
```

### Passo 2: Configurar Assinatura

No Xcode:
1. Selecione o projeto "SnapSieve" no navegador
2. Selecione o target "SnapSieve"
3. Vá na aba "Signing & Capabilities"
4. Verifique:
   - Team: Marlow Sousa (ZTT8S9QUXR)
   - Signing Certificate: Automatic (ou selecione "Apple Distribution")

### Passo 3: Criar Archive

1. No menu do Xcode: **Product > Archive**
2. Aguarde o build completar (2-3 minutos)
3. O Organizer abrirá automaticamente

### Passo 4: Distribuir

No Organizer:
1. Selecione o archive "SnapSieve"
2. Clique em **"Distribute App"**
3. Selecione **"App Store Connect"**
4. Clique **"Upload"**
5. Opções recomendadas:
   - ✅ Upload your app's symbols
   - ✅ Manage Version and Build Number (Automatically)
6. Clique **"Next"** e siga o assistente
7. Aguarde o upload completar (10-30 minutos)

### Passo 5: Preparar na App Store Connect

1. Acesse: https://appstoreconnect.apple.com
2. Vá em "My Apps"
3. Clique no "+" para criar novo app:
   - Platform: macOS
   - Name: Snap Sieve
   - Primary Language: Portuguese (Brazil)
   - Bundle ID: com.marlowsousa.snapsieve
   - SKU: snapsieve-001
4. Preencha as informações básicas

### Passo 6: Aguardar Processamento

1. No App Store Connect, vá em "Activity"
2. O build aparecerá com status "Processing"
3. Aguarde 15-60 minutos até mudar para "Ready"

### Passo 7: Adicionar Build à Versão

1. Volte para a versão 1.0 do app
2. Role até "Build"
3. Clique no "+"
4. Selecione o build processado
5. Clique "Done"

### Passo 8: Preencher Metadata

Use os arquivos criados:
- Nome: Snap Sieve - Organize Suas Fotos
- Subtítulo: Limpe e organize sua biblioteca
- Descrição: (copie de `fastlane/metadata/pt-BR/description.txt`)
- Keywords: fotos,duplicadas,limpeza,organizar,espaço,similar,qualidade
- Screenshots: Adicione no mínimo 3 (2560x1600px)
- Privacy URL: Hospede primeiro no GitHub Pages
- Support URL: https://github.com/wolram/PhotoCleaner

### Passo 9: Submeter para Revisão

1. Verifique que tudo está preenchido
2. Clique em "Add for Review"
3. Clique em "Submit for Review"
4. Aguarde aprovação (24-48h)

## 🎯 Opção 2: Via Fastlane (Automático)

Se você tem certificado Apple Distribution instalado:

```bash
# Fazer release completo
fastlane mac release

# Ou apenas upload de metadata
fastlane mac metadata
```

## 📸 Como Tirar Screenshots

### Requisitos
- Resolução: 2560x1600px
- Formato: PNG
- Mínimo: 3 screenshots

### Passos

1. **Rode o app:**
```bash
open SnapSieve.xcodeproj
# Pressione ⌘R no Xcode
```

2. **Capture as telas importantes:**
   - Tela principal (sidebar + overview)
   - Resultados da análise (stats)
   - Duplicados (grid de fotos)
   - Modo Peneira (comparação)
   - Estatísticas (gráficos)

3. **Tire os screenshots:**
   - Pressione ⇧⌘5 (Shift+Command+5)
   - Ou ⇧⌘4 e selecione a janela

4. **Salve em:**
```bash
/Users/macbook/Documents/GitHub/PhotoCleaner/fastlane/screenshots/
```

5. **Verifique a resolução:**
```bash
sips -g pixelWidth -g pixelHeight screenshot.png
```

6. **Redimensionar se necessário:**
```bash
sips -z 1600 2560 screenshot.png --out screenshot_final.png
```

## 🔐 Hospedar Política de Privacidade

A política precisa estar em uma URL pública.

### Opção A: GitHub Pages (Grátis)

```bash
cd /Users/macbook/Documents/GitHub/PhotoCleaner

# 1. Criar branch gh-pages
git checkout -b gh-pages

# 2. Copiar política
cp PhotoCleaner/App/PRIVACY_POLICY.md index.md

# 3. Commit e push
git add index.md
git commit -m "Add privacy policy for App Store"
git push origin gh-pages

# 4. Voltar para main
git checkout main
```

Depois:
1. Vá em: https://github.com/wolram/PhotoCleaner/settings/pages
2. Ative GitHub Pages com source "gh-pages"
3. A URL será: https://wolram.github.io/PhotoCleaner/

4. Atualize a URL:
```bash
echo "https://wolram.github.io/PhotoCleaner/" > fastlane/metadata/pt-BR/privacy_url.txt
```

### Opção B: Seu Site Pessoal

Se você tem um site, hospede lá e atualize a URL.

## 🐛 Problemas Comuns

### "No Signing Identity Found"
**Solução:**
1. Abra Xcode > Settings > Accounts
2. Adicione sua conta Apple Developer
3. Clique em "Manage Certificates"
4. Adicione "Apple Distribution"

### "Build is Invalid"
**Solução:**
- Verifique se o Team ID está correto no project.yml
- Limpe: Product > Clean Build Folder
- Archive novamente

### "Missing Privacy Policy"
**Solução:**
- Hospede a política online (GitHub Pages)
- Adicione a URL no App Store Connect

### "Screenshots Required"
**Solução:**
- Tire pelo menos 3 screenshots em 2560x1600px
- Adicione no App Store Connect

## ✅ Checklist Final

Antes de submeter:

- [ ] Screenshots adicionados (mínimo 3)
- [ ] Política de privacidade hospedada online
- [ ] URL de privacidade adicionada no App Store Connect
- [ ] Build processado e selecionado
- [ ] Descrição preenchida
- [ ] Keywords configuradas
- [ ] Categoria selecionada (Utilities)
- [ ] Preço definido (ou grátis)
- [ ] Support URL adicionada
- [ ] Copyright preenchido
- [ ] Rating Information preenchido

## 🎉 Próximos Passos

Após aprovação:
1. Compartilhe nas redes sociais
2. Peça reviews de usuários
3. Responda todos os reviews
4. Planeje atualizações futuras

---

**Boa sorte com a publicação!** 🚀

Se tiver dúvidas:
- Guia completo: `GUIA_PUBLICACAO_APP_STORE.md`
- Fastlane: `fastlane/README.md`
- App Store Connect: https://appstoreconnect.apple.com
