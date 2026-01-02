# 📱 ESPECIFICAÇÕES DE TELAS - LumaClean

## 1. HOME / DASHBOARD

### Layout Structure
```
┌─────────────────────────────────┐
│  PhotoCleaner          Settings |
├─────────────────────────────────┤
│                                 │
│  Organize. Optimize. Simplify.  │ (Subtitle)
│                                 │
├─────────────────────────────────┤
│  [📸 12,847]  [⬆️ 324]  [⚡2.3GB]│
├─────────────────────────────────┤
│                                 │
│      [▶ Start Smart Scan]       │
│                                 │
├─────────────────────────────────┤
│  Quick Actions:                 │
│  [Scan Duplicates] [Last Result]│
│                                 │
├─────────────────────────────────┤
│  Recent Analysis                │
│  ──────────────────────────────  │
│  • 2h ago: 324 duplicates found │
│  • Yesterday: 52 low quality    │
└─────────────────────────────────┘
```

### Component Details

#### Header
- **Typography**: "PhotoCleaner" em HEADING_1 bold
- **Color**: Gradient blue-to-teal
- **Background**: CARD_BG semi-transparent
- **Padding**: 24px XL
- **Border**: Bottom 1px rgba(255,255,255,0.1)

#### Hero Section
- **Title**: "Organize your photos intelligently" (DISPLAY_MEDIUM)
- **Subtitle**: "Detect duplicates, find similar, clean up with AI" (BODY_LARGE)
- **Alignment**: Center
- **Spacing**: 24px above title, 40px below subtitle
- **Background**: Animated (floating orbs)

#### Stat Cards (3 colunas)
```
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ 📸           │  │ ⬆️            │  │ ⚡           │
│ Photos       │  │ Duplicates    │  │ Space        │
│ 12,847       │  │ 324           │  │ 2.3 GB       │
│              │  │               │  │              │
└──────────────┘  └──────────────┘  └──────────────┘

Estrutura:
- Icon: 24px, color varia por card (blue, coral, teal)
- Label: CAPTION, TEXT_SECONDARY
- Value: HEADING_3, TEXT_PRIMARY
- Padding: 16px
- Background: CARD_BG + border subtle
- Height: 140px
- Width: equal distribution
- Gap: 16px

Hover:
- Border color fade para PRIMARY_BLUE
- Shadow upgrade
- Transform: translateY(-4px)
```

#### Primary CTA Button
```
Button: "Start Smart Scan"
Type: Primary
Size: 44px height
Width: 100% (max 400px)
Icon: magnifying glass (18px)
Action: Navigate to Scan screen

States:
- Default: Blue gradient
- Hover: Elevated + glow
- Scanning: Pulse animation (teal)
- Disabled: Grayed out
```

#### Quick Actions
```
┌────────────────────────────────┐
│ Quick Actions                  │
├────────────────────────────────┤
│ [Scan Duplicates] [Last Result]│
│ [View All]                     │
└────────────────────────────────┘

- 2 buttons side-by-side
- Tipo: Secondary
- Gap: 12px
- Full width when available
- Responsive: Stack on mobile
```

#### Recent Activity
```
┌────────────────────────────────┐
│ Recent Analysis                │
├────────────────────────────────┤
│ ✓ 2h ago: 324 duplicates found│
│ ⚠️ Yesterday: 52 low quality    │
│ ✓ 3 days ago: Complete scan    │
└────────────────────────────────┘

- List layout
- Item height: 48px
- Icon: 16px, color state
- Time: TEXT_TERTIARY, right aligned
- Description: BODY_SMALL
- Divider: subtle bottom border
```

---

## 2. LIBRARY SCAN SCREEN

### Layout During Scan
```
┌─────────────────────────────────┐
│  < Back           Scanning      │
├─────────────────────────────────┤
│                                 │
│      Scanning your library...   │ (Title)
│                                 │
│         📸                      │ (Animated)
│                                 │
│      ███████░░░░░░             │ (Progress)
│      45% (3,284 / 7,124)        │
│                                 │
│  Time remaining: 2 min 15 sec  │
│  [Cancel]                       │
│                                 │
├─────────────────────────────────┤
│  Status: Analyzing duplicates   │
│  Speed: 234 photos/sec          │
└─────────────────────────────────┘
```

### Components

#### Header
- Title: "Scanning your library..." (HEADING_2)
- Center aligned
- Color: TEXT_PRIMARY

#### Animated Indicator
```
🌀 Spinner circular
- Size: 80x80px
- Stroke: 4px gradient blue-teal
- Rotation: 360° in 1s
- At center of screen
```

#### Progress Bar
```
║ ████████░░░░░░░░░ ║  45%

- Width: 100% (max 300px)
- Height: 4px
- Background track: rgba(255,255,255,0.1)
- Fill: gradient blue → teal
- Smooth animation on value change (300ms)
- Label: TEXT_SECONDARY right

Abaixo:
- "45% (3,284 / 7,124)"
- BODY_SMALL, TEXT_SECONDARY
```

#### Stats Row
```
Time remaining: 2 min 15 sec
Speed: 234 photos/sec

- 2 columns
- CAPTION, TEXT_SECONDARY
- Hover: show detailed info
```

#### Cancel Button
```
Button: "Cancel"
Type: Secondary
Size: 44px
Width: auto (min 100px)
Action: Confirm cancel dialog
```

#### Status Footer
```
Status: Analyzing duplicates
Speed: 234 photos/sec

- Background: DARK_ALT
- Padding: 12px 16px
- CAPTION, TEXT_SECONDARY
- Updates in real-time
```

---

## 3. DUPLICATES REVIEW SCREEN

### Layout
```
┌─────────────────────────────────┐
│  < Back      Duplicates (24)    │
├─────────────────────────────────┤
│  [All]  [Pending]  [Resolved]   │ (Tabs)
├─────────────────────────────────┤
│                                 │
│  Group 1 (5 photos)             │
│  ┌─────────┐ ┌─────────┐        │
│  │ 📸      │ │ 📸      │  ✓    │ (Photo 1, 2)
│  │ Primary │ │ Keep    │        │
│  └─────────┘ └─────────┘        │
│                                 │
│  ┌─────────┐ ┌─────────┐        │
│  │ 📸      │ │ 📸      │        │ (Photo 3, 4)
│  │ Delete  │ │ Delete  │        │
│  └─────────┘ └─────────┘        │
│                                 │
│  [Auto-Select Best] [Deselect]  │
│                                 │
│  Group 2 (3 photos)             │
│  [...]                          │
│                                 │
└─────────────────────────────────┘
```

### Components

#### Header
- Back button + Title: "Duplicates (24)"
- HEADING_2 em TEXT_PRIMARY

#### Tab Navigation
```
[All]  [Pending]  [Resolved]

- 3 tabs
- Underline animation: 200ms slide
- Tab text: BODY_SMALL
- Active: blue text + bottom border
- Inactive: gray text
```

#### Duplicate Group Card
```
┌──────────────────────────────────┐
│ Group 1 (5 photos)               │
├──────────────────────────────────┤
│ ┌──────────┐ ┌──────────┐        │
│ │ Photo 1  │ │ Photo 2  │  ✓     │
│ │ Primary  │ │ Keep     │        │
│ └──────────┘ └──────────┘        │
│                                  │
│ ┌──────────┐ ┌──────────┐        │
│ │ Photo 3  │ │ Photo 4  │        │
│ │ Delete   │ │ Delete   │        │
│ └──────────┘ └──────────┘        │
│                                  │
│ [Auto-Select] [Manual Select]    │
└──────────────────────────────────┘

Container:
- Background: CARD_BG
- Border: 1px rgba(51,102,255,0.2)
- Border Radius: 12px
- Padding: 16px
- Margin-bottom: 16px
- Hover: Border blue, shadow lift
```

#### Photo Thumbnail
```
┌────────┐
│ 📸     │
│        │ ← Thumbnail 120x120px
│        │
└────────┘
        Label (Quality/Date)
        
- Border Radius: 8px
- Border: 2px based on selection
  • Selected: PRIMARY_BLUE
  • Unselected: rgba(255,255,255,0.1)
  • Primary: PRIMARY_TEAL
- Overlay on hover: semi-transparent overlay + checkbox appear
- Aspect ratio: 1:1
- Shadow: ELEVATION_1 on hover
```

#### Selection Label
```
Position: Bottom of thumbnail
- "Primary": CAPTION bold, TEAL color
- "Keep": CAPTION bold, BLUE color
- "Delete": CAPTION bold, RED color
- Animated appear (scale + fade)
```

#### Checkmark (✓)
```
Position: Top-right corner
- Size: 32x32px
- Background: PRIMARY_TEAL
- Color: White
- Border Radius: 50%
- Scale: 1.2 on appear (300ms spring)
- Only visible quando selecionado
```

#### Group Actions
```
[Auto-Select Best] [Manual Select]

- 2 buttons tipo secondary
- Full width
- Gap: 12px
- Height: 40px
- Below group de photos
```

---

## 4. SIMILAR PHOTOS SCREEN

### Layout
```
┌─────────────────────────────────┐
│  < Back    Similar (45)         │
├─────────────────────────────────┤
│  Similarity: [●●●●●○○]  (High)  │ (Slider)
├─────────────────────────────────┤
│                                 │
│  Group A (8 photos)             │
│  ┌──┐ ┌──┐ ┌──┐ ┌──┐           │
│  │📸│ │📸│ │📸│ │📸│           │
│  └──┘ └──┘ └──┘ └──┘           │
│  ┌──┐ ┌──┐ ┌──┐ ┌──┐           │
│  │📸│ │📸│ │📸│ │📸│           │
│  └──┘ └──┘ └──┘ └──┘           │
│                                 │
│  Group B (6 photos)             │
│  [...]                          │
│                                 │
│ [Select All in Group] [Deselect]│
│                                 │
└─────────────────────────────────┘
```

### Components

#### Similarity Slider
```
Similarity: [●●●●●○○]  (High)

- Label: "Similarity threshold"
- Slider: 0-100
- Current value displayed
- Teal color (accent)
- On change: real-time group refresh
- Dragging: smooth animation
```

#### Photo Grid
```
Columns responsive:
- Desktop (1200px): 4 columns
- Tablet (768px): 3 columns
- Mobile (375px): 2 columns

Gap: 12px
Height: square aspect ratio
Border Radius: 8px
```

#### Photo Item (Smaller)
```
Size: 100x100px
- Hover: scale 1.05, shadow lift
- Selected: border 2px PRIMARY_BLUE
- Batch select: checkbox overlay
```

#### Group Container
```
Similar Group A (8 photos)

- Title: BODY_REGULAR, TEXT_SECONDARY
- Padding: 16px horizontal
- Margin-bottom: 24px
- Grid dentro

Group actions:
[Select All] [Deselect] (abaixo do grid)
```

---

## 5. QUALITY FILTER SCREEN

### Layout
```
┌─────────────────────────────────┐
│  < Back      Quality Filter     │
├─────────────────────────────────┤
│  Quality Threshold:             │
│  [●●●●●●○○○] 60%               │ (Slider)
├─────────────────────────────────┤
│  Flagged Issues (234 photos)    │
│                                 │
│  [🌫️ Blur] [☀️ Exposure]  [🎨 Color]│
│                                 │
├─────────────────────────────────┤
│  Low Quality Photos             │
│  ┌──┐ ┌──┐ ┌──┐ ┌──┐           │
│  │📸│ │📸│ │📸│ │📸│           │
│  │⚠️ │ │⚠️ │ │⚠️ │ │⚠️ │           │
│  └──┘ └──┘ └──┘ └──┘           │
│                                 │
│ [Delete Low Quality]            │
│                                 │
└─────────────────────────────────┘
```

### Components

#### Quality Threshold Slider
```
[●●●●●●○○○] 60%

- Range: 0-100
- Default: 30%
- Thumb: 18x18px
- Track height: 4px
- Live preview de filtered photos
- Smooth updates (150ms)
```

#### Issue Badges
```
[🌫️ Blur] [☀️ Exposure] [🎨 Color]

- Pills shaped (border-radius full)
- Background: rgba(color, 0.2)
- Text: CAPTION bold
- Color varies by issue type:
  • Blur: CORAL
  • Exposure: WARNING (amber)
  • Color: Primary (blue)
- Tap to filter by issue type
```

#### Quality Indicator Icon
```
Overlay no thumbnail:
⚠️ Yellow warning icon
20x20px
Top-right corner
Indicate why flagged
```

#### Delete Button
```
[Delete Low Quality]

Type: Danger
Full width
Height: 44px
Icon + text
Confirm dialog on click
```

---

## 6. SETTINGS SCREEN

### Layout
```
┌─────────────────────────────────┐
│  < Back        Settings         │
├─────────────────────────────────┤
│  PROCESSING                     │
│  ┌─────────────────────────────┐│
│  │ Duplicate Threshold      0.5 │
│  │ ▬▼▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬  │
│  └─────────────────────────────┘│
│  Lower = stricter matching      │
│                                 │
│  ┌─────────────────────────────┐│
│  │ Similarity Threshold      12 │
│  │ ▬▬▬▼▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬  │
│  └─────────────────────────────┘│
│  Lower = more similar            │
│                                 │
│  Concurrent Tasks         [  8  ]
│                                 │
├─────────────────────────────────┤
│  INTERFACE                      │
│  Dark Mode         [Toggle ON]  │
│  Animations        [Toggle ON]  │
│                                 │
├─────────────────────────────────┤
│  ADVANCED                       │
│  [Reset to Defaults]            │
│  [Privacy Policy]               │
│  [About PhotoCleaner]           │
│                                 │
└─────────────────────────────────┘
```

### Components

#### Settings Section
```
┌──────────────────────────┐
│ SETTINGS TITLE           │
├──────────────────────────┤
│ [Setting 1]              │
│ [Setting 2]              │
│ [Setting 3]              │
└──────────────────────────┘

- Header: HEADING_4, TEXT_SECONDARY, ALL CAPS
- Background: subtle separator
- Padding: 12px 16px
- Items: padding 16px
- Divider entre items: 1px border bottom
```

#### Slider Setting
```
Duplicate Threshold: 0.5

┌─────────────────────────────┐
│ Label          Value (right)│
│ ▬▼▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬│
│ Helper text below           │
└─────────────────────────────┘

- Label: BODY_REGULAR
- Value: BODY_REGULAR bold (right aligned)
- Slider: full width
- Helper: CAPTION, TEXT_SECONDARY
- Padding: 16px
```

#### Number Input Setting
```
Concurrent Tasks: [  8  ]

- Input box: 60x44px
- Number spinner (up/down)
- Min: 1, Max: 16
- Default: 8
```

#### Toggle Setting
```
Dark Mode         [Toggle ON]

- Label left (BODY_REGULAR)
- Toggle right
- State text: TEXT_SECONDARY small
- Height: 44px
```

#### Button Setting
```
[Reset to Defaults]
[Privacy Policy]
[About PhotoCleaner]

Type: Tertiary
Full width
Height: 44px
Text: center aligned
Icon arrow right (optional)
```

---

## 7. DETAIL / FULLSCREEN VIEW (Photo Preview)

### Layout
```
┌─────────────────────────────────┐
│  < Back        [...]            │
├─────────────────────────────────┤
│                                 │
│          ┌──────────────┐       │
│          │              │       │
│          │              │       │
│          │   📸 (Large) │       │
│          │              │       │
│          │              │       │
│          └──────────────┘       │
│                                 │
├─────────────────────────────────┤
│  File: DSC_001234.jpg           │
│  Size: 3.2 MB                   │
│  Date: Mar 15, 2025             │
│  Quality Score: 85%             │
│                                 │
│  [Delete] [Keep]                │
│                                 │
└─────────────────────────────────┘
```

### Components

#### Full Image
```
- Max size: 80% viewport height
- Aspect ratio maintained
- Centered
- Zoom capability (pinch on trackpad)
- Shadow: ELEVATION_2
- Border Radius: 12px
```

#### Info Panel
```
File: DSC_001234.jpg         (BODY_SMALL, TEXT_SECONDARY)
Size: 3.2 MB                 (BODY_SMALL)
Date: Mar 15, 2025           (BODY_SMALL)
Quality Score: 85% ⭐⭐⭐⭐⭐  (BODY_SMALL + stars)

- Padding: 16px
- Background: CARD_BG
- Grid or list layout
- Icons left (16px)
```

#### Action Buttons
```
[Delete] [Keep]

- Secondary buttons
- Side by side
- Gap: 12px
- Full width responsive
- Height: 44px
```

---

## 8. MODALS / DIALOGS

### Confirmation Dialog
```
┌──────────────────────────────────┐
│  ⚠️ Confirm Delete              │
├──────────────────────────────────┤
│                                  │
│  Delete 5 photos?                │
│                                  │
│  These will be removed from      │
│  Photos library permanently.     │
│                                  │
│  [Cancel]  [Delete]              │
│                                  │
└──────────────────────────────────┘

- Icon: 40x40px, color: WARNING
- Title: HEADING_3
- Description: BODY_SMALL
- Buttons: Cancel (secondary), Delete (danger)
- Button gap: 12px, full width responsive
```

### Error Dialog
```
┌──────────────────────────────────┐
│  ❌ Error                         │
├──────────────────────────────────┤
│                                  │
│  Failed to process photos        │
│                                  │
│  Permission denied. Grant        │
│  Photos access in Settings.      │
│                                  │
│  [Settings]  [Dismiss]           │
│                                  │
└──────────────────────────────────┘
```

### Success Toast
```
┌──────────────────────────────────┐
│ ✓ 5 photos deleted               │
└──────────────────────────────────┘

- Duration: 3 seconds auto-dismiss
- Position: bottom center
- Animation: slide up + fade
- Exit: slide down + fade
```

---

## RESPONSIVENESS

### Breakpoints
```
Mobile (375px):
- Single column layouts
- Stacked buttons
- Smaller thumbnails (2 per row)
- Full-width components

Tablet (768px):
- 2-3 columns where appropriate
- Side-by-side buttons
- Medium thumbnails (3 per row)

Desktop (1024px+):
- Multi-column optimal layout
- 4 columns for photo grids
- Sidebar navigation visible
```

### Safe Areas
```
macOS: padding 24px horizontal minimum
iPad: respect safe area insets
```

---

## ANIMATION SUMMARY

- ✨ Screen transitions: 300ms fade + scale
- 🎨 Hover states: 150-200ms ease-out
- 📊 Progress updates: smooth 150ms
- 🔄 Loading: 1.5s shimmer or 1s spinner
- 💨 Dismiss: 200-300ms fade + slide
- ✅ Success: toast auto-dismisses 3s
