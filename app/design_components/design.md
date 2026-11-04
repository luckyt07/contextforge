# DESIGN.md — Warm Editorial Workspace

> Specification for design systems, AI agents, and frontend/Flutter engineers.
> Defines exact color tokens (Light & Dark), typography hierarchy, spacing scale, corner radii, and component design patterns.

---

## 1. Design Philosophy & Aesthetic
- **Style**: Warm, contemplative, editorial, human-centered minimal workspace.
- **Inspiration**: Claude Artifacts & OpenAI minimalist interface with archival paper tactile warmth.
- **Key Principles**:
    - Content-first, typography-driven clarity without visual bloat or heavy decoration.
    - Tactile warmth using archival paper substrates (`#FFF8F5`) and warm ink text rather than harsh clinical stark whites or pure blacks.
    - Terracotta / warm coral accent (`#C15F3C`) applied with precision and restraint for interactive primary intents only.
    - Border-delineated structure rather than heavy drop shadows.

---

## 2. Color Palette & Semantic Tokens

### Primary Accent
| Token | Light Mode | Dark Mode | Usage / Role |
| :--- | :--- | :--- | :--- |
| `color.brand.primary` | `#C15F3C` | `#C15F3C` | Signature terracotta accent, primary buttons, active indicator, focus ring |
| `color.brand.primaryContainer` | `#FCECE6` | `#432418` | Active row highlight, selected tag backgrounds, chip fill |
| `color.brand.onPrimary` | `#FFFFFF` | `#FFFFFF` | Text/icons placed on `brand.primary` |
| `color.brand.onPrimaryContainer`| `#712F18` | `#FFDBCE` | High-contrast text on `primaryContainer` |

### Surfaces & Canvas
| Token | Light Mode | Dark Mode | Usage / Role |
| :--- | :--- | :--- | :--- |
| `color.surface.canvas` | `#FFF8F5` | `#1A1715` | Main scaffold canvas background (Archival Cream / Obsidian Ink) |
| `color.surface.card` | `#FFFFFF` | `#24201D` | Elevated content cards, dialogue sheets, modal popovers |
| `color.surface.subdued` | `#FBF2ED` | `#2B2623` | Recessed container wells, search bars, text input background |
| `color.surface.containerLow` | `#F8F1EB` | `#201D1A` | Secondary background sections, subtle list dividers |

### Stroke & Borders
| Token | Light Mode | Dark Mode | Usage / Role |
| :--- | :--- | :--- | :--- |
| `color.border.default` | `#E1D8D4` | `#3D3632` | Standard card outlines, modal borders, hairline dividers (Stone Linen / Dark Ash) |
| `color.border.subtle` | `#EFE8E4` | `#302A27` | Subtle inner table/list dividers |
| `color.border.focus` | `#C15F3C` | `#E07A58` | Active input border and focused states |

### Text & Iconography
| Token | Light Mode | Dark Mode | Usage / Role |
| :--- | :--- | :--- | :--- |
| `color.text.primary` | `#2C2523` | `#F5EFEB` | Headings, titles, high-contrast primary reading body (Printer's Ink / Parchment) |
| `color.text.secondary` | `#796E69` | `#A89F9A` | Subtitles, helper text, timestamps, meta captions (Warm Slate / Pale Putty) |
| `color.text.tertiary` | `#ADA29D` | `#6E6560` | Placeholders, inactive icons, subtle watermarks |
| `color.text.disabled` | `#C5BBB6` | `#524C48` | Disabled buttons, inactive action states |

### Code & Technical Elements
| Token | Light Mode | Dark Mode | Usage / Role |
| :--- | :--- | :--- | :--- |
| `color.code.background` | `#F8F5F2` | `#1E1B19` | Monospace code block substrate |
| `color.code.border` | `#E8E2DD` | `#332E2A` | Code block enclosing stroke |
| `color.code.text` | `#3A312E` | `#EBE4DF` | Standard code text / syntax base |

---

## 3. Typography Scale & Font Families

### Font Families
1. **Editorial Serif**: `Merriweather`, `serif`
    - Role: Headings, document titles, modal headers, major conversational section titles.
    - Character: Literary, thoughtful, warm, authoritative.
2. **Interface Sans**: `Inter`, `system-ui`, `-apple-system`, `sans-serif`
    - Role: UI controls, body text, form labels, buttons, navigation items.
    - Character: Clean, legible, ergonomic at small sizes.
3. **Monospace**: `JetBrains Mono`, `Consolas`, `monospace`
    - Role: Code blocks, metadata tags, token references, model identifier pills.

### Typography Hierarchy Scale
| Style Name | Font Family | Size | Weight | Line Height | Letter Spacing |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `display` | `Merriweather` | `28px` | `700` (Bold) | `1.20` | `-0.02em` |
| `headline` | `Merriweather` | `22px` | `700` (Bold) | `1.25` | `-0.015em` |
| `title-lg` | `Merriweather` | `18px` | `600` (SemiBold)| `1.30` | `-0.01em` |
| `title-md` | `Inter` | `15px` | `600` (SemiBold)| `1.35` | `0em` |
| `body-lg` | `Inter` | `15px` | `400` (Regular) | `1.50` | `0em` |
| `body-md` | `Inter` | `14px` | `400` (Regular) | `1.45` | `0em` |
| `label-md` | `Inter` | `12px` | `500` (Medium) | `1.30` | `+0.01em` |
| `caption` | `Inter` | `11px` | `400` (Regular) | `1.25` | `+0.01em` |
| `code-sm` | `JetBrains Mono`| `13px` | `400` (Regular) | `1.50` | `0em` |

---

## 4. Spacing System (4px Baseline Grid)

| Token | Dimension | Common Use Case |
| :--- | :--- | :--- |
| `space.2xs` | `4px` | Tight inline gaps between icon and label, chip padding |
| `space.xs` | `8px` | Small element padding, tag horizontal padding, input icon margin |
| `space.sm` | `12px` | Compact gutters, card internal item spacing, list item padding |
| `space.md` | `16px` | Standard screen horizontal margin, container padding, modal header spacing |
| `space.lg` | `20px` | Medium section separation, form field vertical gaps |
| `space.xl` | `24px` | Major group separation, sheet top padding |
| `space.2xl` | `32px` | Screen block margins, hero section top/bottom padding |

---

## 5. Shape & Corner Radii

| Token | Value | Target UI Elements |
| :--- | :--- | :--- |
| `radius.sm` | `6px` | Small badges, sub-chips, tooltip bubbles |
| `radius.md` | `8px` | Metadata tags, filter chips, code snippets |
| `radius.lg` | `12px` | Primary action buttons, text form inputs, dropdown selectors |
| `radius.xl` | `16px` | Content cards, modal sheets, dialogue panels |
| `radius.full` | `9999px` | Circular avatar frames, pill buttons, status indicators |

---

## 6. Elevation & Shadows

The design relies primarily on **1px hairline strokes** (`border: 1px solid var(--border-default)`) rather than floating drop shadows:
- **Default Surface**: `box-shadow: none; border: 1px solid var(--border-default)`
- **Modal / Floating Sheet**:
    - `box-shadow: 0 8px 30px rgba(44, 37, 35, 0.08)` (Light)
    - `box-shadow: 0 8px 30px rgba(0, 0, 0, 0.40)` (Dark)
- **Interactive Hover**: subtle translateY(-1px) with border color transition to primary accent.

---

## 7. Core Component Guidelines

### A. Navigation & Top App Bar
- Keep top bar minimal: Back button (left), Screen title in `title-lg` or `title-md` (`Merriweather` or `Inter`), optional subtle single action button.
- Bottom border: `1px solid var(--border-default)`.
- Background matches canvas substrate (`#FFF8F5` / `#1A1715`).

### B. Project Cards & List Rows
- Background: Surface card (`#FFFFFF` / `#24201D`).
- Outline: `1px solid var(--border-default)`.
- Corner Radius: `16px`.
- Padding: `16px`.
- Primary title in `Merriweather`, description in `Inter` body-md, meta stats in `label-md`.

### C. Chat Screen & Dialogue
- Focus on conversation: No image banners, no unnecessary citation chips, no cluttered action buttons.
- User Bubble: Minimal, or right-aligned card with `surface.card` or subdued background.
- Assistant Response: Rendered directly on the canvas substrate in clear typographic hierarchy.
- Code Blocks inside chat:
    - Font: `JetBrains Mono` 13px.
    - Background: `color.code.background` (`#F8F5F2` / `#1E1B19`).
    - Radius: `8px`.
    - Border: `1px solid var(--border-subtle)`.
- Input Field:
    - Pill or `12px` rounded container with `color.surface.subdued`.
    - Placeholder: `"Message..."`.
    - Clean Send button with Terracotta accent (`#C15F3C`).

### D. Modal Bottom Sheets (e.g. Create Project)
- Draggable top bar pill (`36px x 4px`, rounded-full, `#E1D8D4`).
- Close icon button in top right.
- Clear title in `Merriweather` headline (20px-22px).
- Inputs styled with `radius.lg` (12px), background `#FFFFFF` or `#FBF2ED`, and subtle border.
- Full-width CTA button styled with `color.brand.primary` and white text.
