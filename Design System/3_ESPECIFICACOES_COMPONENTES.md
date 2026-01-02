# 🧩 COMPONENTES DE UI - PHOTOCLEANER

## 1. BUTTONS

### Button Primário
```
ESTADOS:
- Default:   Background: PRIMARY_BLUE (#3366FF)
- Hover:     Background: #2450DD (luminância -10%)
             Shadow: 0 10px 30px rgba(51, 102, 255, 0.2)
- Active:    Background: #1A3CA8 (luminância -20%)
- Disabled:  Background: #505050
             Text: TEXT_DISABLED
             Cursor: not-allowed

DIMENSÕES:
- Height: 44px
- Padding: 12px 24px
- Border Radius: 12px
- Font: BUTTON_TEXT (16px, semibold)
- Icon size: 18px

LAYOUT:
- Icon + Label: Gap 12px
- Icon Only: Width/Height = 44px
- Full Width: Width = 100%

VARIAÇÕES:
Small (32px height, 8px 16px padding, 14px font)
Large (52px height, 16px 32px padding)
Icon Only (44x44px)

ANIMAÇÃO:
- Transição: 150ms ease-out
- Hover: scale 1.02, brightness +5%
- Active: scale 0.98, brightness -5%
```

### Button Secundário
```
ESTADO:
- Default:   Background: CARD_BG (#1F1F26)
             Border: 1px solid rgba(255, 255, 255, 0.2)
- Hover:     Background: DARK_ALT (#27272F)
             Border: 1px solid rgba(51, 102, 255, 0.4)
- Active:    Background: rgba(51, 102, 255, 0.2)
- Disabled:  Background: #505050
             Opacity: 0.5

DIMENSÕES: Same as Primary
TIPOGRAFIA: BUTTON_TEXT

ANIMAÇÃO:
- Border color fade: 150ms
- Background shift: 150ms
```

### Button Tertiary (Ghost)
```
ESTADO:
- Default:   Background: transparent
             Text: TEXT_PRIMARY
             No border
- Hover:     Background: rgba(51, 102, 255, 0.1)
- Active:    Background: rgba(51, 102, 255, 0.2)

DIMENSÕES: Same as Primary
TIPOGRAFIA: BUTTON_TEXT
INTERAÇÃO: Underline effect on hover (2px bottom border)
```

### Button Danger
```
ESTADO:
- Default:   Background: ERROR (#FF6B6B)
- Hover:     Background: #FF4F4F (brightness -10%)
             Shadow: 0 10px 30px rgba(255, 107, 107, 0.3)
- Active:    Background: #FF2B2B (brightness -20%)
- Disabled:  Background: #505050 (grayed out)

DIMENSÕES: Same as Primary
TIPOGRAFIA: BUTTON_TEXT (com ícone de trash ou warning)
USO: Deletar, ações destrutivas
```

### Button Loading State
```
VISUAL:
- Desabilita o botão
- Mostra spinner circular
- Substitui ícone/texto por animation
- Mantém altura/largura

ANIMAÇÃO:
- Spinner: rotação 360° em 1s, linear, infinita
- Cores: PRIMARY_BLUE com TEAL accent

CÓDIGO:
<Button isLoading={true} disabled>
  Processando...
</Button>
```

---

## 2. CARDS

### Card Padrão
```
ESTRUTURA:
- Padding: 24px (XL)
- Background: CARD_BG (#1F1F26)
- Border: 1px solid rgba(255, 255, 255, 0.1)
- Border Radius: 12px (LG)
- Shadow: ELEVATION_1

ESTADOS:
- Default:   Como acima
- Hover:     Elevation upgrade para ELEVATION_2
             Border color: rgba(51, 102, 255, 0.3)
             Transform: translateY(-4px)
- Active:    Border: 2px solid PRIMARY_BLUE

ANIMAÇÃO:
- Hover elevation: 200ms ease-out
- Transform: 200ms ease-out
- Cursor: pointer

VARIAÇÕES:
- Elevated:  Shadow ELEVATION_2, Border mais clara
- Bordered:  2px border PRIMARY_BLUE, Shadow none
- Flat:      Background diferente, no shadow
```

### Card com Gradient Border
```
VISUAL:
- Border: Gradient de PRIMARY_BLUE para PRIMARY_TEAL
- Cria efeito premium
- Padding: 1px (border thickness)
- Inner background: CARD_BG

CÓDIGO:
background: linear-gradient(135deg, #3366FF, #1ADD9C)
padding: 1px
border-radius: 12px

INNER:
background: CARD_BG
border-radius: 11px (1px menor)
```

### Card Interativo (Clicável)
```
ESTADOS:
- Default:   Cursor pointer, shadow normal
- Hover:     Elevation+, transform translateY(-4px)
- Active:    Scale 0.98, elevation normal
- Focus:     Outline 2px PRIMARY_BLUE (offset 2px)

EXEMPLO:
Photo preview card, Library item card
```

---

## 3. INPUT FIELDS

### Text Input
```
ESTRUTURA:
- Height: 44px
- Padding: 12px 16px
- Border Radius: 8px (MD)
- Border: 1px solid rgba(255, 255, 255, 0.2)
- Background: DARK_ALT (#27272F)
- Font: BODY_REGULAR (15px)

ESTADOS:
- Default:   Border e background como acima
- Focused:   Border: 2px PRIMARY_BLUE
             Background: rgba(51, 102, 255, 0.05)
             Shadow: 0 0 0 3px rgba(51, 102, 255, 0.1)
- Error:     Border: 2px ERROR (#FF6B6B)
             Shadow: 0 0 0 3px rgba(255, 107, 107, 0.1)
- Disabled:  Background: #505050 (20% opacity)
             Color: TEXT_DISABLED
             Cursor: not-allowed

PLACEHOLDER:
- Color: TEXT_TERTIARY
- Size: Same as input
- Opacity: 0.7

ANIMAÇÃO:
- Focus: 150ms ease-out
- Border color: 150ms
- Shadow: 150ms
```

### Input com Icon
```
LAYOUT:
- Ícone left (16px):    padding-left aumenta para 40px
- Ícone right (16px):   padding-right aumenta para 40px
- Gap entre icon/text:  8px
- Icon size:            18px
- Icon color:           TEXT_SECONDARY

EXEMPLO:
Search input: 🔍 Buscar fotos...
Filter input: ⚙️ Qualidade mínima
```

### Input Range (Slider)
```
DIMENSÕES:
- Height track: 4px
- Height thumb: 18px
- Thumb width: 18px

CORES:
- Track filled: PRIMARY_BLUE
- Track empty: rgba(255, 255, 255, 0.2)
- Thumb: PRIMARY_BLUE
- Thumb hover: PRIMARY_TEAL

ESTADOS:
- Default:   Como acima
- Hover:     Thumb size +2px
- Active:    Thumb scale 1.15
- Disabled:  Greyed out

ANIMAÇÃO:
- Thumb scale: 150ms
- Track color: 150ms

EXEMPLO:
Duplicate Threshold: ▬▼▬▬▬▬ 0.5
Quality Threshold: ▬▬▬▼▬▬ 0.65
```

---

## 4. TOGGLES & SWITCHES

### Toggle/Switch
```
DIMENSÕES:
- Height: 28px
- Width: 52px (quando ativo: 60px via label width)
- Border Radius: 14px (FULL para arredondado)
- Track height: 24px

CORES:
- Off - Track:    rgba(255, 255, 255, 0.2)
- Off - Thumb:    #505050
- On - Track:     PRIMARY_BLUE
- On - Thumb:     WHITE

ANIMAÇÃO:
- Thumb slide: 200ms cubic-bezier(0.34, 1.56, 0.64, 1)
- Color fade: 150ms

INTERAÇÃO:
- Cursor: pointer
- Tap target: mínimo 44px

VARIAÇÃO:
With label: [Toggle] "Enable Smart Mode"
```

### Checkbox
```
DIMENSÕES:
- Box: 20x20px
- Border Radius: 4px
- Border: 2px

CORES:
- Unchecked:  Border PRIMARY_BLUE, Background transparent
- Checked:    Background PRIMARY_BLUE, Checkmark branco
- Hover:      Border PRIMARY_TEAL, shadow leve
- Disabled:   Greyed out, cursor not-allowed

ANIMAÇÃO:
- Checkmark appear: 200ms spring
- Border color: 150ms

LAYOUT:
[☑] Label text (gap 12px)
```

---

## 5. PROGRESS INDICATORS

### Progress Bar Linear
```
DIMENSÕES:
- Height: 4px
- Max width: 100% (do container)
- Border Radius: 2px

CORES:
- Background (empty): rgba(255, 255, 255, 0.1)
- Fill (progress):    gradient PRIMARY_BLUE → PRIMARY_TEAL
- Label:              TEXT_SECONDARY

ANIMAÇÃO:
- Fill width: duration dependente do valor
  - 0-25%: 300ms
  - 25-75%: 1000ms
  - 75-100%: 500ms

VARIAÇÕES:
- Com percentual: "45% complete"
- Com label: "Processing 324 photos"
- Indeterminate (infinita)

INDETERMINATE:
- Shimmer left-to-right infinito
- Opacity fluctua de 0.3 a 1.0
```

### Circular Progress
```
DIMENSÕES:
- Diâmetro: 40px (small), 60px (medium), 80px (large)
- Stroke width: 4px

CORES:
- Background track: rgba(255, 255, 255, 0.1)
- Progress fill:    gradient PRIMARY_BLUE → PRIMARY_TEAL
- Center text:      TEXT_PRIMARY (percentual)

ANIMAÇÃO:
- Strokedasarray: animação SVG
- Rotação continuous para indeterminate

EXEMPLO:
    45%
 ╱────╲
│      │
│      │
 ╲────╱
```

### Skeleton Loading
```
VISUAL:
- Placeholder com cor DARK_ALT
- Shimmer animation left-to-right
- Border radius igual ao componente real

CORES:
- Background: DARK_ALT (#27272F)
- Shimmer: LINEAR gradient 45deg
  De: rgba(255,255,255,0) até rgba(255,255,255,0.15) até rgba(255,255,255,0)

ANIMAÇÃO:
- Shimmer movement: 1.5s infinite
- Easing: ease-in-out

VARIAÇÕES:
- Circular (avatar)
- Rectangle (card)
- Text lines
```

---

## 6. BADGES & LABELS

### Badge
```
DIMENSÕES:
- Padding: 4px 12px
- Height: 24px
- Border Radius: 12px (FULL)
- Font: CAPTION_BOLD (12px)

VARIAÇÕES DE COR:
- Default:    Background: CARD_BG, Border: 1px rgba(255,255,255,0.2)
- Primary:    Background: rgba(51, 102, 255, 0.2), Text: PRIMARY_BLUE
- Success:    Background: rgba(77, 184, 125, 0.2), Text: SUCCESS
- Warning:    Background: rgba(255, 165, 0, 0.2), Text: WARNING
- Error:      Background: rgba(255, 107, 107, 0.2), Text: ERROR

EXEMPLOS:
[AI Detected] [Duplicate] [4 Similar] [Low Quality]

COM ÍCONE:
[✓ Verified] (icon + text, gap 6px)
```

### Label / Tag
```
ESTRUTURA:
- Padding: 8px 12px
- Border Radius: 6px
- Font: BODY_SMALL (13px)
- Removível (com X):  Gap 8px, cursor pointer

CORES:
- Background: CARD_BG
- Border: 1px rgba(51, 102, 255, 0.3)
- Text: TEXT_PRIMARY

VARIAÇÕES:
- Filled:     Background color + text white
- Outline:    Background transparent + border + text color
- Soft:       Background com baixa opacity + text cor

EXEMPLO:
[Portrait ✕] [Landscape ✕] [Sunset ✕]
```

---

## 7. NAVIGATION

### TabBar (macOS)
```
ESTRUTURA:
- Height: 44px
- Padding: 12px horizontal
- Gap entre tabs: 8px
- Background: CARD_BG com transparência

ESTILO ABAS:
- Text: BODY_SMALL (13px)
- Icon size: 18px
- Padding: 8px 12px

ESTADOS:
- Default:   Text: TEXT_SECONDARY
- Active:    Text: PRIMARY_BLUE
             Underline: 3px PRIMARY_BLUE (bottom)
             Font: semibold

ANIMAÇÃO:
- Underline slide: 200ms ease-out
- Text color: 150ms
- Icon color: 150ms

CONTEÚDO:
[🏠 Home] [📸 Library] [✨ Duplicates] [🔧 Settings]
```

### Sidebar / Navigation
```
ESTRUTURA:
- Width: 260px (macOS) ou 280px (iPad)
- Background: CARD_BG
- Padding: 24px vertical
- Items gap: 8px

ITEM PADRÃO:
- Altura: 44px
- Padding: 12px 16px
- Ícone: 18px (esquerda)
- Label: BODY_REGULAR (15px)
- Gap: 12px

ESTADOS:
- Default:   Color: TEXT_SECONDARY
             Cursor: pointer
- Hover:     Background: rgba(51, 102, 255, 0.1)
- Active:    Background: rgba(51, 102, 255, 0.2)
             Text: PRIMARY_BLUE
             Left border: 3px PRIMARY_BLUE

ANIMAÇÃO:
- Background: 150ms
- Border slide-in: 150ms

SEÇÕES:
- Main (Home, Library, Scan)
- Tools (Duplicates, Similar, Quality)
- Settings, Help
```

---

## 8. MODALS & DIALOGS

### Modal/Dialog Box
```
ESTRUTURA:
- Background overlay: rgba(0, 0, 0, 0.6)
- Modal background: CARD_BG
- Border: 1px rgba(255, 255, 255, 0.1)
- Border Radius: 16px (XL)
- Shadow: ELEVATION_4
- Min width: 400px
- Max width: 600px
- Padding: 32px

ANIMAÇÃO ENTRADA:
- Fade in: opacity 0→1, 200ms
- Scale in: scale 0.9→1.0, 200ms
- Delay staggered para elementos

LAYOUT:
┌─────────────────────┐
│ Título         [✕]  │
├─────────────────────┤
│                     │
│   Conteúdo          │
│                     │
├─────────────────────┤
│ [Cancel]    [Confirm]│
└─────────────────────┘

BOTÕES:
- Primary (direita): Ação principal
- Secondary (esquerda): Cancelar
- Spacing: 12px entre botões
```

### Confirmation Dialog
```
VISUAL:
- Ícone de confirmação (teal, 40px)
- Título bold
- Descrição em gray
- 2 botões (confirm em red se destrutivo)

EXEMPLO:
🚨
Delete 5 photos?
These photos will be permanently removed.

[Cancel] [Delete]
```

---

## 9. TOOLTIPS

```
ESTRUTURA:
- Padding: 8px 12px
- Background: rgba(0, 0, 0, 0.9)
- Text: 12px white
- Border Radius: 6px
- Max width: 200px
- Pointer: 8px triangle

ANIMAÇÃO:
- Fade in: 200ms
- Aparece em hover após 200ms delay

POSIÇÃO:
- Top/Bottom (preferência)
- Auto adjust em edges

EXEMPLO:
─────────────────────
│ Duplicate threshold │
│ (lower = stricter)  │
─────────────────────
        ▼
    [?] (help icon)
```

---

## 10. EMPTY & ERROR STATES

### Empty State
```
LAYOUT:
- Ícone grande: 80x80px, color: TEXT_TERTIARY
- Título: HEADING_3, TEXT_PRIMARY
- Descrição: BODY_SMALL, TEXT_SECONDARY
- CTA button: PRIMARY (opcional)
- Spacing: 24px entre elementos

EXEMPLO:
          📭
    No duplicates found
  Your photos are organized!
    
    [Scan Again]
```

### Error State
```
LAYOUT:
- Ícone: ⚠️ 64x64px (WARNING color)
- Título: HEADING_3, "Something went wrong"
- Mensagem: BODY_SMALL
- Error code: CAPTION, TEXT_TERTIARY
- CTAs: [Retry] [Settings]

EXEMPLO:
       ⚠️
  Processing failed
Failed to read photo metadata.
Error code: PHOTOS_001

[Retry] [Open Settings]
```

---

## DOCUMENTO DE REFERÊNCIA

Todos os componentes devem manter:
✅ Consistência de espaçamento (múltiplos de 4px)
✅ Tipografia padronizada
✅ Estados completos documentados
✅ Animações suaves (150ms-300ms base)
✅ Accessibility (WCAG AA minimum)
✅ Documentação de uso com exemplos
