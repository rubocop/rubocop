# Security

## Security/Eval

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for the use of `Kernel#eval` and `Binding#eval`.

### Example

```ruby
# bad

eval(something)
binding.eval(something)
```

## Security/JSONLoad

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for the use of JSON class methods which have potential
security issues.

Autocorrect is disabled by default because it's potentially dangerous.
If using a stream, like `JSON.load(open('file'))`, it will need to call
`#read` manually, like `JSON.parse(open('file').read)`.
If reading single values (rather than proper JSON objects), like
`JSON.load('false')`, it will need to pass the `quirks_mode: true`
option, like `JSON.parse('false', quirks_mode: true)`.
Other similar issues may apply.

### Example

```ruby
# always offense
JSON.load("{}")
JSON.restore("{}")

# no offense
JSON.parse("{}")
```

### Important attributes

Attribute | Value
--- | ---
AutoCorrect | false

### References

* [http://ruby-doc.org/stdlib-2.3.0/libdoc/json/rdoc/JSON.html#method-i-load](http://ruby-doc.org/stdlib-2.3.0/libdoc/json/rdoc/JSON.html#method-i-load)

## Security/MarshalLoad

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for the use of Marshal class methods which have
potential security issues leading to remote code execution when
loading from an untrusted source.

### Example

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

* [http://ruby-doc.org/core-2.3.3/Marshal.html#module-Marshal-label-Security+considerations](http://ruby-doc.org/core-2.3.3/Marshal.html#module-Marshal-label-Security+considerations)

## Security/YAMLLoad

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for the use of YAML class methods which have
potential security issues leading to remote code execution when
loading from an untrusted source.

### Example

```ruby
# bad
YAML.load("--- foo")

# good
YAML.safe_load("--- foo")
YAML.dump("foo")
```

### Important attributes

Attribute | Value
--- | ---
AutoCorrect | false

### References

* [https://ruby-doc.org/stdlib-2.3.3/libdoc/yaml/rdoc/YAML.html#module-YAML-label-Security](https://ruby-doc.org/stdlib-2.3.3/libdoc/yaml/rdoc/YAML.html#module-YAML-label-Security)
