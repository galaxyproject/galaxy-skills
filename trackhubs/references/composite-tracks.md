# Composite tracks — the single-type rule

UCSC composite tracks bundle related sub-tracks under one control panel. They have one hard rule that every first-time hub author trips over:

> **All sub-tracks of a composite must share the same `type`.**

A composite with `type bigMaf` accepts only `bigMaf` sub-tracks. A composite with `type bigChain` accepts only `bigChain` sub-tracks. Mixing types makes `hubCheck` emit "type mismatch in compositeTrack" and silently drops the offending sub-tracks at render time.

## Decision: composite vs. superTrack vs. multiWig

| Container | Sub-track types | When to use |
|---|---|---|
| `compositeTrack on` | single `type` | grouping N tracks of the same kind (e.g. one chain per pairwise comparison) |
| `superTrack on` | any mix | visually grouping unrelated tracks in the browser UI; no shared settings |
| `multiWig on` | bigWig only | overlaying multiple bigWigs in one panel |

Most "I want everything under one heading" cases are actually `superTrack`. Composite is the right answer only when the sub-tracks really do share a `type`.

## Worked examples

### One standalone + two composites (the common shape)

```
# Standalone bigMaf (one big alignment, no siblings)
track multiz
shortLabel multiz
longLabel  8-way multi-z alignment
type bigMaf
bigDataUrl multiz.bb
visibility pack

# Composite of bigChain — one per pairwise comparison
track chains_composite
compositeTrack on
shortLabel Chains
longLabel  Pairwise chain alignments
type bigChain
visibility hide

    track chain_to_A
    parent chains_composite off
    type bigChain GCA_A
    bigDataUrl chains/this_to_A.bigChain.bb
    linkDataUrl chains/this_to_A.bigChain.link.bb

    track chain_to_B
    parent chains_composite off
    type bigChain GCA_B
    bigDataUrl chains/this_to_B.bigChain.bb
    linkDataUrl chains/this_to_B.bigChain.link.bb

# Composite of bigBed 12 — gene projections from N anchors
track annot_composite
compositeTrack on
shortLabel Gene projections
longLabel  Cross-strain gene projections
type bigBed 12
visibility dense

    track annot_from_A
    parent annot_composite on
    type bigBed 12
    bigDataUrl annot_from_A.bb

    track annot_from_B
    parent annot_composite off
    type bigBed 12
    bigDataUrl annot_from_B.bb
```

### `superTrack` for grouping unrelated track types

```
track all_pangenome
superTrack on show
shortLabel Pangenome
longLabel  Everything pangenome on this assembly

    track multiz
    parent all_pangenome
    type bigMaf
    bigDataUrl multiz.bb

    track chains_composite
    parent all_pangenome
    compositeTrack on
    type bigChain
        track chain_to_A
        parent chains_composite off
        type bigChain GCA_A
        bigDataUrl chains/this_to_A.bigChain.bb
        linkDataUrl chains/this_to_A.bigChain.link.bb
```

Note the nesting: `superTrack` holds the standalone bigMaf and the bigChain composite as siblings; the composite's own sub-tracks live one level deeper. The composite still has to be single-type internally — `superTrack` only relaxes the rule at the outer level.

## Errors hubCheck emits

| Error | Real meaning |
|---|---|
| `type mismatch in compositeTrack` | one of your sub-tracks declares a different `type` than the composite's parent `type` |
| `parent track not found` | you set `parent X` on a sub-track but no track named `X` exists, or it isn't a composite/superTrack |
| `compositeTrack lines must come before sub-tracks` | indent or order issue — composite header must precede its members |
| `unknown track type` | `type X` is not a UCSC-supported type. Common typo: `chain` (use `bigChain`), `maf` (use `bigMaf`) |

## Tips for AI-generated trackDb.txt

- Generate one container per track-type bucket. If the bucket has one member, emit it standalone (no composite wrapper). If the bucket has many, wrap in composite.
- Verify every `type` matches its sub-track's actual file extension and schema. Don't assume `type bed` is a safe placeholder — it isn't; pick the actual type.
- For composite parents, set the second `type` argument (e.g. `type bigChain GCA_xxx`) **only on sub-tracks**, not on the composite parent. The parent's `type bigChain` (no second word) is correct.
