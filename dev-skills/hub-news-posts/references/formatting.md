# Galaxy Hub News Post Formatting Guide

Detailed formatting reference for Galaxy Hub news posts.

## Frontmatter Reference

### Required Fields

```yaml
---
title: "Galaxy 25.1 Released"          # Post title
date: "2025-12-17"                      # Publication date (YYYY-MM-DD)
tease: "New features include..."        # Short description (~100 chars)
tags: [release, galaxy]                 # Categorization tags (must exist in TAGS.yaml)
subsites: [all]                         # Where to show: all, eu, freiburg, global
contributions:
  authorship:
    - nekrut                            # Contributor IDs (not free-text names)
    - bebatut
  funding:
    - deNBI                             # Optional funding org IDs
---
```

### Optional Fields

```yaml
main_subsite: eu                        # Primary subsite for this post
supporters: [elixir, denbi, eosc]       # Funding logos to display
location:
  name: "Freiburg, DE"                  # Event location
hide_tease: false                       # Show tease on listing page
autotoc: true                           # Auto-generate table of contents
```

### Common Tags

**All tags must exist in `content/TAGS.yaml`**. CI validation will reject unknown tags. Tags are case-sensitive — check the file before using any tag.

- `release` - Galaxy version releases
- `training` - Training events and materials
- `tools` - Tool updates and announcements
- `community` - Community news
- `paper` - Publication announcements
- `event` - Conferences and meetings
- `hackathon` - Hackathon reports

### Subsite Options

| Value | Description |
|-------|-------------|
| `all` | Show on all Galaxy sites |
| `eu` | European Galaxy |
| `freiburg` | Galaxy Freiburg |
| `global` | Main Galaxy site |

## Markdown Formatting

### Headers

```markdown
## Section Header
### Subsection
#### Minor Section
```

### Lists

```markdown
- Bullet point
- Another point
  - Nested item

1. Numbered item
2. Second item
```

### Links

```markdown
[Link text](https://example.com)
[Internal link](/events/gcc2025/)
```

### Code

````markdown
Inline `code` text

```python
# Code block
def hello():
    print("Hello Galaxy!")
```
````

### Alerts/Callouts

```html
<div class="alert alert-info" role="alert">
  ℹ️ Information message
</div>

<div class="alert alert-success" role="alert">
  ✅ Success message
</div>

<div class="alert alert-warning" role="alert">
  ⚠️ Warning message
</div>
```

## Image Formatting

### Basic Image (Same Directory)

```markdown
![Alt text](./image.png)
```

### Image with Caption

```markdown
![Alt text](./figure1.png)

> **Figure 1.** Caption describing the image.
```

### HTML Image (Required for images/ subdirectory)

```html
<img src="./images/photo.jpg" />
```

### Sized/Styled Image

```html
<img src="./images/logo.png" width="200" alt="Logo" />

<img class="float-right" src="./images/sidebar.png" width="150" />
```

### Image Gallery

```html
<div style="display: flex; gap: 10px;">
  <img src="./img1.png" style="width: 48%;" />
  <img src="./img2.png" style="width: 48%;" />
</div>
```

## Table Formatting

### Simple Markdown Table

```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Data     | Data     | Data     |
```

### Styled HTML Table

```html
<table class="table">
  <tr>
    <th>Header</th>
    <th style="text-align: right;">Value</th>
  </tr>
  <tr>
    <td>Item</td>
    <td style="text-align: right; background-color: #e8f3e6;">
      <strong style="color: #3e7b36;">123</strong>
    </td>
  </tr>
</table>
```

### Gradient Stats Cards

```html
<table class="table">
  <tr>
    <td style="background: linear-gradient(135deg, #667eea, #764ba2); color: white; text-align: center; padding: 15px; border-radius: 8px;">
      <strong style="font-size: 1.5em;">650K+</strong><br/>registered users
    </td>
    <td style="background: linear-gradient(135deg, #43e97b, #38f9d7); color: white; text-align: center; padding: 15px; border-radius: 8px;">
      <strong style="font-size: 1.5em;">186M+</strong><br/>jobs executed
    </td>
  </tr>
</table>
```

## Embedded Content

### YouTube Video

```html
<iframe width="560" height="315"
  src="https://www.youtube.com/embed/VIDEO_ID"
  frameborder="0" allowfullscreen></iframe>
```

### PDF Embed

```html
<iframe src="https://example.com/document.pdf"
  width="100%" height="500px"></iframe>
```

### Vega Chart

```html
<vega-embed spec="https://gist.githubusercontent.com/USER/GIST_ID/raw/HASH/chart.json" />
```

## Color Reference

### Galaxy Brand Colors

| Color | Hex | Usage |
|-------|-----|-------|
| Galaxy Blue | `#197cd2` | Primary accent |
| Galaxy Dark | `#2c3143` | Headers, dark backgrounds |
| Light Blue | `#48a1dd` | Secondary accent |

### Useful Gradients

```css
/* Purple-Pink */
background: linear-gradient(135deg, #667eea, #764ba2);

/* Orange-Red */
background: linear-gradient(135deg, #f093fb, #f5576c);

/* Blue-Cyan */
background: linear-gradient(135deg, #4facfe, #00f2fe);

/* Green-Teal */
background: linear-gradient(135deg, #43e97b, #38f9d7);
```

## File Organization

### Recommended Structure

```
content/news/2025-01-15-announcement/
├── index.md              # Main content
├── hero.png              # Hero/header image
├── figure1.png           # Inline figures
└── figure2.png
```

### For Many Images

```
content/news/2025-01-15-event-report/
├── index.md
└── images/
    ├── photo1.jpg
    ├── photo2.jpg
    └── diagram.png
```

## Pre-Commit Checklist

- [ ] Frontmatter has all required fields
- [ ] Date format is YYYY-MM-DD
- [ ] Images use correct path syntax (`./` prefix for HTML)
- [ ] Large images resized (< 500KB recommended)
- [ ] Vega charts use gist URLs, not local files
- [ ] Links work (internal and external)
- [ ] Tags exist in `content/TAGS.yaml` (CI rejects unknown tags)
- [ ] Local build succeeds (`yarn develop`)
