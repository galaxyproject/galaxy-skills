# Contributing to Galaxy Skills

Thank you for your interest in contributing to Galaxy Skills! This guide will help you create high-quality skills that help AI agents work effectively with Galaxy development.

---

## What Makes a Good Skill?

A good skill:

- **Solves a specific problem** - Clear scope and purpose
- **Provides guardrails** - Prevents common mistakes
- **Includes examples** - Concrete references to learn from
- **Is well-structured** - Easy for LLMs to parse and apply
- **Is tested** - Validated with real use cases

---

## Skill Structure

### Minimal Skill (Single File)

```
my-skill/
└── SKILL.md
```

### Complete Skill (Multi-File)

```
my-skill/
├── SKILL.md              # Main skill file (required)
├── README.md             # Human-readable overview
├── references/           # Reference documentation
│   ├── patterns.md
│   └── common-issues.md
├── examples/             # Concrete examples
│   ├── simple/
│   └── complex/
└── resources/            # Supporting files
    └── templates/
```

---

## SKILL.md Format

Every skill must have a `SKILL.md` file with YAML frontmatter:

```markdown
---
name: my-skill-name
description: Brief description of when to use this skill (1-2 sentences)
---

# Skill Title

## When to Use

Clear description of when this skill should be invoked.

## Quick Reference

Key information in tables or lists for fast lookup.

## Workflow

Step-by-step process:

1. Step one
2. Step two
3. Step three

## Common Patterns

Reusable patterns with code examples.

## Troubleshooting

Common issues and solutions.

## Resources

Links to other files in this skill or external resources.
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Kebab-case identifier (e.g., `tool-updates`) |
| `description` | Yes | When to use this skill (shown to LLM) |
| `version` | No | Semantic version (e.g., `1.0.0`) |
| `tags` | No | Array of tags for categorization |

---

## Skill Categories

Place your skill in the appropriate category:

| Skill Family | Purpose | Examples |
|--------------|---------|----------|
| `tool-dev/` | Galaxy tool development (creation + updates) | creation/, updates/, shared/ |
| `hub-news-posts/` | Documentation and content creation | Galaxy Hub news posts |
| `nf-to-galaxy/` | Nextflow → Galaxy conversion | process-to-tool, workflow conversion |
| `galaxy-integration/` | Galaxy instance integration (MCP, BioBlend) | tool-checking, workflow-testing |

---

## Writing Guidelines

### 1. Be Specific

❌ **Bad**: "Update the tool"
✅ **Good**: "Update the `@TOOL_VERSION@` token in `macros.xml`"

### 2. Use Code Examples

Always show concrete examples:

```markdown
## Repeat Element Access

```xml
<!-- WRONG -->
#for item in $section.repeat:
    --flag '$section.item'
#end for

<!-- CORRECT -->
#for item in $section.repeat:
    --flag '$item.param_name'
#end for
\```
```

### 3. Include Guardrails

Explicitly call out common mistakes:

```markdown
## Common Mistakes

| Mistake | Why It's Wrong | Fix |
|---------|----------------|-----|
| Using exact counts in tests | Breaks when upstream data changes | Use `min=` instead |
```

### 4. Reference Other Skills

Link to related skills when appropriate:

```markdown
## See Also

- For testing, see the `planemo` skill
- For help sections, see `tool-updates/help-sections.md`
```

### 5. Keep It Scannable

Use:
- Tables for structured data
- Lists for sequences
- Code blocks for examples
- Headings for navigation

---

## Testing Your Skill

### 1. Manual Testing

Test your skill with an AI agent:

```bash
# Claude Code
# Just open a project with the skill in .claude/skills/

# Windsurf/Cursor/Aider
openskills install /path/to/your/skill
openskills read your-skill-name
```

Ask the AI to perform tasks the skill covers and verify:
- Does it follow the workflow?
- Does it avoid common mistakes?
- Does it produce correct output?

### 2. Validation Checklist

- [ ] SKILL.md has valid YAML frontmatter
- [ ] Description clearly states when to use
- [ ] Includes concrete examples
- [ ] Workflow is step-by-step
- [ ] Common mistakes are documented
- [ ] Links to resources work
- [ ] Tested with at least one AI agent

---

## Submission Process

### 1. Fork and Branch

```bash
git clone https://github.com/YOUR_USERNAME/skills
cd skills
git checkout -b add-my-skill
```

### 2. Create Your Skill

```bash
# Choose the right top-level skill family or create new one
mkdir -p my-skill
cd my-skill

# Create SKILL.md with frontmatter
cat > SKILL.md << 'EOF'
---
name: my-skill
description: Brief description
---

# My Skill

...
EOF
```

### 3. Test Locally

Test your skill with an AI agent before submitting.

### 4. Submit PR

```bash
git add .
git commit -m "Add my-skill for [purpose]"
git push origin add-my-skill
```

Open a PR on GitHub with:
- **Title**: "Add [skill-name] skill"
- **Description**: 
  - What problem does this solve?
  - How was it tested?
  - Example usage

---

## Review Criteria

PRs will be reviewed for:

1. **Clarity** - Is the skill easy to understand?
2. **Completeness** - Does it cover the topic adequately?
3. **Examples** - Are there concrete examples?
4. **Structure** - Does it follow the format?
5. **Testing** - Has it been tested with an AI agent?
6. **Scope** - Is it focused on a specific task?

---

## Skill Maintenance

### Updating Existing Skills

If you find issues or improvements:

1. Open an issue describing the problem
2. Submit a PR with the fix
3. Update the version in frontmatter (if versioned)

### Deprecating Skills

If a skill becomes obsolete:

1. Add `deprecated: true` to frontmatter
2. Add deprecation notice at top of SKILL.md
3. Point to replacement skill if applicable

---

## Examples of Good Skills

Study these existing skills for reference:

- **tool-updates** - Multi-file skill with detailed workflow
- **hub-news-posts** - Single-file skill with clear structure

---

## Getting Help

- **Questions?** Open a discussion on GitHub
- **Bug reports?** Open an issue
- **Ideas?** Check [GROWTH_PLAN.md](GROWTH_PLAN.md) for planned skills

---

## Code of Conduct

Be respectful, constructive, and collaborative. We're all here to make Galaxy development better.

---

## License

By contributing, you agree that your contributions will be licensed under the same license as this repository.
