#!/usr/bin/env python3
"""Validate and lint a Galaxy User-Defined Tool (UDT) offline.

Runs the same checks Galaxy runs on the server -- the ``UserToolSource`` schema
(structure + the four semantic validators) and ``lint_user_tool_source`` -- without
needing a live Galaxy. Use it as a fast pre-submit gate before create_user_tool.

Requirements:
    pip install galaxy-tool-util pyyaml

Usage:
    python validate.py my-tool.yml
    python validate.py -            # read YAML/JSON from stdin

Exit codes:
    0  valid and lint-clean
    1  schema validation failed
    2  lint findings (server create would reject these)
    3  missing dependency or unreadable input
"""

import sys

try:
    import yaml
except ImportError:
    sys.exit("Missing dependency: pip install pyyaml")

try:
    from galaxy.tool_util_models import UserToolSource, format_validation_errors
    from galaxy.tool_util.lint import lint_user_tool_source
except ImportError:
    sys.exit("Missing dependency: pip install galaxy-tool-util")

from pydantic import ValidationError


def main(argv):
    if len(argv) != 2:
        sys.exit(__doc__)

    source = argv[1]
    text = sys.stdin.read() if source == "-" else open(source).read()
    data = yaml.safe_load(text)

    try:
        tool = UserToolSource.model_validate(data)
    except ValidationError as exc:
        print("Schema validation FAILED:")
        for bullet in format_validation_errors(exc):
            print(f"  - {bullet}")
        return 1

    findings = lint_user_tool_source(tool)
    if findings:
        print("Lint findings (server create would reject these):")
        for bullet in findings:
            print(f"  - {bullet}")
        return 2

    print(f"OK: '{tool.name}' is valid and lint-clean.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
