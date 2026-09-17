# Sample Galaxy Hub News Post

This is a complete example of a Galaxy Hub news post.

## File Location

Save as: `content/news/2025-01-15-sample-announcement/index.md`

---

## Complete Example

```markdown
---
title: "Galaxy 25.2 Released with Major Performance Improvements"
date: "2025-01-15"
tease: "50% faster job scheduling, new visualization tools, and enhanced workflow editor"
tags: [release, galaxy]
subsites: [all]
contributions:
  authorship:
    - galaxyproject
---

![Galaxy 25.2 Release](./hero.png)

*Image credit: Galaxy Project*

We're excited to announce the release of Galaxy 25.2, featuring significant performance improvements and new capabilities.

## Highlights

- **50% faster** job scheduling through optimized queue management
- **New visualizations** including interactive network graphs
- **Enhanced workflow editor** with improved drag-and-drop
- **Better mobile support** for on-the-go analysis

## Performance Improvements

The new release brings substantial performance gains:

<table class="table">
  <tr>
    <td style="background: linear-gradient(135deg, #667eea, #764ba2); color: white; text-align: center; padding: 15px; border-radius: 8px;">
      <strong style="font-size: 1.5em;">50%</strong><br/>faster scheduling
    </td>
    <td style="background: linear-gradient(135deg, #43e97b, #38f9d7); color: white; text-align: center; padding: 15px; border-radius: 8px;">
      <strong style="font-size: 1.5em;">30%</strong><br/>less memory
    </td>
  </tr>
</table>

### Benchmark Results

| Metric | v25.1 | v25.2 | Improvement |
|--------|-------|-------|-------------|
| Job scheduling | 2.4s | 1.2s | 50% faster |
| Workflow load | 1.8s | 1.1s | 39% faster |
| History render | 0.9s | 0.6s | 33% faster |

## New Visualizations

The release includes three new visualization tools:

### Network Graphs

Interactive network visualization for pathway analysis:

![Network Graph Example](./network-viz.png)

> **Figure 1.** Example network visualization showing protein interactions.

### Heatmap Improvements

Enhanced heatmap with clustering options:

<img src="./images/heatmap.png" width="500" />

## Installation

Upgrade your Galaxy instance:

```bash
git fetch origin
git checkout release_25.2
./scripts/common_startup.sh
```

<div class="alert alert-info" role="alert">
  ℹ️ Remember to backup your database before upgrading!
</div>

## Contributors

Thanks to our amazing contributors:

- @developer1 - Performance optimizations
- @developer2 - New visualizations
- @developer3 - Workflow improvements

## Resources

- [Full Release Notes](https://docs.galaxyproject.org/en/release_25.2/releases/25.2.html)
- [Upgrade Guide](https://docs.galaxyproject.org/en/release_25.2/admin/upgrading.html)
- [Training Materials](https://training.galaxyproject.org/)

---

**Questions?** Join us on [Matrix](https://matrix.to/#/#galaxyproject:matrix.org) or the [Help Forum](https://help.galaxyproject.org/).
```

---

## Directory Contents

For this example, the directory would contain:

```
content/news/2025-01-15-sample-announcement/
├── index.md          # The content above
├── hero.png          # Header image
├── network-viz.png   # Figure 1
└── images/
    └── heatmap.png   # Additional image
```

## Notes

1. **Hero image** at top provides visual interest
2. **Stats table** with gradients for key metrics
3. **Mix of markdown and HTML** tables as appropriate
4. **Code blocks** for technical instructions
5. **Alert box** for important notices
6. **Clear sections** with headers
7. **Links** to related resources
