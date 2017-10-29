# Naming

## Naming/AccessorMethodName

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop makes sure that accessor methods are named properly.

### Example

```ruby
# bad
def set_attribute(value) ...

# good
def attribute=(value)

# bad
def get_attribute ...

# good
def attribute ...
```

### References

* [https://github.com/bbatsov/ruby-style-guide#accessor_mutator_method_names](https://github.com/bbatsov/ruby-style-guide#accessor_mutator_method_names)

## Naming/AsciiIdentifiers

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for non-ascii characters in identifier names.

### References

* [https://github.com/bbatsov/ruby-style-guide#english-identifiers](https://github.com/bbatsov/ruby-style-guide#english-identifiers)

## Naming/BinaryOperatorParameterName

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop makes sure that certain binary operator methods have their
sole  parameter named `other`.

### Example

```ruby
# bad
def +(amount); end

# good
def +(other); end
```

### References

* [https://github.com/bbatsov/ruby-style-guide#other-arg](https://github.com/bbatsov/ruby-style-guide#other-arg)

## Naming/ClassAndModuleCamelCase

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cops checks for class and module names with
an underscore in them.

### Example

```ruby
# bad
class My_Class
end
module My_Module
end

# good
class MyClass
end
module MyModule
end
```

### References

* [https://github.com/bbatsov/ruby-style-guide#camelcase-classes](https://github.com/bbatsov/ruby-style-guide#camelcase-classes)

## Naming/ConstantName

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks whether constant names are written using
SCREAMING_SNAKE_CASE.

To avoid false positives, it ignores cases in which we cannot know
for certain the type of value that would be assigned to a constant.

### Example

```ruby
# bad
InchInCm = 2.54
INCHinCM = 2.54
Inch_In_Cm = 2.54

# good
INCH_IN_CM = 2.54
```

### References

* [https://github.com/bbatsov/ruby-style-guide#screaming-snake-case](https://github.com/bbatsov/ruby-style-guide#screaming-snake-case)

## Naming/FileName

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop makes sure that Ruby source files have snake_case
names. Ruby scripts (i.e. source files with a shebang in the
first line) are ignored.

### Important attributes

Attribute | Value
--- | ---
Exclude |
ExpectMatchingDefinition | false
Regex |
IgnoreExecutableScripts | true
AllowedAcronyms | CLI, DSL, ACL, API, ASCII, CPU, CSS, DNS, EOF, GUID, HTML, HTTP, HTTPS, ID, IP, JSON, LHS, QPS, RAM, RHS, RPC, SLA, SMTP, SQL, SSH, TCP, TLS, TTL, UDP, UI, UID, UUID, URI, URL, UTF8, VM, XML, XMPP, XSRF, XSS

### References

* [https://github.com/bbatsov/ruby-style-guide#snake-case-files](https://github.com/bbatsov/ruby-style-guide#snake-case-files)

## Naming/HeredocDelimiterCase

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks that your heredocs are using the configured case.
By default it is configured to enforce uppercase heredocs.

### Example

```ruby
# EnforcedStyle: uppercase (default)

# good
<<-SQL
  SELECT * FROM foo
SQL

# bad
<<-sql
  SELECT * FROM foo
sql
```
```ruby
# EnforcedStyle: lowercase

# good
<<-sql
  SELECT * FROM foo
sql

# bad
<<-SQL
  SELECT * FROM foo
SQL
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | uppercase
SupportedStyles | lowercase, uppercase

### References

* [https://github.com/bbatsov/ruby-style-guide#heredoc-delimiters](https://github.com/bbatsov/ruby-style-guide#heredoc-delimiters)

## Naming/HeredocDelimiterNaming

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks that your heredocs are using meaningful delimiters.
By default it disallows `END` and `EO*`, and can be configured through
blacklisting additional delimiters.

### Example

```ruby
# good
<<-SQL
  SELECT * FROM foo
SQL

# bad
<<-END
  SELECT * FROM foo
END

# bad
<<-EOS
  SELECT * FROM foo
EOS
```

### Important attributes

Attribute | Value
--- | ---
Blacklist | END, (?-mix:EO[A-Z]{1})

### References

* [https://github.com/bbatsov/ruby-style-guide#heredoc-delimiters](https://github.com/bbatsov/ruby-style-guide#heredoc-delimiters)

## Naming/MethodName

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop makes sure that all methods use the configured style,
snake_case or camelCase, for their names.

### Example

```ruby
# EnforcedStyle: snake_case

# bad
def fooBar; end

# good
def foo_bar; end
```
```ruby
# EnforcedStyle: camelCase

# bad
def foo_bar; end

# good
def fooBar; end
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | snake_case
SupportedStyles | snake_case, camelCase

### References

* [https://github.com/bbatsov/ruby-style-guide#snake-case-symbols-methods-vars](https://github.com/bbatsov/ruby-style-guide#snake-case-symbols-methods-vars)

## Naming/PredicateName

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop makes sure that predicates are named properly.

### Example

```ruby
# bad
def is_even?(value) ...

# good
def even?(value)

# bad
def has_value? ...

# good
def value? ...
```

### Important attributes

Attribute | Value
--- | ---
NamePrefix | is_, has_, have_
NamePrefixBlacklist | is_, has_, have_
NameWhitelist | is_a?
MethodDefinitionMacros | define_method, define_singleton_method
Exclude | spec/\*\*/\*

### References

* [https://github.com/bbatsov/ruby-style-guide#bool-methods-qmark](https://github.com/bbatsov/ruby-style-guide#bool-methods-qmark)

## Naming/VariableName

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop makes sure that all variables use the configured style,
snake_case or camelCase, for their names.

### Example

```ruby
# EnforcedStyle: snake_case

# bad
fooBar = 1

# good
foo_bar = 1
```
```ruby
# EnforcedStyle: camelCase

# bad
foo_bar = 1

# good
fooBar = 1
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | snake_case
SupportedStyles | snake_case, camelCase

### References

* [https://github.com/bbatsov/ruby-style-guide#snake-case-symbols-methods-vars](https://github.com/bbatsov/ruby-style-guide#snake-case-symbols-methods-vars)

## Naming/VariableNumber

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop makes sure that all numbered variables use the
configured style, snake_case, normalcase or non_integer,
for their numbering.

### Example

```ruby
# EnforcedStyle: snake_case

# bad

variable1 = 1

# good

variable_1 = 1
```
```ruby
# EnforcedStyle: normalcase

# bad

variable_1 = 1

# good

variable1 = 1
```
```ruby
# EnforcedStyle: non_integer

# bad

variable1 = 1

variable_1 = 1

# good

variableone = 1

variable_one = 1
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | normalcase
SupportedStyles | snake_case, normalcase, non_integer
