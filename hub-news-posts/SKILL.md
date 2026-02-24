---
name: hub-news-posts
description: This skill should be used when creating Galaxy Hub news posts, writing content for galaxyproject.org/news, or converting content to Galaxy Hub markdown format.
---

# Galaxy Hub News Posts

Create news posts for the Galaxy Project website (galaxyproject.org).

## Directory Structure

Posts live in `/content/news/YYYY-MM-DD-slug-name/`:

```
content/news/2025-01-15-my-announcement/
├── index.md           # Main content file
├── hero.png           # Images in same directory
└── images/            # OR in images/ subdirectory
    └── figure1.png
```

## Required Frontmatter

```yaml
---
title: "Post Title"
date: "YYYY-MM-DD"
tease: "Short description for listing pages"
tags: [galaxy, training, tools]
subsites: [all]
contributions:
  authorship:
    - contributor-id        # GitHub username or ID from hub contributors
  funding:
    - deNBI                 # Optional funding org IDs
---
```

**Note:** The `contributions` block replaces the old `authors` field. Contributor IDs (not free-text names) are used — these must match entries known to the hub.

### Tags

**IMPORTANT**: All tags must exist in `content/TAGS.yaml`. CI validation (`scripts/validate_news.py`) will reject unknown tags. Before using a tag, check the file to confirm it's in the allow-list. Tags are case-sensitive.

### Optional Frontmatter Fields

| Field | Description |
|-------|-------------|
| `main_subsite` | Primary subsite (eu, freiburg, global) |
| `supporters` | Funding/support logos [elixir, denbi, eosc] |
| `location.name` | Event location |
| `hide_tease` | Set false to show tease on listing |
| `autotoc` | Enable/disable table of contents |

## Image Handling

**Option A - Same directory** (simpler):
```markdown
![Description](./image.png)
![Description](image.png)
```

**Option B - images/ subdirectory** (for many images):
```html
<img src="./images/figure1.png" />
```

**CRITICAL**: HTML img tags MUST use `./` prefix:
- `<img src="./images/x.png">` ✓
- `<img src="images/x.png">` ❌ (build fails!)

## Vega Charts

Use external URLs only (gists work well):

```html
<vega-embed spec="https://gist.githubusercontent.com/user/id/raw/hash/chart.json" />
```

Create gist: `gh gist create chart.json --public`

Local file paths do NOT work with vega-embed.

## Styled HTML Tables

```html
<table class="table">
  <tr>
    <td style="background: linear-gradient(135deg, #667eea, #764ba2); color: white; padding: 15px;">
      <strong>Value</strong><br/>label
    </td>
  </tr>
</table>
```

Supported styles:
- `background-color: #xxx`
- `background: linear-gradient(...)`
- `color`, `padding`, `border-radius`
- Emojis work (flags: 🇪🇺 🇺🇸 🇦🇺)

## Workflow

1. Create feature branch: `git checkout -b news/post-slug`
2. Create directory: `mkdir -p content/news/YYYY-MM-DD-slug-name`
3. Add index.md with frontmatter
4. Verify all tags exist in `content/TAGS.yaml`
5. Add images (resize large ones first)
6. For Vega charts: create gist, use raw URL
7. Test locally: `yarn develop`
8. Commit, push, and open a PR against `galaxyproject/galaxy-hub`

## Common Issues

| Problem | Solution |
|---------|----------|
| Build fails on images | Use `./` prefix in HTML img src |
| Vega chart blank | Must use external URL (gist), not local file |
| Large images slow build | Resize with PIL before committing |
| CI fails on unknown tags | All tags must exist in `content/TAGS.yaml` — check before using |

## References

- See `references/formatting.md` for detailed formatting guide
- See `examples/sample-post.md` for complete template
