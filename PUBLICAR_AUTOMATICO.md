# 🚀 Publicação Automática - 100% Automatizada

## ✅ Tudo Pronto!

Seu projeto está **100% configurado** para publicação automática.

## 🎯 Publicar com 1 Comando

```bash
./publicar.sh
```

**É só isso!** O script vai:

1. ✅ Verificar credenciais
2. ✅ Gerar projeto Xcode
3. ✅ Criar screenshots de placeholder (se necessário)
4. ✅ Fazer build de release
5. ✅ Criar archive
6. ✅ Exportar para PKG
7. ✅ Upload para App Store Connect
8. ✅ Enviar metadata e screenshots

## 📋 O que foi configurado

- ✅ **Team ID:** ZTT8S9QUXR
- ✅ **Apple ID:** marlow.dsds@gmail.com
- ✅ **Senha:** Configurada no .env
- ✅ **Fastlane:** Totalmente configurado
- ✅ **Metadata:** Descrição em português pronta
- ✅ **ExportOptions:** Configurado para App Store

## 🎬 Passo a Passo

### 1. Execute o script

```bash
cd /Users/macbook/Documents/GitHub/PhotoCleaner
./publicar.sh
```

### 2. Confirme quando perguntar

O script vai mostrar suas credenciais e perguntar se quer continuar.
Digite `y` e pressione Enter.

### 3. Aguarde (5-10 minutos)

O script vai:
- Gerar o projeto
- Fazer build
- Criar archive
- Fazer upload

Você verá o progresso no terminal.

### 4. Após o upload

Acesse: https://appstoreconnect.apple.com

1. Vá em "Activity"
2. O build aparecerá como "Processing"
3. Aguarde 15-60 minutos
4. Quando ficar "Ready", adicione à versão 1.0
5. Clique em "Submit for Review"

## 🔧 Comandos Alternativos

Se preferir usar Fastlane diretamente:

```bash
# Publicação completa
fastlane mac publish

# Apenas validar build
fastlane mac validate

# Apenas upload de metadata
fastlane mac metadata
```

## 📸 Screenshots

O script cria screenshots de placeholder automaticamente.

**Para substituir por screenshots reais:**

1. Rode o app: `open SnapSieve.xcodeproj` (⌘R no Xcode)
2. Tire screenshots: ⇧⌘5
3. Salve em: `fastlane/screenshots/`
4. Resolução: 2560x1600px
5. Rode `./publicar.sh` novamente

## 🐛 Troubleshooting

### "No signing identity found"

**Solução:**
1. Abra Xcode > Settings > Accounts
2. Adicione sua conta Apple Developer
3. Clique em "Manage Certificates"
4. Adicione "Apple Distribution"
5. Tente novamente

### "Invalid username or password"

**Solução:**
1. Verifique o email no `.env` (FASTLANE_USER)
2. Verifique a senha no `.env` (FASTLANE_PASSWORD)
3. Se usar 2FA, gere uma App-Specific Password em:
   https://appleid.apple.com/account/manage

### "Build failed"

**Solução:**
```bash
# Limpar e tentar novamente
rm -rf build
./publicar.sh
```

## 🎉 Pronto!

Quando o build for aprovado pela Apple (24-48h):
- ✅ Seu app estará na App Store
- ✅ URL: https://apps.apple.com/app/idXXXXXXXXXX
- ✅ Compartilhe nas redes sociais!

---

**É automático!** Só rodar `./publicar.sh` 🚀
