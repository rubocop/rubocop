# Security

## Security/Eval

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | 0.47 | -

This cop checks for the use of `Kernel#eval` and `Binding#eval`.

### Examples

```ruby
# bad

eval(something)
binding.eval(something)
```

## Security/JSONLoad

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes (Unsafe) | 0.43 | 0.44

This cop checks for the use of JSON class methods which have potential
security issues.

Autocorrect is disabled by default because it's potentially dangerous.
If using a stream, like `JSON.load(open('file'))`, it will need to call
`#read` manually, like `JSON.parse(open('file').read)`.
If reading single values (rather than proper JSON objects), like
`JSON.load('false')`, it will need to pass the `quirks_mode: true`
option, like `JSON.parse('false', quirks_mode: true)`.
Other similar issues may apply.

### Examples

```ruby
# bad
JSON.load("{}")
JSON.restore("{}")

# good
JSON.parse("{}")
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
AutoCorrect | `false` | Boolean

### References

* [https://ruby-doc.org/stdlib-2.3.0/libdoc/json/rdoc/JSON.html#method-i-load](https://ruby-doc.org/stdlib-2.3.0/libdoc/json/rdoc/JSON.html#method-i-load)

## Security/MarshalLoad

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | 0.47 | -

This cop checks for the use of Marshal class methods which have
potential security issues leading to remote code execution when
loading from an untrusted source.

### Examples

```ruby
# bad
Marshal.load("{}")
Marshal.restore("{}")

# good
Marshal.dump("{}")

# okish - deep copy hack
Marshal.load(Marshal.dump({}))
```

### References

* [https://ruby-doc.org/core-2.3.3/Marshal.html#module-Marshal-label-Security+considerations](https://ruby-doc.org/core-2.3.3/Marshal.html#module-Marshal-label-Security+considerations)

## Security/Open

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | No | No | 0.53 | -

This cop checks for the use of `Kernel#open`.

`Kernel#open` enables not only file access but also process invocation
by prefixing a pipe symbol (e.g., `open("| ls")`). So, it may lead to
a serious security risk by using variable input to the argument of
`Kernel#open`. It would be better to use `File.open`, `IO.popen` or
`URI#open` explicitly.

### Examples

```ruby
# bad
open(something)

# good
File.open(something)
IO.popen(something)
URI.parse(something).open
```

## Security/YAMLLoad

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | Yes (Unsafe) | 0.47 | -

This cop checks for the use of YAML class methods which have
potential security issues leading to remote code execution when
loading from an untrusted source.

### Examples

```ruby
# bad
YAML.load("--- foo")

# good
YAML.safe_load("--- foo")
YAML.dump("foo")
```

### References

* [https://ruby-doc.org/stdlib-2.3.3/libdoc/yaml/rdoc/YAML.html#module-YAML-label-Security](https://ruby-doc.org/stdlib-2.3.3/libdoc/yaml/rdoc/YAML.html#module-YAML-label-Security)
