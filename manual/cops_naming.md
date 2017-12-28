# Naming

## Naming/AccessorMethodName

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop makes sure that accessor methods are named properly.

### Examples

```ruby
# bad
def set_attribute(value)
end

# good
def attribute=(value)
end

# bad
def get_attribute
end

# good
def attribute
end
```

### References

* [https://github.com/bbatsov/ruby-style-guide#accessor_mutator_method_names](https://github.com/bbatsov/ruby-style-guide#accessor_mutator_method_names)

## Naming/AsciiIdentifiers

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for non-ascii characters in identifier names.

### Examples

```ruby
# bad
def καλημερα # Greek alphabet (non-ascii)
end

# bad
def こんにちはと言う # Japanese character (non-ascii)
end

# bad
def hello_🍣 # Emoji (non-ascii)
end

# good
def say_hello
end

# bad
신장 = 10 # Hangul character (non-ascii)

# good
height = 10

# bad
params[:عرض_gteq] # Arabic character (non-ascii)

# good
params[:width_gteq]
```

### References

* [https://github.com/bbatsov/ruby-style-guide#english-identifiers](https://github.com/bbatsov/ruby-style-guide#english-identifiers)

## Naming/BinaryOperatorParameterName

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop makes sure that certain binary operator methods have their
sole  parameter named `other`.

### Examples

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

### Examples

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

### Examples

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

### Examples

```ruby
# bad
lib/layoutManager.rb

anything/usingCamelCase

# good
lib/layout_manager.rb

anything/using_snake_case.rake
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Exclude | `[]` | Array
ExpectMatchingDefinition | `false` | Boolean
Regex | `<none>` | 
IgnoreExecutableScripts | `true` | Boolean
AllowedAcronyms | `CLI`, `DSL`, `ACL`, `API`, `ASCII`, `CPU`, `CSS`, `DNS`, `EOF`, `GUID`, `HTML`, `HTTP`, `HTTPS`, `ID`, `IP`, `JSON`, `LHS`, `QPS`, `RAM`, `RHS`, `RPC`, `SLA`, `SMTP`, `SQL`, `SSH`, `TCP`, `TLS`, `TTL`, `UDP`, `UI`, `UID`, `UUID`, `URI`, `URL`, `UTF8`, `VM`, `XML`, `XMPP`, `XSRF`, `XSS` | Array

### References

* [https://github.com/bbatsov/ruby-style-guide#snake-case-files](https://github.com/bbatsov/ruby-style-guide#snake-case-files)

## Naming/HeredocDelimiterCase

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks that your heredocs are using the configured case.
By default it is configured to enforce uppercase heredocs.

### Examples

#### EnforcedStyle: uppercase (default)

```ruby
# bad
<<-sql
  SELECT * FROM foo
sql

# good
<<-SQL
  SELECT * FROM foo
SQL
```
#### EnforcedStyle: lowercase

```ruby
# bad
<<-SQL
  SELECT * FROM foo
SQL

# good
<<-sql
  SELECT * FROM foo
sql
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
EnforcedStyle | `uppercase` | `lowercase`, `uppercase`

### References

* [https://github.com/bbatsov/ruby-style-guide#heredoc-delimiters](https://github.com/bbatsov/ruby-style-guide#heredoc-delimiters)

## Naming/HeredocDelimiterNaming

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks that your heredocs are using meaningful delimiters.
By default it disallows `END` and `EO*`, and can be configured through
blacklisting additional delimiters.

### Examples

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

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Blacklist | `END`, `(?-mix:EO[A-Z]{1})` | Array

### References

* [https://github.com/bbatsov/ruby-style-guide#heredoc-delimiters](https://github.com/bbatsov/ruby-style-guide#heredoc-delimiters)

## Naming/MethodName

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop makes sure that all methods use the configured style,
snake_case or camelCase, for their names.

### Examples

#### EnforcedStyle: snake_case (default)

```ruby
# bad
def fooBar; end

# good
def foo_bar; end
```
#### EnforcedStyle: camelCase

```ruby
# bad
def foo_bar; end

# good
def fooBar; end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
EnforcedStyle | `snake_case` | `snake_case`, `camelCase`

### References

* [https://github.com/bbatsov/ruby-style-guide#snake-case-symbols-methods-vars](https://github.com/bbatsov/ruby-style-guide#snake-case-symbols-methods-vars)

## Naming/PredicateName

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop makes sure that predicates are named properly.

### Examples

```ruby
# bad
def is_even?(value)
end

# good
def even?(value)
end

# bad
def has_value?
end

# good
def value?
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
NamePrefix | `is_`, `has_`, `have_` | Array
NamePrefixBlacklist | `is_`, `has_`, `have_` | Array
NameWhitelist | `is_a?` | Array
MethodDefinitionMacros | `define_method`, `define_singleton_method` | Array
Exclude | `spec/**/*` | Array

### References

* [https://github.com/bbatsov/ruby-style-guide#bool-methods-qmark](https://github.com/bbatsov/ruby-style-guide#bool-methods-qmark)

## Naming/UncommunicativeBlockParamName

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop makes sure block parameter names meet a configurable
level of description

### Examples

```ruby
# bad
foo { |num1, num2| num1 + num2 }

bar do |varOne, varTwo|
  varOne + varTwo
end

# With `MinParamNameLength` set to number greater than 1
baz { |x, y, z| do_stuff(x, y, z) }

# good
foo { |first_num, second_num| first_num + second_num }

bar do |var_one, var_two|
  var_one + var_two
end

baz { |age, height, gender| do_stuff(age, height, gender) }
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
MinParamNameLength | `1` | Integer
AllowedNames | `<none>` | 

## Naming/UncommunicativeMethodArgName

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop makes sure method argument names meet a configurable
level of description

### Examples

```ruby
# bad
def foo(num1, num2)
  num1 + num2
end

def bar(varOne, varTwo)
  varOne + varTwo
end

# With `MinArgNameLength` set to number greater than 1
def baz(x, y, z)
  do_stuff(x, y, z)
end

# good
def foo(first_num, second_num)
  first_num + second_num
end

def bar(var_one, var_two)
  var_one + var_two
end

def baz(age_x, height_y, gender_z)
  do_stuff(age_x, height_y, gender_z)
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
MinArgNameLength | `3` | Integer
AllowedNames | `<none>` | 

## Naming/VariableName

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop makes sure that all variables use the configured style,
snake_case or camelCase, for their names.

### Examples

#### EnforcedStyle: snake_case (default)

```ruby
# bad
fooBar = 1

# good
foo_bar = 1
```
#### EnforcedStyle: camelCase

```ruby
# bad
foo_bar = 1

# good
fooBar = 1
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
EnforcedStyle | `snake_case` | `snake_case`, `camelCase`

### References

* [https://github.com/bbatsov/ruby-style-guide#snake-case-symbols-methods-vars](https://github.com/bbatsov/ruby-style-guide#snake-case-symbols-methods-vars)

## Naming/VariableNumber

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop makes sure that all numbered variables use the
configured style, snake_case, normalcase or non_integer,
for their numbering.

### Examples

#### EnforcedStyle: snake_case

```ruby
# bad

variable1 = 1

# good

variable_1 = 1
```
#### EnforcedStyle: normalcase (default)

```ruby
# bad

variable_1 = 1

# good

variable1 = 1
```
#### EnforcedStyle: non_integer

```ruby
# bad

variable1 = 1

variable_1 = 1

# good

variableone = 1

variable_one = 1
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
EnforcedStyle | `normalcase` | `snake_case`, `normalcase`, `non_integer`
