# Galaxy Tool Testing Reference

Standalone reference for planemo testing. Used by tool-dev and other skills (nf-to-galaxy, galaxy-integration).

For the full tool development guide, see `../SKILL.md`. For the complete assertion specification, see the [Galaxy Tool XSD Schema](https://docs.galaxyproject.org/en/latest/dev/schema.html).

---

## Running Tests

### Full Test Suite

```bash
# With biocontainers (standard for CLI-wrapping tools)
planemo test --biocontainers tools/{tool_name}/

# Without containers (API tools with fixtures)
planemo test tools/{tool_name}/
```

### Specific Test

```bash
# Run a specific test by 0-based index
planemo test --test_index 0 tools/{tool_name}/{tool}.xml

# Single tool file
planemo test --biocontainers tools/{tool_name}/{tool}.xml
```

### With a Local Galaxy Instance

```bash
planemo test --galaxy_root /path/to/galaxy tools/{tool_name}/
```

---

## Test Output Files

After running tests, planemo produces:
- `tool_test_output.json` — machine-readable detailed results
- `tool_test_output.html` — human-readable report

---

## Writing Tests

### Basic Test

```xml
<tests>
    <test expect_num_outputs="1">
        <param name="input" value="test_input.txt"/>
        <output name="output">
            <assert_contents>
                <has_text text="expected output"/>
            </assert_contents>
        </output>
    </test>
</tests>
```

### With Sections and Conditionals

```xml
<test expect_num_outputs="2">
    <conditional name="output_mode">
        <param name="mode" value="advanced"/>
    </conditional>
    <section name="options">
        <param name="threads" value="4"/>
    </section>
    <output name="output" file="expected_output.txt"/>
</test>
```

**Avoid pipe syntax** for nested inputs. Use explicit nesting:

```xml
<!-- BAD: pipe syntax -->
<param name="filtering|min_score" value="0.5"/>

<!-- GOOD: explicit nesting -->
<section name="filtering">
    <param name="min_score" value="0.5"/>
</section>
```

### With Repeat Elements

```xml
<test expect_num_outputs="1">
    <section name="filters">
        <repeat name="filter_list">
            <param name="filter_value" value="value1"/>
        </repeat>
        <repeat name="filter_list">
            <param name="filter_value" value="value2"/>
        </repeat>
    </section>
    <output name="output">
        <assert_contents>
            <has_text text="value1"/>
        </assert_contents>
    </output>
</test>
```

### Collection Output

```xml
<test expect_num_outputs="1">
    <param name="input" value="test_input.fa"/>
    <output_collection name="results" type="list" count="5">
        <element name="file1">
            <assert_contents>
                <has_text text="expected"/>
            </assert_contents>
        </element>
    </output_collection>
</test>
```

Use `min` instead of exact `count` when output count may vary:

```xml
<output_collection type="list" min="10">
```

---

## Assertion Types

### Content Assertions (`<assert_contents>`)

```xml
<assert_contents>
    <!-- Text matching -->
    <has_text text="must contain this"/>
    <has_text text="must not contain" negate="true"/>
    <has_line line="exact line match"/>
    <has_line_matching expression="regex.*pattern"/>

    <!-- Structure -->
    <has_n_lines n="10"/>
    <has_n_lines min="5" max="20"/>
    <has_n_columns n="4"/>
    <has_n_columns n="4" sep="\t"/>

    <!-- Size -->
    <has_size value="1000" delta="100"/>
    <has_size min="500"/>
</assert_contents>
```

### File Comparison Modes

```xml
<!-- Exact match (default) -->
<output name="output" file="expected.txt"/>

<!-- Partial match — output must contain expected file's content -->
<output name="output" file="expected_subset.txt" compare="contains"/>

<!-- Allow N lines to differ (timestamps, floats) -->
<output name="output" file="expected.txt" lines_diff="2"/>

<!-- Size-based comparison for binary files -->
<output name="output" file="expected.bam" ftype="bam" compare="sim_size" delta="100"/>
```

### Stream and Command Assertions

```xml
<!-- Assert on stderr content -->
<assert_stderr>
    <has_text text="WARNING: low coverage"/>
</assert_stderr>

<!-- Assert on stdout content -->
<assert_stdout>
    <has_text text="Processing complete"/>
</assert_stdout>

<!-- Assert on the constructed command line -->
<assert_command>
    <has_text text="--expected-flag"/>
</assert_command>
```

### Testing Compressed Outputs

Use `decompress="true"` to test content inside compressed files:

```xml
<element name="output" ftype="fastq.gz">
    <assert_contents>
        <has_text text="expected" decompress="true"/>
    </assert_contents>
</element>
```

---

## Common Test Failures

### Data Changes Over Time

**Problem**: Upstream database changes, exact counts fail.

**Solution**: Use `min=` instead of exact values.

```xml
<!-- Fragile: exact count -->
<has_n_lines n="142"/>
<output_collection type="list" count="12">

<!-- Robust: minimum -->
<has_n_lines min="140"/>
<output_collection type="list" min="10">
```

### Variable Output

**Problem**: Output varies between runs (timestamps, random seeds, floating point).

**Solution**: Test for required content, not exact match.

```xml
<assert_contents>
    <has_text text="required header"/>
    <has_n_columns n="4"/>
</assert_contents>
```

Or use `lines_diff` for mostly-stable output:

```xml
<output name="output" file="expected.tsv" lines_diff="2"/>
```

### Floating Point

**Problem**: Floating point precision differences across platforms.

**Solution**: Use size-based assertions with delta.

```xml
<has_size value="1000" delta="50"/>
```

### Compressed Output

**Problem**: Testing content of compressed files.

**Solution**: Use `decompress="true"`.

```xml
<element name="output" decompress="true">
    <assert_contents>
        <has_text text="expected"/>
    </assert_contents>
</element>
```

---

## Analyzing Test Failures

### Quick Summary from tool_test_output.json

```python
import json

with open("tool_test_output.json") as f:
    data = json.load(f)

print(f"Summary: {data.get('summary', {})}")

for t in data.get("tests", []):
    status = t.get("data", {}).get("status")
    if status != "success":
        print(f"\n=== {t.get('id')} ===")
        print(f"Status: {status}")
        print(f"Problems: {t.get('data', {}).get('output_problems', [])}")
```

### Detailed Job Info

```python
for t in data.get("tests", []):
    if t.get("data", {}).get("status") != "success":
        job = t.get("data", {}).get("job", {})
        if job.get("stderr"):
            print(f"stderr: {job['stderr'][-500:]}")
        if job.get("stdout"):
            print(f"stdout: {job['stdout'][-500:]}")
```

---

## Test Numbering

Tests are 0-indexed:
- Test 0 = First `<test>` in file
- Test 1 = Second `<test>` in file
- etc.

When `tool_test_output.json` reports `test-5`, that's the 6th test.

---

## Test Structure Rules

- Give each test a **unique purpose** (e.g., "defaults", "compression on", "filtering active")
- Always include `expect_num_outputs` to verify file counts
- **Test data under 1 MB** — use assertions instead of golden files for larger outputs
- Include tests for output filters to verify filtering actually occurs
- Include tests for error conditions with expected failure

---

## Related

- **Full tool development guide**: `../SKILL.md`
- **Tool placement guide**: `tool-placement.md`
