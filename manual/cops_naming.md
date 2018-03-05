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

## Naming/MemoizedInstanceVariableName

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for memoized methods whose instance variable name
does not match the method name.

### Examples

```ruby
# bad
# Method foo is memoized using an instance variable that is
# not `@foo`. This can cause confusion and bugs.
def foo
  @something ||= calculate_expensive_thing
end

# good
def foo
  @foo ||= calculate_expensive_thing
end

# good
def foo
  @foo ||= begin
    calculate_expensive_thing
  end
end

# good
def foo
  helper_variable = something_we_need_to_calculate_foo
  @foo ||= calculate_expensive_thing(helper_variable)
end
```

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

This cop checks block parameter names for how descriptive they
are. It is highly configurable.

The `MinNameLength` config option takes an integer. It represents
the minimum amount of characters the name must be. Its default is 1.
The `AllowNamesEndingInNumbers` config option takes a boolean. When
set to false, this cop will register offenses for names ending with
numbers. Its default is false. The `AllowedNames` config option
takes an array of whitelisted names that will never register an
offense. The `ForbiddenNames` config option takes an array of
blacklisted names that will always register an offense.

### Examples

```ruby
# bad
bar do |varOne, varTwo|
  varOne + varTwo
end

# With `AllowNamesEndingInNumbers` set to false
foo { |num1, num2| num1 * num2 }

# With `MinParamNameLength` set to number greater than 1
baz { |a, b, c| do_stuff(a, b, c) }

# good
bar do |thud, fred|
  thud + fred
end

foo { |speed, distance| speed * distance }

baz { |age, height, gender| do_stuff(age, height, gender) }
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
MinNameLength | `1` | Integer
AllowNamesEndingInNumbers | `true` | Boolean
AllowedNames | `[]` | Array
ForbiddenNames | `[]` | Array

## Naming/UncommunicativeMethodParamName

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks method parameter names for how descriptive they
are. It is highly configurable.

The `MinNameLength` config option takes an integer. It represents
the minimum amount of characters the name must be. Its default is 3.
The `AllowNamesEndingInNumbers` config option takes a boolean. When
set to false, this cop will register offenses for names ending with
numbers. Its default is false. The `AllowedNames` config option
takes an array of whitelisted names that will never register an
offense. The `ForbiddenNames` config option takes an array of
blacklisted names that will always register an offense.

### Examples

```ruby
# bad
def bar(varOne, varTwo)
  varOne + varTwo
end

# With `AllowNamesEndingInNumbers` set to false
def foo(num1, num2)
  num1 * num2
end

# With `MinArgNameLength` set to number greater than 1
def baz(a, b, c)
  do_stuff(a, b, c)
end

# good
def bar(thud, fred)
  thud + fred
end

def foo(speed, distance)
  speed * distance
end

def baz(age_a, height_b, gender_c)
  do_stuff(age_a, height_b, gender_c)
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
MinNameLength | `3` | Integer
AllowNamesEndingInNumbers | `true` | Boolean
AllowedNames | `io`, `id`, `to` | Array
ForbiddenNames | `[]` | Array

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
