# Galaxy Skills maintenance tasks.

# Synchronize the Galaxy Markdown directive references vendored into skills.
#
# Source of truth: client/src/components/Markdown/directives.{yml,md} in
# galaxyproject/galaxy. directives.md is generated from directives.yml upstream
# (make client-gen-markdown-directives); both are "do not edit by hand" here — to
# change content, change it in Galaxy and re-sync.
#
# Each skill vendors exactly one form (no duplicated content across a skill):
# workflow-reports uses the human-readable directives.md; reproduciblify uses the
# machine-readable directives.yml.
#
# Override the source to pull from an unmerged branch, e.g.:
#   make sync-directives GALAXY_REPO=jmchilton/galaxy GALAXY_REF=directives
GALAXY_REPO ?= galaxyproject/galaxy
GALAXY_REF  ?= dev
GALAXY_RAW  := https://raw.githubusercontent.com/$(GALAXY_REPO)/$(GALAXY_REF)
DIRECTIVES_SRC  := client/src/components/Markdown

# Each entry is <dest-dir>:<filename> — maps an upstream directives file to the
# one skill that consumes it.
DIRECTIVE_TARGETS := workflow-reports/references:directives.md reproduciblify/references:directives.yml

.PHONY: sync-directives
sync-directives:
	@for pair in $(DIRECTIVE_TARGETS); do \
		dir=$${pair%%:*}; f=$${pair##*:}; \
		mkdir -p $$dir; \
		echo "$(GALAXY_REPO)@$(GALAXY_REF): $$f -> $$dir/$$f"; \
		curl -fsSL "$(GALAXY_RAW)/$(DIRECTIVES_SRC)/$$f" -o "$$dir/$$f"; \
	done
	@echo "Synced from $(GALAXY_REPO)@$(GALAXY_REF)"
