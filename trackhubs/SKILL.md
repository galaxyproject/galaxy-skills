---
name: trackhubs
description: Building UCSC Track Hubs (track hubs and assembly hubs) — bigBed/bigChain/bigMaf format requirements, composite-track rules, hub.txt / genomes.txt / trackDb.txt structure. Use when emitting a UCSC hub from Galaxy outputs, wrapping a hub-publishing tool, or debugging hubCheck failures.
---

# UCSC Track Hubs

Reference for building UCSC Track Hubs and Assembly Hubs from Galaxy outputs. Catches the recurring class of LLM errors where the wrong track type is emitted, composites mix incompatible types, or `genomes.txt` ships with empty `defaultPos`.

## When to Use

- Emitting a UCSC hub bundle (`hub.txt` + `genomes.txt` + per-assembly `trackDb.txt`) from any Galaxy workflow
- Writing a Galaxy tool that produces big-format files (`bigBed`, `bigMaf`, `bigChain`, `bigWig`, `vcfTabix`) destined for a hub
- Debugging `hubCheck` failures
- Reviewing AI-generated `trackDb.txt` / `genomes.txt`

## The four errors that catch every first attempt

| Mistake | What breaks | Fix |
|---|---|---|
| `type chain` with a `.chain.gz` file | Hub silently fails to load chain tracks | Use `type bigChain` with `bigChain.bb` + `linkDataUrl` to `bigChain.link.bb`. See `references/chain-to-bigchain.md` |
| Mixing `bigMaf` + `bigChain` in one composite | `hubCheck` fails: "type mismatch in compositeTrack" | One composite per `type`. See `references/composite-tracks.md` |
| Empty `defaultPos` in `genomes.txt` | Hub loads but the browser jumps nowhere; users see "no data" | `defaultPos chrN:start-end` must be a real region |
| Missing `.2bit` for an assembly hub | Hub fails to render the assembly's chromosomes | Build with `faToTwoBit` and point `twoBitPath` at the file (relative to `genomes.txt`) |

All four are documented with concrete fixes in the references below.

## Quick reference — track type → file format

| Track type    | File format       | Schema (`-as=`) | Companion files       |
|---------------|-------------------|-----------------|-----------------------|
| `bigMaf`      | `.bb` (bigBed 3+1)| `bigMaf.as`     | optional `.bb.bai` index for fast range queries |
| `bigChain`    | `.bb` (bigBed 6+6)| `bigChain.as`   | **required**: `.bigChain.link.bb` (bigBed 4+1, `bigLink.as`) referenced via `linkDataUrl` |
| `bigBed`      | `.bb` (bigBed N)  | optional        | none                  |
| `bigBed 12 +` | `.bb` (bigBed 12+N)| custom `.as` schema for the `+N` fields | none |
| `bigWig`      | `.bw`             | none            | none                  |
| `vcfTabix`    | `.vcf.gz`         | none            | **required**: `.tbi` (UCSC needs Tabix `.tbi`, not BCFtools default `.csi`) |
| `bam`         | `.bam`            | none            | **required**: `.bai`  |

**Always**: every binary file needs its index/companion. Hub will load but the track will be silently missing if a companion is absent.

## hub.txt / genomes.txt / trackDb.txt — full structure

```
hub-root/
├── hub.txt            ← describes the whole hub (one file)
├── genomes.txt        ← lists every assembly (one record per assembly)
└── {ACC}/             ← per-assembly directory
    ├── trackDb.txt    ← tracks for this assembly
    ├── groups.txt     ← OPTIONAL track-group ordering
    ├── {ACC}.2bit     ← REQUIRED for assembly hubs (custom genomes)
    ├── description.html  ← OPTIONAL assembly description
    └── …big files referenced by trackDb.txt
```

A bare-minimum `hub.txt`:

```
hub MyHub
shortLabel My hub
longLabel  Full descriptive label of the hub
genomesFile genomes.txt
email me@example.org
```

A bare-minimum `genomes.txt` record for an **assembly hub** (custom genome not in UCSC's databases):

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

For a **track hub** on an already-supported UCSC assembly (e.g. `hg38`, `mm10`), drop `twoBitPath` and `htmlPath` and use the UCSC assembly name as `genome`. The other fields stay.

A `trackDb.txt` with one standalone track + one composite:

```
track multiz
shortLabel multiz
longLabel  8-way multi-z alignment
type bigMaf
bigDataUrl multiz.bb
visibility pack
speciesOrder strain1 strain2 strain3 …

track chains_composite
compositeTrack on
shortLabel Pairwise chains
longLabel  Pairwise chain alignments to other assemblies
type bigChain
visibility hide

    track chain_to_GCA_X
    parent chains_composite off
    shortLabel chain to GCA_X
    longLabel  Chain alignment to GCA_X
    type bigChain GCA_X        ← second word = target assembly
    bigDataUrl chains/this_to_X.bigChain.bb
    linkDataUrl chains/this_to_X.bigChain.link.bb
    visibility hide
```

## Workflow — emitting a hub from a Galaxy workflow

1. **Per-assembly files first**. For each assembly the hub will carry:
   - Build the `.2bit` via `faToTwoBit` (if it's an assembly hub).
   - Convert every binary input to its big-format with the right `bedToBigBed -as=…` / `mafToBigMaf` / `bgzip` + `tabix` pipeline.
   - Make sure every companion (`.bb.bai`, `.link.bb`, `.tbi`) is built and named exactly as the trackDb will reference it.
2. **Emit `trackDb.txt` per assembly** with a generator (Python is fine). Group tracks into composites by **single `type`**. bigMaf and bigChain go in separate top-level tracks. See `references/composite-tracks.md`.
3. **Emit `genomes.txt`** with the 9 required fields. `defaultPos` must be a real region on a real contig. `twoBitPath` must resolve (relative to `genomes.txt`).
4. **Emit `hub.txt`**. Validate with `hubCheck -level=warn file://$WORK/hub.txt`. Fix every warning before publishing.
5. **Publish**: `rsync` to the hub server, or stage to a public bucket (S3, Dropbox-with-direct-link, etc.) referenced by the catalog.

Galaxy collection trick: the hub layout requires per-assembly directories. Galaxy can encode this via `list:list` collections (outer = assembly, inner = track type). The `build_trackdb` wrapper should accept the outer collection name as the assembly accession.

## Common Pitfalls

### bigMaf and bigChain cannot share a composite

```xml
<!-- WRONG: hubCheck error "type mismatch in compositeTrack" -->
track multi_align
compositeTrack on
type bed                  ← bogus placeholder
    track maf_track
    type bigMaf
    bigDataUrl x.maf.bb
    track chain_track
    type bigChain
    bigDataUrl y.chain.bb
```

```xml
<!-- CORRECT: standalone bigMaf + separate bigChain composite -->
track multiz
type bigMaf
bigDataUrl x.maf.bb

track chains
compositeTrack on
type bigChain
    track chain_a
    parent chains off
    type bigChain GCA_xxx
    bigDataUrl y.chain.bb
    linkDataUrl y.chain.link.bb
```

UCSC's composite-track rule: **all sub-tracks share one `type`.** Multi-type bundling needs `superTrack on` (which only groups visually) or `multiWig` (bigWig-only).

### bigChain needs both `.bb` and `.link.bb`

A bigChain track references **two** files. The data file (`bigDataUrl`, bigBed 6+6 from `bigChain.as`) carries the chain headers; the link file (`linkDataUrl`, bigBed 4+1 from `bigLink.as`) carries the block-by-block alignment positions. Without the link file the track loads but draws nothing.

See `references/chain-to-bigchain.md` for the awk/Python recipe.

### `defaultPos` must be a real contig:start-end

```
defaultPos                                          ← WRONG, empty
defaultPos chr1                                     ← WRONG, no range
defaultPos chr1:1                                   ← WRONG, no end
defaultPos chr1:1-200000                            ← OK
defaultPos LT635625.2:1264700-1277700               ← OK (assembly-hub style)
```

For an assembly hub, the contig name must match a name in the `.2bit`. The `twoBitInfo` tool will dump contig names if you forget them.

### vcfTabix needs `.tbi`, not `.csi`

`bcftools index` defaults to `.csi`. UCSC's `vcfTabix` only reads Tabix `.tbi`. Re-index with `bcftools index -t` or `tabix -p vcf`.

## See Also

- `references/composite-tracks.md` — the single-type rule and supertrack / multiWig alternatives
- `references/chain-to-bigchain.md` — concrete chain → bigChain conversion script
- `references/genomes-txt-fields.md` — every field of `genomes.txt` with required-vs-optional and worked examples
- `references/hubcheck-debugging.md` — common `hubCheck` errors and their fixes
- Galaxy `ucsc-kent-tools` wrappers (iuc) — most kent utilities are already wrapped; missing pieces flagged in `tool-dev` skill
- UCSC official docs:
  - <https://genome.ucsc.edu/goldenPath/help/hgTrackHubHelp.html> — Track Hub guide
  - <https://genome.ucsc.edu/goldenPath/help/hubQuickStartAssembly.html> — Assembly Hub quickstart
  - <https://genome.ucsc.edu/goldenPath/help/bigChain.html> — bigChain conversion recipe
  - <https://genome.ucsc.edu/goldenPath/help/bigMaf.html> — bigMaf conversion recipe
