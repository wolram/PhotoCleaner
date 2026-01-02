# 🎨 ESPECIFICAÇÕES DE DESIGN - PHOTOCLEANER

## 1. PALETA DE CORES

### Cores Primárias
```
PRIMARY_BLUE
  Hex: #3366FF
  RGB: rgb(51, 102, 255)
  HSL: hsl(217, 100%, 60%)
  Uso: CTAs, highlights, elementos principais
  Aplicação: Botões primários, links, accents

PRIMARY_CORAL
  Hex: #FF7F4D
  RGB: rgb(255, 127, 77)
  HSL: hsl(17, 100%, 67%)
  Uso: Ações secundárias, alertas positivos
  Aplicação: Botões secundários, badges de sucesso

PRIMARY_TEAL
  Hex: #1ADD9C
  RGB: rgb(26, 221, 156)
  HSL: hsl(152, 89%, 48%)
  Uso: IA/Inteligência, inovação, processamento
  Aplicação: Indicadores de IA, loading states, animations
```

### Cores de Neutrals
```
DARK_BG (Background principal)
  Hex: #14141A
  RGB: rgb(20, 20, 26)
  HSL: hsl(240, 13%, 9%)
  Luminância: 1.5%

CARD_BG (Cards e containers)
  Hex: #1F1F26
  RGB: rgb(31, 31, 38)
  HSL: hsl(240, 10%, 13%)
  Luminância: 2.5%

DARK_ALT (Variante para hover)
  Hex: #27272F
  RGB: rgb(39, 39, 47)
  HSL: hsl(240, 9%, 17%)
  Luminância: 3.5%

LIGHT_BG (Para modo light, se necessário)
  Hex: #F3F3F7
  RGB: rgb(243, 243, 247)
  HSL: hsl(240, 25%, 96%)
  Luminância: 94%
```

### Cores de Texto
```
TEXT_PRIMARY (Texto principal)
  Hex: #FFFFFF
  RGB: rgb(255, 255, 255)
  Opacity: 100%
  Contraste com DARK_BG: 21:1 ✅

TEXT_SECONDARY (Texto secundário)
  Hex: #A0A0A0
  RGB: rgb(160, 160, 160)
  Opacity: 100%
  Contraste com DARK_BG: 8.5:1 ✅

TEXT_TERTIARY (Texto desmarcado)
  Hex: #707070
  RGB: rgb(112, 112, 112)
  Opacity: 100%
  Contraste com DARK_BG: 5.2:1

TEXT_DISABLED (Texto desabilitado)
  Hex: #505050
  RGB: rgb(80, 80, 80)
  Opacity: 70%
```

### Cores de Estado
```
SUCCESS
  Hex: #4DB87D
  RGB: rgb(77, 184, 125)
  HSL: hsl(141, 41%, 51%)
  Uso: Ações bem-sucedidas, confirmação

WARNING
  Hex: #FFA500
  RGB: rgb(255, 165, 0)
  HSL: hsl(39, 100%, 50%)
  Uso: Avisos, ações que precisam atenção

ERROR
  Hex: #FF6B6B
  RGB: rgb(255, 107, 107)
  HSL: hsl(0, 100%, 71%)
  Uso: Erros, ações destrutivas

INFO
  Hex: #5DADE2
  RGB: rgb(93, 173, 226)
  HSL: hsl(204, 66%, 63%)
  Uso: Informações, dicas
```

### Cores com Opacidade (Gradientes)
```
PRIMARY_BLUE + 30%:  rgba(51, 102, 255, 0.3)
PRIMARY_BLUE + 15%:  rgba(51, 102, 255, 0.15)
PRIMARY_TEAL + 20%:  rgba(26, 221, 156, 0.2)
PRIMARY_TEAL + 5%:   rgba(26, 221, 156, 0.05)
TEXT_PRIMARY + 5%:   rgba(255, 255, 255, 0.05)
```

---

## 2. TIPOGRAFIA

### Famílias de Fonte
**Principal:** -apple-system, BlinkMacSystemFont, 'Segoe UI', SF Pro Display
**Fallback:** Helvetica Neue, Arial

### Escala de Tipos

#### Display (Heróis)
```
DISPLAY_LARGE
  Tamanho: 64px
  Peso: Bold (700)
  Linha: 1.2 (77px)
  Espaço letra: -2px
  Uso: Hero titles em landing pages
  Exemplo: "Organize suas fotos inteligentemente"

DISPLAY_MEDIUM
  Tamanho: 48px
  Peso: Bold (700)
  Linha: 1.25 (60px)
  Espaço letra: -1px
  Uso: Títulos de seções principais
```

#### Heading (Títulos)
```
HEADING_1
  Tamanho: 34px
  Peso: Bold (700)
  Linha: 1.3 (44px)
  Uso: Títulos de página
  Exemplo: "PhotoCleaner"

HEADING_2
  Tamanho: 28px
  Peso: Bold (700)
  Linha: 1.3 (36px)
  Uso: Subtítulos, headings de seção

HEADING_3
  Tamanho: 22px
  Peso: Semibold (600)
  Linha: 1.3 (29px)
  Uso: Subheadings, títulos de cards

HEADING_4
  Tamanho: 18px
  Peso: Semibold (600)
  Linha: 1.4 (25px)
  Uso: Títulos de grupos
```

#### Body (Corpo)
```
BODY_LARGE
  Tamanho: 17px
  Peso: Regular (400)
  Linha: 1.5 (25px)
  Uso: Texto principal, descrições
  Exemplo: "Detecte duplicatas, encontre similares..."

BODY_REGULAR
  Tamanho: 15px
  Peso: Regular (400)
  Linha: 1.5 (22px)
  Uso: Texto padrão de interfaces

BODY_SMALL
  Tamanho: 13px
  Peso: Regular (400)
  Linha: 1.5 (19px)
  Uso: Labels secundários, helper text
```

#### Caption & Labels
```
CAPTION
  Tamanho: 12px
  Peso: Regular (400)
  Linha: 1.5 (18px)
  Uso: Texto muito pequeno, timestamps
  Exemplo: "Última scan: 2h atrás"

CAPTION_BOLD
  Tamanho: 12px
  Peso: Semibold (600)
  Linha: 1.5 (18px)
  Uso: Labels em tags, badges

BUTTON_TEXT
  Tamanho: 16px
  Peso: Semibold (600)
  Linha: 1.2
  Uso: Texto em botões
  Exemplo: "Start Smart Scan"
```

### Pesos Utilizados
- Regular: 400
- Medium: 500
- Semibold: 600
- Bold: 700

---

## 3. SISTEMA DE ESPAÇAMENTO

### Base Unit: 4px

#### Escala Completa
```
XS:    4px   (1 unit)
SM:    8px   (2 units)
MD:   12px   (3 units)
LG:   16px   (4 units)
XL:   24px   (6 units)
2XL:  32px   (8 units)
3XL:  48px   (12 units)
4XL:  64px   (16 units)
5XL:  96px   (24 units)
```

### Spacing por Contexto
```
PADDING_TIGHT:     8px      (buttons pequenos)
PADDING_DEFAULT:   16px     (botões, cards)
PADDING_RELAXED:   24px     (seções)
PADDING_LOOSE:     32px     (containers principais)

MARGIN_COMPACT:    12px     (entre elementos)
MARGIN_DEFAULT:    16px     (espaço normal)
MARGIN_SECTION:    32px     (entre seções)
MARGIN_HERO:       48px     (seções grandes)
```

### Grid Layout
```
GRID_COLUMNS:      12
GRID_GAP:          16px (mobile), 24px (desktop)
CONTAINER_WIDTH:   1200px
CONTAINER_PADDING: 24px (horizontal)
```

---

## 4. SHADOWS & ELEVATIONS

### Sombra Sistema (Elevação)
```
ELEVATION_0
  Box-shadow: none
  Uso: Elementos planos

ELEVATION_1 (Cards hovering)
  Box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3)
  Blur: 8px
  Offset: 0 2px

ELEVATION_2 (Floating elements)
  Box-shadow: 0 4px 16px rgba(0, 0, 0, 0.4)
  Blur: 16px
  Offset: 0 4px

ELEVATION_3 (Modals, dropdowns)
  Box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5)
  Blur: 32px
  Offset: 0 8px

ELEVATION_4 (Important overlays)
  Box-shadow: 0 16px 48px rgba(0, 0, 0, 0.6)
  Blur: 48px
  Offset: 0 16px
```

### Sombras Coloridas (Com brand color)
```
PRIMARY_GLOW
  Box-shadow: 0 10px 30px rgba(51, 102, 255, 0.2)
  Uso: Botão primário hover

ACCENT_GLOW
  Box-shadow: 0 10px 30px rgba(26, 221, 156, 0.2)
  Uso: Elementos destacados com IA
```

---

## 5. BORDER RADIUS

```
RADIUS_NONE:     0px
RADIUS_SM:       4px    (inputs, small elements)
RADIUS_MD:       8px    (cards padrão)
RADIUS_LG:       12px   (buttons, containers)
RADIUS_XL:       16px   (large cards)
RADIUS_FULL:     9999px (pills, avatars, circles)
```

---

## 6. OPACIDADES

```
OPACITY_DISABLED:    0.5 (50%)
OPACITY_HOVER:       0.8 (80%)
OPACITY_PRESSED:     0.6 (60%)
OPACITY_SUBTLE:      0.1 (10%)
OPACITY_LIGHT:       0.3 (30%)
OPACITY_MEDIUM:      0.6 (60%)
OPACITY_STRONG:      0.9 (90%)
```

---

## 7. BREAKPOINTS

```
MOBILE_SMALL:  320px
MOBILE:        375px
TABLET:        768px
LAPTOP:        1024px
DESKTOP:       1200px
DESKTOP_WIDE:  1440px+
```

---

## REFERÊNCIA RÁPIDA (Token JSON)

```json
{
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
      "error": "#FF6B6B"
    }
  },
  "spacing": {
    "xs": "4px",
    "sm": "8px",
    "md": "12px",
    "lg": "16px",
    "xl": "24px"
  },
  "typography": {
    "heading1": {
      "size": "34px",
      "weight": 700,
      "lineHeight": 1.3
    }
  }
}
```
