# PhotoCleaner - Guia Completo de Publicação na App Store

## 🎯 PASSO A PASSO COMPLETO

### FASE 1: PREPARAÇÃO NO XCODE

#### 1.1 Configure o Info.plist

No Xcode, abra o arquivo `Info.plist` e adicione:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>PhotoCleaner precisa acessar suas fotos para analisar e identificar duplicatas, fotos similares e avaliar a qualidade das imagens. Todo processamento é feito localmente no seu dispositivo.</string>

<key>CFBundleDisplayName</key>
<string>PhotoCleaner</string>

<key>CFBundleShortVersionString</key>
<string>1.0</string>

<key>CFBundleVersion</key>
<string>1</string>
```

#### 1.2 Configure o Projeto

1. Selecione o projeto no Xcode
2. Na aba **General**:
   - **Display Name:** PhotoCleaner
   - **Bundle Identifier:** `com.seuNome.PhotoCleaner` (deve ser único)
   - **Version:** 1.0
   - **Build:** 1
   - **Deployment Target:** macOS 14.0

3. Na aba **Signing & Capabilities**:
   - ✅ Automatically manage signing
   - Selecione seu **Team** (sua conta Developer)
   - Certifique-se que o certificado está válido

#### 1.3 Adicione o Ícone do App

1. Crie um ícone 1024x1024px (PNG, sem transparência)
2. No Xcode, vá em **Assets.xcassets** > **AppIcon**
3. Arraste sua imagem para o slot 1024x1024

**Dica:** Use ferramentas como:
- [Icon Slate](https://www.kodlian.com/apps/icon-slate)
- [AppIconBuilder](https://appiconbuilder.com)
- Canva (template de app icon)

#### 1.4 Adicione Arquivos Necessários

✅ Já criados:
- `PrivacyInfo.xcprivacy` - Manifesto de privacidade
- `APP_STORE_DESCRIPTION.md` - Descrições prontas
- `PRIVACY_POLICY.md` - Política de privacidade

Adicione `PrivacyInfo.xcprivacy` ao projeto:
1. Arraste o arquivo para o Xcode
2. ✅ Copy items if needed
3. ✅ Add to targets: PhotoCleaner

---

### FASE 2: CRIAR O BUILD

#### 2.1 Configure para Release

1. No Xcode, menu: **Product** > **Scheme** > **Edit Scheme**
2. Selecione **Run** na sidebar
3. Tab **Info**: Build Configuration = **Release**

#### 2.2 Archive o App

1. Menu: **Product** > **Archive**
2. Aguarde o build compilar (pode levar alguns minutos)
3. Quando terminar, abrirá a janela **Organizer**

#### 2.3 Valide o Archive

Na janela Organizer:
1. Selecione seu archive
2. Clique **Validate App**
3. Escolha suas opções:
   - ✅ Upload your app's symbols
   - ✅ Manage Version and Build Number (deixe automático)
4. Clique **Validate**
5. Aguarde a validação (alguns minutos)

Se houver erros, corrija e archive novamente.

#### 2.4 Distribua para App Store

1. Clique **Distribute App**
2. Escolha **App Store Connect**
3. Escolha **Upload**
4. Selecione as mesmas opções da validação
5. Clique **Upload**
6. Aguarde o upload completar

---

### FASE 3: APP STORE CONNECT

#### 3.1 Crie o App

1. Acesse [App Store Connect](https://appstoreconnect.apple.com)
2. Vá em **My Apps**
3. Clique no **+** > **New App**
4. Preencha:
   - **Platforms:** macOS
   - **Name:** PhotoCleaner
   - **Primary Language:** Portuguese (Brazil) ou English
   - **Bundle ID:** Selecione o mesmo do Xcode
   - **SKU:** `photocleaner-2025` (identificador único interno)
   - **User Access:** Full Access

#### 3.2 Preencha Informações do App

##### App Information
- **Name:** PhotoCleaner - Organize Suas Fotos
- **Subtitle:** Limpe e organize sua biblioteca (30 caracteres max)
- **Primary Category:** Utilities
- **Secondary Category:** Productivity
- **Content Rights:** ✅ Contains third-party content (se usar icons/assets de terceiros)

##### Pricing and Availability
- **Price:** Tier 20 (~$19.99 USD / R$ 99,90)
- **Availability:** Todos os países
- **Pre-Order:** Não (deixe desmarcado para primeira versão)

##### Privacy Policy
- **URL:** Cole o link do seu site com a política de privacidade
  - Você pode hospedar gratuitamente no GitHub Pages
  - Ou usar o arquivo `PRIVACY_POLICY.md` que criei

#### 3.3 Prepare a Versão 1.0

Clique em **+ Version or Platform** > **macOS** > **1.0**

##### Screenshots (IMPORTANTE!)

Você precisa de **pelo menos 3 screenshots**:

**Tamanhos aceitos:**
- 1280 x 800 pixels (mínimo)
- 1440 x 900 pixels
- 2880 x 1800 pixels (Retina, recomendado)

**Como tirar screenshots:**

1. Rode o app no Mac
2. Navegue para cada tela importante
3. Pressione **Cmd + Shift + 4** e arraste para capturar
4. Ou use **Cmd + Shift + 5** para mais opções

**Screenshots sugeridos (em ordem):**

1. **Tela Principal** com grupos de fotos duplicadas visíveis
2. **Resultados da Análise** mostrando estatísticas e espaço recuperável
3. **Modo Battle** com duas fotos lado a lado
4. **Visualização de Grupo** com grid de fotos duplicadas
5. **Detalhes de Qualidade** (opcional)

##### Description (Descrição)

Cole a descrição completa do arquivo `APP_STORE_DESCRIPTION.md`:
- Use a versão em **Português** se Primary Language = Portuguese (Brazil)
- Use a versão em **English** se Primary Language = English

##### Keywords (Palavras-chave)

```
fotos,duplicadas,limpeza,organizar,espaço,similar,qualidade,album,gerenciador,duplicados
```

##### Support URL
Cole o link do seu:
- Site pessoal
- GitHub repository
- Página de suporte

##### Marketing URL (opcional)
Link para página de marketing do app (se tiver)

##### Promotional Text (opcional - 170 caracteres)
```
🎉 Lançamento! Libere gigabytes de espaço encontrando fotos duplicadas e similares com IA. Modo Battle exclusivo para escolher suas melhores fotos!
```

##### What's New in This Version
```
Versão 1.0 - Lançamento Inicial

✨ Recursos principais:
• Detecção inteligente de fotos duplicadas
• Identificação de fotos similares
• Análise automática de qualidade
• Modo Battle para comparação interativa
• Interface nativa do macOS
• 100% processamento local - privacidade garantida
```

#### 3.4 App Privacy

1. Vá na seção **App Privacy**
2. Clique **Get Started**
3. **Do you or your third-party partners collect data from this app?**
   - Selecione **No** (não coletamos dados)
4. Salve

#### 3.5 Age Rating

1. Clique **Edit** em Age Rating
2. Responda todas as perguntas com **No**
3. Resultado deve ser: **4+**
4. Salve

#### 3.6 Build Selection

1. Vá na seção **Build**
2. Aguarde seu build aparecer (pode levar 30-60 minutos após upload)
3. Quando aparecer, clique no **+** ao lado de "Build"
4. Selecione o build que você fez upload
5. Clique **Done**

#### 3.7 Export Compliance

Quando adicionar o build, perguntará sobre criptografia:
- **Does your app use encryption?**
  - Responda **No** (a menos que tenha adicionado criptografia custom)

---

### FASE 4: SUBMETER PARA REVISÃO

#### 4.1 Checklist Final

Certifique-se que preencheu:
- ✅ Screenshots (mínimo 3)
- ✅ Description
- ✅ Keywords
- ✅ Support URL
- ✅ Privacy Policy URL
- ✅ Build selecionado
- ✅ App Privacy configurado
- ✅ Age Rating preenchido
- ✅ Pricing configurado

#### 4.2 Adicionar Informações de Contato (Para Revisão)

No topo da página, clique **App Information**:
- **Review Information:**
  - First Name
  - Last Name
  - Phone Number
  - Email

- **Notes:** (opcional)
```
PhotoCleaner é um app de limpeza de fotos que usa Vision Framework e Core ML da Apple para encontrar duplicatas e avaliar qualidade. Todo processamento é local. 

Para testar:
1. Conceda acesso à biblioteca de fotos quando solicitado
2. Clique em "Iniciar Análise"
3. Aguarde o scan completar
4. Explore os grupos de duplicatas
5. Teste o Modo Battle clicando em qualquer grupo

Nenhuma conta ou configuração especial é necessária.
```

#### 4.3 Submeter!

1. Clique **Save** no topo
2. Clique **Add for Review**
3. Revise todas as informações
4. Clique **Submit for Review**

🎉 **Pronto! Seu app está em revisão!**

---

### FASE 5: AGUARDAR APROVAÇÃO

#### Timeline Esperado

- **In Review:** 24-48 horas normalmente
- **Status:** Você pode acompanhar em App Store Connect
- **Notificações:** Você receberá emails sobre mudanças de status

#### Possíveis Status

1. **Waiting for Review** - Na fila
2. **In Review** - Sendo analisado
3. **Pending Developer Release** - Aprovado! (escolha quando publicar)
4. **Ready for Sale** - Publicado e disponível

#### Se for Rejeitado

Não se preocupe! É comum. Apple pode pedir:
- Melhores screenshots
- Mais detalhes na descrição
- Clarificação sobre uso de APIs
- Demonstração de funcionalidade

Você pode:
- Responder no Resolution Center
- Fazer as alterações necessárias
- Resubmeter

---

## 🎨 DICAS DE SCREENSHOTS DE QUALIDADE

### Ferramentas Recomendadas

1. **CleanShot X** - Melhor app para screenshots no Mac
2. **Shottr** - Gratuito e poderoso
3. **Photoshop/Figma** - Para adicionar molduras/texto

### Boas Práticas

- ✅ Use o tema claro do macOS (mais profissional)
- ✅ Mostre dados realistas (não vazios)
- ✅ Capture em Retina (2880 x 1800)
- ✅ Adicione descrições curtas em cada screenshot
- ✅ Use a mesma janela/tamanho em todos
- ✅ Destaque recursos principais

### Template de Screenshot

Você pode adicionar texto sobre os screenshots:
```
Screenshot 1: "Encontre duplicatas automaticamente"
Screenshot 2: "Veja quanto espaço pode recuperar"
Screenshot 3: "Compare e escolha as melhores fotos"
```

---

## 💰 CONFIGURAÇÃO DE PREÇO R$ 99,90

### App Store Connect - Pricing

1. Vá em **Pricing and Availability**
2. Em **Price**, clique **Edit**
3. Selecione **Tier 20**

**Tier 20 equivale a:**
- 🇺🇸 USD: $19.99
- 🇧🇷 BRL: R$ 99,90 (aproximado, Apple ajusta)
- 🇪🇺 EUR: €19.99

### Alternativas de Preço

Se quiser testar outros valores:
- **Tier 15:** ~$14.99 / R$ 74,90
- **Tier 25:** ~$24.99 / R$ 124,90
- **Tier 10:** ~$9.99 / R$ 49,90

---

## 🆘 RESOLUÇÃO DE PROBLEMAS COMUNS

### "Invalid Bundle Identifier"
- Certifique-se que o Bundle ID no Xcode é único
- Deve seguir formato: `com.seuNome.PhotoCleaner`

### "App uses non-public API"
- Remova qualquer uso de APIs privadas
- Todas as APIs que usei são públicas (Vision, SwiftData, Photos)

### "Insufficient App Description"
- Use a descrição completa que forneci
- Deve ter pelo menos 200 caracteres

### "Missing Screenshot"
- Mínimo 3 screenshots obrigatório
- Devem estar no tamanho correto

### "Missing Privacy Policy"
- Hospede a `PRIVACY_POLICY.md` em algum lugar
- GitHub Pages é gratuito e fácil

### Build não aparece no App Store Connect
- Aguarde até 60 minutos
- Verifique email por problemas de processamento
- Certifique-se que submeteu corretamente

---

## 📧 HOSPEDANDO POLÍTICA DE PRIVACIDADE (GRÁTIS)

### Opção 1: GitHub Pages (Recomendado)

1. Crie um repositório no GitHub
2. Adicione o arquivo `PRIVACY_POLICY.md`
3. Vá em Settings > Pages
4. Source: Deploy from branch (main)
5. Sua URL será: `https://seuUsuario.github.io/repo/PRIVACY_POLICY.md`

### Opção 2: Notion (Fácil)

1. Crie uma página no Notion
2. Cole o conteúdo da política
3. Clique **Share** > **Publish to web**
4. Copie o link público

### Opção 3: Google Sites

1. Crie um site no Google Sites
2. Adicione uma página "Privacy Policy"
3. Cole o conteúdo
4. Publique

---

## ✅ CHECKLIST FINAL ANTES DE SUBMETER

### No Xcode
- [ ] Bundle ID único e correto
- [ ] Versão 1.0 e Build 1
- [ ] Ícone de app adicionado (1024x1024)
- [ ] NSPhotoLibraryUsageDescription no Info.plist
- [ ] PrivacyInfo.xcprivacy incluído
- [ ] Certificado de assinatura válido
- [ ] Archive criado com sucesso
- [ ] Validação passou sem erros
- [ ] Upload para App Store Connect completo

### No App Store Connect
- [ ] App criado com informações corretas
- [ ] Screenshots adicionados (mínimo 3)
- [ ] Descrição completa preenchida
- [ ] Keywords configuradas
- [ ] Categoria selecionada (Utilities)
- [ ] Preço Tier 20 configurado
- [ ] Privacy Policy URL adicionada
- [ ] Support URL adicionada
- [ ] App Privacy = No data collected
- [ ] Age Rating = 4+
- [ ] Build selecionado na versão 1.0
- [ ] Informações de contato preenchidas

---

## 🚀 DEPOIS DA APROVAÇÃO

### Marketing

- Compartilhe nas redes sociais
- Peça para amigos testarem e avaliarem
- Responda reviews
- Considere Product Hunt

### Atualizações Futuras

Ideias para versão 1.1:
- Suporte a arquivos RAW
- Exportar relatórios
- Integração com iCloud Photos
- Agendamento de scans automáticos

### Suporte

- Responda emails de usuários rapidamente
- Monitore reviews na App Store
- Corrija bugs encontrados

---

## 📊 MONITORAMENTO

### App Analytics (App Store Connect)

Acompanhe:
- Downloads
- Vendas
- Crashes
- Reviews

### TestFlight (Opcional)

Para futuras versões, use TestFlight:
- Beta testing antes de publicar
- Coleta de feedback
- Identificação de bugs

---

## 💡 DICA FINAL

**Não se preocupe se for rejeitado na primeira vez!**

É super comum. Apple é rigorosa mas justa. Se for rejeitado:
1. Leia o feedback com atenção
2. Faça as alterações solicitadas
3. Resubmeta

A maioria dos apps é aprovada em 1-3 tentativas.

---

## 🎉 BOA SORTE!

Você tem tudo pronto para publicar! Siga os passos acima e em breve seu app estará na App Store.

Se tiver dúvidas durante o processo, você pode:
- Consultar a [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- Contatar o Apple Developer Support
- Revisar esta documentação

**Sucesso com seu lançamento! 🚀**
