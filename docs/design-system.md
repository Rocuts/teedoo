# TeeDoo Design System

NovaForge architectural structure adapted with TeeDoo's Purple Enterprise color palette.

## Design Philosophy

- **Purple Enterprise aesthetic**: Deep indigo/violet tones replace pure black accents
- **Precision over ornament**: Sharp edges (2px radius on buttons), thin 1px borders, no drop shadows
- **Glassmorphism**: Frosted glass effects with violet-tinted borders
- **Dual theme**: Dark (GitHub-dark base) and Light (warm gray base) with animated transitions
- **Typography-driven**: Geist font family, fluid-scaled headlines
- **Generous whitespace**: Sections breathe with `py-32` (128px)
- **Accessibility-first**: WCAG AA contrast, `prefers-reduced-motion` respected

## Anti-Patterns (NEVER do these)

- Colorful gradients, rainbow effects, or neon glows on UI elements
- Drop shadows on cards or panels (use border color shifts instead)
- Rounded corners larger than 16px on cards (glassmorphism exception)
- Decorative animations without informational purpose
- Skeleton loaders with animated shimmer (use static placeholders)
- Thick borders (always 1px)
- Opacity-based text hierarchy on light backgrounds (use specific gray values)

---

## Color Palette

### Surfaces

| Token | Dark Mode | Light Mode | Usage |
|---|---|---|---|
| `surface-base` | `#0D1117` | `#FAFAFA` | Main background |
| `surface-elevated` | `#161B22` | `#F5F3FF` (Violet-50) | Cards, panels, alt sections |
| `surface-card` | `#1C2128` | `#FFFFFF` | Card backgrounds |
| `surface-border` | `#3D444D` | `#E5E7EB` | Borders, dividers |
| `surface-input` | `#0D1117` 66% | `#F3F4F6` | Input fields |
| `surface-modal` | `#161B22` EE% | `#FFFFFF` F0% | Modal overlays |
| `surface-sidebar` | `#0D1117` | `#F5F3FF` | Sidebar bg |
| `surface-topbar` | `#161B22` 60% | `#EEEEEE` EE% | App bar / top bar |

### Text Colors

| Token | Dark Mode | Light Mode | Usage |
|---|---|---|---|
| `text-primary` | `#F0F3F6` | `#1E1B4B` (Indigo-950) | Headlines, primary text |
| `text-secondary` | `#9EA7B3` | `#6B7280` (Gray-500) | Descriptions, secondary |
| `text-tertiary` | `#636E7B` | `#6B7280` | Hints, placeholders |
| `text-on-accent` | `#FFFFFF` | `#FFFFFF` | Text on accent buttons |

### Accent Colors (Violet)

| Token | Dark Mode | Light Mode | Usage |
|---|---|---|---|
| `accent-primary` | `#8B5CF6` (Violet-500) | `#7C3AED` (Violet-600) | Primary CTA, focus rings |
| `accent-hover` | `#A78BFA` (Violet-400) | `#6D28D9` (Violet-700) | Hover states |
| `accent-secondary` | `#7C3AED` (Violet-600) | `#8B5CF6` (Violet-500) | Secondary accent |
| `accent-subtle` | `#8B5CF6` 10% | `#8B5CF6` 10% | Accent backgrounds |

### AI Badge Colors

| Token | Dark Mode | Light Mode |
|---|---|---|
| `ai-purple` | `#A78BFA` | `#8B5CF6` |
| `ai-purple-bg` | `#8B5CF6` 10% | `#8B5CF6` 10% |
| `ai-purple-border` | `#A78BFA` 20% | `#8B5CF6` 20% |

### Status Colors

| Token | Dark Mode | Light Mode |
|---|---|---|
| `success` | `#3FB950` | `#16A34A` |
| `success-bg` | `#3FB950` 10% | `#16A34A` 10% |
| `warning` | `#D29922` | `#CA8A04` |
| `warning-bg` | `#D29922` 10% | `#CA8A04` 10% |
| `error` | `#F85149` | `#DC2626` |
| `error-bg` | `#F85149` 10% | `#DC2626` 10% |
| `info` | `#58A6FF` | `#2563EB` |
| `info-bg` | `#58A6FF` 10% | `#2563EB` 10% |

### Border Colors

| Token | Dark Mode | Light Mode |
|---|---|---|
| `border-primary` | `#3D444D` | `#E5E7EB` |
| `border-subtle` | `#8B5CF6` 27% | `#E5E7EB` |
| `border-accent` | `#8B5CF6` 27% | `#8B5CF6` 27% |

### Glass Effects

| Token | Dark Mode | Light Mode |
|---|---|---|
| `glass-fill` | `#1C2128` 20% | `#F5F3FF` 60% |
| `glass-border` | `#8B5CF6` 20% | `#E9D5FF` 53% |
| `glass-hover` | `#2D333B` 33% | `#F3E8FF` 53% |
| `blur-sigma` | 40.0 | 16.0 |
| `card-radius` | 16.0 | 16.0 |

---

## Typography

### Font Stack

```
--font-sans:    Geist
--font-heading: Geist
--font-mono:    Geist Mono

Smoothing: antialiased (both webkit and moz)
```

### Fluid Type Scale

| Level | CSS Value | Min | Max |
|---|---|---|---|
| Hero | `clamp(3.5rem, 8vw, 7rem)` | 56px | 112px |
| H1 | `clamp(2.5rem, 6vw, 5rem)` | 40px | 80px |
| H2 | `clamp(1.5rem, 3vw, 2.25rem)` | 24px | 36px |
| Body | `clamp(1.05rem, 1.5vw, 1.25rem)` | 16.8px | 20px |

### Text Styles

| Style | Size | Weight | Tracking | Line Height |
|---|---|---|---|---|
| Hero headline | fluid-hero | bold (700) | tracking-tight | tight (1.1) |
| Section headline | fluid-h1 | bold (700) | tracking-tight | tight (1.1) |
| Subsection title | fluid-h2 | semibold | tracking-tight | snug (1.3) |
| Card title | text-xl | semibold | default | snug |
| Body copy | fluid-p | normal | default | relaxed (1.75) |
| Eyebrow | text-[10px] | bold | tracking-[0.3em+] | normal |
| Small label | text-xs | medium | tracking-wide | normal |

---

## Border Radius

| Token | Value | Usage |
|---|---|---|
| `radius-sm` | 2px | Buttons, small interactive elements |
| `radius-md` | 4px | Inputs, badges, chips |
| `radius-lg` | 6px | Cards, panels, containers |
| `radius-xl` | 8px | Maximum for standard elements |
| `radius-glass` | 16px | Glass cards only (glassmorphism exception) |

---

## Spacing

### Section Rhythm

| Pattern | Value | Pixels |
|---|---|---|
| Standard section | `py-32` | 128px |
| Compact section | `py-24` | 96px |
| Tight section | `py-12` | 48px |
| Container padding | `px-6` | 24px |

### Component Spacing

| Pattern | Value | Context |
|---|---|---|
| Card padding | `p-8` | Standard cards |
| Card padding (large) | `p-10` | Feature/service cards |
| Card padding (hero) | `p-12` | Flagship cards |
| Grid gap (cards) | `gap-6` | Card grids |
| Grid gap (medium) | `gap-8` | Mixed layouts |
| Grid gap (section) | `gap-12` | Section internals |
| Grid gap (large) | `gap-16` | Title + content blocks |

### Container

```
max-w-7xl mx-auto px-6
```

---

## Components

### Buttons

```
Primary (Dark):    bg-[#8B5CF6] text-white hover:bg-[#A78BFA] rounded-[2px]
Primary (Light):   bg-[#7C3AED] text-white hover:bg-[#6D28D9] rounded-[2px]
Secondary (Dark):  border border-[#3D444D] bg-transparent text-[#F0F3F6] hover:bg-[#161B22] hover:border-[#8B5CF6]/40
Secondary (Light): border border-[#E5E7EB] bg-transparent text-[#1E1B4B] hover:bg-[#F5F3FF] hover:border-[#8B5CF6]/40
Ghost (Dark):      bg-transparent text-[#9EA7B3] hover:text-[#F0F3F6] hover:bg-[#161B22]
Ghost (Light):     bg-transparent text-[#6B7280] hover:text-[#1E1B4B] hover:bg-[#F5F3FF]

Sizes:
  sm: px-5 py-2.5 text-xs font-medium tracking-wide
  md: px-7 py-3 text-sm font-medium
  lg: px-10 py-4 text-base font-medium

Focus: focus-visible:ring-2 focus-visible:ring-[#8B5CF6] focus-visible:ring-offset-2
Tap:   whileTap={{ scale: 0.98 }}
```

### Cards / Panels

```
Dark:   bg-[#161B22] border border-[#3D444D] rounded-[6px] hover:border-[#8B5CF6]/30
Light:  bg-[#F5F3FF] border border-[#E5E7EB] rounded-[6px] hover:border-[#8B5CF6]/30
Glass:  bg-[#1C2128]/20 border border-[#8B5CF6]/20 backdrop-blur-[40px] rounded-[16px]

Hover: hover:-translate-y-[2px] transition-all duration-300 ease-out
NO shadows -- ever.
Padding: p-8 (standard) or p-10 to p-12 (spacious)
```

### Inputs / Forms

```
Dark:   border-b border-[#3D444D] bg-transparent text-[#F0F3F6] placeholder:text-[#636E7B] focus:border-[#8B5CF6]
Light:  border-b border-[#E5E7EB] bg-transparent text-[#1E1B4B] placeholder:text-[#6B7280] focus:border-[#7C3AED]

Chip (unselected dark):  border border-[#3D444D] text-[#9EA7B3]
Chip (selected dark):    bg-[#8B5CF6] text-white border-[#8B5CF6]
Chip (unselected light): border border-[#E5E7EB] text-[#6B7280]
Chip (selected light):   bg-[#7C3AED] text-white border-[#7C3AED]
```

### Navigation

```
Dark header:   bg-[#0D1117] border-b border-[#3D444D] text-[#F0F3F6]
Light header:  bg-[#FAFAFA] border-b border-[#E5E7EB] text-[#1E1B4B]
Scrolled:      backdrop-blur-xl bg-opacity-90
Menu overlay:  bg-[#0D1117]
Height:        h-16 (64px), fixed top-0 z-50
```

### Eyebrow / Badge

```
Dark:   text-[10px] font-bold uppercase tracking-[0.35em] text-[#9EA7B3]
        Line: inline-block w-3 h-px bg-[#F0F3F6]/30
Light:  text-[10px] font-bold uppercase tracking-[0.35em] text-[#1E1B4B]/90
        Line: inline-block w-3 h-px bg-[#1E1B4B]/30
```

### Section Background Alternation

```
Dark mode:  #0D1117 -> #161B22 -> #0D1117 -> #1C2128
Light mode: #FAFAFA -> #F5F3FF -> #FFFFFF -> #0D1117 (dark accent section)
Dividers:   border-t border-[#3D444D] (dark) | border-t border-[#E5E7EB] (light)
```

---

## Motion System

### Easing Curves

```
smooth:    [0.25, 0.1, 0.25, 1]   -- Default for most animations
decel:     [0, 0, 0.2, 1]         -- Controlled deceleration
entrance:  [0.22, 1, 0.36, 1]     -- Stagger items, FAQ, reveals
```

### Durations

```
fast:    0.3s   -- Hovers, micro-interactions
normal:  0.5s   -- Fade-ups, standard transitions
slow:    0.7s   -- Text reveals, dramatic entrances
section: 0.8s   -- Full section reveals on scroll
```

### Animation Variants

```
fadeUp:    { hidden: { opacity: 0, y: 20 }, visible: { opacity: 1, y: 0 } }
fadeIn:    { hidden: { opacity: 0 }, visible: { opacity: 1 } }
stagger:   { staggerChildren: 0.1, delayChildren: 0.1 }
section:   { hidden: { opacity: 0, y: 30 }, visible: { opacity: 1, y: 0 } }
```

### Spring Configurations

| Name | Config | Usage |
|---|---|---|
| magnetic | `{ stiffness: 150, damping: 15 }` | Magnetic buttons, cursor |
| crisp | `{ stiffness: 400, damping: 25 }` | Snappy feedback |
| parallax | `{ stiffness: 100, damping: 30, mass: 0.5 }` | Scroll parallax |
| entrance | `{ stiffness: 80, damping: 25 }` | Section entrances |
| form | `{ stiffness: 260, damping: 20 }` | Form interactions |

### Viewport Triggers

```
viewportOnce:    { once: true, margin: "-80px" }
viewportSection: { once: true, margin: "-120px" }
```

---

## Layout

### Page Structure

```
body: bg-[#0D1117] text-[#F0F3F6] min-h-screen flex flex-col (dark)
body: bg-[#FAFAFA] text-[#1E1B4B] min-h-screen flex flex-col (light)

Header (fixed, z-50)
Main (flex-1)
Footer (bg-[#0D1117] border-t border-[#3D444D])
```

### Grid Systems

```
3-column:  grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6
2-column:  grid grid-cols-1 lg:grid-cols-2 gap-16
Container: max-w-7xl mx-auto px-6
```

### Responsive Breakpoints

```
Default:  0px+    (mobile)
md:       768px+  (tablet)
lg:       1024px+ (desktop)
xl:       1280px+ (wide desktop)
```

---

## Key Difference from NovaForge

Where NovaForge uses `#0a0a0a` black as both surface and accent, TeeDoo separates these:
- **`#0D1117` GitHub-dark** for surfaces
- **`#8B5CF6` Violet-500** for accent (dark) / **`#7C3AED` Violet-600** for accent (light)

This gives the UI a distinctive purple enterprise identity while maintaining the same architectural rigor.

---

## Source Files

- Colors: `lib/core/theme/app_colors.dart`
- Theme extension: `lib/core/theme/app_colors_theme.dart`
- Theme builder: `lib/core/theme/app_theme.dart`
- Glass effects: `lib/core/theme/glass_theme.dart`
- Motion: `lib/core/theme/app_motion.dart`
- Typography: `lib/core/theme/app_typography.dart`
- Spacing: `lib/core/theme/app_spacing.dart`
- Radius: `lib/core/theme/app_radius.dart`
