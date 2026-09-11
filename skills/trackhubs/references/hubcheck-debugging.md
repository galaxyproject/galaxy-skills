# `hubCheck` errors and what they mean

`hubCheck` (from kentUtils) validates a hub against UCSC's schema before publishing. Run it with `-level=warn` to catch the soft issues that still load but break behavior.

```bash
hubCheck -level=warn file:///path/to/hub.txt           # local
hubCheck -level=warn https://my.cdn/hub/hub.txt        # public
```

`hubCheck` exits non-zero only on errors. Warnings still print but pass exit code. Read every warning.

## Errors

| Error | Cause | Fix |
|---|---|---|
| `Can't find genomesFile genomes.txt` | `hub.txt` references the wrong relative path | check the `genomesFile` line in `hub.txt` |
| `type mismatch in compositeTrack` | composite contains sub-tracks of different `type`s | split into one composite per type (see `composite-tracks.md`) |
| `unknown track type X` | typo or made-up type — common: `chain` (should be `bigChain`), `maf` (should be `bigMaf`) | use a real type from the [supported list](https://genome.ucsc.edu/goldenPath/help/trackDb/trackDbHub.html) |
| `parent track Y not found` | sub-track has `parent Y` but no track `Y` exists, or Y is not a composite/superTrack | check the parent name spelling; ensure the parent is declared before the child in the file |
| `Required field defaultPos missing or empty` | `defaultPos` line is blank or absent from `genomes.txt` | set a real `chrN:start-end` |
| `Can't find twoBit file …` | `.2bit` path in `genomes.txt` resolves to nothing | build with `faToTwoBit`, fix the relative path |
| `bigDataUrl … not found` | track's binary file is missing or wrong relative path | verify the file exists at the path `trackDb.txt` declares |
| `Can't open bigBed file …: header byte not valid` | the file isn't actually a bigBed (e.g. trying to use `.bed`, `.bed.gz`, or `.chain.gz` as `bigDataUrl`) | rebuild with `bedToBigBed` (or appropriate big-format converter) |
| `compositeTrack lines must come before sub-tracks` | composite header is below its members | move the composite parent stanza to before its children |

## Warnings

| Warning | What it means | Should you fix it? |
|---|---|---|
| `track has no shortLabel` | UI will show a default label | yes, always — labels are mandatory in practice |
| `bigMaf has no .bb.bai index` | mafIndex companion missing; range queries are slow | optional but recommended for genome-scale views |
| `vcfTabix file has .csi index, expected .tbi` | UCSC's `vcfTabix` only reads Tabix `.tbi` | yes — re-index with `bcftools index -t` or `tabix -p vcf` |
| `bigChain has no linkDataUrl` | track will load but draw nothing | yes — bigChain is a paired-file format |
| `assembly hub: no description.html for genome X` | UI shows blank assembly info | cosmetic, recommended for public hubs |

## Debugging recipes

### Hub loads but a track is silently missing

`hubCheck` passed but the track doesn't appear. Most common causes:

1. **Wrong `type`**: e.g. `type chain` with a `.chain.gz` file. UCSC silently drops unknown types from the trackDb. Check that `type` is a [supported type](https://genome.ucsc.edu/goldenPath/help/trackDb/trackDbHub.html).
2. **Empty `bigDataUrl` target**: the file exists but is 0 bytes. Check `ls -la` on the path.
3. **Wrong companion index**: bigChain without `.link.bb`, bigMaf without `.bb.bai` (sometimes), `vcfTabix` with `.csi` instead of `.tbi`. Track loads at zero items.
4. **Region has no data**: try `defaultPos` from a contig you know carries data.

### Hub loads but jumps to a blank page

The browser opens but shows "no data" or a blank ideogram:

1. `defaultPos` points at a contig name not in the `.2bit`. Dump contig names with `twoBitInfo {ACC}.2bit stdout | head` and pick one that exists.
2. `defaultPos` range is past the end of the contig. Verify with `twoBitInfo`.

### Hub is too slow at default zoom

Default zoom over a whole genome with un-indexed tracks chokes:

1. Build `.bb.bai` index for every bigMaf (`mafIndex` from kentUtils).
2. Tabix-index every VCF (`tabix -p vcf`).
3. Sort BED inputs to `bedToBigBed` before conversion.
4. Set `visibility hide` on rarely-used tracks (chains, secondary alignments) so they don't auto-render.

## Workflow integration

When wrapping a hub-publishing workflow:

1. Run `hubCheck -level=warn` as the **last** workflow step before declaring the hub ready.
2. Fail the workflow on any warning. The default `-level=error` is too permissive — the silent-failure warnings above are exactly the ones that bite users.
3. Persist `hubCheck` stdout to a workflow output so reviewers can audit.
