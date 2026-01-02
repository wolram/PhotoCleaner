# ✨ ANIMAÇÕES & MICROINTERAÇÕES - PHOTOCLEANER

## 1. TIMING & EASING

### Durations Padrão
```
INSTANT:        0ms (imperceptível)
FAST:          150ms (feedback rápido)
NORMAL:        300ms (padrão)
SLOW:          500ms (transitions importantes)
VERY_SLOW:     800ms (intros, hero animations)
VERY_VERY_SLOW: 2000ms+ (background, loops infinitos)
```

### Easing Functions
```
EASE_OUT_QUAD:      cubic-bezier(0.25, 0.46, 0.45, 0.94)
                    Uso: Elementos deixando tela
EASE_OUT_CUBIC:     cubic-bezier(0.215, 0.61, 0.355, 1)
                    Uso: Modais abrindo
EASE_IN_OUT_QUAD:   cubic-bezier(0.455, 0.03, 0.515, 0.955)
                    Uso: Hover states suaves
EASE_IN_OUT_CUBIC:  cubic-bezier(0.645, 0.045, 0.355, 1)
                    Uso: Transições complexas
EASE_OUT_BOUNCE:    cubic-bezier(0.34, 1.56, 0.64, 1)
                    Uso: Spring effects
EASE_IN_ELASTIC:    cubic-bezier(0.6, -0.28, 0.735, 0.045)
                    Uso: Scale entries playful
LINEAR:             linear
                    Uso: Contínuas (spinning, scrolling)
```

### Swift/SwiftUI Equivalentes
```
.easeOut            → cubic-bezier(0.25, 0.46, 0.45, 0.94)
.easeIn             → cubic-bezier(0.42, 0, 1, 1)
.easeInOut          → cubic-bezier(0.42, 0, 0.58, 1)
.linear             → linear
.spring(response: 0.3, dampingFraction: 0.7)
                    → Bounce effect para 300ms com 70% damping
```

---

## 2. BACKGROUND ANIMADO (HERO)

### Animated Gradient Background
```
VISUAL:
- 2 orbes circulares animadas
- Blur 80px para efeito bokeh
- Gradientes com cores primárias

ORB 1:
- Posição: top -200px, left -150px
- Tamanho: 400x400px
- Cores: PRIMARY_BLUE (opaco) → PRIMARY_BLUE (transparente)
- Animação: float 8s ease-in-out infinite
  Keyframes:
    0%: translate(0, 0)
    50%: translate(30px, -30px)
    100%: translate(0, 0)

ORB 2:
- Posição: bottom -100px, right -100px
- Tamanho: 350x350px
- Cores: PRIMARY_TEAL (opaco) → PRIMARY_TEAL (transparente)
- Animação: float-reverse 10s ease-in-out infinite
  Keyframes:
    0%: translate(0, 0)
    50%: translate(-30px, 30px)
    100%: translate(0, 0)

BACKDROP:
- Base color: DARK_BG
- Overlay: Semi-transparent CARD_BG
- Mantém legibilidade de conteúdo (contrast 4.5:1+)

PERFORMANCE:
- GPU accelerated (use transform, não position)
- Capped em 60fps
- Use will-change: transform
```

### HTML/CSS Implementation
```css
@keyframes float {
  0%, 100% { transform: translate(0, 0); }
  50% { transform: translate(30px, -30px); }
}

@keyframes float-reverse {
  0%, 100% { transform: translate(0, 0); }
  50% { transform: translate(-30px, 30px); }
}

.orb-1 {
  animation: float 8s ease-in-out infinite;
  will-change: transform;
}

.orb-2 {
  animation: float-reverse 10s ease-in-out infinite;
  will-change: transform;
}
```

### SwiftUI Implementation
```swift
ZStack {
    // Orbs animadas
    Circle()
        .fill(LinearGradient(...))
        .offset(x: animatingOffset.width, y: animatingOffset.height)
        .animation(
            Animation.easeInOut(duration: 8)
                .repeatForever(autoreverses: true),
            value: animatingOffset
        )
}
.onAppear {
    withAnimation {
        animatingOffset = CGSize(width: 30, height: -30)
    }
}
```

---

## 3. TRANSITIONS

### Fade Transition
```
PROPRIEDADE: opacity
DURATION: 200ms (FAST)
EASING: ease-in-out

KEYFRAMES:
0%:    opacity: 0
100%:  opacity: 1

USO:
- Elementos simples aparecendo
- Overlay de modais
- Card lists
- Text content

EXEMPLO:
Card aparece sem movimento, apenas opacidade
```

### Slide Transition
```
VARIAÇÕES:

SLIDE_IN_LEFT:
Duration: 300ms
Easing: ease-out-cubic
Keyframes:
  0%:   transform: translateX(-100px), opacity: 0
  100%: transform: translateX(0), opacity: 1
Uso: Sidebar opening, side panels

SLIDE_IN_TOP:
Duration: 300ms
Easing: ease-out-cubic
Keyframes:
  0%:   transform: translateY(-50px), opacity: 0
  100%: transform: translateY(0), opacity: 1
Uso: Toast notifications, header elements

SLIDE_IN_RIGHT:
Duration: 300ms
Easing: ease-out-cubic
Keyframes:
  0%:   transform: translateX(100px), opacity: 0
  100%: transform: translateX(0), opacity: 1
Uso: Detail panels, drawers
```

### Scale Transition
```
ZOOM_IN:
Duration: 250ms
Easing: ease-out-cubic
Keyframes:
  0%:   transform: scale(0.9), opacity: 0
  100%: transform: scale(1), opacity: 1
Uso: Modals, popups, important cards

ZOOM_OUT:
Duration: 250ms
Easing: ease-in-cubic
Keyframes:
  0%:   transform: scale(1), opacity: 1
  100%: transform: scale(0.9), opacity: 0
Uso: Elementos sendo fechados/removidos
```

### Morph Transition
```
PROPRIEDADE: border-radius
DURATION: 300ms
EASING: ease-in-out

CIRCLE_TO_SQUARE:
0%:   border-radius: 50% (círculo perfeito)
100%: border-radius: 8px (quadrado com cantos)

QUADRADO_TO_CIRCLE:
0%:   border-radius: 8px
100%: border-radius: 50%

USO:
- State transitions importantes
- Visual feedback inteligente
- Conversão de estado (play → pause, etc)
```

---

## 4. HOVER & INTERACTIVE STATES

### Button Hover
```
PROPRIEDADES ANIMADAS:
- background-color: 150ms ease-out
- transform: 150ms ease-out
- box-shadow: 150ms ease-out

TRANSFORMAÇÃO:
- translateY(-2px) para lifted effect
- scale(1.02) para engrandecimento sutil

EXEMPLO PRIMARY BUTTON:
Default:
  Background: #3366FF
  Transform: scale(1), translateY(0)
  Shadow: 0 10px 30px rgba(51, 102, 255, 0.2)

Hover:
  Background: #2450DD
  Transform: scale(1.02), translateY(-2px)
  Shadow: 0 15px 40px rgba(51, 102, 255, 0.3)

Active:
  Transform: scale(0.98), translateY(0)
  Background: #1A3CA8
```

### Card Hover
```
PROPRIEDADES:
- box-shadow: ELEVATION_1 → ELEVATION_2, 200ms
- transform: 200ms ease-out
- border-color: fade, 150ms

TRANSFORMAÇÃO:
- translateY(-4px) para lifting

BORDER COLOR:
Default:   rgba(255, 255, 255, 0.1)
Hover:     rgba(51, 102, 255, 0.3)
Active:    rgba(51, 102, 255, 0.6)

EXEMPLO:
Photo card em library:
Hover → Eleva-se 4px + borda azul + sombra aumenta
```

### Input Focus
```
PROPRIEDADES:
- border-color: 150ms ease-out
- box-shadow: 150ms ease-out
- background-color: 150ms ease-out

ESTADOS:

Default:
  Border: 1px rgba(255, 255, 255, 0.2)
  Background: #27272F
  Shadow: none

Focused:
  Border: 2px #3366FF
  Background: rgba(51, 102, 255, 0.05)
  Shadow: 0 0 0 3px rgba(51, 102, 255, 0.1)

Error:
  Border: 2px #FF6B6B
  Shadow: 0 0 0 3px rgba(255, 107, 107, 0.1)
```

---

## 5. LOADING STATES

### Pulse Animation
```
VISUAL:
- Anel ou círculo pulsando
- Expande para fora
- Opacidade decresce

DURAÇÃO: 1.5s infinite
EASING: ease-out

KEYFRAMES:
0%:   transform: scale(1), opacity: 1
100%: transform: scale(1.3), opacity: 0

CORES:
- Primária: PRIMARY_BLUE
- Secundária: PRIMARY_TEAL

USO:
- Processamento em andamento
- Sync status
- Upload/Download
```

### Spinner Circular
```
VISUAL:
- SVG circle com strokeDasharray animado
- Rotação infinita

DURAÇÃO: 1s linear infinite
EASING: linear

PROPRIEDADE:
- stroke-dashoffset: animado
  0%:   offset: 0
  100%: offset: -100

CORES:
- Stroke: gradient PRIMARY_BLUE → PRIMARY_TEAL
- Background: rgba(255, 255, 255, 0.1)

SVG SPEC:
- viewBox: 0 0 100 100
- Circle: cx=50, cy=50, r=45
- strokeWidth: 4
- strokeLinecap: round
```

### Skeleton Shimmer
```
VISUAL:
- Placeholder color: DARK_ALT
- Shimmer effect: gradient da esquerda para direita

DURAÇÃO: 1.5s infinite
EASING: ease-in-out

SHIMMER GRADIENT:
background: linear-gradient(
  90deg,
  #1F1F26 0%,
  #27272F 50%,
  #1F1F26 100%
)
background-size: 200% 100%
animation: shimmer 1.5s ease-in-out infinite

KEYFRAMES:
0%:   background-position: 200% 0
100%: background-position: -200% 0

USO:
- Carregando lista de photos
- Cards enquanto busca dados
- Profile pictures

VARIAÇÕES:
- Circular (avatars)
- Rectangle (cards)
- Lines (text)
```

---

## 6. NOTIFICATIONS & TOASTS

### Toast Notification
```
ENTRADA:
Duration: 300ms
Easing: ease-out-cubic
Transform: slideInUp + fadeIn
  0%:   translateY(100px), opacity: 0
  100%: translateY(0), opacity: 1

SAÍDA (AUTO-DISMISS):
Duration: 300ms
Easing: ease-in-cubic
Delay: 3000ms (tempo de exibição)
Transform: slideOutDown + fadeOut
  0%:   translateY(0), opacity: 1
  100%: translateY(100px), opacity: 0

LAYOUT:
┌──────────────────────────────┐
│ ✓ 5 photos deleted           │
└──────────────────────────────┘

POSIÇÃO: Bottom-center
ALTURA: 48px
PADDING: 16px 24px
BORDER-RADIUS: 8px

CORES:
- Success: Background: rgba(77, 184, 125, 0.9), Text: white
- Error:   Background: rgba(255, 107, 107, 0.9), Text: white
- Info:    Background: rgba(51, 102, 255, 0.9), Text: white
```

### Progress Toast
```
VISUAL:
- Toast com progress bar
- Percentual ou status text
- Cancel button (X)

DURAÇÃO: Até conclusão
ATUALIZAÇÕES: Smooth width animation (150ms)

EXEMPLO:
┌──────────────────────────┐
│ Organizing photos... 45% │
│ ████████░░░░░░░ ✕       │
└──────────────────────────┘
```

---

## 7. Page & SCREEN TRANSITIONS

### Full Page Transition
```
TIPO: Fade + Scale

ENTRADA (Nova página):
Duration: 300ms
Easing: ease-out-cubic
Keyframes:
  0%:   opacity: 0, transform: scale(0.95)
  100%: opacity: 1, transform: scale(1)

SAÍDA (Página anterior):
Duration: 250ms
Easing: ease-in-cubic
Keyframes:
  0%:   opacity: 1, transform: scale(1)
  100%: opacity: 0, transform: scale(1.05)

EXEMPLO:
- Navegação entre Library → Duplicates
- Settings abrir/fechar
```

### Modal Transition
```
OVERLAY (Fundo escuro):
Entrada: fadeIn, 200ms ease-out
Saída: fadeOut, 200ms ease-in

MODAL (Caixa de diálogo):
Entrada:
  Duration: 250ms
  Easing: ease-out-cubic
  Transform: scale(0.9) + translateY(-20px) → scale(1) + translateY(0)
  Opacity: 0 → 1

Saída:
  Duration: 200ms
  Easing: ease-in-cubic
  Transform: scale(0.95) + translateY(20px)
  Opacity: 1 → 0

STAGGER (Múltiplos elementos dentro do modal):
- Title: delay 50ms
- Content: delay 100ms
- Buttons: delay 150ms
```

---

## 8. DATA UPDATES & LIST ANIMATIONS

### Add Item to List
```
ANIMAÇÃO:
- Novo item slides in + fades in
- Existentes descem com animação

NOVO ITEM:
Duration: 300ms
Easing: ease-out-cubic
Transform: slideInLeft + fadeIn
  0%:   translateX(-50px), opacity: 0, height: 0
  100%: translateX(0), opacity: 1, height: auto

EXISTENTES:
Duration: 200ms
Easing: ease-out-quad
Transform: translateY(item_height)

EXEMPLO:
[Duplicates detected!]
[↑] Existing items move down
[→ New item slides in]
```

### Remove Item from List
```
ANIMAÇÃO:
- Item slides out + fades out
- Existentes sobem com animação

REMOVIDO:
Duration: 250ms
Easing: ease-in-cubic
Transform: slideOutRight + fadeOut + collapse
  0%:   translateX(0), opacity: 1, height: auto
  100%: translateX(50px), opacity: 0, height: 0

EXISTENTES (abaixo):
Duration: 200ms
Easing: ease-out-quad
Delay: 50ms
Transform: translateY(-removed_item_height)
```

### Reorder/Sort Animation
```
COMPORTAMENTO:
- Itens que mudam de posição animam smoothly

Duration: 300ms
Easing: cubic-bezier(0.25, 0.46, 0.45, 0.94)
Transform: translateY(new_position - old_position)

EXEMPLO:
[Item A]
[Item B] ← Move down
[Item C] ← Move up
[Sorting animation plays]
```

---

## 9. PROPERTY-SPECIFIC ANIMATIONS

### Color Transitions
```
PROPRIEDADE: color, background-color, border-color
DURAÇÃO: 150ms (rápido) a 300ms (normal)
EASING: ease-in-out

EXEMPLO - Badge color change:
State: Default → Active
  background-color: CARD_BG → rgba(51, 102, 255, 0.2)
  Duration: 150ms ease-in-out
```

### Size Transitions
```
PROPRIEDADE: width, height, font-size
DURAÇÃO: 200ms (normal) a 300ms (complexo)
EASING: ease-out

EXEMPLO - Button expand:
Hover:
  width: 44px → auto (com padding)
  height: 44px → 44px (mantém)
  Duration: 200ms ease-out
```

### Opacity Transitions
```
PROPRIEDADE: opacity
DURAÇÃO: 150ms (rápido) a 300ms (fade suave)
EASING: linear ou ease-in-out

EXEMPLO - Disabled state:
opacity: 1 → 0.5
Duration: 150ms ease-in-out
```

---

## 10. PERFORMANCE GUIDELINES

### GPU Acceleration
```
SEMPRE USE (triggers GPU acceleration):
- transform (translate, rotate, scale)
- opacity

EVITE (causam repaint):
- position (top, left, right, bottom)
- width, height (em animações)
- margin, padding (em animações)
```

### Frame Rate Target
```
60fps SEMPRE que possível
Máximo de simultâneas: 3-4 animações pesadas

OTIMIZAÇÃO:
- Use will-change: transform, opacity
- Minimize reflows
- Batch DOM updates
- Use requestAnimationFrame
```

### Mobile/Tablet
```
Reduzir duração em 20% para sensação mais rápida
Desabilitar animações pesadas em baixo-end devices
Usar prefers-reduced-motion para accessibility
```

---

## SUMMARY TABLE

| Tipo | Duration | Easing | Uso |
|------|----------|--------|-----|
| Hover | 150ms | ease-out | Button, Card hover |
| Focus | 150ms | ease-in-out | Input focus ring |
| Transition | 300ms | ease-out-cubic | Page transitions |
| Modal | 250ms | ease-out-cubic | Modal open |
| Loading | 1.5s | ease-out | Pulse animations |
| Spinner | 1s | linear | Loading spinner |
| Shimmer | 1.5s | ease-in-out | Skeleton loaders |
| Toast | 300ms | ease-out-cubic | Notification entry |
| Auto-dismiss | 3s | linear | Toast duration |
| Auto-exit | 300ms | ease-in-cubic | Toast exit |
