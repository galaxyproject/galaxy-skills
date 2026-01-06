# Galaxy Tool Testing

## Running Tests

### Full Test Suite
```bash
planemo test tools/{tool_name}/
```

### Specific Test
```bash
planemo test --test_index 0 tools/{tool_name}/{tool}.xml
```

### With Galaxy Instance
```bash
planemo test --galaxy_root /path/to/galaxy tools/{tool_name}/
```

## Test Output Files
After running tests:
- `tool_test_output.json` - Detailed results
- `tool_test_output.html` - Human-readable report

## Analyzing Failures

### Quick Summary
```python
import json
with open('tool_test_output.json') as f:
    data = json.load(f)

print(f"Summary: {data.get('summary', {})}")

for t in data.get('tests', []):
    status = t.get('data', {}).get('status')
    if status != 'success':
        print(f"\n=== {t.get('id')} ===")
        print(f"Status: {status}")
        print(f"Problems: {t.get('data', {}).get('output_problems', [])}")
```

### Detailed Job Info
```python
for t in data.get('tests', []):
    if t.get('data', {}).get('status') != 'success':
        job = t.get('data', {}).get('job', {})
        print(f"stderr: {job.get('stderr', '')[-500:]}")
        print(f"stdout: {job.get('stdout', '')[-500:]}")
```

## Writing Tests

### Basic Test
```xml
<test expect_num_outputs="1">
    <param name="input" value="test_input.txt"/>
    <output name="output">
        <assert_contents>
            <has_text text="expected output"/>
        </assert_contents>
    </output>
</test>
```

### With Sections and Conditionals
```xml
<test expect_num_outputs="2">
    <conditional name="query|subcommand">
        <param name="mode" value="advanced"/>
        <param name="extra_param" value="value"/>
    </conditional>
    <section name="options">
        <param name="threads" value="4"/>
    </section>
    <output name="output" file="expected_output.txt"/>
</test>
```

### With Repeat Elements
```xml
<test>
    <section name="filters">
        <repeat name="filter_list">
            <param name="filter_value" value="value1"/>
        </repeat>
        <repeat name="filter_list">
            <param name="filter_value" value="value2"/>
        </repeat>
    </section>
</test>
```

### Collection Output
```xml
<test>
    <output_collection name="results" type="list" count="5">
        <element name="file1">
            <assert_contents>
                <has_text text="expected"/>
            </assert_contents>
        </element>
    </output_collection>
</test>
```

## Assertion Types

### Content Assertions
```xml
<assert_contents>
    <has_text text="must contain this"/>
    <has_text text="must not contain" negate="true"/>
    <has_line line="exact line match"/>
    <has_n_lines n="10"/>
    <has_n_lines min="5" max="20"/>
    <has_n_columns n="4"/>
    <has_size value="1000" delta="100"/>
</assert_contents>
```

### File Comparison
```xml
<output name="output" file="expected.txt"/>
<output name="output" file="expected.txt" compare="contains"/>
<output name="output" file="expected.txt" lines_diff="2"/>
```

### Command Assertions
```xml
<assert_command>
    <has_text text="--expected-flag"/>
</assert_command>
```

## Common Test Failures

### Data Changes Over Time
**Problem**: Upstream database changes, exact counts fail

**Solution**: Use `min=` instead of exact values
```xml
<!-- Bad: Exact count -->
<has_n_lines n="142"/>
<output_collection type="list" count="12">

<!-- Good: Minimum -->
<has_n_lines min="140"/>
<output_collection type="list" min="10">
```

### Variable Output
**Problem**: Output varies between runs

**Solution**: Test for required content, not exact match
```xml
<assert_contents>
    <has_text text="required header"/>
    <has_n_columns n="4"/>
</assert_contents>
```

### Floating Point
**Problem**: Floating point precision differences

**Solution**: Use delta
```xml
<has_size value="1000" delta="50"/>
```

### Compressed Output
**Problem**: Testing compressed files

**Solution**: Use `decompress="true"`
```xml
<element name="output" decompress="true">
    <assert_contents>
        <has_text text="expected"/>
    </assert_contents>
</element>
```

## Test Numbering
Tests are 0-indexed:
- Test 0 = First `<test>` in file
- Test 1 = Second `<test>` in file
- etc.

When `tool_test_output.json` reports `test-5`, that's the 6th test.
