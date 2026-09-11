# `genomes.txt` field reference

One record per assembly, separated by a blank line. Required fields differ between **assembly hubs** (custom genome, you ship the `.2bit`) and **track hubs** (genome already in UCSC's databases, you just add tracks).

## Required fields — Assembly Hub

| Field | Required | Notes |
|---|---|---|
| `genome` | yes | Assembly identifier — usually the GenBank accession (`GCA_xxx`). Used as the directory name for per-assembly files. |
| `trackDb` | yes | Relative path to `trackDb.txt`. Convention: `{genome}/trackDb.txt`. |
| `groups` | yes | Relative path to `groups.txt`. Convention: `{genome}/groups.txt`. |
| `description` | yes | Human-readable description shown in the genome chooser. |
| `twoBitPath` | yes | Relative path to the assembly's `.2bit`. Build with `faToTwoBit input.fa output.2bit`. |
| `organism` | yes | Common name with underscores for spaces: `Plasmodium_vivax`. |
| `defaultPos` | yes | **Real** `chrN:start-end` — must point at a contig in the `.2bit`. Empty value = hub fails to render. |
| `scientificName` | yes | Two-word binomial: `Plasmodium vivax`. |
| `htmlPath` | recommended | Relative path to an HTML description file shown when the assembly is selected. |
| `orderKey` | optional | Integer for sort order in the chooser. Lower = earlier. |

## Required fields — Track Hub

For a known UCSC assembly (e.g. `hg38`, `mm10`, `dm6`):

| Field | Required | Notes |
|---|---|---|
| `genome` | yes | Must match a UCSC assembly name **exactly** (case-sensitive). Wrong: `hg38` for an assembly UCSC calls `GRCh38`. Check with `curl -s https://api.genome.ucsc.edu/list/ucscGenomes \| jq …` if unsure. |
| `trackDb` | yes | Relative path. |
| All other fields | not needed | `twoBitPath`, `defaultPos`, etc. come from UCSC's existing assembly metadata. |

## Examples

### Assembly Hub record

```
genome GCA_900093555.2
trackDb GCA_900093555.2/trackDb.txt
groups GCA_900093555.2/groups.txt
description Plasmodium vivax PvP01 (GCA_900093555.2)
twoBitPath GCA_900093555.2/GCA_900093555.2.2bit
organism Plasmodium_vivax
defaultPos LT635625.2:1264700-1277700
scientificName Plasmodium vivax
htmlPath GCA_900093555.2/description.html
```

### Track Hub record (existing UCSC assembly)

```
genome hg38
trackDb hg38/trackDb.txt
```

That's the whole record. Track hubs are far easier to ship; reach for an assembly hub only when the target genome isn't already in UCSC.

## Validation pitfalls

- **Path resolution**: every relative path is relative to the directory containing `genomes.txt`, not to the hub root. If `genomes.txt` is at `hub/genomes.txt`, `twoBitPath GCA_X/GCA_X.2bit` resolves to `hub/GCA_X/GCA_X.2bit`.
- **Symlinks**: relative symlinks for `.2bit` are fine if you're publishing via `rsync` (which dereferences by default). `rclone copy --copy-links` works too. `cp -d` keeps symlinks and breaks them at the destination — avoid.
- **`defaultPos` not on a real contig**: `hubCheck` will pass but the browser jumps nowhere. Pick a contig you've confirmed with `twoBitInfo {ACC}.2bit stdout | head`.
- **Spaces in `organism`**: use underscores. UCSC parses the rest of the line as the value but downstream pages break on raw spaces.
- **Missing blank line between records**: `hubCheck` reports the second record as malformed. One blank line separator is required.

## Building `genomes.txt` from a Galaxy workflow

A `build_genomes_txt` tool should accept:

- A collection of assemblies with their accessions, `.2bit` files, and `.sizes` files
- A `defaultPos` mapping (e.g. a TSV: `accession\tcontig:start-end`)
- The species name (used for `organism`, `scientificName`)
- Optional `htmlPath`s

…and emit a single `genomes.txt`. The most common cause of a working-but-empty hub is a missing or empty `defaultPos`, so the tool should refuse to emit a record where `defaultPos` is empty rather than letting it through.
