# Makefile for the gxwf-cli skill.
#
# This skill is synced *in its entirety* from galaxy-tool-util-ts, which is the
# source of truth. There the SKILL.md is generated from the commander program
# definitions via `make gen-skill`; do not hand-edit the copy here. Re-pull it
# with:
#   make -C gxwf-cli sync

SKILL_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
SKILL := $(SKILL_DIR)SKILL.md
SOURCE_URL := https://raw.githubusercontent.com/jmchilton/galaxy-tool-util-ts/main/docs/skills/gxwf-cli/SKILL.md
SOURCE_WEB := https://github.com/jmchilton/galaxy-tool-util-ts/blob/main/docs/skills/gxwf-cli/SKILL.md

.PHONY: sync
sync: ## Re-pull SKILL.md from galaxy-tool-util-ts
	@echo "Fetching $(SOURCE_URL)"
	@tmp=$$(mktemp); \
	curl -fsSL "$(SOURCE_URL)" -o "$$tmp" || { echo "Fetch failed"; rm -f "$$tmp"; exit 1; }; \
	awk -v web="$(SOURCE_WEB)" -v raw="$(SOURCE_URL)" '\
	  { print } \
	  /^---$$/ { fm++; if (fm==2 && !done) { done=1; \
	    print ""; \
	    print "<!--"; \
	    print "SYNCED DOCUMENT — do not hand-edit."; \
	    print "Source of truth: " web; \
	    print "Raw:             " raw; \
	    print "Upstream it is generated from the CLI via `make gen-skill`."; \
	    print "To update here:  run `make -C gxwf-cli sync` (re-pulls the raw source)."; \
	    print "-->"; \
	  } }' "$$tmp" > "$(SKILL)"; \
	rm -f "$$tmp"; \
	echo "Wrote $(SKILL)"

.PHONY: help
help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  %-10s %s\n", $$1, $$2}'
