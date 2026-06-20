# Makefile for the tool-install-yaml skill.
#
# The reference doc is synced verbatim (minus the source's own vault frontmatter)
# from galaxy-brain. Re-pull it with:
#   make -C tool-install-yaml sync

SKILL_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
REFERENCE := $(SKILL_DIR)references/tool-install-yaml.md
SOURCE_URL := https://raw.githubusercontent.com/jmchilton/galaxy-brain/main/vault/research/Component%20-%20Tool%20Install%20YAML.md
SOURCE_WEB := https://github.com/jmchilton/galaxy-brain/blob/main/vault/research/Component%20-%20Tool%20Install%20YAML.md

.PHONY: sync
sync: ## Re-pull the reference doc from galaxy-brain
	@echo "Fetching $(SOURCE_URL)"
	@tmp=$$(mktemp); \
	curl -fsSL "$(SOURCE_URL)" -o "$$tmp" || { echo "Fetch failed"; rm -f "$$tmp"; exit 1; }; \
	{ \
	  echo '<!--'; \
	  echo 'SYNCED DOCUMENT — do not hand-edit.'; \
	  echo 'Source: $(SOURCE_WEB)'; \
	  echo 'Raw:    $(SOURCE_URL)'; \
	  echo 'To update: run `make -C tool-install-yaml sync` (re-pulls the raw source below this comment).'; \
	  echo '-->'; \
	  echo ''; \
	  awk 'NR==1 && $$0=="---"{fm=1; next} fm && $$0=="---"{fm=0; next} !fm{print}' "$$tmp"; \
	} > "$(REFERENCE)"; \
	rm -f "$$tmp"; \
	echo "Wrote $(REFERENCE)"

.PHONY: help
help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  %-10s %s\n", $$1, $$2}'
