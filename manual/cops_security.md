# Security

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
Reference | http://ruby-doc.org/stdlib-2.3.0/libdoc/json/rdoc/JSON.html#method-i-load
AutoCorrect | false


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
```

### Important attributes

Attribute | Value
--- | ---
Reference | http://ruby-doc.org/core-2.3.3/Marshal.html#module-Marshal-label-Security+considerations

