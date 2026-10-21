# Pairing imported reads

Use this guidance when creating a read collection from imported files, URLs or
existing Galaxy datasets, or when converting a flat read collection to pairs.

## Inspect the selected inputs

Use the complete source manifest or history listing, including additional pages.
Match the files the user selected, rather than every dataset in the history.
Check FASTQ extensions or Galaxy datatypes and available source metadata. Separate
reference FASTA, sample sheets and other non-read files from the proposed read
collection. Preserve dataset IDs and source locations alongside the names.

Recognize a mate token only when it has a complementary token in the same naming
position and the rest of the sample identity agrees:

| Example names | Candidate sample and mate mapping |
| --- | --- |
| `sample_1.fq.gz`, `sample_2.fq.gz` | `sample`: 1 → forward, 2 → reverse |
| `sample_R1.fastq`, `sample_R2.fastq` | `sample`: R1 → forward, R2 → reverse |
| `sample-F.fastq.gz`, `sample-R.fastq.gz` | `sample`: F → forward, R → reverse |
| `sample.forward.fq`, `sample.reverse.fq` | `sample`: forward, reverse |
| `sample_S1_L001_R1_001.fastq.gz`, `sample_S1_L001_R2_001.fastq.gz` | Keep sample, lane and chunk identity; vary only the read token |

These are candidate mappings, not proof that the read records correspond. Use
source metadata or a sample sheet when available. Numbers can denote replicates;
letters can be part of sample names. Do not infer pairs from arbitrary `1`, `2`,
`F` or `R` substrings, or from the order in which files were returned. Filenames
with several possible mate tokens need clarification. Do not infer how to split
interleaved FASTQ from its filename alone.

Every proposed sample needs exactly one forward and one reverse file. Keep lanes,
chunks and distinct source directories separate during matching; merging them is
a separate decision. Report orphaned reads, duplicate mates and conflicting sample
identifiers explicitly. Do not silently discard them or combine matching
basenames from unrelated sources.

## Resolve the user's choice

If the request says only "make a collection" and the reads appear paired, ask
before creating either the final collection or a temporary list:

> I found 8 FASTQ files that appear to form 4 read pairs, for example
> `M117-bl_1.fq.gz` and `M117-bl_2.fq.gz`. Would you like a paired collection?
> The reference `chrM.fa.gz` will stay separate.
>
> Create paired collection · Create flat list · Review pairing

Wait for the answer. A suggested or preselected option is not an answer. When
files are unmatched or ambiguous, show those exceptions and resolve their
handling before building the affected collection.

If the user already requested a paired collection or chose a flat list, honor
that choice. Do not repeat the structure question for the same inputs. An explicit
flattening request should remain a flattening operation even if mate names are
present. If there is no pairing evidence and the intended flat structure is
clear, proceed without a pairing prompt. Absence of a familiar filename pattern
does not by itself prove single-end data; clarify genuinely unknown layout.

For several samples, the paired result is `list:paired`, with sample identifiers
at the outer level and `forward`/`reverse` beneath each sample. Record the chosen
structure, the actual dataset-to-mate mapping and any agreed exclusions in the
analysis record. Revisit the choice if the input set or mapping changes materially.

## Build and verify

Use the skill's native Galaxy tool strategies. A flat list can be a necessary
intermediate for Apply Rules after the paired destination has been agreed; label
it as an intermediate, and do not present it as the completed read collection.
Use the actual tool schema and track the rules table's column indices. If a
construction step fails, inspect its error and fix the inputs or choose another
supported native tool. Do not silently fall back to ad-hoc API collection creation.

Before reporting completion, inspect the returned collection and all nested
elements, fetching further pages/details if the response is truncated. Confirm:

- The collection type matches the chosen structure and population has completed.
- Every expected sample is present with the agreed identifier.
- Each paired sample has exactly `forward` and `reverse` with the correct source
  datasets from the agreed mapping; neither mate is duplicated or swapped.
  Native tools such as Apply Rules may copy datasets and return new IDs. In that
  case, verify the source/copy provenance instead of requiring identical IDs.
- All expected input datasets are accounted for, and excluded files match the
  user's decision. Read datasets are ready and have appropriate FASTQ datatypes.

Record the collection ID and this evidence in the analysis record. Successful job
status or the collection name alone is insufficient. These checks verify the
collection structure and assignments; they do not establish read-level
concordance within FASTQ files.

The [Galaxy collections tutorial](https://training.galaxyproject.org/training-material/topics/galaxy-interface/tutorials/collections/tutorial.html#creating-a-paired-dataset-collection)
uses the eight `M117` FASTQ files above as four read pairs, with `chrM.fa.gz` as a
separate reference.
