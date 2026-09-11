# Galaxy Hub News Posts Skill

Claude Code skill for creating Galaxy Hub news posts at [galaxyproject.org/news](https://galaxyproject.org/news/).

## Installation

Copy or symlink this directory to your Claude Code skills location:

```bash
# Option 1: Personal skills (all projects)
ln -s /path/to/hub-news-posts ~/.claude/skills/hub-news-posts

# Option 2: Project skills (shared via git)
ln -s /path/to/hub-news-posts .claude/skills/hub-news-posts
```

## Usage

The skill activates automatically when you ask Claude to:

- "Create a Galaxy Hub news post about..."
- "Write a news announcement for galaxyproject.org"
- "Convert this content to Galaxy Hub format"

### Example Prompts

```
Create a news post announcing the Galaxy 25.2 release with these highlights:
- 50% faster job scheduling
- New network visualization
- Enhanced workflow editor
```

```
Convert this email newsletter to a Galaxy Hub news post
```

```
Create a news post about the upcoming GCC2026 conference in Clermont-Ferrand
```

## What the Skill Knows

### Directory Structure
- Posts go in `/content/news/YYYY-MM-DD-slug-name/`
- Main file is `index.md`
- Images can be in same directory or `images/` subdirectory

### Frontmatter
Required fields: `title`, `date`, `tease`, `authors`, `tags`, `subsites`

### Image Handling
- Markdown: `![alt](./image.png)`
- HTML (for images/ subdir): `<img src="./images/file.jpg" />` (note `./` prefix!)

### Vega Charts
- Must use external URLs (gists), not local files
- Create with: `gh gist create chart.json --public`

### Styled Tables
- Supports `<table class="table">` with inline CSS
- Gradients, colors, emojis all work

## Files

| File | Description |
|------|-------------|
| `SKILL.md` | Main skill definition with quick reference |
| `references/formatting.md` | Detailed formatting guide, colors, checklist |
| `examples/sample-post.md` | Complete working example |

## Common Issues

| Problem | Solution |
|---------|----------|
| Build fails on images | Use `./` prefix: `<img src="./images/x.png">` |
| Vega chart blank | Use gist URL, not local file |
| Slow build | Resize large images before committing |

## Contributing

Based on lessons learned creating the [Galaxy 2025 Year in Review](https://github.com/nekrut/galaxy-hub/tree/news/2025-year-in-review) post. PRs welcome for additional patterns and fixes.
