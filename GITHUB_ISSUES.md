# GitHub Issues - PhotoCleaner

Este arquivo contem as issues a serem criadas no GitHub Project.
Use como referencia para criar issues manualmente ou via API.

---

## Milestone M0 - Estabilizacao

### Issue 1: Criar PrivacyInfo.xcprivacy

**Title:** [FIX] Criar PrivacyInfo.xcprivacy para App Store compliance

**Labels:** `bug`, `priority:P0`, `size:XS`

**Body:**
```markdown
## Objetivo
Adicionar manifesto de privacidade obrigatorio para submissao na App Store.

## Contexto
A partir do iOS 17 / macOS 14, Apple exige um arquivo PrivacyInfo.xcprivacy declarando o uso de APIs sensiveis. Sem ele, a submissao sera rejeitada.

## Criterios de Aceite
- [ ] Arquivo PrivacyInfo.xcprivacy criado na raiz do target PhotoCleaner
- [ ] Declaracao de NSPrivacyAccessedAPITypes configurada (se aplicavel)
- [ ] Arquivo adicionado ao Xcode project como resource
- [ ] Build compila sem warnings relacionados

## Referencias
- https://developer.apple.com/documentation/bundleresources/privacy_manifest_files

## Agente
Dev Agent
```

---

### Issue 2: Completar Info.plist

**Title:** [FIX] Completar Info.plist com valores corretos

**Labels:** `bug`, `priority:P0`, `size:XS`

**Body:**
```markdown
## Objetivo
Preencher campos vazios e personalizar Bundle Identifier.

## Estado Atual
- CFBundleDisplayName esta vazio
- Bundle ID generico: com.photocleaner.app

## Criterios de Aceite
- [ ] CFBundleDisplayName = "PhotoCleaner"
- [ ] Bundle Identifier personalizado (ex: com.SEUDOMINIO.PhotoCleaner)
- [ ] CFBundleIconFile referenciando app icon
- [ ] Todos os campos obrigatorios preenchidos

## Agente
Dev Agent
```

---

### Issue 3: Remover placeholders dos documentos

**Title:** [DOCS] Remover placeholders e preencher informacoes reais

**Labels:** `documentation`, `priority:P1`, `size:S`

**Body:**
```markdown
## Objetivo
Substituir todos os [PLACEHOLDER] por informacoes reais do owner.

## Arquivos Afetados
- PRIVACY_POLICY.md - [SEU EMAIL AQUI], [SEU NOME/EMPRESA]
- APP_STORE_DESCRIPTION.md - [URL DO SEU SITE], [SEU EMAIL]
- README.md - Links do repositorio, email, etc

## Criterios de Aceite
- [ ] Email de suporte definido
- [ ] Nome/empresa definidos
- [ ] URLs de GitHub atualizadas
- [ ] Copyright atualizado

## Bloqueador
Decisao do owner sobre branding/identidade

## Agente
Docs Agent
```

---

## Milestone M1 - Release Ready

### Issue 4: Criar App Icon completo

**Title:** [DESIGN] Criar App Icon para todas as resolucoes

**Labels:** `design`, `priority:P0`, `size:M`

**Body:**
```markdown
## Objetivo
Gerar icone do app em todos os tamanhos requeridos para macOS.

## Requisitos
- Icone master: 1024x1024 PNG (sem transparencia, sem cantos arredondados)
- macOS arredonda automaticamente

## Tamanhos Necessarios
| Tamanho | @1x | @2x |
|---------|-----|-----|
| 16x16 | icon_16x16.png | icon_16x16@2x.png |
| 32x32 | icon_32x32.png | icon_32x32@2x.png |
| 128x128 | icon_128x128.png | icon_128x128@2x.png |
| 256x256 | icon_256x256.png | icon_256x256@2x.png |
| 512x512 | icon_512x512.png | icon_512x512@2x.png |

## Criterios de Aceite
- [ ] Design aprovado pelo owner
- [ ] Todos os tamanhos gerados
- [ ] Contents.json atualizado em Assets.xcassets/AppIcon.appiconset
- [ ] Preview funciona no Xcode

## Sugestoes de Design
- Tema: Limpeza/Organizacao de fotos
- Cores: Azul/Verde (confianca, limpeza)
- Simbolo: Camera, lupa, escova/vassoura, ou combinacao

## Agente
Design Agent
```

---

### Issue 5: Capturar screenshots para App Store

**Title:** [DESIGN] Capturar 5 screenshots profissionais para App Store

**Labels:** `design`, `priority:P0`, `size:M`

**Body:**
```markdown
## Objetivo
Criar screenshots de alta qualidade para a pagina do app na App Store.

## Requisitos
- Resolucao: 2880 x 1800 pixels (Retina)
- Minimo: 3 screenshots
- Recomendado: 5 screenshots
- Formato: PNG ou JPEG

## Screenshots Sugeridos

1. **Tela Principal**
   - Sidebar visivel
   - Grupos de duplicatas carregados
   - Stats visiveis

2. **Resultados da Analise**
   - Estatisticas proeminentes
   - Espaco recuperavel destacado
   - Numeros de duplicatas/similares

3. **Modo Battle**
   - Duas fotos lado a lado
   - VS badge visivel
   - Bracket no sidebar

4. **Grid de Fotos Similares**
   - Multiplos grupos visiveis
   - Thumbnails de qualidade
   - Score de qualidade visivel

5. **Configuracoes ou Qualidade**
   - Tela de Settings ou
   - Detalhes de analise de qualidade

## Criterios de Aceite
- [ ] 5 screenshots em resolucao Retina
- [ ] Dados de demonstracao realistas (nao vazios)
- [ ] Tema claro preferivel (melhor legibilidade)
- [ ] Textos descritivos sobrepostos (opcional)

## Agente
Design Agent
```

---

### Issue 6: Hospedar Privacy Policy

**Title:** [INFRA] Hospedar Privacy Policy em URL publica

**Labels:** `infrastructure`, `priority:P0`, `size:S`

**Body:**
```markdown
## Objetivo
Disponibilizar a Privacy Policy em uma URL acessivel publicamente.

## Opcoes
1. **GitHub Pages** (Recomendado)
   - Criar repo ou usar o mesmo
   - Ativar Pages em Settings
   - URL: https://USERNAME.github.io/REPO/PRIVACY_POLICY

2. **Notion**
   - Criar pagina publica
   - Share > Publish to web

3. **Site proprio**
   - Subir em dominio proprio

## Criterios de Aceite
- [ ] URL publica acessivel
- [ ] Conteudo em PT e EN
- [ ] URL documentada no projeto
- [ ] Pronta para usar no App Store Connect

## Agente
DevOps Agent
```

---

### Issue 7: Configurar Apple Developer Account

**Title:** [INFRA] Setup completo da Apple Developer Account

**Labels:** `infrastructure`, `priority:P0`, `size:L`

**Body:**
```markdown
## Objetivo
Configurar conta Developer para publicacao na App Store.

## Pre-requisitos
- Apple ID
- Cartao de credito para pagamento ($99/ano)
- Documentos de identidade (para verificacao)

## Steps
1. [ ] Acessar developer.apple.com/programs
2. [ ] Enroll no Apple Developer Program
3. [ ] Pagar taxa anual
4. [ ] Aguardar aprovacao (24-48h)
5. [ ] Acessar Certificates, Identifiers & Profiles
6. [ ] Criar App ID para PhotoCleaner
7. [ ] Gerar Distribution Certificate
8. [ ] Criar Provisioning Profile
9. [ ] Configurar Xcode com Team ID
10. [ ] Testar build com signing

## Criterios de Aceite
- [ ] Conta ativa e verificada
- [ ] Certificados validos
- [ ] Xcode consegue assinar builds
- [ ] Archive funciona sem erros

## Agente
DevOps Agent
```

---

### Issue 8: Criar pagina de suporte

**Title:** [MARKETING] Criar pagina de suporte minima

**Labels:** `marketing`, `priority:P1`, `size:S`

**Body:**
```markdown
## Objetivo
Landing page simples com FAQ e contato para suporte.

## Conteudo Minimo
- FAQ com 5-10 perguntas comuns
- Email de contato
- Link para Privacy Policy
- Informacoes sobre o app

## Opcoes de Hospedagem
- GitHub Pages (gratuito)
- Notion (gratuito)
- Carrd (freemium)
- Site proprio

## Criterios de Aceite
- [ ] Pagina acessivel publicamente
- [ ] FAQ basico
- [ ] Email de contato funcional
- [ ] Link para Privacy Policy

## Agente
Growth Agent
```

---

## Milestone M2 - Beta

### Issue 9: Setup TestFlight

**Title:** [QA] Configurar distribuicao beta via TestFlight

**Labels:** `qa`, `priority:P1`, `size:M`

**Body:**
```markdown
## Objetivo
Distribuir versao beta para testers antes do lancamento publico.

## Steps
1. [ ] Upload build para App Store Connect
2. [ ] Preencher Test Information
3. [ ] Criar grupo de beta testers
4. [ ] Adicionar testers por email
5. [ ] Distribuir via TestFlight
6. [ ] Coletar feedback

## Criterios de Aceite
- [ ] Build processado no TestFlight
- [ ] Pelo menos 5 testers convidados
- [ ] Feedback coletado e documentado
- [ ] Bugs criticos corrigidos

## Dependencias
- M1 completo
- Build validado

## Agente
QA Agent
```

---

### Issue 10: Adicionar tratamento de erros robusto

**Title:** [ENHANCEMENT] Melhorar tratamento de erros e edge cases

**Labels:** `enhancement`, `priority:P1`, `size:M`

**Body:**
```markdown
## Objetivo
Garantir UX suave mesmo em cenarios de erro.

## Cenarios a Cobrir
1. **Permissao negada para Photos**
   - Mensagem clara
   - Botao para abrir System Preferences

2. **Biblioteca vazia**
   - Empty state amigavel
   - Sugestoes de acao

3. **Erro durante scan**
   - Feedback visual
   - Opcao de retry
   - Resultados parciais salvos

4. **Memoria insuficiente**
   - Reducao automatica de batch size
   - Aviso ao usuario

## Criterios de Aceite
- [ ] Todos os cenarios tem tratamento
- [ ] Mensagens de erro claras
- [ ] Opcoes de recovery quando possivel
- [ ] Logs estruturados para debug

## Agente
Dev Agent
```

---

## Milestone M3 - Publicacao

### Issue 11: Submeter para App Store Review

**Title:** [RELEASE] Primeira submissao para App Store

**Labels:** `release`, `priority:P0`, `size:M`

**Body:**
```markdown
## Objetivo
Submeter versao 1.0 para aprovacao da Apple.

## Checklist Pre-Submissao
- [ ] Build archivado e validado
- [ ] Todos os screenshots enviados
- [ ] Descricao preenchida (PT/EN)
- [ ] Keywords configuradas
- [ ] Categoria: Utilities
- [ ] Preco: Tier 20
- [ ] Privacy Policy URL
- [ ] Support URL
- [ ] Age Rating: 4+
- [ ] App Privacy: No data collected

## Steps
1. [ ] Upload build via Xcode Organizer
2. [ ] Preencher todos os campos no ASC
3. [ ] Adicionar build a versao 1.0
4. [ ] Revisar informacoes
5. [ ] Submit for Review

## Criterios de Aceite
- [ ] Status: "Waiting for Review"
- [ ] Email de confirmacao recebido

## Dependencias
- M0 + M1 completos

## Agente
Store Agent
```

---

## Milestone M4 - Pos-Launch

### Issue 12: Setup de analytics basico

**Title:** [ENHANCEMENT] Configurar analytics respeitando privacidade

**Labels:** `enhancement`, `priority:P2`, `size:M`

**Body:**
```markdown
## Objetivo
Entender uso do app mantendo compromisso de privacidade.

## Abordagem
- Usar APENAS App Store Analytics (built-in)
- Crash reporting via Xcode Organizer
- ZERO SDKs de terceiros

## Metricas Disponiveis
- Downloads
- Vendas
- Crashes
- Reviews

## Criterios de Aceite
- [ ] App Store Analytics habilitado
- [ ] Xcode Organizer configurado
- [ ] Dashboard de monitoramento

## Agente
DevOps Agent
```

---

### Issue 13: Suporte a arquivos RAW

**Title:** [FEATURE] Adicionar suporte a fotos RAW

**Labels:** `enhancement`, `priority:P3`, `size:XL`

**Body:**
```markdown
## Objetivo
Processar e analisar fotos em formato RAW.

## Formatos Alvo
- DNG (Adobe)
- CR2/CR3 (Canon)
- NEF (Nikon)
- ARW (Sony)
- RAF (Fujifilm)

## Desafios
- Thumbnails de RAW
- Performance de leitura
- Analise de qualidade adaptada

## Criterios de Aceite
- [ ] Deteccao de arquivos RAW
- [ ] Thumbnails gerados
- [ ] Analise de duplicatas funciona
- [ ] Documentacao atualizada

## Estimativa
XL (3+ dias de desenvolvimento)

## Agente
Dev Agent
```

---

## Resumo de Issues

| # | Titulo | Prioridade | Milestone |
|---|--------|------------|-----------|
| 1 | PrivacyInfo.xcprivacy | P0 | M0 |
| 2 | Info.plist | P0 | M0 |
| 3 | Placeholders docs | P1 | M0 |
| 4 | App Icon | P0 | M1 |
| 5 | Screenshots | P0 | M1 |
| 6 | Privacy Policy hosting | P0 | M1 |
| 7 | Apple Developer Account | P0 | M1 |
| 8 | Pagina de suporte | P1 | M1 |
| 9 | TestFlight | P1 | M2 |
| 10 | Tratamento de erros | P1 | M2 |
| 11 | Submissao App Store | P0 | M3 |
| 12 | Analytics | P2 | M4 |
| 13 | Suporte RAW | P3 | M4 |

---

*Para criar estas issues no GitHub, use o GitHub CLI ou a interface web.*
