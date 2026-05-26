# trackhubs

UCSC Track Hub and Assembly Hub building skills. See [SKILL.md](SKILL.md) for the entry point.

## Why this skill exists

UCSC Track Hubs are a common publishing target for comparative-genomics outputs from Galaxy: pangenome graphs, multiz alignments, pairwise chains, gene annotations, selection scans, and cohort VCFs all surface naturally as hub tracks. The schema is well-documented but has several traps that an LLM consistently falls into without guardrails:

- Inventing `type chain` (not a real track-hub type) instead of `bigChain`
- Pointing tracks at gzipped text files instead of indexed binaries
- Putting `bigMaf` and `bigChain` in the same composite (composites must be single-type)
- Emitting `genomes.txt` with empty `defaultPos` (silent failure)
- Missing companion files (`.bb.bai`, `.bigChain.link.bb`, `.tbi` instead of `.csi`)

Each of those errors was caught only by review of a real PR (galaxyproject/brc-analytics#1279), not by `hubCheck -level=warn`. This skill encodes the lessons so the next workflow gets them right the first time.

## Skill structure

- **[SKILL.md](SKILL.md)** — main entry point. Quick reference, workflow, common pitfalls.
- **[references/composite-tracks.md](references/composite-tracks.md)** — single-type rule, superTrack vs. compositeTrack vs. multiWig
- **[references/chain-to-bigchain.md](references/chain-to-bigchain.md)** — full chain → bigChain conversion script + recipe
- **[references/genomes-txt-fields.md](references/genomes-txt-fields.md)** — every field of `genomes.txt`, assembly-hub vs. track-hub, validation pitfalls
- **[references/hubcheck-debugging.md](references/hubcheck-debugging.md)** — `hubCheck` error and warning catalog

## See also

- [Galaxy `ucsc-kent-tools` wrappers](https://github.com/galaxyproject/tools-iuc/tree/main/tools/ucsc-tools) — most kent utilities are already wrapped; this skill calls out the gaps
- UCSC official docs:
  - <https://genome.ucsc.edu/goldenPath/help/hgTrackHubHelp.html>
  - <https://genome.ucsc.edu/goldenPath/help/hubQuickStartAssembly.html>
  - <https://genome.ucsc.edu/goldenPath/help/bigChain.html>
  - <https://genome.ucsc.edu/goldenPath/help/bigMaf.html>
  - <https://genome.ucsc.edu/goldenPath/help/trackDb/trackDbHub.html> — the full trackDb field reference
