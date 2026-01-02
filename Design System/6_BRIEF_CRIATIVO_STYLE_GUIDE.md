# 🎯 BRIEF CRIATIVO + STYLE GUIDE - PHOTOCLEANER

---

## PARTE I: BRIEF CRIATIVO

### Visão Estratégica
PhotoCleaner é um aplicativo macOS que moderniza a gestão de biblioteca de fotos através de inteligência artificial, detectando duplicatas, encontrando similares e avaliando qualidade - tudo processado localmente no dispositivo do usuário, preservando privacidade.

### Posicionamento
**"Clarity Through Intelligence"** - A aplicação combina minimalismo visual (interface limpa) com poder tecnológico (IA avançada), transmitindo confiança, velocidade e precisão.

### Valores da Marca
1. **Privacidade em Primeiro Lugar** - Dados nunca saem do seu dispositivo
2. **Inteligência Acessível** - IA poderosa, interface simples
3. **Precisão Técnica** - Algoritmos cientificamente validados
4. **Experiência Premium** - Design sofisticado e responsivo
5. **Inovação com Propósito** - Resolve um problema real

### Target Audience
- **Fotógrafos amadores** (18-45 anos)
- **Profissionais de criação** (designers, content creators)
- **Power users macOS** que valorizam privacidade
- **Usuários tech-savvy** que entendem IA

### Tone & Voice
- **Confiante** sem ser arrogante
- **Acessível** sem ser condescendente
- **Moderno** sem ser trendy demais
- **Preciso** na linguagem técnica
- **Entusiasmado** sobre capacidades de IA

### Design Philosophy
**"Form follows function, guided by intelligence"**

O design serve à funcionalidade, mas com elegância. Cada elemento visual comunica inteligência (gradientes sutis, animações suaves, glassmorphism). O usuário nunca se questiona "por que isso é assim?" - a resposta é sempre "porque funciona melhor assim."

---

## PARTE II: VISUAL IDENTITY GUIDELINES

### Logo & Wordmark

#### Logo Mark (Símbolo)
```
Conceito: Estilização de uma foto limpa/organizada

OPÇÃO 1: Photo + Check
- Câmera ou quadrado (foto) com checkmark
- Minimalista, 2-3 cores
- Escalável de 16x16px a 512x512px

OPÇÃO 2: AI Lens
- Objetivo de câmera com elementos de IA (partículas)
- Dinâmico, mostra tecnologia

OPÇÃO 3: Simplified Frame
- Frame fotográfico limpo e moderno
- Com elemento teal (IA)

ESPECIFICAÇÕES:
- Primary color: PRIMARY_BLUE ou teal
- Secondary: WHITE ou DARK_BG para contexto
- Clear space: 1/4 da altura do logo
- Mínimo size: 24x24px
- Deve ser reconhecível em monocromático
```

#### Wordmark
```
"PhotoCleaner"
Fonte: Apple System Font (SF Pro Display)
Peso: Semibold 600
Capitalization: Title Case

Versões:
- Horizontal (logo + texto)
- Stacked (logo sobre texto)
- Texto only (para cabeçalhos)
- Monochromatic (logo preto/branco)
```

### Color Usage Guidelines

#### Primary Use
```
PRIMARY_BLUE (#3366FF):
- Botões primários
- Links e CTAs
- Ícones principais
- Indicadores de ação

PRIMARY_CORAL (#FF7F4D):
- Ações secundárias
- Alertas positivos
- Badges de destaque
- Accents secundários

PRIMARY_TEAL (#1ADD9C):
- Indicadores de IA
- Processamento em andamento
- Confirmações
- Elementos de inovação
```

#### Secondary Use
```
NEUTRALS (Backgrounds):
- DARK_BG: Fundo principal
- CARD_BG: Containers
- DARK_ALT: Hover states, alternates
- Variações com opacidade para efeitos

TEXT (Hierarquia):
- TEXT_PRIMARY: Conteúdo principal
- TEXT_SECONDARY: Suporte, descrições
- TEXT_TERTIARY: Texto desmarcado
- TEXT_DISABLED: Estados desabilitados
```

#### State Colors
```
Sempre usar cores de estado consistentes:
- SUCCESS (#4DB87D): Ações bem-sucedidas
- WARNING (#FFA500): Avisos e atenção
- ERROR (#FF6B6B): Erros e ações destrutivas
- INFO (#5DADE2): Informações e dicas

APLICAÇÃO:
- Não apenas para alertas
- Também em badges, indicadores, ícones
- Mantém coerência visual de significado
```

#### Gradients Recomendados
```
GRADIENT_HERO:
Linear, 135deg
De: PRIMARY_BLUE → PRIMARY_TEAL
Uso: Hero sections, CTAs destacadas

GRADIENT_SUBTLE:
Linear, 135deg
De: PRIMARY_BLUE (10% opacity) → PRIMARY_TEAL (5% opacity)
Uso: Backgrounds de containers premium

GRADIENT_AI:
Linear, 90deg
De: PRIMARY_TEAL → PRIMARY_BLUE
Uso: Spinners, loading indicators, IA elements
```

### Typography Usage

#### Padrões por Contexto

**Headlines / Seções Principais**
- Use HEADING_1 ou HEADING_2
- Sempre TEXT_PRIMARY (white)
- Spacing inferior: 1.5x da altura da font
- Máx 60 caracteres (readability)

**Body Copy**
- Padrão: BODY_REGULAR (15px)
- Line-height: 1.5 (aprox 22px)
- Color: TEXT_PRIMARY
- Max-width: 80 caracteres para melhor leitura

**Labels & Secundário**
- Use CAPTION para ajuda, timestamps
- Use BODY_SMALL para descrições
- Color: TEXT_SECONDARY ou TEXT_TERTIARY
- Nunca em weight < Regular (400)

**Buttons**
- BUTTON_TEXT (16px, semibold)
- Center-aligned
- Minúsculo de 8 caracteres
- Max com icon + label: 20 caracteres

**Exemplos de Hierarchy**
```
HEADING_1 (34px bold)
Organize your photos

HEADING_3 (22px semibold)
Smart Duplicates Detection

BODY_REGULAR (15px regular)
Identifies duplicate photos using vision...

CAPTION (12px regular)
Updated 2 hours ago
```

---

## PARTE III: INTERACTION & ANIMATION STYLE GUIDE

### Animation Philosophy
**"Motion that means something"**

Animações não são decoração - comunicam estado, feedback ou transição. Evite movimento aleatório; todo movimento tem propósito.

### Animation Personality
- **Responsive** - Feedback imediato (150ms)
- **Natural** - Easing curves que seguem física real
- **Intelligent** - Animações communicam processamento de IA
- **Smooth** - 60fps sempre
- **Restrained** - Nem toda transição precisa de confete

### Common Patterns

#### Element Appearing
```
Fade In + Scale:
- Opacity: 0 → 1
- Scale: 0.9 → 1.0
- Duration: 250ms
- Easing: ease-out-cubic

Exemplo: Card popping into view
```

#### Element Disappearing
```
Fade Out + Scale:
- Opacity: 1 → 0
- Scale: 1.0 → 0.9
- Duration: 200ms
- Easing: ease-in-cubic

Exemplo: Card being deleted
```

#### User Interaction
```
Hover:
- Color shift: 150ms ease-out
- Transform: subtle (scale 1.02 or translateY -2px)
- Shadow upgrade

Active/Press:
- Scale down 0.98
- Maintain feedback visual
- Duration: 100ms
```

#### Processing/Loading
```
Spinner rotation:
- 360° em 1s
- Linear easing (constante)
- Cores: blue → teal gradient
- Never stops abruptly

Pulse effect:
- Scale 1.0 → 1.3
- Opacity 1 → 0
- Duration: 1.5s
- Repeat infinito
- Easing: ease-out
```

### Accessibility in Motion

#### Respect prefers-reduced-motion
```
if (prefers-reduced-motion) {
  - Remover todas animations
  - Manter instant transitions
  - Keeps states/feedback visual
}
```

#### Motion Duration Rules
- Máximo 500ms para normal transitions
- Loading spinners podem ser > 1s
- Auto-dismiss: mínimo 3s + manual close
- Respeitar preferências do sistema

---

## PARTE IV: COMPONENT DESIGN PRINCIPLES

### Button Philosophy
**"Buttons are CTAs, treat them seriously"**

- Nunca use apenas cor para button (precisa iconografia/texto também)
- Primary button deve estar em visão 100% do tempo
- Sempre mostrar loading state
- Disabled state: clara mudança visual

### Card Philosophy
**"Cards are containers, make them feel premium"**

- Cards devem ter elevação visual clara
- Hover state é esperado em desktop
- Padding nunca menos de 16px
- Use subtle borders ou shadows, não ambos

### Input Philosophy
**"Inputs are gateways, make them approachable"**

- Focus state MUST ser visível (border + shadow)
- Error state sempre com mensagem helper
- Placeholder nunca carregar semântica importante
- Icon esquerda para ações, direita para status

### Modal Philosophy
**"Modals are interruptions, make them valuable"**

- Conteúdo modal nunca > 600px wide
- Sempre botão de close (X) ou Back
- Backdrop sempre para context
- Não stacking de modals (evitar)

---

## PARTE V: ACCESSIBILITY GUIDELINES

### Color Contrast
```
WCAG AA Minimum: 4.5:1 para texto
WCAG AAA Target: 7:1 para texto

Verificar:
- TEXT_PRIMARY (#FFF) on DARK_BG: ✅ 21:1
- TEXT_SECONDARY (#A0A0A0) on DARK_BG: ✅ 8.5:1
- Primary button text on blue: ✅ Conferir
- Todos estados hover/focus
```

### Focus Indicators
```
Obrigatório em:
- Buttons
- Links
- Inputs
- Interactive elements

Visual:
- 2px outline
- Color: PRIMARY_BLUE
- Offset: 2px externo
- Border Radius: match element
```

### Alt Text & Labels
```
Ícones sem texto: sempre aria-label
Inputs: sempre <label> or aria-label
Images: descritivo alt text
Decorative elements: aria-hidden="true"
```

### Keyboard Navigation
```
Tab order: sensível (left-to-right, top-to-bottom)
Shortcuts: 
  - Cmd+S: Scan
  - Cmd+D: Delete selected
  - Esc: Close modal
Todos button/links accessible via keyboard
```

---

## PARTE VI: PLATFORM-SPECIFIC GUIDELINES

### macOS Specific
```
- Respect system color mode (dark mode default)
- Use native system fonts (SF Pro)
- Support trackpad gestures
- Respect keyboard shortcuts (Cmd, Option, Shift)
- Follow Mac HIG (Human Interface Guidelines)
- Window chrome: native title bar
- Responder a system accent color (preferências)
```

### iPad (future consideration)
```
- Larger touch targets (mínimo 44x44px)
- Respeitar safe areas
- Support split-screen multitasking
- Gestures: 2-finger tap, pinch, swipe
- Horizontal e vertical orientations
- Magic Keyboard support
```

---

## PARTE VII: RESPONSIVE DESIGN RULES

### Mobile First (375px+)
```
- Single column layouts
- Stacked buttons
- Full-width components
- Larger touch targets
- Simplified navigation
```

### Tablet (768px+)
```
- 2-3 column grids
- Side-by-side buttons quando space
- Sidebar pode aparecer
- Mais espaço para content
```

### Desktop (1024px+)
```
- Multi-column layouts
- Optimal 4-column grids
- Sidebar navigation permanent
- Utilize horizontal space
- Mais whitespace
```

### Fluid Scaling
```
Font sizes: clamp(min, preferred, max)
Exemplo:
  clamp(14px, 3vw, 34px) para héroe title
  
Spacing: responsive multiples
Exemplo:
  gap: clamp(8px, 2vw, 24px)
  
Never absolute values only
```

---

## PARTE VIII: DESIGN TOKENS (JSON REFERENCE)

```json
{
  "tokens": {
    "colors": {
      "primary": {
        "blue": "#3366FF",
        "coral": "#FF7F4D",
        "teal": "#1ADD9C"
      },
      "neutral": {
        "darkBg": "#14141A",
        "cardBg": "#1F1F26",
        "darkAlt": "#27272F"
      },
      "text": {
        "primary": "#FFFFFF",
        "secondary": "#A0A0A0",
        "tertiary": "#707070"
      },
      "state": {
        "success": "#4DB87D",
        "warning": "#FFA500",
        "error": "#FF6B6B",
        "info": "#5DADE2"
      }
    },
    "spacing": {
      "xs": "4px",
      "sm": "8px",
      "md": "12px",
      "lg": "16px",
      "xl": "24px",
      "2xl": "32px"
    },
    "typography": {
      "heading1": {
        "size": "34px",
        "weight": 700,
        "lineHeight": 1.3,
        "letterSpacing": "-0.02em"
      },
      "body": {
        "size": "15px",
        "weight": 400,
        "lineHeight": 1.5,
        "letterSpacing": "0"
      }
    },
    "shadows": {
      "elevation1": "0 2px 8px rgba(0, 0, 0, 0.3)",
      "elevation2": "0 4px 16px rgba(0, 0, 0, 0.4)",
      "glow": "0 10px 30px rgba(51, 102, 255, 0.2)"
    },
    "radius": {
      "sm": "4px",
      "md": "8px",
      "lg": "12px",
      "full": "9999px"
    },
    "timing": {
      "fast": "150ms",
      "normal": "300ms",
      "slow": "500ms"
    }
  }
}
```

---

## PARTE IX: DO'S AND DON'Ts

### ✅ DO's
- Use whitespace generosamente
- Maintain visual hierarchy
- Consistência de spacing
- Feedback visual em interações
- Test contrast ratios
- Respect system preferences
- Use tokens consistently
- Animate with purpose
- Test no teclado
- Considere performance

### ❌ DON'Ts
- Não misture muitos tamanhos de fonte
- Não use cor apenas para significado
- Não textos muito pequenos (< 12px)
- Não animations sem propósito
- Não ignorar keyboard navigation
- Não elementos clicáveis < 44px
- Não textos muito compridos (> 80 chars)
- Não backgrounds com baixo contrast
- Não stacking de modals
- Não breaking de grid spacing

---

## PARTE X: DESIGN SYSTEM EVOLUTION

### Versionamento
```
Version 1.0: Initial release
- Core components
- Typography system
- Color palette
- Animation library

Future versions:
- Component variants
- Dark/light mode transitions
- Accessibility refinements
- Performance optimizations
```

### Contributing
```
To propose changes:
1. Document use case
2. Show before/after
3. Check impact across screens
4. Get stakeholder approval
5. Update all instances
6. Add to changelog
```

### Maintenance
```
Review quarterly:
- Usage patterns
- Performance metrics
- User feedback
- New OS requirements
- Library updates
```

---

## CONCLUSÃO

Este design system encapsula a filosofia de PhotoCleaner: **tecnologia inteligente, expressa com simplicidade visual e elegância funcional**.

Cada detalhe - de cores até timing de animações - serve para reforçar confiança, privacidade, e inovação.

**Design não é estética, é comunicação. Comunique bem.**
