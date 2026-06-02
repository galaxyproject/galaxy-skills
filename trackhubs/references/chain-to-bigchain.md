# Chain → bigChain conversion

UCSC track hubs accept pairwise chain alignments only as the `bigChain` track type, which reads two indexed binary bigBed files. A `.chain.gz` text file as `bigDataUrl` will not load. Build both files with one pass over the chain.

## What you produce

For every input `pair.chain` (or `pair.chain.gz`):

| Output | Format | Schema (`-as=`) | Hub reference |
|---|---|---|---|
| `pair.bigChain.bb` | bigBed 6+6 | `bigChain.as` | `bigDataUrl` |
| `pair.bigChain.link.bb` | bigBed 4+1 | `bigLink.as` | `linkDataUrl` |

Both files are needed. Without the link file the track loads but draws nothing.

## Schema files

`bigChain.as`:

```
table bigChain
"bigChain pairAlignment"
    (
    string  chrom;         "Reference sequence chromosome or scaffold"
    uint    chromStart;    "Start position in chromosome"
    uint    chromEnd;      "End position in chromosome"
    string  name;          "Chain id (numeric, unique within file)"
    uint    score;         "Display score (use 1000)"
    char[1] strand;        "+ or - for query strand"
    uint    tSize;         "Target sequence length"
    string  qName;         "Query sequence name"
    uint    qSize;         "Query sequence length"
    uint    qStart;        "Start of alignment on query"
    uint    qEnd;          "End of alignment on query"
    uint    chainScore;    "Score from the chain header"
    )
```

`bigLink.as`:

```
table bigLink
"bigLink pairwise alignment"
    (
    string  chrom;         "Reference sequence chromosome or scaffold"
    uint    chromStart;    "Start position in chromosome"
    uint    chromEnd;      "End position in chromosome"
    string  name;          "Chain id (matches chain in bigChain)"
    uint    qStart;        "Start in query"
    )
```

## The pass — Python

The UCSC chain format alternates one header line per chain plus a sequence of block lines (`size dt dq`, last line of each chain block has only `size`):

```
chain SCORE tName tSize tStrand tStart tEnd qName qSize qStrand qStart qEnd id
size dt dq
size dt dq
…
size
(blank line)
chain …
```

`hgLoadChain -noBin -test …` in kentUtils does this conversion natively but is not always available. The script below produces equivalent output in one pass:

```python
#!/usr/bin/env python3
"""Convert UCSC chain (gz or plain) to bigChain.bed + bigLink.bed."""
import gzip, sys
from pathlib import Path

def open_text(p):
    p = Path(p)
    return gzip.open(p, "rt") if p.suffix == ".gz" else open(p)

def convert(chain_path, big_bed, big_link):
    with open_text(chain_path) as fh, open(big_bed, "w") as out_bed, open(big_link, "w") as out_link:
        skip = False
        for line in fh:
            line = line.rstrip()
            if not line:
                continue
            if line.startswith("chain "):
                p = line.split()
                score, tName, tSize, tStrand = int(p[1]), p[2], int(p[3]), p[4]
                tStart, tEnd = int(p[5]), int(p[6])
                qName, qSize, qStrand = p[7], int(p[8]), p[9]
                qStart, qEnd, chain_id = int(p[10]), int(p[11]), p[12]
                if tStrand != "+":
                    sys.stderr.write(f"skip chain {chain_id}: tStrand={tStrand}\n")
                    skip = True
                    continue
                skip = False
                out_bed.write("\t".join(map(str, [
                    tName, tStart, tEnd, chain_id, 1000, qStrand,
                    tSize, qName, qSize, qStart, qEnd, score
                ])) + "\n")
                t_cur, q_cur = tStart, qStart
            else:
                if skip:
                    continue
                p = line.split()
                if len(p) == 3:
                    size, dt, dq = int(p[0]), int(p[1]), int(p[2])
                elif len(p) == 1:
                    size, dt, dq = int(p[0]), 0, 0
                else:
                    continue
                out_link.write("\t".join(map(str, [
                    tName, t_cur, t_cur + size, chain_id, q_cur
                ])) + "\n")
                t_cur += size + dt
                q_cur += size + dq

if __name__ == "__main__":
    convert(*sys.argv[1:])
```

## End-to-end recipe

```bash
# 1. Convert chain to two bed files
python3 chain_to_bigChain.py pair.chain.gz pair.bigChain.bed.raw pair.bigLink.bed.raw

# 2. Sort (bedToBigBed requires sorted input)
sort -k1,1 -k2,2n pair.bigChain.bed.raw > pair.bigChain.bed
sort -k1,1 -k2,2n pair.bigLink.bed.raw  > pair.bigLink.bed

# 3. Build bigBeds against the TARGET assembly's .sizes
bedToBigBed -type=bed6+6 -as=bigChain.as -tab pair.bigChain.bed target.sizes pair.bigChain.bb
bedToBigBed -type=bed4+1 -as=bigLink.as  -tab pair.bigLink.bed  target.sizes pair.bigChain.link.bb
```

Run-time: ~5 s per chain pair on one CPU; an 8-strain × 7-target panel (56 pairs) finishes in ~5 min.

## trackDb stanza

```
track chain_to_A
parent chains_composite off
shortLabel chain to A
longLabel  Chain alignment from this assembly to A
type bigChain GCA_A                          ← second word is the target assembly in genomes.txt
bigDataUrl chains/this_to_A.bigChain.bb       ← bigBed 6+6
linkDataUrl chains/this_to_A.bigChain.link.bb ← bigBed 4+1
visibility hide
```

Both `bigDataUrl` and `linkDataUrl` are required.

## Galaxy wrapping notes

For a Galaxy tool wrapper:

- Inputs: chain file (`.chain.gz` or `.chain`), target `.sizes`, optionally the target assembly name (for the `type bigChain {ASSEMBLY}` line in the generated `trackDb.txt` stanza).
- Outputs: paired `.bigChain.bb` + `.bigChain.link.bb`. Use a `list:paired` collection so downstream `build_trackdb` can map over assembly pairs.
- Datatype: declare the outputs as `bigbed` (Galaxy doesn't have a `bigChain` datatype yet; `bigbed` is the closest match).

## Common conversion bugs

| Bug | Fix |
|---|---|
| `bedToBigBed` errors with "out of order" | forgot `sort -k1,1 -k2,2n` |
| `bedToBigBed` errors with "chromosome not in .sizes" | wrong `.sizes` (you used source instead of target) |
| `chain` lines with `tStrand=-` | rare but possible; either swap orientations upstream (`chainSwap` from kentUtils) or skip those chains as shown in the script |
| Empty `bigChain.bb` | chain file was empty after PAF→chain step; check the upstream `axtChain`/`paftools.js view -f chain` step |
