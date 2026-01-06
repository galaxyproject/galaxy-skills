# Common Galaxy Tool Bugs

## Command Section Bugs

### Repeat Element Access
**Bug**: Accessing repeat param incorrectly in loop

```cheetah
# WRONG - accesses outer scope, not loop variable
#for item in $filters.search:
    --search '$filters.search_term'
#end for

# CORRECT - access param through loop variable
#for item in $filters.search:
    --search '$item.search'
#end for
```

**Symptom**: Galaxy expands to garbage like `SafeStringWrapper__str__...`

### Missing Conditional Check
**Bug**: Using param without checking if set

```cheetah
# WRONG - fails if param is empty
--flag '$optional_param'

# CORRECT - check first
#if $optional_param:
    --flag '$optional_param'
#end if

# Or for strings that might be empty
#if str($optional_param):
    --flag '$optional_param'
#end if
```

### Wrong String Comparison
**Bug**: Comparing to wrong type

```cheetah
# WRONG - comparing to boolean
#if $param == True:

# CORRECT - compare to string 'true'
#if str($param) == 'true':
```

## Output Section Bugs

### Wrong Filter Value
**Bug**: Filter checks wrong value

```xml
<!-- BUG: 3' UTR output filtering on 5p-utr -->
<data name="threep_utr" format="fasta">
    <filter>"5p-utr" in file_choices['include']</filter>  <!-- WRONG -->
</data>

<!-- CORRECT -->
<data name="threep_utr" format="fasta">
    <filter>"3p-utr" in file_choices['include']</filter>
</data>
```

### Filter Syntax Error
**Bug**: Incorrect filter expression

```xml
<!-- WRONG - missing quotes -->
<filter>param == value</filter>

<!-- CORRECT -->
<filter>param == 'value'</filter>

<!-- WRONG - wrong nesting -->
<filter>section.param == 'value'</filter>

<!-- CORRECT -->
<filter>section['param'] == 'value'</filter>
```

## Input Section Bugs

### Sanitizer Too Restrictive
**Bug**: Valid characters rejected

```xml
<!-- May reject valid input -->
<param name="id" type="text">
    <sanitizer invalid_char="">
        <valid initial="string.letters"/>
    </sanitizer>
</param>

<!-- Better - include digits and common chars -->
<param name="id" type="text">
    <sanitizer invalid_char="">
        <valid initial="string.letters,string.digits">
            <add value="_"/>
            <add value="-"/>
        </valid>
    </sanitizer>
</param>
```

### Missing Validator
**Bug**: Empty required field not caught

```xml
<!-- Add validator for required text -->
<param name="required_text" type="text">
    <validator type="length" min="1" message="Required field"/>
</param>
```

## Test Section Bugs

### Exact Counts
**Bug**: Using exact counts for variable data

```xml
<!-- WRONG - fails when upstream data changes -->
<has_n_lines n="142"/>
<output_collection count="12">

<!-- CORRECT - flexible -->
<has_n_lines min="140"/>
<output_collection min="10">
```

### Wrong Test Path
**Bug**: Incorrect nesting for conditional params

```xml
<!-- WRONG -->
<param name="subcommand|param" value="x"/>

<!-- CORRECT -->
<conditional name="query|subcommand">
    <param name="mode" value="x"/>
</conditional>
```

## Macro Bugs

### Typos
Common typos found in macros:
- "amnio acid" → "amino acid"
- "nucelotide" → "nucleotide"
- "protien" → "protein"
- "sequnce" → "sequence"

### Token Not Expanded
**Bug**: Token syntax wrong

```xml
<!-- WRONG -->
<token name="VERSION">1.0</token>
version="VERSION"

<!-- CORRECT -->
<token name="@VERSION@">1.0</token>
version="@VERSION@"
```

## Help Section Bugs

### RST Table Alignment
**Bug**: Table columns don't render

```rst
# WRONG - columns don't align
====  =====
Col1  Col2
====  =====
val   val
====  =====

# CORRECT - equal signs must span content
======  ======
Col1    Col2
======  ======
value   value
======  ======
```

### Unescaped Underscore
**Bug**: Link broken by underscore

```rst
# WRONG - underscore breaks RST
https://example.com/path_with_underscore

# CORRECT
https://example.com/path\_with\_underscore
```

## Debugging Tips

1. **Check Galaxy logs** for Cheetah template errors
2. **Use `<assert_command>`** to verify command construction
3. **Test incrementally** - one change at a time
4. **Compare with working tools** in same repo
5. **Read the job stderr** in test output JSON
