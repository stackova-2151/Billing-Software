# 🎨 Reports Module - Visual Design Specification

## 📱 Screen Layout Preview

### Desktop View (1920×1080)
```
╔═══════════════════════════════════════════════════════════════════════════╗
║  📊 Reports & Analytics                          🔄 Refresh  📥 Export PDF ║
╠═══════════════════════════════════════════════════════════════════════════╣
║                                                                            ║
║  ┌────────────────────────────────────────────────────────────────────┐  ║
║  │ Filters                                                             │  ║
║  │ [Today] [Last 7 Days] [Custom Range]                               │  ║
║  └────────────────────────────────────────────────────────────────────┘  ║
║                                                                            ║
║  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐   ║
║  │ 💰 Total     │ │ 🛒 Total     │ │ 📈 Avg Order │ │ 👥 Customers │   ║
║  │    Sales     │ │    Orders    │ │    Value     │ │              │   ║
║  │              │ │              │ │              │ │              │   ║
║  │  ₹15,250.50  │ │      45      │ │   ₹338.90    │ │      32      │   ║
║  │  Total Sales │ │ Total Orders │ │ Avg Order    │ │  Customers   │   ║
║  └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘   ║
║                                                                            ║
║  ┌────────────────────────────────────────────────────────────────────┐  ║
║  │ Sales Trend                                                         │  ║
║  │                                                                     │  ║
║  │  ₹3k ┤                                    ╱╲                        │  ║
║  │      │                          ╱╲      ╱  ╲                       │  ║
║  │  ₹2k ┤                    ╱╲  ╱  ╲    ╱    ╲                      │  ║
║  │      │              ╱╲  ╱  ╲╱    ╲  ╱      ╲                     │  ║
║  │  ₹1k ┤        ╱╲  ╱  ╲╱            ╲╱        ╲                    │  ║
║  │      │  ╱╲  ╱  ╲╱                             ╲                   │  ║
║  │   ₹0 ┼──────────────────────────────────────────────────────────  │  ║
║  │      └─15/01─16/01─17/01─18/01─19/01─20/01─21/01                 │  ║
║  └────────────────────────────────────────────────────────────────────┘  ║
║                                                                            ║
║  ┌──────────────────────────────┐ ┌──────────────────────────────────┐  ║
║  │ Payment Breakdown            │ │ Top Items                         │  ║
║  │                              │ │                                   │  ║
║  │         ╱────╲               │ │  Pizza    ████████████ ₹5,500    │  ║
║  │       ╱   55.7% ╲             │ │  Burger   ██████████ ₹3,600     │  ║
║  │      │   Cash    │            │ │  Pasta    ███████ ₹2,700        │  ║
║  │      │           │            │ │  Salad    █████ ₹1,800          │  ║
║  │       ╲  44.3%  ╱             │ │  Juice    ████ ₹1,650           │  ║
║  │         ╲─Online─╱             │ │                                   │  ║
║  │                              │ │                                   │  ║
║  │  ■ Cash ₹8,500  ■ Online ₹6,750│ │                                   │  ║
║  └──────────────────────────────┘ └──────────────────────────────────┘  ║
║                                                                            ║
║  ┌────────────────────────────────────────────────────────────────────┐  ║
║  │ Recent Orders                                  Showing 10 of 45     │  ║
║  ├──────────┬────────────────┬──────────┬──────────┬─────────────────┤  ║
║  │ Order ID │ Date & Time    │ Amount   │ Payment  │ Customer        │  ║
║  ├──────────┼────────────────┼──────────┼──────────┼─────────────────┤  ║
║  │ a1b2c3d4 │ 15/01/24 10:30 │ ₹450.00  │ [CASH]   │ John Doe        │  ║
║  │ e5f6g7h8 │ 15/01/24 11:15 │ ₹320.50  │ [ONLINE] │ Jane Smith      │  ║
║  │ i9j0k1l2 │ 15/01/24 12:00 │ ₹680.00  │ [CASH]   │ Bob Wilson      │  ║
║  │ ...      │ ...            │ ...      │ ...      │ ...             │  ║
║  └──────────┴────────────────┴──────────┴──────────┴─────────────────┘  ║
║                                                                            ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

---

## 🎨 Color Palette

### Summary Cards Gradients

#### Card 1: Total Sales (Green)
```
┌─────────────────┐
│ 💰              │  Gradient: #10B981 → #059669
│                 │  Text: White
│   ₹15,250.50    │  Icon BG: White 20% opacity
│   Total Sales   │  Shadow: Medium
└─────────────────┘
```

#### Card 2: Total Orders (Blue)
```
┌─────────────────┐
│ 🛒              │  Gradient: #6366F1 → #8B5CF6
│                 │  Text: White
│       45        │  Icon BG: White 20% opacity
│  Total Orders   │  Shadow: Medium
└─────────────────┘
```

#### Card 3: Avg Order Value (Orange)
```
┌─────────────────┐
│ 📈              │  Gradient: #F59E0B → #D97706
│                 │  Text: White
│    ₹338.90      │  Icon BG: White 20% opacity
│  Avg Order Val  │  Shadow: Medium
└─────────────────┘
```

#### Card 4: Customers (Purple)
```
┌─────────────────┐
│ 👥              │  Gradient: #3B82F6 → #2563EB
│                 │  Text: White
│       32        │  Icon BG: White 20% opacity
│   Customers     │  Shadow: Medium
└─────────────────┘
```

---

## 📊 Chart Specifications

### Line Chart (Sales Trend)

**Visual Style:**
```
- Line Color: Primary gradient (#6366F1 → #8B5CF6)
- Line Width: 3px
- Line Style: Curved (smooth bezier)
- Fill: Gradient from primary 30% to transparent
- Dots: White with primary border (4px radius)
- Grid: Horizontal only, light gray (#E2E8F0)
- Tooltip: Dark background, white text
```

**Animation:**
```
Duration: 1500ms
Curve: easeInOut
Effect: Line draws from left to right
Fill: Fades in simultaneously
```

**Axes:**
```
X-Axis: Date labels (dd/MM format)
Y-Axis: Currency (₹1k, ₹2k, ₹3k)
Font: 11px, gray (#475569)
```

---

### Pie Chart (Payment Breakdown)

**Visual Style:**
```
- Cash Segment: Green (#10B981)
- Online Segment: Blue (#3B82F6)
- Center Hole: 60px radius
- Segment Gap: 2px
- Labels: White, bold, percentage
- Touch Effect: Segment enlarges to 70px radius
```

**Animation:**
```
Duration: 1200ms
Curve: easeOutBack
Effect: Segments rotate and expand from center
```

**Legend:**
```
Position: Below chart
Style: Color box (16×16px) + Label + Amount
Font: 12px label, 14px bold amount
```

---

### Bar Chart (Top Items)

**Visual Style:**
```
- Bar Width: 24px
- Bar Radius: 6px (top corners only)
- Bar Colors: Gradient (5 different colors)
  1. Primary (#6366F1)
  2. Purple (#8B5CF6)
  3. Green (#10B981)
  4. Orange (#F59E0B)
  5. Blue (#3B82F6)
- Grid: Horizontal only, light gray
- Tooltip: Dark background, white text
```

**Animation:**
```
Duration: 1200ms
Curve: easeOut
Effect: Bars grow from bottom to top
```

**Axes:**
```
X-Axis: Item names (truncated to 8 chars)
Y-Axis: Currency (₹1k, ₹2k, ₹3k)
Font: 10-11px, gray (#475569)
```

---

## 🎭 Animation Sequences

### Page Load Animation
```
Timeline:
0ms    → Page appears
100ms  → Filter section fades in
200ms  → Summary cards scale in (staggered)
400ms  → Card 1 appears
500ms  → Card 2 appears
600ms  → Card 3 appears
700ms  → Card 4 appears
800ms  → Counter animations start (1500ms duration)
1000ms → Line chart starts drawing
1200ms → Pie chart starts rotating
1400ms → Bar chart bars start growing
2300ms → All animations complete
```

### Counter Animation
```
Effect: Number increments from 0 to target value
Duration: 1500ms
Curve: easeOutCubic
Update: Every frame (60fps)
Format: 
  - Integers: No decimals
  - Currency: 2 decimals
  - Prefix: ₹ for currency
```

### Hover Effects (Web Only)
```
Summary Cards:
  - Default: Scale 1.0
  - Hover: Scale 0.98
  - Duration: 300ms
  - Cursor: pointer

Buttons:
  - Default: Scale 1.0
  - Hover: Brightness 110%
  - Active: Scale 0.95
  - Duration: 200ms
```

---

## 📐 Spacing & Layout

### Container Padding
```
Screen: 20px all sides
Cards: 20px all sides
Filter Section: 20px all sides
Chart Containers: 20px all sides
Table: 20px horizontal, 0px vertical
```

### Grid Spacing
```
Summary Cards:
  - Gap: 16px
  - Aspect Ratio: 1.5:1

Charts:
  - Vertical Gap: 16px
  - Horizontal Gap: 16px (when side-by-side)
```

### Typography
```
Screen Title: 24px, Bold, #0F172A
Section Title: 16px, Bold, #0F172A
Card Value: 28px, Bold, White
Card Label: 14px, Medium, White 90%
Table Header: 11px, Bold, #0F172A
Table Cell: 10px, Regular, #475569
Button Text: 14px, Medium, White
```

---

## 🎯 Interactive States

### Filter Chips
```
Default:
  - Background: White
  - Border: 1px #E2E8F0
  - Text: #0F172A
  - Radius: 12px

Selected:
  - Background: #6366F1
  - Border: 1px #6366F1
  - Text: White
  - Font Weight: 600

Hover:
  - Border: 1px #6366F1
  - Cursor: pointer
```

### Buttons
```
Primary (Export PDF):
  - Background: #6366F1
  - Text: White
  - Padding: 12px 20px
  - Radius: 12px
  - Shadow: Medium
  - Icon: 18px

Hover:
  - Background: #4F46E5
  - Shadow: Large

Active:
  - Background: #4338CA
  - Scale: 0.98
```

### Table Rows
```
Default:
  - Background: White
  - Text: #475569

Hover (Web):
  - Background: #F8FAFC
  - Cursor: default

Header:
  - Background: #F8FAFC
  - Text: #0F172A
  - Font Weight: Bold
```

---

## 📱 Responsive Breakpoints

### Mobile (< 800px)
```
Summary Cards: 1 column
Chart Layout: Stacked vertically
Table: Horizontal scroll
Padding: 16px
Font Sizes: -2px from desktop
```

### Tablet (800px - 1200px)
```
Summary Cards: 2 columns (2×2 grid)
Chart Layout: 
  - Line chart: Full width
  - Pie & Bar: Side by side
Table: Full width
Padding: 20px
Font Sizes: Same as desktop
```

### Desktop (> 1200px)
```
Summary Cards: 4 columns (1×4 grid)
Chart Layout:
  - Line chart: Full width
  - Pie & Bar: Side by side
Table: Full width
Padding: 20px
Font Sizes: Standard
```

---

## 🎨 Shadow System

### Small Shadow
```css
box-shadow: 0 1px 4px rgba(0, 0, 0, 0.04);
```

### Medium Shadow
```css
box-shadow: 
  0 2px 8px rgba(0, 0, 0, 0.06),
  0 1px 3px rgba(0, 0, 0, 0.02);
```

### Large Shadow
```css
box-shadow:
  0 4px 16px rgba(0, 0, 0, 0.08),
  0 2px 6px rgba(0, 0, 0, 0.04);
```

---

## 🎪 Loading States

### Initial Load
```
┌────────────────────────────┐
│                            │
│      ⟳ Loading...          │
│                            │
│  (Circular Progress)       │
│                            │
└────────────────────────────┘
```

### PDF Export
```
┌────────────────────────────┐
│                            │
│  Generating PDF...         │
│                            │
│  (Circular Progress)       │
│                            │
└────────────────────────────┘
```

### Empty State
```
┌────────────────────────────┐
│                            │
│      📊                    │
│                            │
│  No data available         │
│  for selected date range   │
│                            │
└────────────────────────────┘
```

---

## 🎨 Badge Styles

### Payment Mode Badges
```
CASH:
  - Background: #D1FAE5 (light green)
  - Text: #10B981 (green)
  - Padding: 4px 8px
  - Radius: 8px
  - Font: 11px, Bold

ONLINE:
  - Background: #DBEAFE (light blue)
  - Text: #3B82F6 (blue)
  - Padding: 4px 8px
  - Radius: 8px
  - Font: 11px, Bold
```

---

## 📊 Data Formatting

### Currency
```
Format: ₹X,XXX.XX
Examples:
  - ₹1,250.50
  - ₹15,000.00
  - ₹338.90

Chart Axis:
  - ₹1k (for 1000)
  - ₹2.5k (for 2500)
  - ₹10k (for 10000)
```

### Dates
```
Full: 15/01/2024 10:30
Short: 15/01
Chart: dd/MM
PDF: dd MMM yyyy
```

### Numbers
```
Integers: 45
Decimals: 338.90
Percentages: 55.7%
```

---

## 🎯 Accessibility

### Color Contrast
```
All text meets WCAG AA standards:
- White on gradients: 4.5:1 minimum
- Dark text on white: 7:1+
- Badge text: 4.5:1 minimum
```

### Interactive Elements
```
- Minimum touch target: 44×44px
- Focus indicators: 2px blue outline
- Keyboard navigation: Full support
- Screen reader: Proper labels
```

---

## 🎨 Final Polish

### Micro-interactions
- Button press: Subtle scale (0.98)
- Card hover: Gentle lift
- Chart touch: Highlight segment
- Chip select: Smooth color transition

### Transitions
- All: 200-300ms ease-out
- Charts: 1200-1500ms custom curves
- Counters: 1500ms ease-out-cubic

### Performance
- 60fps animations
- Hardware acceleration
- Efficient repaints
- No jank or lag

---

**This design specification ensures a premium, professional, and consistent user experience across all devices.** 🎨✨
