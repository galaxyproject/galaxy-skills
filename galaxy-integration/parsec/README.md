# parsec sub-skill

BioBlend-backed Galaxy CLI skill for shell scripting, batch operations, and jq pipelines.

## Regenerating the command index

The `## Command index` section in `SKILL.md` is auto-generated from the live parsec CLI.
Run this whenever parsec is updated or new commands are added.

```bash
# 1. Install parsec (dev dep, not needed at runtime)
pip install galaxy-parsec
# or, if working from source:
uv pip install -e /path/to/parsec

# 2. Regenerate
python generate_command_index.py
```

The script is idempotent — it only replaces the `<!-- AUTO-GENERATED:START/END -->` region
and preserves all hand-written content.
