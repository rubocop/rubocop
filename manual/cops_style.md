# Style

## Style/Alias

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop enforces the use of either `#alias` or `#alias_method`
depending on configuration.
It also flags uses of `alias :symbol` rather than `alias bareword`.

### Example

```ruby
# EnforcedStyle: prefer_alias

# good
alias bar foo

# bad
alias_method :bar, :foo
alias :bar :foo
```
```ruby
# EnforcedStyle: prefer_alias_method

# good
alias_method :bar, :foo

# bad
alias bar foo
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | prefer_alias
SupportedStyles | prefer_alias, prefer_alias_method

### References

* [https://github.com/bbatsov/ruby-style-guide#alias-method](https://github.com/bbatsov/ruby-style-guide#alias-method)

## Style/AndOr

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for uses of `and` and `or`, and suggests using `&&` and
`|| instead`. It can be configured to check only in conditions, or in
all contexts.

### Example

```ruby
# EnforcedStyle: always (default)

# good
foo.save && return
if foo && bar

# bad
foo.save and return
if foo and bar
```
```ruby
# EnforcedStyle: conditionals

# good
foo.save && return
foo.save and return
if foo && bar

# bad
if foo and bar
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | always
SupportedStyles | always, conditionals

### References

* [https://github.com/bbatsov/ruby-style-guide#no-and-or-or](https://github.com/bbatsov/ruby-style-guide#no-and-or-or)

## Style/ArrayJoin

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for uses of "*" as a substitute for *join*.

Not all cases can reliably checked, due to Ruby's dynamic
types, so we consider only cases when the first argument is an
array literal or the second is a string literal.

### References

* [https://github.com/bbatsov/ruby-style-guide#array-join](https://github.com/bbatsov/ruby-style-guide#array-join)

## Style/AsciiComments

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for non-ascii (non-English) characters
in comments.

### References

* [https://github.com/bbatsov/ruby-style-guide#english-comments](https://github.com/bbatsov/ruby-style-guide#english-comments)

## Style/Attr

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for uses of Module#attr.

### References

* [https://github.com/bbatsov/ruby-style-guide#attr](https://github.com/bbatsov/ruby-style-guide#attr)

## Style/AutoResourceCleanup

Enabled by default | Supports autocorrection
--- | ---
Disabled | No

This cop checks for cases when you could use a block
accepting version of a method that does automatic
resource cleanup.

### Example

```ruby
# bad
f = File.open('file')

# good
File.open('file') do |f|
  ...
end
```

## Style/BarePercentLiterals

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks if usage of %() or %Q() matches configuration.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | bare_percent
SupportedStyles | percent_q, bare_percent

### References

* [https://github.com/bbatsov/ruby-style-guide#percent-q-shorthand](https://github.com/bbatsov/ruby-style-guide#percent-q-shorthand)

## Style/BeginBlock

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for BEGIN blocks.

### References

* [https://github.com/bbatsov/ruby-style-guide#no-BEGIN-blocks](https://github.com/bbatsov/ruby-style-guide#no-BEGIN-blocks)

## Style/BlockComments

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop looks for uses of block comments (=begin...=end).

### References

* [https://github.com/bbatsov/ruby-style-guide#no-block-comments](https://github.com/bbatsov/ruby-style-guide#no-block-comments)

## Style/BlockDelimiters

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Check for uses of braces or do/end around single line or
multi-line blocks.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | line_count_based
SupportedStyles | line_count_based, semantic, braces_for_chaining
ProceduralMethods | benchmark, bm, bmbm, create, each_with_object, measure, new, realtime, tap, with_object
FunctionalMethods | let, let!, subject, watch
IgnoredMethods | lambda, proc, it

### References

* [https://github.com/bbatsov/ruby-style-guide#single-line-blocks](https://github.com/bbatsov/ruby-style-guide#single-line-blocks)

## Style/BracesAroundHashParameters

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for braces around the last parameter in a method call
if the last parameter is a hash.
It supports `braces`, `no_braces` and `context_dependent` styles.

### Example

```ruby
# The `braces` style enforces braces around all method
# parameters that are hashes.

# bad
some_method(x, y, a: 1, b: 2)

# good
some_method(x, y, {a: 1, b: 2})
```
```ruby
# The `no_braces` style checks that the last parameter doesn't
# have braces around it.

# bad
some_method(x, y, {a: 1, b: 2})

# good
some_method(x, y, a: 1, b: 2)
```
```ruby
# The `context_dependent` style checks that the last parameter
# doesn't have braces around it, but requires braces if the
# second to last parameter is also a hash literal.

# bad
some_method(x, y, {a: 1, b: 2})
some_method(x, y, {a: 1, b: 2}, a: 1, b: 2)

# good
some_method(x, y, a: 1, b: 2)
some_method(x, y, {a: 1, b: 2}, {a: 1, b: 2})
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | no_braces
SupportedStyles | braces, no_braces, context_dependent

## Style/CaseEquality

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for uses of the case equality operator(===).

### References

* [https://github.com/bbatsov/ruby-style-guide#no-case-equality](https://github.com/bbatsov/ruby-style-guide#no-case-equality)

## Style/CharacterLiteral

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for uses of the character literal ?x.

### References

* [https://github.com/bbatsov/ruby-style-guide#no-character-literals](https://github.com/bbatsov/ruby-style-guide#no-character-literals)

## Style/ClassAndModuleChildren

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks the style of children definitions at classes and
modules. Basically there are two different styles:

nested - have each child on its own line
  class Foo
    class Bar
    end
  end

compact - combine definitions as much as possible
  class Foo::Bar
  end

The compact style is only forced for classes/modules with one child.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | nested
SupportedStyles | nested, compact

### References

* [https://github.com/bbatsov/ruby-style-guide#namespace-definition](https://github.com/bbatsov/ruby-style-guide#namespace-definition)

## Style/ClassCheck

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop enforces consistent use of `Object#is_a?` or `Object#kind_of?`.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | is_a?
SupportedStyles | is_a?, kind_of?

## Style/ClassMethods

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for uses of the class/module name instead of
self, when defining class/module methods.

### Example

```ruby
# bad
class SomeClass
  def SomeClass.class_method
    ...
  end
end

# good
class SomeClass
  def self.class_method
    ...
  end
end
```

### References

* [https://github.com/bbatsov/ruby-style-guide#def-self-class-methods](https://github.com/bbatsov/ruby-style-guide#def-self-class-methods)

## Style/ClassVars

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for uses of class variables. Offenses
are signaled only on assignment to class variables to
reduced the number of offenses that would be reported.

### References

* [https://github.com/bbatsov/ruby-style-guide#no-class-vars](https://github.com/bbatsov/ruby-style-guide#no-class-vars)

## Style/CollectionMethods

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

This cop enforces the use of consistent method names
from the Enumerable module.

Unfortunately we cannot actually know if a method is from
Enumerable or not (static analysis limitation), so this cop
can yield some false positives.

### Important attributes

Attribute | Value
--- | ---
PreferredMethods | {"collect"=>"map", "collect!"=>"map!", "inject"=>"reduce", "detect"=>"find", "find_all"=>"select"}

### References

* [https://github.com/bbatsov/ruby-style-guide#map-find-select-reduce-size](https://github.com/bbatsov/ruby-style-guide#map-find-select-reduce-size)

## Style/ColonMethodCall

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for methods invoked via the :: operator instead
of the . operator (like FileUtils::rmdir instead of FileUtils.rmdir).

### References

* [https://github.com/bbatsov/ruby-style-guide#double-colons](https://github.com/bbatsov/ruby-style-guide#double-colons)

## Style/CommandLiteral

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop enforces using `` or %x around command literals.

### Example

```ruby
# Good if EnforcedStyle is backticks or mixed, bad if percent_x.
folders = `find . -type d`.split

# Good if EnforcedStyle is percent_x, bad if backticks or mixed.
folders = %x(find . -type d).split

# Good if EnforcedStyle is backticks, bad if percent_x or mixed.
`
  ln -s foo.example.yml foo.example
  ln -s bar.example.yml bar.example
`

# Good if EnforcedStyle is percent_x or mixed, bad if backticks.
%x(
  ln -s foo.example.yml foo.example
  ln -s bar.example.yml bar.example
)

# Bad unless AllowInnerBackticks is true.
`echo \`ls\``
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | backticks
SupportedStyles | backticks, percent_x, mixed
AllowInnerBackticks | false

### References

* [https://github.com/bbatsov/ruby-style-guide#percent-x](https://github.com/bbatsov/ruby-style-guide#percent-x)

## Style/CommentAnnotation

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks that comment annotation keywords are written according
to guidelines.

### Important attributes

Attribute | Value
--- | ---
Keywords | TODO, FIXME, OPTIMIZE, HACK, REVIEW

### References

* [https://github.com/bbatsov/ruby-style-guide#annotate-keywords](https://github.com/bbatsov/ruby-style-guide#annotate-keywords)

## Style/CommentedKeyword

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for comments put on the same line as some keywords.
These keywords are: `begin`, `class`, `def`, `end`, `module`.

Note that some comments (such as `:nodoc:` and `rubocop:disable`) are
allowed.

### Example

```ruby
# bad
if condition
  statement
end # end if

# bad
class X # comment
  statement
end

# bad
def x; end # comment

# good
if condition
  statement
end

# good
class x # :nodoc:
  y
end
```

## Style/ConditionalAssignment

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Check for `if` and `case` statements where each branch is used for
assignment to the same variable when using the return of the
condition can be used instead.

### Example

```ruby
EnforcedStyle: assign_to_condition

# bad
if foo
  bar = 1
else
  bar = 2
end

case foo
when 'a'
  bar += 1
else
  bar += 2
end

if foo
  some_method
  bar = 1
else
  some_other_method
  bar = 2
end

# good
bar = if foo
        1
      else
        2
      end

bar += case foo
       when 'a'
         1
       else
         2
       end

bar << if foo
         some_method
         1
       else
         some_other_method
         2
       end

EnforcedStyle: assign_inside_condition
# bad
bar = if foo
        1
      else
        2
      end

bar += case foo
       when 'a'
         1
       else
         2
       end

bar << if foo
         some_method
         1
       else
         some_other_method
         2
       end

# good
if foo
  bar = 1
else
  bar = 2
end

case foo
when 'a'
  bar += 1
else
  bar += 2
end

if foo
  some_method
  bar = 1
else
  some_other_method
  bar = 2
end
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | assign_to_condition
SupportedStyles | assign_to_condition, assign_inside_condition
SingleLineConditionsOnly | true
IncludeTernaryExpressions | true

## Style/Copyright

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

Check that a copyright notice was given in each source file.

The default regexp for an acceptable copyright notice can be found in
config/default.yml.  The default can be changed as follows:

    Style/Copyright:
      Notice: '^Copyright (\(c\) )?2\d{3} Acme Inc'

This regex string is treated as an unanchored regex.  For each file
that RuboCop scans, a comment that matches this regex must be found or
an offense is reported.

### Important attributes

Attribute | Value
--- | ---
Notice | ^Copyright (\(c\) )?2[0-9]{3} .+
AutocorrectNotice |

## Style/DateTime

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for uses of `DateTime` that should be replaced by
`Date` or `Time`.

### Example

```ruby
# bad - uses `DateTime` for current time
DateTime.now

# good - uses `Time` for current time
Time.now

# bad - uses `DateTime` for modern date
DateTime.iso8601('2016-06-29')

# good - uses `Date` for modern date
Date.iso8601('2016-06-29')

# good - uses `DateTime` with start argument for historical date
DateTime.iso8601('1751-04-23', Date::ENGLAND)
```

### References

* [https://github.com/bbatsov/ruby-style-guide#date--time](https://github.com/bbatsov/ruby-style-guide#date--time)

## Style/DefWithParentheses

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for parentheses in the definition of a method,
that does not take any arguments. Both instance and
class/singleton methods are checked.

### References

* [https://github.com/bbatsov/ruby-style-guide#method-parens](https://github.com/bbatsov/ruby-style-guide#method-parens)

## Style/Dir

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for places where the `#__dir__` method can replace more
complex constructs to retrieve a canonicalized absolute path to the
current file.

### Example

```ruby
# bad
path = File.expand_path(File.dirname(__FILE__))

# bad
path = File.dirname(File.realpath(__FILE__))

# good
path = __dir__
```

## Style/Documentation

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for missing top-level documentation of
classes and modules. Classes with no body are exempt from the
check and so are namespace modules - modules that have nothing in
their bodies except classes, other modules, or constant definitions.

The documentation requirement is annulled if the class or module has
a "#:nodoc:" comment next to it. Likewise, "#:nodoc: all" does the
same for all its children.

### Important attributes

Attribute | Value
--- | ---
Exclude | spec/\*\*/\*, test/\*\*/\*

## Style/DocumentationMethod

Enabled by default | Supports autocorrection
--- | ---
Disabled | No

This cop checks for missing documentation comment for public methods.
It can optionally be configured to also require documentation for
non-public methods.

### Example

```ruby
# bad

class Foo
  def bar
    puts baz
  end
end

module Foo
  def bar
    puts baz
  end
end

def foo.bar
  puts baz
end

# good

class Foo
  # Documentation
  def bar
    puts baz
  end
end

module Foo
  # Documentation
  def bar
    puts baz
  end
end

# Documentation
def foo.bar
  puts baz
end
```

### Important attributes

Attribute | Value
--- | ---
Exclude | spec/\*\*/\*, test/\*\*/\*
RequireForNonPublicMethods | false

## Style/DoubleNegation

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for uses of double negation (!!) to convert something
to a boolean value. As this is both cryptic and usually redundant, it
should be avoided.

Please, note that when something is a boolean value
!!something and !something.nil? are not the same thing.
As you're unlikely to write code that can accept values of any type
this is rarely a problem in practice.

### Example

```ruby
# bad
!!something

# good
!something.nil?
```

### References

* [https://github.com/bbatsov/ruby-style-guide#no-bang-bang](https://github.com/bbatsov/ruby-style-guide#no-bang-bang)

## Style/EachForSimpleLoop

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for loops which iterate a constant number of times,
using a Range literal and `#each`. This can be done more readably using
`Integer#times`.

This check only applies if the block takes no parameters.

### Example

```ruby
# bad
(1..5).each { }

# good
5.times { }
```
```ruby
# bad
(0...10).each {}

# good
10.times {}
```

## Style/EachWithObject

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop looks for inject / reduce calls where the passed in object is
returned at the end and so could be replaced by each_with_object without
the need to return the object at the end.

However, we can't replace with each_with_object if the accumulator
parameter is assigned to within the block.

### Example

```ruby
# bad
[1, 2].inject({}) { |a, e| a[e] = e; a }

# good
[1, 2].each_with_object({}) { |e, a| a[e] = e }
```

## Style/EmptyCaseCondition

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for case statements with an empty condition.

### Example

```ruby
# bad:
case
when x == 0
  puts 'x is 0'
when y == 0
  puts 'y is 0'
else
  puts 'neither is 0'
end

# good:
if x == 0
  puts 'x is 0'
elsif y == 0
  puts 'y is 0'
else
  puts 'neither is 0'
end

# good: (the case condition node is not empty)
case n
when 0
  puts 'zero'
when 1
  puts 'one'
else
  puts 'more'
end
```

## Style/EmptyElse

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for empty else-clauses, possibly including comments and/or an
explicit `nil` depending on the EnforcedStyle.

SupportedStyles:

### Example

```ruby
# good for all styles

if condition
  statement
else
  statement
end

# good for all styles
if condition
  statement
end
```
```ruby
# empty - warn only on empty else

# bad
if condition
  statement
else
end

# good
if condition
  statement
else
  nil
end
```
```ruby
# nil - warn on else with nil in it

# bad
if condition
  statement
else
  nil
end

# good
if condition
  statement
else
end
```
```ruby
# both - warn on empty else and else with nil in it

# bad
if condition
  statement
else
  nil
end

# bad
if condition
  statement
else
end
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | both
SupportedStyles | empty, nil, both

## Style/EmptyLiteral

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for the use of a method, the result of which
would be a literal, like an empty array, hash or string.

### References

* [https://github.com/bbatsov/ruby-style-guide#literal-array-hash](https://github.com/bbatsov/ruby-style-guide#literal-array-hash)

## Style/EmptyMethod

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for the formatting of empty method definitions.
By default it enforces empty method definitions to go on a single
line (compact style), but it can be configured to enforce the `end`
to go on its own line (expanded style).

Note: A method definition is not considered empty if it contains
      comments.

### Example

```ruby
# EnforcedStyle: compact (default)

# bad
def foo(bar)
end

def self.foo(bar)
end

# good
def foo(bar); end

def foo(bar)
  # baz
end

def self.foo(bar); end
```
```ruby
# EnforcedStyle: expanded

# bad
def foo(bar); end

def self.foo(bar); end

# good
def foo(bar)
end

def self.foo(bar)
end
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | compact
SupportedStyles | compact, expanded

### References

* [https://github.com/bbatsov/ruby-style-guide#no-single-line-methods](https://github.com/bbatsov/ruby-style-guide#no-single-line-methods)

## Style/Encoding

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks ensures source files have no utf-8 encoding comments.

### References

* [https://github.com/bbatsov/ruby-style-guide#utf-8](https://github.com/bbatsov/ruby-style-guide#utf-8)

## Style/EndBlock

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for END blocks.

### References

* [https://github.com/bbatsov/ruby-style-guide#no-END-blocks](https://github.com/bbatsov/ruby-style-guide#no-END-blocks)

## Style/EvenOdd

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for places where Integer#even? or Integer#odd?
should have been used.

### Example

```ruby
# bad
if x % 2 == 0

# good
if x.even?
```

### References

* [https://github.com/bbatsov/ruby-style-guide#predicate-methods](https://github.com/bbatsov/ruby-style-guide#predicate-methods)

## Style/FlipFlop

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop looks for uses of flip flop operator

### References

* [https://github.com/bbatsov/ruby-style-guide#no-flip-flops](https://github.com/bbatsov/ruby-style-guide#no-flip-flops)

## Style/For

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop looks for uses of the *for* keyword, or *each* method. The
preferred alternative is set in the EnforcedStyle configuration
parameter. An *each* call with a block on a single line is always
allowed, however.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | each
SupportedStyles | for, each

### References

* [https://github.com/bbatsov/ruby-style-guide#no-for-loops](https://github.com/bbatsov/ruby-style-guide#no-for-loops)

## Style/FormatString

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop enforces the use of a single string formatting utility.
Valid options include Kernel#format, Kernel#sprintf and String#%.

The detection of String#% cannot be implemented in a reliable
manner for all cases, so only two scenarios are considered -
if the first argument is a string literal and if the second
argument is an array literal.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | format
SupportedStyles | format, sprintf, percent

### References

* [https://github.com/bbatsov/ruby-style-guide#sprintf](https://github.com/bbatsov/ruby-style-guide#sprintf)

## Style/FormatStringToken

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

Use a consistent style for named format string tokens.

### Example

```ruby
EnforcedStyle: annotated

# bad

format('%{greeting}', greeting: 'Hello')
format('%s', 'Hello')

# good

format('%<greeting>s', greeting: 'Hello')
```
```ruby
EnforcedStyle: template

# bad

format('%<greeting>s', greeting: 'Hello')
format('%s', 'Hello')

# good

format('%{greeting}', greeting: 'Hello')
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | annotated
SupportedStyles | annotated, template

## Style/FrozenStringLiteralComment

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop is designed to help upgrade to Ruby 3.0. It will add the
comment `# frozen_string_literal: true` to the top of files to
enable frozen string literals. Frozen string literals will be default
in Ruby 3.0. The comment will be added below a shebang and encoding
comment. The frozen string literal comment is only valid in Ruby 2.3+.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | when_needed
SupportedStyles | when_needed, always, never

## Style/GlobalVars

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cops looks for uses of global variables.
It does not report offenses for built-in global variables.
Built-in global variables are allowed by default. Additionally
users can allow additional variables via the AllowedVariables option.

Note that backreferences like $1, $2, etc are not global variables.

### Example

```ruby
# bad
$foo = 2

# good
FOO = 2
foo = 2
```

### Important attributes

Attribute | Value
--- | ---
AllowedVariables |

### References

* [https://github.com/bbatsov/ruby-style-guide#instance-vars](https://github.com/bbatsov/ruby-style-guide#instance-vars)
* [http://www.zenspider.com/Languages/Ruby/QuickRef.html](http://www.zenspider.com/Languages/Ruby/QuickRef.html)

## Style/GuardClause

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

Use a guard clause instead of wrapping the code inside a conditional
expression

### Example

```ruby
# bad
def test
  if something
    work
  end
end

# good
def test
  return unless something
  work
end

# also good
def test
  work if something
end

# bad
if something
  raise 'exception'
else
  ok
end

# good
raise 'exception' if something
ok
```

### Important attributes

Attribute | Value
--- | ---
MinBodyLength | 1

### References

* [https://github.com/bbatsov/ruby-style-guide#no-nested-conditionals](https://github.com/bbatsov/ruby-style-guide#no-nested-conditionals)

## Style/HashSyntax

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks hash literal syntax.

It can enforce either the use of the class hash rocket syntax or
the use of the newer Ruby 1.9 syntax (when applicable).

A separate offense is registered for each problematic pair.

The supported styles are:

* ruby19 - forces use of the 1.9 syntax (e.g. `{a: 1}`) when hashes have
  all symbols for keys
* hash_rockets - forces use of hash rockets for all hashes
* no_mixed_keys - simply checks for hashes with mixed syntaxes
* ruby19_no_mixed_keys - forces use of ruby 1.9 syntax and forbids mixed
  syntax hashes

### Example

```ruby
"EnforcedStyle => 'ruby19'"

# good
{a: 2, b: 1}
{:c => 2, 'd' => 2} # acceptable since 'd' isn't a symbol
{d: 1, 'e' => 2} # technically not forbidden

# bad
{:a => 2}
{b: 1, :c => 2}
```
```ruby
"EnforcedStyle => 'hash_rockets'"

# good
{:a => 1, :b => 2}

# bad
{a: 1, b: 2}
{c: 1, 'd' => 5}
```
```ruby
"EnforcedStyle => 'no_mixed_keys'"

# good
{:a => 1, :b => 2}
{c: 1, d: 2}

# bad
{:a => 1, b: 2}
{c: 1, 'd' => 2}
```
```ruby
"EnforcedStyle => 'ruby19_no_mixed_keys'"

# good
{a: 1, b: 2}
{:c => 3, 'd' => 4}

# bad
{:a => 1, :b => 2}
{c: 2, 'd' => 3} # should just use hash rockets
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | ruby19
SupportedStyles | ruby19, hash_rockets, no_mixed_keys, ruby19_no_mixed_keys
UseHashRocketsWithSymbolValues | false
PreferHashRocketsForNonAlnumEndingSymbols | false

### References

* [https://github.com/bbatsov/ruby-style-guide#hash-literals](https://github.com/bbatsov/ruby-style-guide#hash-literals)

## Style/IdenticalConditionalBranches

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for identical lines at the beginning or end of
each branch of a conditional statement.

### Example

```ruby
# bad
if condition
  do_x
  do_z
else
  do_y
  do_z
end

# good
if condition
  do_x
else
  do_y
end
do_z

# bad
if condition
  do_z
  do_x
else
  do_z
  do_y
end

# good
do_z
if condition
  do_x
else
  do_y
end

# bad
case foo
when 1
  do_x
when 2
  do_x
else
  do_x
end

# good
case foo
when 1
  do_x
  do_y
when 2
  # nothing
else
  do_x
  do_z
end
```

## Style/IfInsideElse

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

If the `else` branch of a conditional consists solely of an `if` node,
it can be combined with the `else` to become an `elsif`.
This helps to keep the nesting level from getting too deep.

### Example

```ruby
# good
if condition_a
  action_a
elsif condition_b
  action_b
else
  action_c
end

# bad
if condition_a
  action_a
else
  if condition_b
    action_b
  else
    action_c
  end
end
```

## Style/IfUnlessModifier

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for if and unless statements that would fit on one line
if written as a modifier if/unless.
The maximum line length is configurable.

### Important attributes

Attribute | Value
--- | ---
MaxLineLength | 80

### References

* [https://github.com/bbatsov/ruby-style-guide#if-as-a-modifier](https://github.com/bbatsov/ruby-style-guide#if-as-a-modifier)

## Style/IfUnlessModifierOfIfUnless

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

Checks for if and unless statements used as modifiers of other if or
unless statements.

### Example

```ruby
# bad
tired? ? 'stop' : 'go faster' if running?

# bad
if tired?
  "please stop"
else
  "keep going"
end if running?

# good
if running?
  tired? ? 'stop' : 'go faster'
end
```

## Style/IfWithSemicolon

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

Checks for uses of semicolon in if statements.

### References

* [https://github.com/bbatsov/ruby-style-guide#no-semicolon-ifs](https://github.com/bbatsov/ruby-style-guide#no-semicolon-ifs)

## Style/ImplicitRuntimeError

Enabled by default | Supports autocorrection
--- | ---
Disabled | No

This cop checks for `raise` or `fail` statements which do not specify an
explicit exception class. (This raises a `RuntimeError`. Some projects
might prefer to use exception classes which more precisely identify the
nature of the error.)

### Example

```ruby
# bad
raise 'Error message here'

# good
raise ArgumentError, 'Error message here'
```

## Style/InfiniteLoop

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Use `Kernel#loop` for infinite loops.

### Example

```ruby
# bad
while true
  work
end

# good
loop do
  work
end
```

### References

* [https://github.com/bbatsov/ruby-style-guide#infinite-loop](https://github.com/bbatsov/ruby-style-guide#infinite-loop)

## Style/InlineComment

Enabled by default | Supports autocorrection
--- | ---
Disabled | No

This cop checks for trailing inline comments.

### Example

```ruby
# good
foo.each do |f|
  # Standalone comment
  f.bar
end

# bad
foo.each do |f|
  f.bar # Trailing inline comment
end
```

## Style/InverseMethods

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop check for usages of not (`not` or `!`) called on a method
when an inverse of that method can be used instead.
Methods that can be inverted by a not (`not` or `!`) should be defined
in `InverseMethods`
Methods that are inverted by inverting the return
of the block that is passed to the method should be defined in
`InverseBlocks`

### Example

```ruby
# bad
!foo.none?
!foo.any? { |f| f.even? }
!foo.blank?
!(foo == bar)
foo.select { |f| !f.even? }
foo.reject { |f| f != 7 }

# good
foo.none?
foo.blank?
foo.any? { |f| f.even? }
foo != bar
foo == bar
!!('foo' =~ /^\w+$/)
```

### Important attributes

Attribute | Value
--- | ---
InverseMethods | {:any?=>:none?, :even?=>:odd?, :===>:!=, :=~=>:!~, :<=>:>=, :>=>:<=}
InverseBlocks | {:select=>:reject, :select!=>:reject!}

## Style/Lambda

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop (by default) checks for uses of the lambda literal syntax for
single line lambdas, and the method call syntax for multiline lambdas.
It is configurable to enforce one of the styles for both single line
and multiline lambdas as well.

### Example

```ruby
# EnforcedStyle: line_count_dependent (default)

# bad
f = lambda { |x| x }
f = ->(x) do
      x
    end

# good
f = ->(x) { x }
f = lambda do |x|
      x
    end
```
```ruby
# EnforcedStyle: lambda

# bad
f = ->(x) { x }
f = ->(x) do
      x
    end

# good
f = lambda { |x| x }
f = lambda do |x|
      x
    end
```
```ruby
# EnforcedStyle: literal

# bad
f = lambda { |x| x }
f = lambda do |x|
      x
    end

# good
f = ->(x) { x }
f = ->(x) do
      x
    end
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | line_count_dependent
SupportedStyles | line_count_dependent, lambda, literal

### References

* [https://github.com/bbatsov/ruby-style-guide#lambda-multi-line](https://github.com/bbatsov/ruby-style-guide#lambda-multi-line)

## Style/LambdaCall

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for use of the lambda.(args) syntax.

### Example

```ruby
# bad
lambda.(x, y)

# good
lambda.call(x, y)
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | call
SupportedStyles | call, braces

### References

* [https://github.com/bbatsov/ruby-style-guide#proc-call](https://github.com/bbatsov/ruby-style-guide#proc-call)

## Style/LineEndConcatenation

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for string literal concatenation at
the end of a line.

### Example

```ruby
# bad
some_str = 'ala' +
           'bala'

some_str = 'ala' <<
           'bala'

# good
some_str = 'ala' \
           'bala'
```

## Style/MethodCallWithArgsParentheses

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

This cop checks presence of parentheses in method calls containing
parameters. By default, macro methods are ignored. Additional methods
can be added to the `IgnoredMethods` list.

### Example

```ruby
# bad
array.delete e

# good
array.delete(e)

# good
# Operators don't need parens
foo == bar

# good
# Setter methods don't need parens
foo.bar = baz

# okay with `puts` listed in `IgnoredMethods`
puts 'test'

# IgnoreMacros: true (default)

# good
class Foo
  bar :baz
end

# IgnoreMacros: false

# bad
class Foo
  bar :baz
end
```

### Important attributes

Attribute | Value
--- | ---
IgnoreMacros | true
IgnoredMethods |

### References

* [https://github.com/bbatsov/ruby-style-guide#method-invocation-parens](https://github.com/bbatsov/ruby-style-guide#method-invocation-parens)

## Style/MethodCallWithoutArgsParentheses

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for unwanted parentheses in parameterless method calls.

### Example

```ruby
# bad
object.some_method()

# good
object.some_method
```

### References

* [https://github.com/bbatsov/ruby-style-guide#method-invocation-parens](https://github.com/bbatsov/ruby-style-guide#method-invocation-parens)

## Style/MethodCalledOnDoEndBlock

Enabled by default | Supports autocorrection
--- | ---
Disabled | No

This cop checks for methods called on a do...end block. The point of
this check is that it's easy to miss the call tacked on to the block
when reading code.

### Example

```ruby
a do
  b
end.c
```

### References

* [https://github.com/bbatsov/ruby-style-guide#single-line-blocks](https://github.com/bbatsov/ruby-style-guide#single-line-blocks)

## Style/MethodDefParentheses

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cops checks for parentheses around the arguments in method
definitions. Both instance and class/singleton methods are checked.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | require_parentheses
SupportedStyles | require_parentheses, require_no_parentheses, require_no_parentheses_except_multiline

### References

* [https://github.com/bbatsov/ruby-style-guide#method-parens](https://github.com/bbatsov/ruby-style-guide#method-parens)

## Style/MethodMissing

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for the presence of `method_missing` without also
defining `respond_to_missing?` and falling back on `super`.

### Example

```ruby
#bad
def method_missing(...)
  ...
end

#good
def respond_to_missing?(...)
  ...
end

def method_missing(...)
  ...
  super
end
```

### References

* [https://github.com/bbatsov/ruby-style-guide#no-method-missing](https://github.com/bbatsov/ruby-style-guide#no-method-missing)

## Style/MinMax

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for potential uses of `Enumerable#minmax`.

### Example

```ruby
# bad
bar = [foo.min, foo.max]
return foo.min, foo.max

# good
bar = foo.minmax
return foo.minmax
```

## Style/MissingElse

Enabled by default | Supports autocorrection
--- | ---
Disabled | No

Checks for `if` expressions that do not have an `else` branch.
SupportedStyles

if
case

### Example

```ruby
# bad
if condition
  statement
end
```
```ruby
# bad
case var
when condition
  statement
end
```
```ruby
# good
if condition
  statement
else
# the content of the else branch will be determined by Style/EmptyElse
end
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | both
SupportedStyles | if, case, both

## Style/MixinGrouping

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for grouping of mixins in `class` and `module` bodies.
By default it enforces mixins to be placed in separate declarations,
but it can be configured to enforce grouping them in one declaration.

### Example

```ruby
EnforcedStyle: separated (default)

# bad
class Foo
  include Bar, Qox
end

# good
class Foo
  include Qox
  include Bar
end

EnforcedStyle: grouped

# bad
class Foo
  extend Bar
  extend Qox
end

# good
class Foo
  extend Qox, Bar
end
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | separated
SupportedStyles | separated, grouped

### References

* [https://github.com/bbatsov/ruby-style-guide#mixin-grouping](https://github.com/bbatsov/ruby-style-guide#mixin-grouping)

## Style/MixinUsage

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks that `include`, `extend` and `prepend` exists at
the top level.
Using these at the top level affects the behavior of `Object`.
There will not be using `include`, `extend` and `prepend` at
the top level. Let's use it inside `class` or `module`.

### Example

```ruby
# bad
include M

class C
end

# bad
extend M

class C
end

# bad
prepend M

class C
end

# good
class C
  include M
end

# good
class C
  extend M
end

# good
class C
  prepend M
end
```

## Style/ModuleFunction

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cops checks for use of `extend self` or `module_function` in a
module.

Supported styles are: module_function, extend_self.

These offenses are not auto-corrected since there are different
implications to each approach.

### Example

```ruby
# Good if EnforcedStyle is module_function
module Test
  module_function
  ...
end

# Good if EnforcedStyle is extend_self
module Test
  extend self
  ...
end
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | module_function
SupportedStyles | module_function, extend_self

### References

* [https://github.com/bbatsov/ruby-style-guide#module-function](https://github.com/bbatsov/ruby-style-guide#module-function)

## Style/MultilineBlockChain

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for chaining of a block after another block that spans
multiple lines.

### Example

```ruby
Thread.list.find_all do |t|
  t.alive?
end.map do |t|
  t.object_id
end
```

### References

* [https://github.com/bbatsov/ruby-style-guide#single-line-blocks](https://github.com/bbatsov/ruby-style-guide#single-line-blocks)

## Style/MultilineIfModifier

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for uses of if/unless modifiers with multiple-lines bodies.

### Example

```ruby
# bad
{
  result: 'this should not happen'
} unless cond

# good
{ result: 'ok' } if cond
```

### References

* [https://github.com/bbatsov/ruby-style-guide#no-multiline-if-modifiers](https://github.com/bbatsov/ruby-style-guide#no-multiline-if-modifiers)

## Style/MultilineIfThen

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for uses of the `then` keyword in multi-line if statements.

### Example

```ruby
if cond then
end
```
```ruby
if cond then a
elsif cond then b
end
```

### References

* [https://github.com/bbatsov/ruby-style-guide#no-then](https://github.com/bbatsov/ruby-style-guide#no-then)

## Style/MultilineMemoization

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks expressions wrapping styles for multiline memoization.

### Example

```ruby
# EnforcedStyle: keyword (default)

# bad
foo ||= (
  bar
  baz
)

# good
foo ||= begin
  bar
  baz
end
```
```ruby
# EnforcedStyle: braces

# bad
foo ||= begin
  bar
  baz
end

# good
foo ||= (
  bar
  baz
)
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | keyword
SupportedStyles | keyword, braces

## Style/MultilineTernaryOperator

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for multi-line ternary op expressions.

### References

* [https://github.com/bbatsov/ruby-style-guide#no-multiline-ternary](https://github.com/bbatsov/ruby-style-guide#no-multiline-ternary)

## Style/MultipleComparison

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks against comparing a variable with multiple items, where
`Array#include?` could be used instead to avoid code repetition.

### Example

```ruby
# bad
a = 'a'
foo if a == 'a' || a == 'b' || a == 'c'

# good
a = 'a'
foo if ['a', 'b', 'c'].include?(a)
```

## Style/MutableConstant

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks whether some constant value isn't a
mutable literal (e.g. array or hash).

### Example

```ruby
# bad
CONST = [1, 2, 3]

# good
CONST = [1, 2, 3].freeze
```

## Style/NegatedIf

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for uses of if with a negated condition. Only ifs
without else are considered. There are three different styles:

  - both
  - prefix
  - postfix

### Example

```ruby
# EnforcedStyle: both
# enforces `unless` for `prefix` and `postfix` conditionals

# good

unless foo
  bar
end

# bad

if !foo
  bar
end

# good

bar unless foo

# bad

bar if !foo
```
```ruby
# EnforcedStyle: prefix
# enforces `unless` for just `prefix` conditionals

# good

unless foo
  bar
end

# bad

if !foo
  bar
end

# good

bar if !foo
```
```ruby
# EnforcedStyle: postfix
# enforces `unless` for just `postfix` conditionals

# good

bar unless foo

# bad

bar if !foo

# good

if !foo
  bar
end
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | both
SupportedStyles | both, prefix, postfix

### References

* [https://github.com/bbatsov/ruby-style-guide#unless-for-negatives](https://github.com/bbatsov/ruby-style-guide#unless-for-negatives)

## Style/NegatedWhile

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for uses of while with a negated condition.

### References

* [https://github.com/bbatsov/ruby-style-guide#until-for-negatives](https://github.com/bbatsov/ruby-style-guide#until-for-negatives)

## Style/NestedModifier

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for nested use of if, unless, while and until in their
modifier form.

### Example

```ruby
# bad
something if a if b

# good
something if b && a
```

### References

* [https://github.com/bbatsov/ruby-style-guide#no-nested-modifiers](https://github.com/bbatsov/ruby-style-guide#no-nested-modifiers)

## Style/NestedParenthesizedCalls

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for unparenthesized method calls in the argument list
of a parenthesized method call.

### Example

```ruby
# good
method1(method2(arg), method3(arg))

# bad
method1(method2 arg, method3, arg)
```

### Important attributes

Attribute | Value
--- | ---
Whitelist | be, be_a, be_an, be_between, be_falsey, be_kind_of, be_instance_of, be_truthy, be_within, eq, eql, end_with, include, match, raise_error, respond_to, start_with

## Style/NestedTernaryOperator

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for nested ternary op expressions.

### References

* [https://github.com/bbatsov/ruby-style-guide#no-nested-ternary](https://github.com/bbatsov/ruby-style-guide#no-nested-ternary)

## Style/Next

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Use `next` to skip iteration instead of a condition at the end.

### Example

```ruby
# bad
[1, 2].each do |a|
  if a == 1
    puts a
  end
end

# good
[1, 2].each do |a|
  next unless a == 1
  puts a
end
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | skip_modifier_ifs
MinBodyLength | 3
SupportedStyles | skip_modifier_ifs, always

### References

* [https://github.com/bbatsov/ruby-style-guide#no-nested-conditionals](https://github.com/bbatsov/ruby-style-guide#no-nested-conditionals)

## Style/NilComparison

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for comparison of something with nil using ==.

### Example

```ruby
# bad
if x == nil

# good
if x.nil?
```

### References

* [https://github.com/bbatsov/ruby-style-guide#predicate-methods](https://github.com/bbatsov/ruby-style-guide#predicate-methods)

## Style/NonNilCheck

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for non-nil checks, which are usually redundant.

Non-nil checks are allowed if they are the final nodes of predicate.

 # good
 def signed_in?
   !current_user.nil?
 end

### Example

```ruby
# bad
if x != nil

# good (when not allowing semantic changes)
# bad (when allowing semantic changes)
if !x.nil?

# good (when allowing semantic changes)
if x
```

### Important attributes

Attribute | Value
--- | ---
IncludeSemanticChanges | false

### References

* [https://github.com/bbatsov/ruby-style-guide#no-non-nil-checks](https://github.com/bbatsov/ruby-style-guide#no-non-nil-checks)

## Style/Not

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for uses if the keyword *not* instead of !.

### References

* [https://github.com/bbatsov/ruby-style-guide#bang-not-not](https://github.com/bbatsov/ruby-style-guide#bang-not-not)

## Style/NumericLiteralPrefix

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for octal, hex, binary and decimal literals using
uppercase prefixes and corrects them to lowercase prefix
or no prefix (in case of decimals).
eg. for octal use `0o` instead of `0` or `0O`.

Can be configured to use `0` only for octal literals using
`EnforcedOctalStyle` => `zero_only`

### Important attributes

Attribute | Value
--- | ---
EnforcedOctalStyle | zero_with_o
SupportedOctalStyles | zero_with_o, zero_only

### References

* [https://github.com/bbatsov/ruby-style-guide#numeric-literal-prefixes](https://github.com/bbatsov/ruby-style-guide#numeric-literal-prefixes)

## Style/NumericLiterals

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for big numeric literals without _ between groups
of digits in them.

### Example

```ruby
# bad

1000000
1_00_000
1_0000

# good

1_000_000
1000

# good unless Strict is set

10_000_00 # typical representation of $10,000 in cents
```

### Important attributes

Attribute | Value
--- | ---
MinDigits | 5
Strict | false

### References

* [https://github.com/bbatsov/ruby-style-guide#underscores-in-numerics](https://github.com/bbatsov/ruby-style-guide#underscores-in-numerics)

## Style/NumericPredicate

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for usage of comparison operators (`==`,
`>`, `<`) to test numbers as zero, positive, or negative.
These can be replaced by their respective predicate methods.
The cop can also be configured to do the reverse.

The cop disregards `#nonzero?` as it its value is truthy or falsey,
but not `true` and `false`, and thus not always interchangeable with
`!= 0`.

The cop ignores comparisons to global variables, since they are often
populated with objects which can be compared with integers, but are
not themselves `Interger` polymorphic.

### Example

```ruby
# EnforcedStyle: predicate (default)

# bad

foo == 0
0 > foo
bar.baz > 0

# good

foo.zero?
foo.negative?
bar.baz.positive?
```
```ruby
# EnforcedStyle: comparison

# bad

foo.zero?
foo.negative?
bar.baz.positive?

# good

foo == 0
0 > foo
bar.baz > 0
```

### Important attributes

Attribute | Value
--- | ---
AutoCorrect | false
EnforcedStyle | predicate
SupportedStyles | predicate, comparison
Exclude | spec/\*\*/\*

### References

* [https://github.com/bbatsov/ruby-style-guide#predicate-methods](https://github.com/bbatsov/ruby-style-guide#predicate-methods)

## Style/OneLineConditional

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

TODO: Make configurable.
Checks for uses of if/then/else/end on a single line.

### References

* [https://github.com/bbatsov/ruby-style-guide#ternary-operator](https://github.com/bbatsov/ruby-style-guide#ternary-operator)

## Style/OptionHash

Enabled by default | Supports autocorrection
--- | ---
Disabled | No

This cop checks for options hashes and discourages them if the
current Ruby version supports keyword arguments.

### Example

```ruby
Instead of:

def fry(options = {})
  temperature = options.fetch(:temperature, 300)
  ...
end

Prefer:

def fry(temperature: 300)
  ...
end
```

### Important attributes

Attribute | Value
--- | ---
SuspiciousParamNames | options, opts, args, params, parameters

## Style/OptionalArguments

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for optional arguments to methods
that do not come at the end of the argument list

### Example

```ruby
# bad
def foo(a = 1, b, c)
end

# good
def baz(a, b, c = 1)
end

def foobar(a = 1, b = 2, c = 3)
end
```

### References

* [https://github.com/bbatsov/ruby-style-guide#optional-arguments](https://github.com/bbatsov/ruby-style-guide#optional-arguments)

## Style/OrAssignment

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for potential usage of the `||=` operator.

### Example

```ruby
# bad
name = name ? name : 'Bozhidar'

# bad
name = if name
         name
       else
         'Bozhidar'
       end

# bad
unless name
  name = 'Bozhidar'
end

# bad
name = 'Bozhidar' unless name

# good - set name to 'Bozhidar', only if it's nil or false
name ||= 'Bozhidar'
```

### References

* [https://github.com/bbatsov/ruby-style-guide#double-pipe-for-uninit](https://github.com/bbatsov/ruby-style-guide#double-pipe-for-uninit)

## Style/ParallelAssignment

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for simple usages of parallel assignment.
This will only complain when the number of variables
being assigned matched the number of assigning variables.

### Example

```ruby
# bad
a, b, c = 1, 2, 3
a, b, c = [1, 2, 3]

# good
one, two = *foo
a, b = foo()
a, b = b, a

a = 1
b = 2
c = 3
```

### References

* [https://github.com/bbatsov/ruby-style-guide#parallel-assignment](https://github.com/bbatsov/ruby-style-guide#parallel-assignment)

## Style/ParenthesesAroundCondition

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for the presence of superfluous parentheses around the
condition of if/unless/while/until.

### Important attributes

Attribute | Value
--- | ---
AllowSafeAssignment | true

### References

* [https://github.com/bbatsov/ruby-style-guide#no-parens-around-condition](https://github.com/bbatsov/ruby-style-guide#no-parens-around-condition)

## Style/PercentLiteralDelimiters

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop enforces the consistent usage of `%`-literal delimiters.

Specify the 'default' key to set all preferred delimiters at once. You
can continue to specify individual preferred delimiters to override the
default.

### Example

```ruby
# Style/PercentLiteralDelimiters:
#   PreferredDelimiters:
#     default: '[]'
#     '%i':    '()'

# good
%w[alpha beta] + %i(gamma delta)

# bad
%W(alpha #{beta})

# bad
%I(alpha beta)
```

### Important attributes

Attribute | Value
--- | ---
PreferredDelimiters | {"default"=>"()", "%i"=>"[]", "%I"=>"[]", "%r"=>"{}", "%w"=>"[]", "%W"=>"[]"}

### References

* [https://github.com/bbatsov/ruby-style-guide#percent-literal-braces](https://github.com/bbatsov/ruby-style-guide#percent-literal-braces)

## Style/PercentQLiterals

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for usage of the %Q() syntax when %q() would do.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | lower_case_q
SupportedStyles | lower_case_q, upper_case_q

## Style/PerlBackrefs

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop looks for uses of Perl-style regexp match
backreferences like $1, $2, etc.

### References

* [https://github.com/bbatsov/ruby-style-guide#no-perl-regexp-last-matchers](https://github.com/bbatsov/ruby-style-guide#no-perl-regexp-last-matchers)

## Style/PreferredHashMethods

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop (by default) checks for uses of methods Hash#has_key? and
Hash#has_value? where it enforces Hash#key? and Hash#value?
It is configurable to enforce the inverse, using `verbose` method
names also.

### Example

```ruby
# EnforcedStyle: short (default)

# bad
Hash#has_key?
Hash#has_value?

# good
Hash#key?
Hash#value?
```
```ruby
# EnforcedStyle: verbose

# bad
Hash#key?
Hash#value?

# good
Hash#has_key?
Hash#has_value?
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | short
SupportedStyles | short, verbose

### References

* [https://github.com/bbatsov/ruby-style-guide#hash-key](https://github.com/bbatsov/ruby-style-guide#hash-key)

## Style/Proc

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cops checks for uses of Proc.new where Kernel#proc
would be more appropriate.

### References

* [https://github.com/bbatsov/ruby-style-guide#proc](https://github.com/bbatsov/ruby-style-guide#proc)

## Style/RaiseArgs

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks the args passed to `fail` and `raise`. For exploded
style (default), it recommends passing the exception class and message
to `raise`, rather than construct an instance of the error. It will
still allow passing just a message, or the construction of an error
with more than one argument.

The exploded style works identically, but with the addition that it
will also suggest constructing error objects when the exception is
passed multiple arguments.

### Example

```ruby
# EnforcedStyle: exploded

# bad
raise StandardError.new("message")

# good
raise StandardError, "message"
fail "message"
raise MyCustomError.new(arg1, arg2, arg3)
raise MyKwArgError.new(key1: val1, key2: val2)
```
```ruby
# EnforcedStyle: compact

# bad
raise StandardError, "message"
raise RuntimeError, arg1, arg2, arg3

# good
raise StandardError.new("message")
raise MyCustomError.new(arg1, arg2, arg3)
fail "message"
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | exploded
SupportedStyles | compact, exploded

### References

* [https://github.com/bbatsov/ruby-style-guide#exception-class-messages](https://github.com/bbatsov/ruby-style-guide#exception-class-messages)

## Style/RedundantBegin

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for redundant `begin` blocks.

Currently it checks for code like this:

### Example

```ruby
def redundant
  begin
    ala
    bala
  rescue StandardError => e
    something
  end
end

def preferred
  ala
  bala
rescue StandardError => e
  something
end
```

### References

* [https://github.com/bbatsov/ruby-style-guide#begin-implicit](https://github.com/bbatsov/ruby-style-guide#begin-implicit)

## Style/RedundantConditional

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for redundant returning of true/false in conditionals.

### Example

```ruby
# bad
x == y ? true : false

# bad
if x == y
  true
else
  false
end

# good
x == y

# bad
x == y ? false : true

# good
x != y
```

## Style/RedundantException

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for RuntimeError as the argument of raise/fail.

It checks for code like this:

### Example

```ruby
# Bad
raise RuntimeError, 'message'

# Bad
raise RuntimeError.new('message')

# Good
raise 'message'
```

### References

* [https://github.com/bbatsov/ruby-style-guide#no-explicit-runtimeerror](https://github.com/bbatsov/ruby-style-guide#no-explicit-runtimeerror)

## Style/RedundantFreeze

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop check for uses of Object#freeze on immutable objects.

### Example

```ruby
# bad
CONST = 1.freeze

# good
CONST = 1
```

## Style/RedundantParentheses

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for redundant parentheses.

### Example

```ruby
# bad
(x) if ((y.z).nil?)

# good
x if y.z.nil?
```

## Style/RedundantReturn

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for redundant `return` expressions.

It should be extended to handle methods whose body is if/else
or a case expression with a default branch.

### Example

```ruby
def test
  return something
end

def test
  one
  two
  three
  return something
end
```

### Important attributes

Attribute | Value
--- | ---
AllowMultipleReturnValues | false

### References

* [https://github.com/bbatsov/ruby-style-guide#no-explicit-return](https://github.com/bbatsov/ruby-style-guide#no-explicit-return)

## Style/RedundantSelf

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for redundant uses of `self`.

`self` is only needed when:

* Sending a message to same object with zero arguments in
  presence of a method name clash with an argument or a local
  variable.

  Note, with using explicit self you can only send messages
  with public or protected scope, you cannot send private
  messages this way.

  Example:

  def bar
    :baz
  end

  def foo(bar)
    self.bar # resolves name clash with argument
  end

  def foo2
    bar = 1
    self.bar # resolves name clash with local variable
  end

  %w[x y z].select do |bar|
    self.bar == bar # resolves name clash with argument of a block
  end

* Calling an attribute writer to prevent an local variable assignment

  attr_writer :bar

  def foo
    self.bar= 1 # Make sure above attr writer is called
  end

Special cases:

We allow uses of `self` with operators because it would be awkward
otherwise.

### References

* [https://github.com/bbatsov/ruby-style-guide#no-self-unless-required](https://github.com/bbatsov/ruby-style-guide#no-self-unless-required)

## Style/RegexpLiteral

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop enforces using // or %r around regular expressions.

### Example

```ruby
# Good if EnforcedStyle is slashes or mixed, bad if percent_r.
snake_case = /^[\dA-Z_]+$/

# Good if EnforcedStyle is percent_r, bad if slashes or mixed.
snake_case = %r{^[\dA-Z_]+$}

# Good if EnforcedStyle is slashes, bad if percent_r or mixed.
regex = /
  foo
  (bar)
  (baz)
/x

# Good if EnforcedStyle is percent_r or mixed, bad if slashes.
regex = %r{
  foo
  (bar)
  (baz)
}x

# Bad unless AllowInnerSlashes is true.
x =~ /home\//
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | slashes
SupportedStyles | slashes, percent_r, mixed
AllowInnerSlashes | false

### References

* [https://github.com/bbatsov/ruby-style-guide#percent-r](https://github.com/bbatsov/ruby-style-guide#percent-r)

## Style/RescueModifier

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for uses of rescue in its modifier form.

### References

* [https://github.com/bbatsov/ruby-style-guide#no-rescue-modifiers](https://github.com/bbatsov/ruby-style-guide#no-rescue-modifiers)

## Style/ReturnNil

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

This cop enforces consistency between 'return nil' and 'return'.

Supported styles are: return, return_nil.

### Example

```ruby
# EnforcedStyle: return (default)

# bad
def foo(arg)
  return nil if arg
end

# good
def foo(arg)
  return if arg
end

# EnforcedStyle: return_nil

# bad
def foo(arg)
  return if arg
end

# good
def foo(arg)
  return nil if arg
end
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | return
SupportedStyles | return, return_nil

## Style/SafeNavigation

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop transforms usages of a method call safeguarded by a non `nil`
check for the variable whose method is being called to
safe navigation (`&.`).

Configuration option: ConvertCodeThatCanStartToReturnNil
The default for this is `false`. When configured to `true`, this will
check for code in the format `!foo.nil? && foo.bar`. As it is written,
the return of this code is limited to `false` and whatever the return
of the method is. If this is converted to safe navigation,
`foo&.bar` can start returning `nil` as well as what the method
returns.

### Example

```ruby
# bad
foo.bar if foo
foo.bar(param1, param2) if foo
foo.bar { |e| e.something } if foo
foo.bar(param) { |e| e.something } if foo

foo.bar if !foo.nil?
foo.bar unless !foo
foo.bar unless foo.nil?

foo && foo.bar
foo && foo.bar(param1, param2)
foo && foo.bar { |e| e.something }
foo && foo.bar(param) { |e| e.something }

# good
foo&.bar
foo&.bar(param1, param2)
foo&.bar { |e| e.something }
foo&.bar(param) { |e| e.something }

foo.nil? || foo.bar
!foo || foo.bar

# Methods that `nil` will `respond_to?` should not be converted to
# use safe navigation
foo.to_i if foo
```

### Important attributes

Attribute | Value
--- | ---
ConvertCodeThatCanStartToReturnNil | false

## Style/SelfAssignment

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop enforces the use the shorthand for self-assignment.

### Example

```ruby
# bad
x = x + 1

# good
x += 1
```

### References

* [https://github.com/bbatsov/ruby-style-guide#self-assignment](https://github.com/bbatsov/ruby-style-guide#self-assignment)

## Style/Semicolon

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for multiple expressions placed on the same line.
It also checks for lines terminated with a semicolon.

### Important attributes

Attribute | Value
--- | ---
AllowAsExpressionSeparator | false

### References

* [https://github.com/bbatsov/ruby-style-guide#no-semicolon](https://github.com/bbatsov/ruby-style-guide#no-semicolon)

## Style/Send

Enabled by default | Supports autocorrection
--- | ---
Disabled | No

This cop checks for the use of the send method.

### References

* [https://github.com/bbatsov/ruby-style-guide#prefer-public-send](https://github.com/bbatsov/ruby-style-guide#prefer-public-send)

## Style/SignalException

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for uses of `fail` and `raise`.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | only_raise
SupportedStyles | only_raise, only_fail, semantic

### References

* [https://github.com/bbatsov/ruby-style-guide#prefer-raise-over-fail](https://github.com/bbatsov/ruby-style-guide#prefer-raise-over-fail)

## Style/SingleLineBlockParams

Enabled by default | Supports autocorrection
--- | ---
Disabled | No

This cop checks whether the block parameters of a single-line
method accepting a block match the names specified via configuration.

For instance one can configure `reduce`(`inject`) to use |a, e| as
parameters.

### Important attributes

Attribute | Value
--- | ---
Methods | {"reduce"=>["acc", "elem"]}, {"inject"=>["acc", "elem"]}

## Style/SingleLineMethods

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for single-line method definitions.
It can optionally accept single-line methods with no body.

### Important attributes

Attribute | Value
--- | ---
AllowIfMethodIsEmpty | true

### References

* [https://github.com/bbatsov/ruby-style-guide#no-single-line-methods](https://github.com/bbatsov/ruby-style-guide#no-single-line-methods)

## Style/SpecialGlobalVars

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop looks for uses of Perl-style global variables.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | use_english_names
SupportedStyles | use_perl_names, use_english_names

### References

* [https://github.com/bbatsov/ruby-style-guide#no-cryptic-perlisms](https://github.com/bbatsov/ruby-style-guide#no-cryptic-perlisms)

## Style/StabbyLambdaParentheses

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Check for parentheses around stabby lambda arguments.
There are two different styles. Defaults to `require_parentheses`.

### Example

```ruby
# require_parentheses - bad
->a,b,c { a + b + c }

# require_parentheses - good
->(a,b,c) { a + b + c}

# require_no_parentheses - bad
->(a,b,c) { a + b + c }

# require_no_parentheses - good
->a,b,c { a + b + c}
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | require_parentheses
SupportedStyles | require_parentheses, require_no_parentheses

### References

* [https://github.com/bbatsov/ruby-style-guide#stabby-lambda-with-args](https://github.com/bbatsov/ruby-style-guide#stabby-lambda-with-args)

## Style/StderrPuts

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop identifies places where `$stderr.puts` can be replaced by
`warn`. The latter has the advantage of easily being disabled by,
e.g. the -W0 interpreter flag, or setting $VERBOSE to nil.

### Example

```ruby
# bad
$stderr.puts('hello')

# good
warn('hello')
```

### References

* [https://github.com/bbatsov/ruby-style-guide#warn](https://github.com/bbatsov/ruby-style-guide#warn)

## Style/StringLiterals

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks if uses of quotes match the configured preference.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | single_quotes
SupportedStyles | single_quotes, double_quotes
ConsistentQuotesInMultiline | false

### References

* [https://github.com/bbatsov/ruby-style-guide#consistent-string-literals](https://github.com/bbatsov/ruby-style-guide#consistent-string-literals)

## Style/StringLiteralsInInterpolation

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks that quotes inside the string interpolation
match the configured preference.

### Example

```ruby
# EnforcedStyle: single_quotes

# bad
result = "Tests #{success ? "PASS" : "FAIL"}"

# good
result = "Tests #{success ? 'PASS' : 'FAIL'}"
```
```ruby
# EnforcedStyle: double_quotes

# bad
result = "Tests #{success ? 'PASS' : 'FAIL'}"

# good
result = "Tests #{success ? "PASS" : "FAIL"}"
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | single_quotes
SupportedStyles | single_quotes, double_quotes

## Style/StringMethods

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

This cop enforces the use of consistent method names
from the String class.

### Important attributes

Attribute | Value
--- | ---
PreferredMethods | {"intern"=>"to_sym"}

## Style/StructInheritance

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for inheritance from Struct.new.

### Example

```ruby
# bad
class Person < Struct.new(:first_name, :last_name)
end

# good
Person = Struct.new(:first_name, :last_name)
```

### References

* [https://github.com/bbatsov/ruby-style-guide#no-extend-struct-new](https://github.com/bbatsov/ruby-style-guide#no-extend-struct-new)

## Style/SymbolArray

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop can check for array literals made up of symbols that are not
using the %i() syntax.

Alternatively, it checks for symbol arrays using the %i() syntax on
projects which do not want to use that syntax.

Configuration option: MinSize
If set, arrays with fewer elements than this value will not trigger the
cop. For example, a `MinSize of `3` will not enforce a style on an array
of 2 or fewer elements.

### Example

```ruby
EnforcedStyle: percent (default)

# good
%i[foo bar baz]

# bad
[:foo, :bar, :baz]
```
```ruby
EnforcedStyle: brackets

# good
[:foo, :bar, :baz]

# bad
%i[foo bar baz]
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | percent
MinSize | 0
SupportedStyles | percent, brackets

### References

* [https://github.com/bbatsov/ruby-style-guide#percent-i](https://github.com/bbatsov/ruby-style-guide#percent-i)

## Style/SymbolLiteral

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks symbol literal syntax.

### Example

```ruby
# bad
:"symbol"

# good
:symbol
```

## Style/SymbolProc

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Use symbols as procs when possible.

### Example

```ruby
# bad
something.map { |s| s.upcase }

# good
something.map(&:upcase)
```

### Important attributes

Attribute | Value
--- | ---
IgnoredMethods | respond_to, define_method

## Style/TernaryParentheses

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for the presence of parentheses around ternary
conditions. It is configurable to enforce inclusion or omission of
parentheses using `EnforcedStyle`. Omission is only enforced when
removing the parentheses won't cause a different behavior.

### Example

```ruby
EnforcedStyle: require_no_parentheses (default)

# bad
foo = (bar?) ? a : b
foo = (bar.baz?) ? a : b
foo = (bar && baz) ? a : b

# good
foo = bar? ? a : b
foo = bar.baz? ? a : b
foo = bar && baz ? a : b
```
```ruby
EnforcedStyle: require_parentheses

# bad
foo = bar? ? a : b
foo = bar.baz? ? a : b
foo = bar && baz ? a : b

# good
foo = (bar?) ? a : b
foo = (bar.baz?) ? a : b
foo = (bar && baz) ? a : b
```
```ruby
EnforcedStyle: require_parentheses_when_complex

# bad
foo = (bar?) ? a : b
foo = (bar.baz?) ? a : b
foo = bar && baz ? a : b

# good
foo = bar? ? a : b
foo = bar.baz? ? a : b
foo = (bar && baz) ? a : b
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | require_no_parentheses
SupportedStyles | require_parentheses, require_no_parentheses, require_parentheses_when_complex
AllowSafeAssignment | true

## Style/TrailingCommaInArguments

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for trailing comma in argument lists.

### Example

```ruby
# always bad
method(1, 2,)

# good if EnforcedStyleForMultiline is consistent_comma
method(
  1, 2,
  3,
)

# good if EnforcedStyleForMultiline is comma or consistent_comma
method(
  1,
  2,
)

# good if EnforcedStyleForMultiline is no_comma
method(
  1,
  2
)
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyleForMultiline | no_comma
SupportedStylesForMultiline | comma, consistent_comma, no_comma

### References

* [https://github.com/bbatsov/ruby-style-guide#no-trailing-params-comma](https://github.com/bbatsov/ruby-style-guide#no-trailing-params-comma)

## Style/TrailingCommaInLiteral

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for trailing comma in array and hash literals.

### Example

```ruby
# always bad
a = [1, 2,]

# good if EnforcedStyleForMultiline is consistent_comma
a = [
  1, 2,
  3,
]

# good if EnforcedStyleForMultiline is comma or consistent_comma
a = [
  1,
  2,
]

# good if EnforcedStyleForMultiline is no_comma
a = [
  1,
  2
]
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyleForMultiline | no_comma
SupportedStylesForMultiline | comma, consistent_comma, no_comma

### References

* [https://github.com/bbatsov/ruby-style-guide#no-trailing-array-commas](https://github.com/bbatsov/ruby-style-guide#no-trailing-array-commas)

## Style/TrailingUnderscoreVariable

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for extra underscores in variable assignment.

### Example

```ruby
# bad
a, b, _ = foo()
a, b, _, = foo()
a, _, _ = foo()
a, _, _, = foo()

# good
a, b, = foo()
a, = foo()
*a, b, _ = foo()  => We need to know to not include 2 variables in a
a, *b, _ = foo()  => The correction `a, *b, = foo()` is a syntax error

# good if AllowNamedUnderscoreVariables is true
a, b, _something = foo()
```

### Important attributes

Attribute | Value
--- | ---
AllowNamedUnderscoreVariables | true

## Style/TrivialAccessors

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop looks for trivial reader/writer methods, that could
have been created with the attr_* family of functions automatically.

### Important attributes

Attribute | Value
--- | ---
ExactNameMatch | true
AllowPredicates | true
AllowDSLWriters | false
IgnoreClassMethods | false
Whitelist | to_ary, to_a, to_c, to_enum, to_h, to_hash, to_i, to_int, to_io, to_open, to_path, to_proc, to_r, to_regexp, to_str, to_s, to_sym

### References

* [https://github.com/bbatsov/ruby-style-guide#attr_family](https://github.com/bbatsov/ruby-style-guide#attr_family)

## Style/UnlessElse

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop looks for *unless* expressions with *else* clauses.

### References

* [https://github.com/bbatsov/ruby-style-guide#no-else-with-unless](https://github.com/bbatsov/ruby-style-guide#no-else-with-unless)

## Style/UnneededCapitalW

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for usage of the %W() syntax when %w() would do.

## Style/UnneededInterpolation

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for strings that are just an interpolated expression.

### Example

```ruby
# bad
"#{@var}"

# good
@var.to_s

# good if @var is already a String
@var
```

## Style/UnneededPercentQ

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for usage of the %q/%Q syntax when '' or "" would do.

### References

* [https://github.com/bbatsov/ruby-style-guide#percent-q](https://github.com/bbatsov/ruby-style-guide#percent-q)

## Style/VariableInterpolation

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for variable interpolation (like "#@ivar").

### References

* [https://github.com/bbatsov/ruby-style-guide#curlies-interpolate](https://github.com/bbatsov/ruby-style-guide#curlies-interpolate)

## Style/WhenThen

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for *when;* uses in *case* expressions.

### References

* [https://github.com/bbatsov/ruby-style-guide#one-line-cases](https://github.com/bbatsov/ruby-style-guide#one-line-cases)

## Style/WhileUntilDo

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for uses of `do` in multi-line `while/until` statements.

### References

* [https://github.com/bbatsov/ruby-style-guide#no-multiline-while-do](https://github.com/bbatsov/ruby-style-guide#no-multiline-while-do)

## Style/WhileUntilModifier

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for while and until statements that would fit on one line
if written as a modifier while/until.
The maximum line length is configurable.

### Important attributes

Attribute | Value
--- | ---
MaxLineLength | 80

### References

* [https://github.com/bbatsov/ruby-style-guide#while-as-a-modifier](https://github.com/bbatsov/ruby-style-guide#while-as-a-modifier)

## Style/WordArray

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop can check for array literals made up of word-like
strings, that are not using the %w() syntax.

Alternatively, it can check for uses of the %w() syntax, in projects
which do not want to include that syntax.

Configuration option: MinSize
If set, arrays with fewer elements than this value will not trigger the
cop. For example, a `MinSize` of `3` will not enforce a style on an
array of 2 or fewer elements.

### Example

```ruby
EnforcedStyle: percent (default)

# good
%w[foo bar baz]

# bad
['foo', 'bar', 'baz']
```
```ruby
EnforcedStyle: brackets

# good
['foo', 'bar', 'baz']

# bad
%w[foo bar baz]
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | percent
SupportedStyles | percent, brackets
MinSize | 0
WordRegex | (?-mix:\A[\p{Word}\n\t]+\z)

### References

* [https://github.com/bbatsov/ruby-style-guide#percent-w](https://github.com/bbatsov/ruby-style-guide#percent-w)

## Style/YodaCondition

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for Yoda conditions, i.e. comparison operations where
readability is reduced because the operands are not ordered the same
way as they would be ordered in spoken English.

### Example

```ruby
# EnforcedStyle: all_comparison_operators

# bad
99 == foo
"bar" != foo
42 >= foo
10 < bar

# good
foo == 99
foo == "bar"
foo <= 42
bar > 10
```
```ruby
# EnforcedStyle: equality_operators_only

# bad
99 == foo
"bar" != foo

# good
99 >= foo
3 < a && a < 5
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | all_comparison_operators
SupportedStyles | all_comparison_operators, equality_operators_only

### References

* [https://en.wikipedia.org/wiki/Yoda_conditions](https://en.wikipedia.org/wiki/Yoda_conditions)

## Style/ZeroLengthPredicate

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for numeric comparisons that can be replaced
by a predicate method, such as receiver.length == 0,
receiver.length > 0, receiver.length != 0,
receiver.length < 1 and receiver.size == 0 that can be
replaced by receiver.empty? and !receiver.empty.

### Example

```ruby
# bad
[1, 2, 3].length == 0
0 == "foobar".length
array.length < 1
{a: 1, b: 2}.length != 0
string.length > 0
hash.size > 0

# good
[1, 2, 3].empty?
"foobar".empty?
array.empty?
!{a: 1, b: 2}.empty?
!string.empty?
!hash.empty?
```
