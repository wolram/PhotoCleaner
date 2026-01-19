# 🚀 Publicar na App Store - Passo a Passo Simples

## 📋 Você está aqui porque não tem nada no App Store Connect

Sem problemas! Vou te guiar pelo processo completo em **2 passos**.

---

## ✅ PASSO 1: Criar o App no App Store Connect

Execute este comando:

```bash
./criar_app.sh
```

Este script vai:
1. Abrir o App Store Connect no navegador
2. Mostrar exatamente o que você precisa preencher
3. Aguardar você criar o app

**Informações que você vai precisar:**
- Nome: **Snap Sieve**
- Bundle ID: **com.marlowsousa.snapsieve**
- SKU: **snapsieve-001**
- Plataforma: **macOS**
- Idioma: **Portuguese (Brazil)**

**Tempo:** 2-3 minutos

---

## ✅ PASSO 2: Publicar o Build

Depois de criar o app, execute:

```bash
./publicar.sh
```

Este script vai fazer **TUDO automaticamente**:
1. Gerar o projeto Xcode
2. Criar build de release
3. Fazer archive
4. Exportar para PKG
5. Upload para App Store Connect
6. Enviar metadata e screenshots

**Tempo:** 5-10 minutos

---

## 🎬 Em Resumo

```bash
# 1. Criar o app (só uma vez)
./criar_app.sh

# 2. Publicar (automático)
./publicar.sh
```

**É só isso!**

---

## 📱 Após o Upload

1. Acesse: https://appstoreconnect.apple.com
2. Vá em "Activity"
3. Aguarde o build processar (15-60 min)
4. Quando ficar "Ready for Testing":
   - Vá na versão 1.0
   - Adicione o build
   - Preencha informações restantes
   - Clique em "Submit for Review"

---

## 🐛 Problemas?

### "Não consigo fazer login no App Store Connect"

**Causa:** Você precisa de uma conta Apple Developer ativa ($99/ano)

**Solução:** 
1. Vá em: https://developer.apple.com/programs/
2. Faça a inscrição
3. Aguarde aprovação (24-48h)
4. Volte e execute `./criar_app.sh`

### "Bundle ID já existe"

**Causa:** Alguém já registrou esse Bundle ID

**Solução:** Mude o Bundle ID:
1. Edite `project.yml`
2. Mude `PRODUCT_BUNDLE_IDENTIFIER` para algo único
   Ex: `com.seuusuario.snapsieve`
3. Execute `./gerar_projeto.sh`
4. Volte ao Passo 1

### "Build falhou"

**Solução:**
```bash
# Limpar e tentar novamente
rm -rf build
./publicar.sh
```

---

## ✨ Está Tudo Configurado!

- ✅ Fastlane
- ✅ Metadata em português
- ✅ Screenshots de placeholder
- ✅ Credenciais configuradas
- ✅ Scripts de automação

**Agora é só criar o app e publicar!**

```bash
./criar_app.sh    # Passo 1
./publicar.sh     # Passo 2
```

🎉 **Boa sorte!**
