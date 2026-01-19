# 🚀 Guia Completo: Publicar Snap Sieve na App Store

## ✅ Status Atual do Projeto

**O que já está pronto:**
- ✅ Bundle ID: `com.marlowsousa.snapsieve`
- ✅ Versão: 1.0 / Build: 1
- ✅ Ícone do app configurado (11 tamanhos)
- ✅ Info.plist com permissões de Photo Library
- ✅ Entitlements configurados
- ✅ Descrição para App Store (PT e EN)
- ✅ Política de Privacidade
- ✅ Todas as funcionalidades testadas

---

## 📋 PASSO 1: Pré-requisitos

### 1.1. Apple Developer Account

**Você precisa de uma conta Apple Developer:**
- Tipo: **Apple Developer Program** (não basta Apple ID grátis)
- Custo: **$99/ano** (USD)
- Link: https://developer.apple.com/programs/

**Como se inscrever:**
1. Acesse https://developer.apple.com/programs/enroll/
2. Clique em "Start Your Enrollment"
3. Faça login com seu Apple ID
4. Complete o processo de inscrição
5. Aguarde aprovação (geralmente 24-48h)

### 1.2. Certificados e Provisioning

**Depois de aprovado:**
1. Abra **Xcode > Settings (⌘,)**
2. Vá em **Accounts**
3. Clique no **"+"** e adicione sua conta Apple Developer
4. Selecione sua conta e clique em **"Manage Certificates..."**
5. Clique no **"+"** e selecione **"Apple Distribution"**

---

## 📋 PASSO 2: Configurar o Projeto no Xcode

### 2.1. Adicionar seu Team ID

**No terminal:**
```bash
cd /Users/macbook/Documents/GitHub/PhotoCleaner
```

**Edite o arquivo `project.yml` e adicione seu Team ID:**
```yaml
settings:
  base:
    SWIFT_VERSION: "5.9"
    MACOSX_DEPLOYMENT_TARGET: "14.0"
    CODE_SIGN_STYLE: Automatic
    PRODUCT_BUNDLE_IDENTIFIER: com.marlowsousa.snapsieve
    DEVELOPMENT_TEAM: "SEU_TEAM_ID_AQUI"  # ← ADICIONE AQUI
```

**Como encontrar seu Team ID:**
1. Abra Xcode > Settings > Accounts
2. Selecione sua conta
3. O Team ID aparece ao lado do nome da equipe
4. Copie o código (ex: "ABC123XYZ4")

### 2.2. Regenerar o Projeto

```bash
./generate_project.sh
```

### 2.3. Verificar Configurações no Xcode

**Abra o projeto:**
```bash
open SnapSieve.xcodeproj
```

**No Xcode:**
1. Selecione o projeto **SnapSieve** no navegador
2. Selecione o target **SnapSieve**
3. Vá na aba **Signing & Capabilities**
4. Verifique:
   - ✅ Team: Sua equipe selecionada
   - ✅ Bundle Identifier: `com.marlowsousa.snapsieve`
   - ✅ Signing Certificate: "Apple Distribution"
   - ✅ Provisioning Profile: "Automatic"

---

## 📋 PASSO 3: Criar o App no App Store Connect

### 3.1. Acessar App Store Connect

1. Acesse: https://appstoreconnect.apple.com/
2. Faça login com suas credenciais Apple Developer
3. Clique em **"My Apps"**

### 3.2. Criar Novo App

1. Clique no botão **"+"** (topo esquerdo)
2. Selecione **"New App"**
3. Preencha:
   - **Platform:** macOS
   - **Name:** Snap Sieve
   - **Primary Language:** Portuguese (Brazil) OU English (U.S.)
   - **Bundle ID:** com.marlowsousa.snapsieve
   - **SKU:** snapsieve-001 (ou qualquer ID único seu)
   - **User Access:** Full Access

4. Clique **"Create"**

---

## 📋 PASSO 4: Preencher Informações do App

### 4.1. Aba "App Information"

**Preencha:**
- **Name:** Snap Sieve
- **Subtitle:** Organize e limpe suas fotos (ou use do arquivo APP_STORE_DESCRIPTION.md)
- **Privacy Policy URL:** [Você precisa hospedar a política em algum lugar]
  - Opções:
    - GitHub Pages (grátis)
    - Seu site pessoal
    - Google Sites
- **Category:**
  - Primary: **Utilities**
  - Secondary: **Productivity**

### 4.2. Aba "Pricing and Availability"

**Preencha:**
- **Price:** Escolha um tier
  - Grátis: Tier 0
  - R$ 4,90: Tier 1
  - R$ 9,90: Tier 5
  - **R$ 19,90: Tier 10** (recomendado)
  - R$ 49,90: Tier 20
- **Availability:** All countries (ou selecione específicos)

### 4.3. Preparar Screenshots

**Requisitos:**
- Mínimo: **3 screenshots**
- Recomendado: **5 screenshots**
- Resolução: **2560 x 1600 pixels** (Retina)
- Formato: PNG ou JPG

**Como tirar screenshots:**

1. **Execute o app** no Xcode (⌘R)
2. **Navegue para cada tela** que quer capturar:
   - Tela principal com sidebar
   - Duplicates com grupos
   - Similar photos comparison
   - Quality review
   - Sieve Mode em ação

3. **Tire os screenshots:**
   - Pressione **⇧⌘5** (Shift+Command+5)
   - Ou use **⇧⌘4** e selecione a janela

4. **Edite os screenshots** (opcional):
   - Adicione títulos descritivos
   - Destaque features importantes
   - Use ferramentas como Pixelmator ou Figma

**Sugestões de screenshots:**
```
1. "Find Duplicates Instantly" - Tela de duplicados
2. "Compare Similar Photos" - Vista de similar photos
3. "Quality Analysis" - Quality review com grades
4. "Fun Sieve Mode" - Modo Sieve em ação
5. "Reclaim Your Space" - Stats com espaço recuperável
```

---

## 📋 PASSO 5: Criar Nova Versão

### 5.1. Criar Versão 1.0

1. No App Store Connect, clique no seu app
2. Clique em **"+ Version or Platform"**
3. Selecione **"macOS"**
4. Version: **1.0**
5. Clique **"Create"**

### 5.2. Preencher Informações da Versão

**What's New in This Version:**
```
Versão 1.0 - Lançamento Inicial

• Detecção inteligente de fotos duplicadas usando IA
• Identificação de fotos similares
• Análise automática de qualidade (nitidez, exposição, composição)
• Modo Sieve: compare fotos lado a lado de forma divertida
• Interface nativa do macOS
• 100% privado - todo processamento é local
• Recupere gigabytes de espaço na sua biblioteca

Requisitos: macOS 14.0 (Sonoma) ou superior
```

**Description:**
- Cole o conteúdo de `PhotoCleaner/App/APP_STORE_DESCRIPTION.md`
- Use a versão em Português ou English conforme sua escolha

**Keywords:**
```
fotos,duplicadas,limpeza,organizar,espaço,similar,qualidade,album,gerenciador,duplicados
```

**Copyright:**
```
© 2026 Marlow Sousa. Todos os direitos reservados.
```

**Support URL:**
- Seu site pessoal
- Página do GitHub: https://github.com/wolram/PhotoCleaner
- Ou crie uma página simples no GitHub Pages

**Marketing URL (opcional):**
- Mesmo que Support URL se não tiver site específico

### 5.3. Upload Screenshots

1. Role até **"App Previews and Screenshots"**
2. Clique em **"macOS"**
3. Arraste seus screenshots (ordem importa!)
4. Primeiro screenshot é o mais importante

---

## 📋 PASSO 6: Build e Upload

### 6.1. Preparar para Archive

**No Xcode:**

1. Selecione o scheme: **SnapSieve**
2. Selecione dispositivo: **Any Mac (Apple Silicon, Intel)**
3. Verifique o scheme está em **Release**:
   - Product > Scheme > Edit Scheme
   - Run > Info > Build Configuration > **Release**
   - Archive > Build Configuration > **Release**

### 6.2. Criar Archive

```bash
# Limpe o projeto primeiro
Product > Clean Build Folder (⇧⌘K)

# Crie o Archive
Product > Archive (ou ⌘B depois de selecionar Archive)
```

**Ou via linha de comando:**
```bash
xcodebuild -scheme SnapSieve \
  -configuration Release \
  -archivePath ./build/SnapSieve.xcarchive \
  archive
```

### 6.3. Validar e Fazer Upload

**Quando o Archive terminar:**

1. A janela **Organizer** abre automaticamente
2. Seu archive aparece na lista
3. Clique no archive
4. Clique em **"Validate App"**
   - Aguarde validação
   - Corrija erros se houver
5. Clique em **"Distribute App"**
6. Selecione **"App Store Connect"**
7. Clique **"Upload"**
8. Selecione:
   - ✅ Upload your app's symbols (recomendado)
   - ✅ Manage Version and Build Number (Automatically)
9. Clique **"Next"** e siga os passos
10. Aguarde o upload completar (pode levar 10-30 minutos)

---

## 📋 PASSO 7: Aguardar Processamento

### 7.1. Verificar Status

1. Volte ao **App Store Connect**
2. Vá em **"Activity"** (no menu superior)
3. Você verá seu build com status **"Processing"**
4. Aguarde 15-60 minutos até status mudar para **"Ready for Testing"**

### 7.2. Selecionar Build

1. Volte para a versão 1.0 do app
2. Role até **"Build"**
3. Clique no **"+"**
4. Selecione o build que acabou de processar
5. Clique **"Done"**

---

## 📋 PASSO 8: Responder Questões de Compliance

### 8.1. Export Compliance

**Se perguntarem sobre criptografia:**
- **Does your app use encryption?** → **No**
  - (A menos que você adicione recursos de rede/cloud)

### 8.2. Content Rights

**Você possui os direitos do conteúdo?** → **Yes**

### 8.3. Advertising Identifier

**Usa IDFA?** → **No**
- (Você não coleta dados para ads)

---

## 📋 PASSO 9: Submeter para Revisão

### 9.1. Verificar Checklist

**Antes de submeter, verifique:**
- ✅ Screenshots adicionados (mínimo 3)
- ✅ Descrição preenchida
- ✅ Keywords configuradas
- ✅ Preço selecionado
- ✅ Build selecionado
- ✅ Privacy Policy URL adicionada
- ✅ Support URL adicionada
- ✅ Rating Information preenchido
- ✅ Age Rating configurado

### 9.2. Rating Information

**Preencha o questionário:**
- Cartoon or Fantasy Violence: **No**
- Realistic Violence: **No**
- Sexual Content or Nudity: **No**
- Profanity or Crude Humor: **No**
- Alcohol, Tobacco, or Drug Use: **No**
- Mature/Suggestive Themes: **No**
- Horror/Fear Themes: **No**
- Medical/Treatment Information: **No**
- Gambling: **No**
- Contests: **No**
- Unrestricted Web Access: **No**

**Result:** Classificação **4+** (todas as idades)

### 9.3. Submeter

1. Clique no botão **"Add for Review"** (canto superior direito)
2. Se tudo estiver OK, o botão muda para **"Submit for Review"**
3. Clique em **"Submit for Review"**
4. Confirme

---

## 📋 PASSO 10: Aguardar Revisão

### 10.1. Processo de Revisão

**Timeline típico:**
- **In Review:** 24-48 horas
- **Processing:** Imediato após aprovação
- **Ready for Sale:** Algumas horas após aprovação

**Status possíveis:**
- 🟡 **Waiting for Review** - Na fila
- 🔵 **In Review** - Sendo revisado
- 🟢 **Ready for Sale** - Aprovado e disponível!
- 🔴 **Rejected** - Precisa correções

### 10.2. Se For Rejeitado

**Motivos comuns:**
1. Screenshots não representativos
2. Funcionalidade não funciona como descrito
3. Problemas de privacidade
4. Crash durante revisão

**O que fazer:**
1. Leia a mensagem de rejeição cuidadosamente
2. Corrija os problemas
3. Responda à Apple via Resolution Center
4. Ou faça novo build e resubmeta

---

## 📋 PASSO 11: Pós-Publicação

### 11.1. Após Aprovação

**Seu app está na App Store!** 🎉

**Link do app:**
```
https://apps.apple.com/app/idXXXXXXXXXX
```
(Você receberá o ID após aprovação)

### 11.2. Marketing

**Divulgue seu app:**
- Compartilhe no Twitter/X
- Poste no Reddit (r/macapps)
- Publique no Product Hunt
- Compartilhe no LinkedIn
- Crie uma página de landing

### 11.3. Monitoramento

**Acompanhe:**
- Reviews (responda todos!)
- Crashes (via Xcode Organizer)
- Downloads (App Store Connect)
- Receita (se pago)

---

## 🔧 Troubleshooting

### Erro: "Invalid Bundle"

**Causa:** Configuração de signing incorreta

**Solução:**
1. Verifique Team ID no `project.yml`
2. Regenere o projeto: `./generate_project.sh`
3. Limpe: Product > Clean Build Folder
4. Archive novamente

### Erro: "Missing Compliance"

**Causa:** Questão de criptografia não respondida

**Solução:**
1. No App Store Connect, vá em "Activity"
2. Clique no build com warning amarelo
3. Responda "Does not use encryption"

### Erro: "Missing Privacy Policy"

**Causa:** URL de privacidade não fornecida

**Solução:**
1. Hospede o arquivo `PRIVACY_POLICY.md` online
   - GitHub Pages (grátis)
   - Seu site
2. Adicione a URL no App Store Connect

### Build não aparece na lista

**Causa:** Ainda está processando

**Solução:**
- Aguarde 15-60 minutos
- Verifique em "Activity" o status
- Refresh a página

---

## 📚 Recursos Úteis

### Links Importantes

- **App Store Connect:** https://appstoreconnect.apple.com/
- **Developer Portal:** https://developer.apple.com/account/
- **Guidelines:** https://developer.apple.com/app-store/review/guidelines/
- **Human Interface Guidelines:** https://developer.apple.com/design/human-interface-guidelines/macos

### Documentos do Projeto

- `PhotoCleaner/App/APP_STORE_DESCRIPTION.md` - Descrição completa
- `PhotoCleaner/App/PRIVACY_POLICY.md` - Política de privacidade
- `PhotoCleaner/App/PUBLICATION_GUIDE.md` - Guia adicional

---

## ✅ Checklist Final

**Antes de começar:**
- [ ] Tenho Apple Developer Account ativo ($99/ano)
- [ ] Adicionei meu Team ID no project.yml
- [ ] Testei o app completamente
- [ ] Tenho screenshots prontos (mínimo 3)
- [ ] Tenho URL para Privacy Policy
- [ ] Tenho URL para Support

**Durante publicação:**
- [ ] App criado no App Store Connect
- [ ] Informações preenchidas (descrição, preço, etc)
- [ ] Screenshots enviados
- [ ] Build criado e validado
- [ ] Build uploaded para App Store Connect
- [ ] Build processado e selecionado na versão
- [ ] Questões de compliance respondidas
- [ ] Submetido para revisão

**Após publicação:**
- [ ] Monitor reviews
- [ ] Responder perguntas de usuários
- [ ] Planejar próximas atualizações
- [ ] Divulgar o app

---

## 🎯 Próximos Passos Imediatos

1. **Se inscrever no Apple Developer Program** (se ainda não fez)
2. **Adicionar seu Team ID** no `project.yml`
3. **Tirar screenshots** de qualidade
4. **Hospedar Privacy Policy** online
5. **Criar app no App Store Connect**
6. **Fazer archive e upload**

**Boa sorte com a publicação!** 🚀

Se tiver dúvidas durante o processo, consulte este guia ou a documentação oficial da Apple.

---

**Snap Sieve** - Organize e limpe suas fotos com IA
© 2026 Marlow Sousa
