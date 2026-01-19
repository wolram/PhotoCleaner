# 🚀 Fastlane - Guia Rápido de Início

Configuração completa do Fastlane para publicação automática no SnapSieve.

## ✅ O que já está configurado

- ✅ Fastlane instalado e configurado
- ✅ Fastfile com todas as lanes necessárias
- ✅ Appfile configurado
- ✅ Metadata em português brasileiro
- ✅ Estrutura de diretórios criada
- ✅ .gitignore atualizado

## 📋 O que você precisa fazer agora

### 1. Instalar Fastlane (se ainda não tiver)

```bash
brew install fastlane
```

### 2. Configurar Credenciais

Edite o arquivo `.env` na raiz do projeto:

```bash
vi .env
```

Adicione suas credenciais:

```bash
# Apple Developer Team ID (encontre em: Xcode > Settings > Accounts)
TEAM_ID="ABC123XYZ4"

# Apple ID (email da conta Apple Developer)
FASTLANE_USER="seu_email@example.com"
```

**Como encontrar seu Team ID:**
1. Abra Xcode
2. Vá em Xcode > Settings (⌘,)
3. Clique em "Accounts"
4. Selecione sua conta Apple Developer
5. O Team ID aparece ao lado do nome (ex: "ABC123XYZ4")

### 3. Atualizar Apple ID

Edite `fastlane/Appfile`:

```bash
vi fastlane/Appfile
```

Substitua `seu_apple_id@example.com` pelo seu email:

```ruby
apple_id("seu_email@example.com")
```

### 4. Tirar Screenshots

```bash
# 1. Rode o app
open SnapSieve.xcodeproj
# Pressione ⌘R no Xcode

# 2. Tire screenshots (⇧⌘5)
# - Resolução: 2560x1600px
# - Mínimo: 3 screenshots
# - Recomendado: 5 screenshots

# 3. Salve em:
# fastlane/screenshots/
```

**Sugestões de telas:**
- Tela principal com sidebar
- Resultados da análise
- Visualização de duplicados
- Modo Peneira
- Estatísticas

### 5. Hospedar Política de Privacidade

A política precisa estar online. Opções:

**Opção A: GitHub Pages (grátis)**
```bash
# 1. Crie branch gh-pages
git checkout -b gh-pages

# 2. Copie a política
cp PhotoCleaner/App/PRIVACY_POLICY.md index.md

# 3. Commit e push
git add index.md
git commit -m "Add privacy policy"
git push origin gh-pages

# 4. Ative GitHub Pages nas configurações do repo
# URL será: https://wolram.github.io/PhotoCleaner/
```

**Opção B: Hospedar em seu site pessoal**

Depois, atualize a URL em:
```bash
vi fastlane/metadata/pt-BR/privacy_url.txt
```

### 6. Validar Build

Antes de fazer upload, valide:

```bash
fastlane validate
```

Se tudo estiver OK, você verá:
```
✅ Build validado com sucesso!
```

### 7. Release para App Store

```bash
fastlane release
```

Este comando vai:
1. ✅ Gerar projeto Xcode
2. ✅ Configurar certificados
3. ✅ Criar archive
4. ✅ Fazer upload para App Store Connect
5. ✅ Enviar metadata e screenshots

## 🎯 Comandos Úteis

```bash
# Ver todas as lanes disponíveis
fastlane lanes

# Apenas validar (sem upload)
fastlane validate

# Apenas build local
fastlane build

# Upload para TestFlight (beta)
fastlane beta

# Atualizar apenas metadata
fastlane metadata

# Incrementar build automaticamente
fastlane release bump_build:true
```

## 📝 Checklist Pré-Publicação

- [ ] Fastlane instalado (`brew install fastlane`)
- [ ] Team ID configurado no `.env`
- [ ] Apple ID configurado no `.env` e `Appfile`
- [ ] Screenshots adicionados (mínimo 3)
- [ ] Política de privacidade hospedada online
- [ ] URL de privacidade atualizada em `metadata/pt-BR/privacy_url.txt`
- [ ] Validação executada (`fastlane validate`)
- [ ] Conta Apple Developer ativa ($99/ano)

## 🐛 Troubleshooting Rápido

**Erro: "Could not find Team ID"**
→ Adicione seu Team ID no arquivo `.env`

**Erro: "Invalid credentials"**
→ Verifique seu Apple ID no `.env` e `Appfile`

**Erro: "No screenshots found"**
→ Adicione pelo menos 3 screenshots em `fastlane/screenshots/`

**Erro: "Privacy URL invalid"**
→ Hospede a política online e atualize a URL

## 📚 Documentação Completa

- **README Fastlane:** `fastlane/README.md`
- **Guia Completo:** `GUIA_PUBLICACAO_APP_STORE.md`
- **Fastlane Docs:** https://docs.fastlane.tools

## 🎉 Após Publicação

1. Acesse App Store Connect
2. O build estará processando (15-60 min)
3. Quando pronto, clique em "Submit for Review"
4. Aguarde aprovação (24-48h)

**App Store Connect:** https://appstoreconnect.apple.com

---

**Pronto para publicar?**

```bash
fastlane release
```

Boa sorte! 🚀
