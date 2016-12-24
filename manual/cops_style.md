# Style

## Style/AccessModifierIndentation

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Modifiers should be indented as deep as method definitions, or as deep
as the class/module keyword, depending on configuration.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | indent
SupportedStyles | outdent, indent
IndentationWidth | 


## Style/AccessorMethodName

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

## Style/Alias

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop finds uses of `alias` where `alias_method` would be more
appropriate (or is simply preferred due to configuration), and vice
versa.
It also finds uses of `alias :symbol` rather than `alias bareword`.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | prefer_alias
SupportedStyles | prefer_alias, prefer_alias_method


## Style/AlignArray

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Here we check if the elements of a multi-line array literal are
aligned.

## Style/AlignHash

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Here we check if the keys, separators, and values of a multi-line hash
literal are aligned.

### Important attributes

Attribute | Value
--- | ---
EnforcedHashRocketStyle | key
SupportedHashRocketStyles | key, separator, table
EnforcedColonStyle | key
SupportedColonStyles | key, separator, table
EnforcedLastArgumentHashStyle | always_inspect
SupportedLastArgumentHashStyles | always_inspect, always_ignore, ignore_implicit, ignore_explicit


## Style/AlignParameters

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Here we check if the parameters on a multi-line method call or
definition are aligned.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | with_first_parameter
SupportedStyles | with_first_parameter, with_fixed_indentation
IndentationWidth | 


## Style/AndOr

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for uses of *and* and *or*.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | always
SupportedStyles | always, conditionals


## Style/ArrayJoin

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for uses of "*" as a substitute for *join*.

Not all cases can reliably checked, due to Ruby's dynamic
types, so we consider only cases when the first argument is an
array literal or the second is a string literal.

## Style/AsciiComments

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for non-ascii (non-English) characters
in comments.

## Style/AsciiIdentifiers

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for non-ascii characters in identifier names.

## Style/Attr

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for uses of Module#attr.

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
f = File.open('file') do
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


## Style/BeginBlock

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for BEGIN blocks.

## Style/BlockComments

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop looks for uses of block comments (=begin...=end).

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


## Style/BlockEndNewline

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks whether the end statement of a do..end block
is on its own line.

### Example

```ruby
# bad
blah do |i|
  foo(i) end

# good
blah do |i|
  foo(i)
end

# bad
blah { |i|
  foo(i) }

# good
blah { |i|
  foo(i)
}
```

## Style/BracesAroundHashParameters

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for braces around the last parameter in a method call
if the last parameter is a hash.

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

## Style/CaseIndentation

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks how the *when*s of a *case* expression
are indented in relation to its *case* or *end* keyword.

It will register a separate offense for each misaligned *when*.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | case
SupportedStyles | case, end
IndentOneStep | false
IndentationWidth | 


## Style/CharacterLiteral

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for uses of the character literal ?x.

## Style/ClassAndModuleCamelCase

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cops checks for class and module names with
an underscore in them.

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

## Style/ClassVars

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for uses of class variables. Offenses
are signaled only on assignment to class variables to
reduced the number of offenses that would be reported.

## Style/ClosingParenthesisIndentation

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cops checks the indentation of hanging closing parentheses in
method calls, method definitions, and grouped expressions. A hanging
closing parenthesis means `)` preceded by a line break.

### Example

```ruby
# good: when x is on its own line, indent this way
func(
  x,
  y
)

# good: when x follows opening parenthesis, align parentheses
a = b * (x +
         y
        )

# bad
def func(
  x,
  y
  )
```

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


## Style/ColonMethodCall

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for methods invoked via the :: operator instead
of the . operator (like FileUtils::rmdir instead of FileUtils.rmdir).

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


## Style/CommentIndentation

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cops checks the indentation of comments.

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


## Style/ConstantName

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks whether constant names are written using
SCREAMING_SNAKE_CASE.

To avoid false positives, it ignores cases in which we cannot know
for certain the type of value that would be assigned to a constant.

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


## Style/DefWithParentheses

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for parentheses in the definition of a method,
that does not take any arguments. Both instance and
class/singleton methods are checked.

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

# Documenation
def foo.bar
  puts baz
end
```

### Important attributes

Attribute | Value
--- | ---
Exclude | spec/\*\*/\*, test/\*\*/\*
RequireForNonPublicMethods | false


## Style/DotPosition

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks the . position in multi-line method calls.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | leading
SupportedStyles | leading, trailing


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

## Style/ElseAlignment

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cops checks the alignment of else keywords. Normally they should
be aligned with an if/unless/while/until/begin/def keyword, but there
are special cases when they should follow the same rules as the
alignment of end.

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


## Style/EmptyLineBetweenDefs

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks whether method definitions are
separated by empty lines.

### Important attributes

Attribute | Value
--- | ---
AllowAdjacentOneLineDefs | false


## Style/EmptyLines

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cops checks for two or more consecutive blank lines.

## Style/EmptyLinesAroundAccessModifier

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Access modifiers should be surrounded by blank lines.

## Style/EmptyLinesAroundBlockBody

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cops checks if empty lines around the bodies of blocks match
the configuration.

### Example

```ruby
# EnforcedStyle: empty_lines

# good

foo do |bar|

  ...

end

# EnforcedStyle: no_empty_lines

# good

foo do |bar|
  ...
end
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | no_empty_lines
SupportedStyles | empty_lines, no_empty_lines


## Style/EmptyLinesAroundClassBody

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cops checks if empty lines around the bodies of classes match
the configuration.

### Example

```ruby
EnforcedStyle: empty_lines

# good

class Foo

   def bar
     ...
   end

end
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | no_empty_lines
SupportedStyles | empty_lines, empty_lines_except_namespace, empty_lines_special, no_empty_lines


## Style/EmptyLinesAroundMethodBody

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cops checks if empty lines exist around the bodies of methods.

### Example

```ruby
# good

def foo
  ...
end

# bad

def bar

  ...

end
```

## Style/EmptyLinesAroundModuleBody

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cops checks if empty lines around the bodies of modules match
the configuration.

### Example

```ruby
EnforcedStyle: empty_lines

# good

module Foo

  def bar
    ...
  end

end

EnforcedStyle: no_empty_lines

# good

module Foo
  def bar
    ...
  end
end
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | no_empty_lines
SupportedStyles | empty_lines, empty_lines_except_namespace, empty_lines_special, no_empty_lines


## Style/EmptyLiteral

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for the use of a method, the result of which
would be a literal, like an empty array, hash or string.

## Style/EmptyMethod

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for the formatting of empty method definitions.
By default it enforces empty method definitions to go on a single
line (compact style), but it cah be configured to enforce the `end`
to go on its own line (expanded style.)

Note: A method definition is not considered empty if it contains
      comments.

### Example

```ruby
EnforcedStyle: compact (default)

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

EnforcedStyle: expanded

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


## Style/Encoding

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

This cop checks whether the source file has a utf-8 encoding
comment or not.
Setting this check to "always" and "when_needed" makes sense only
for code that should support Ruby 1.9, since in 2.0+ utf-8 is the
default source file encoding. There are three styles:

when_needed - only enforce an encoding comment if there are non ASCII
              characters, otherwise report an offense
always - enforce encoding comment in all files
never - enforce no encoding comment in all files

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | never
SupportedStyles | when_needed, always, never
AutoCorrectEncodingComment | # encoding: utf-8


## Style/EndBlock

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for END blocks.

## Style/EndOfLine

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for Windows-style line endings in the source code.

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

## Style/ExtraSpacing

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for extra/unnecessary whitespace.

### Example

```ruby
# good if AllowForAlignment is true
name      = "RuboCop"
# Some comment and an empty line

website  += "/bbatsov/rubocop" unless cond
puts        "rubocop"          if     debug

# bad for any configuration
set_app("RuboCop")
website  = "https://github.com/bbatsov/rubocop"
```

### Important attributes

Attribute | Value
--- | ---
AllowForAlignment | true
ForceEqualSignAlignment | false


## Style/FileName

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


## Style/FirstArrayElementLineBreak

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

This cop checks for a line break before the first element in a
multi-line array.

### Example

```ruby
# bad
[ :a,
  :b]

# good
[
  :a,
  :b]
```

## Style/FirstHashElementLineBreak

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

This cop checks for a line break before the first element in a
multi-line hash.

### Example

```ruby
# bad
{ a: 1,
  b: 2}

# good
{
  a: 1,
  b: 2 }
```

## Style/FirstMethodArgumentLineBreak

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

This cop checks for a line break before the first argument in a
multi-line method call.

### Example

```ruby
# bad
method(foo, bar,
  baz)

# good
method(
  foo, bar,
  baz)

# ignored
method foo, bar,
  baz
```

## Style/FirstMethodParameterLineBreak

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

This cop checks for a line break before the first parameter in a
multi-line method parameter definition.

### Example

```ruby
# bad
def method(foo, bar,
    baz)
  do_something
end

# good
def method(
    foo, bar,
    baz)
  do_something
end

# ignored
def method foo,
    bar
  do_something
end
```

## Style/FirstParameterIndentation

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks the indentation of the first parameter in a method call.
Parameters after the first one are checked by Style/AlignParameters, not
by this cop.

### Example

```ruby
# bad
some_method(
first_param,
second_param)

# good
some_method(
  first_param,
second_param)
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | special_for_inner_method_call_in_parentheses
SupportedStyles | consistent, special_for_inner_method_call, special_for_inner_method_call_in_parentheses
IndentationWidth | 


## Style/FlipFlop

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop looks for uses of flip flop operator

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


## Style/FormatString

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

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

### Important attributes

Attribute | Value
--- | ---
Reference | http://www.zenspider.com/Languages/Ruby/QuickRef.html
AllowedVariables | 


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


## Style/HashSyntax

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks hash literal syntax.

It can enforce either the use of the class hash rocket syntax or
the use of the newer Ruby 1.9 syntax (when applicable).

A separate offense is registered for each problematic pair.

The supported styles are:

* ruby19 - forces use of the 1.9 syntax (e.g. {a: 1}) when hashes have
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


## Style/IfUnlessModifierOfIfUnless

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

Checks for if and unless statements used as modifers of other if or
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

## Style/IndentArray

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks the indentation of the first element in an array literal
where the opening bracket and the first element are on separate lines.
The other elements' indentations are handled by the AlignArray cop.

By default, array literals that are arguments in a method call with
parentheses, and where the opening square bracket of the array is on the
same line as the opening parenthesis of the method call, shall have
their first element indented one step (two spaces) more than the
position inside the opening parenthesis.

Other array literals shall have their first element indented one step
more than the start of the line where the opening square bracket is.

This default style is called 'special_inside_parentheses'. Alternative
styles are 'consistent' and 'align_brackets'. Here are examples:

    # special_inside_parentheses
    array = [
      :value
    ]
    but_in_a_method_call([
                           :its_like_this
                         ])
    # consistent
    array = [
      :value
    ]
    and_in_a_method_call([
      :no_difference
    ])
    # align_brackets
    and_now_for_something = [
                              :completely_different
                            ]

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | special_inside_parentheses
SupportedStyles | special_inside_parentheses, consistent, align_brackets
IndentationWidth | 


## Style/IndentAssignment

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks the indentation of the first line of the
right-hand-side of a multi-line assignment.

The indentation of the remaining lines can be corrected with
other cops such as `IndentationConsistency` and `EndAlignment`.

### Example

```ruby
# bad
value =
if foo
  'bar'
end

# good
value =
  if foo
  'bar'
end
```

### Important attributes

Attribute | Value
--- | ---
IndentationWidth | 


## Style/IndentHash

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cops checks the indentation of the first key in a hash literal
where the opening brace and the first key are on separate lines. The
other keys' indentations are handled by the AlignHash cop.

By default, Hash literals that are arguments in a method call with
parentheses, and where the opening curly brace of the hash is on the
same line as the opening parenthesis of the method call, shall have
their first key indented one step (two spaces) more than the position
inside the opening parenthesis.

Other hash literals shall have their first key indented one step more
than the start of the line where the opening curly brace is.

This default style is called 'special_inside_parentheses'. Alternative
styles are 'consistent' and 'align_braces'. Here are examples:

    # special_inside_parentheses
    hash = {
      key: :value
    }
    but_in_a_method_call({
                           its_like: :this
                         })
    # consistent
    hash = {
      key: :value
    }
    and_in_a_method_call({
      no: :difference
    })
    # align_braces
    and_now_for_something = {
                              completely: :different
                            }

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | special_inside_parentheses
SupportedStyles | special_inside_parentheses, consistent, align_braces
IndentationWidth | 


## Style/IndentationConsistency

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cops checks for inconsistent indentation.

### Example

```ruby
class A
  def test
    puts 'hello'
     puts 'world'
  end
end
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | normal
SupportedStyles | normal, rails


## Style/IndentationWidth

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cops checks for indentation that doesn't use two spaces.

### Example

```ruby
class A
 def test
  puts 'hello'
 end
end
```

### Important attributes

Attribute | Value
--- | ---
Width | 2


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

## Style/InitialIndentation

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cops checks for indentation of the first non-blank non-comment
line in a file.

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


## Style/LeadingCommentSpace

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks whether comments have a leading space
after the # denoting the start of the comment. The
leading space is not required for some RDoc special syntax,
like #++, #--, #:nodoc, etc. Neither is it required for
=begin/=end comments.

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

## Style/MethodCallParentheses

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

## Style/MethodName

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop makes sure that all methods use the configured style,
snake_case or camelCase, for their names. Some special arrangements
have to be made for operator methods.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | snake_case
SupportedStyles | snake_case, camelCase


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


## Style/MultilineArrayBraceLayout

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks that the closing brace in an array literal is either
on the same line as the last array element, or a new line.

When using the `symmetrical` (default) style:

If an array's opening brace is on the same line as the first element
of the array, then the closing brace should be on the same line as
the last element of the array.

If an array's opening brace is on the line above the first element
of the array, then the closing brace should be on the line below
the last element of the array.

When using the `new_line` style:

The closing brace of a multi-line array literal must be on the line
after the last element of the array.

When using the `same_line` style:

The closing brace of a multi-line array literal must be on the same
line as the last element of the array.

### Example

```ruby
# symmetrical: bad
# new_line: good
# same_line: bad
[ :a,
  :b
]

# symmetrical: bad
# new_line: bad
# same_line: good
[
  :a,
  :b ]

# symmetrical: good
# new_line: bad
# same_line: good
[ :a,
  :b ]

# symmetrical: good
# new_line: good
# same_line: bad
[
  :a,
  :b
]
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | symmetrical
SupportedStyles | symmetrical, new_line, same_line


## Style/MultilineAssignmentLayout

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

This cop checks whether the multiline assignments have a newline
after the assignment operator.

### Example

```ruby
# bad (with EnforcedStyle set to new_line)
foo = if expression
  'bar'
end

# good (with EnforcedStyle set to same_line)
foo = if expression
  'bar'
end

# good (with EnforcedStyle set to new_line)
foo =
  if expression
    'bar'
  end

# good (with EnforcedStyle set to new_line)
foo =
  begin
    compute
  rescue => e
    nil
  end
```

### Important attributes

Attribute | Value
--- | ---
SupportedTypes | block, case, class, if, kwbegin, module
EnforcedStyle | new_line
SupportedStyles | same_line, new_line


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

## Style/MultilineBlockLayout

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks whether the multiline do end blocks have a newline
after the start of the block. Additionally, it checks whether the block
arguments, if any, are on the same line as the start of the block.

### Example

```ruby
# bad
blah do |i| foo(i)
  bar(i)
end

# bad
blah do
  |i| foo(i)
  bar(i)
end

# good
blah do |i|
  foo(i)
  bar(i)
end

# bad
blah { |i| foo(i)
  bar(i)
}

# good
blah { |i|
  foo(i)
  bar(i)
}
```

## Style/MultilineHashBraceLayout

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks that the closing brace in a hash literal is either
on the same line as the last hash element, or a new line.

When using the `symmetrical` (default) style:

If a hash's opening brace is on the same line as the first element
of the hash, then the closing brace should be on the same line as
the last element of the hash.

If a hash's opening brace is on the line above the first element
of the hash, then the closing brace should be on the line below
the last element of the hash.

When using the `new_line` style:

The closing brace of a multi-line hash literal must be on the line
after the last element of the hash.

When using the `same_line` style:

The closing brace of a multi-line hash literal must be on the same
line as the last element of the hash.

### Example

```ruby
# symmetrical: bad
# new_line: good
# same_line: bad
{ a: 1,
  b: 2
}

# symmetrical: bad
# new_line: bad
# same_line: good
{
  a: 1,
  b: 2 }

# symmetrical: good
# new_line: bad
# same_line: good
{ a: 1,
  b: 2 }

# symmetrical: good
# new_line: good
# same_line: bad
{
  a: 1,
  b: 2
}
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | symmetrical
SupportedStyles | symmetrical, new_line, same_line


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

## Style/MultilineMemoization

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks that multiline memoizations are wrapped in a `begin`
and `end` block.

### Example

```ruby
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

## Style/MultilineMethodCallBraceLayout

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks that the closing brace in a method call is either
on the same line as the last method argument, or a new line.

When using the `symmetrical` (default) style:

If a method call's opening brace is on the same line as the first
argument of the call, then the closing brace should be on the same
line as the last argument of the call.

If an method call's opening brace is on the line above the first
argument of the call, then the closing brace should be on the line
below the last argument of the call.

When using the `new_line` style:

The closing brace of a multi-line method call must be on the line
after the last argument of the call.

When using the `same_line` style:

The closing brace of a multi-line method call must be on the same
line as the last argument of the call.

### Example

```ruby
# symmetrical: bad
# new_line: good
# same_line: bad
foo(a,
  b
)

# symmetrical: bad
# new_line: bad
# same_line: good
foo(
  a,
  b)

# symmetrical: good
# new_line: bad
# same_line: good
foo(a,
  b)

# symmetrical: good
# new_line: good
# same_line: bad
foo(
  a,
  b
)
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | symmetrical
SupportedStyles | symmetrical, new_line, same_line


## Style/MultilineMethodCallIndentation

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks the indentation of the method name part in method calls
that span more than one line.

### Example

```ruby
# bad
while a
.b
  something
end

# good, EnforcedStyle: aligned
while a
      .b
  something
end

# good, EnforcedStyle: aligned
Thing.a
     .b
     .c

# good, EnforcedStyle: indented
while a
    .b
  something
end
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | aligned
SupportedStyles | aligned, indented, indented_relative_to_receiver
IndentationWidth | 


## Style/MultilineMethodDefinitionBraceLayout

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks that the closing brace in a method definition is either
on the same line as the last method parameter, or a new line.

When using the `symmetrical` (default) style:

If a method definition's opening brace is on the same line as the
first parameter of the definition, then the closing brace should be
on the same line as the last parameter of the definition.

If an method definition's opening brace is on the line above the first
parameter of the definition, then the closing brace should be on the
line below the last parameter of the definition.

When using the `new_line` style:

The closing brace of a multi-line method definition must be on the line
after the last parameter of the definition.

When using the `same_line` style:

The closing brace of a multi-line method definition must be on the same
line as the last parameter of the definition.

### Example

```ruby
# symmetrical: bad
# new_line: good
# same_line: bad
def foo(a,
  b
)

# symmetrical: bad
# new_line: bad
# same_line: good
def foo(
  a,
  b)

# symmetrical: good
# new_line: bad
# same_line: good
def foo(a,
  b)

# symmetrical: good
# new_line: good
# same_line: bad
def foo(
  a,
  b
)
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | symmetrical
SupportedStyles | symmetrical, new_line, same_line


## Style/MultilineOperationIndentation

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks the indentation of the right hand side operand in
binary operations that span more than one line.

### Example

```ruby
# bad
if a +
b
  something
end
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | aligned
SupportedStyles | aligned, indented
IndentationWidth | 


## Style/MultilineTernaryOperator

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for multi-line ternary op expressions.

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
without else are considered.

## Style/NegatedWhile

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for uses of while with a negated condition.

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

## Style/NestedTernaryOperator

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for nested ternary op expressions.

## Style/Next

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Use `next` to skip iteration instead of a condition at the end.

### Example

```ruby
# bad
[1, 2].each do |a|
  if a == 1 do
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


## Style/Not

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for uses if the keyword *not* instead of !.

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


## Style/NumericLiterals

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for big numeric literals without _ between groups
of digits in them.

### Important attributes

Attribute | Value
--- | ---
MinDigits | 5


## Style/NumericPredicate

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for usage of comparison operators (`==`,
`>`, `<`) to test numbers as zero, positive, or negative.
These can be replaced by their respective predicate methods.
The cop can also be configured to do the reverse.

The cop disregards `nonzero?` as it its value is truthy or falsey,
but not `true` and `false`, and thus not always interchangeable with
`!= 0`.

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


## Style/OneLineConditional

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

TODO: Make configurable.
Checks for uses of if/then/else/end on a single line.

## Style/OpMethod

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


## Style/PercentLiteralDelimiters

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop enforces the consistent usage of `%`-literal delimiters.

### Important attributes

Attribute | Value
--- | ---
PreferredDelimiters | {"%"=>"()", "%i"=>"()", "%I"=>"()", "%q"=>"()", "%Q"=>"()", "%r"=>"{}", "%s"=>"()", "%w"=>"()", "%W"=>"()", "%x"=>"()"}


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

## Style/PredicateName

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
Exclude | spec/\*\*/\*


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


## Style/Proc

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cops checks for uses of Proc.new where Kernel#proc
would be more appropriate.

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
raise RuntimeError.new(arg1, arg2, arg3)
```
```ruby
# EnforcedStyle: compact

# bad
raise StandardError, "message"
raise RuntimeError, arg1, arg2, arg3

# good
raise StandardError.new("message")
raise RuntimeError.new(arg1, arg2, arg3)
fail "message"
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | exploded
SupportedStyles | compact, exploded


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

* Calling an attribute writer to prevent an local variable assignment

  attr_writer :bar

  def foo
    self.bar= 1 # Make sure above attr writer is called
  end

Special cases:

We allow uses of `self` with operators because it would be awkward
otherwise.

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


## Style/RescueEnsureAlignment

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks whether the rescue and ensure keywords are aligned
properly.

### Example

```ruby
# bad
begin
  something
  rescue
  puts 'error'
end

# good
begin
  something
rescue
  puts 'error'
end
```

## Style/RescueModifier

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for uses of rescue in its modifier form.

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


## Style/Send

Enabled by default | Supports autocorrection
--- | ---
Disabled | No

This cop checks for the use of the send method.

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


## Style/SingleLineBlockParams

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

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


## Style/SpaceAfterColon

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for colon (:) not followed by some kind of space.
N.B. this cop does not handle spaces after a ternary operator, which are
instead handled by Style/SpaceAroundOperators.

## Style/SpaceAfterComma

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for comma (,) not followed by some kind of space.

## Style/SpaceAfterMethodName

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for space between a method name and a left parenthesis in defs.

### Example

```ruby
# bad
def func (x) ... end

# good
def func(x) ... end
```

## Style/SpaceAfterNot

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for space after `!`.

### Example

```ruby
# bad
! something

# good
!something
```

## Style/SpaceAfterSemicolon

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for semicolon (;) not followed by some kind of space.

## Style/SpaceAroundBlockParameters

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks the spacing inside and after block parameters pipes.

### Example

```ruby
# bad
{}.each { | x,  y |puts x }

# good
{}.each { |x, y| puts x }
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyleInsidePipes | no_space
SupportedStylesInsidePipes | space, no_space


## Style/SpaceAroundEqualsInParameterDefault

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks that the equals signs in parameter default assignments
have or don't have surrounding space depending on configuration.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | space
SupportedStyles | space, no_space


## Style/SpaceAroundKeyword

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks the spacing around the keywords.

### Example

```ruby
# bad
something 'test'do|x|
end

while(something)
end

something = 123if test

# good
something 'test' do |x|
end

while (something)
end

something = 123 if test
```

## Style/SpaceAroundOperators

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks that operators have space around them, except for **
which should not have surrounding space.

### Important attributes

Attribute | Value
--- | ---
AllowForAlignment | true


## Style/SpaceBeforeBlockBraces

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks that block braces have or don't have a space before the opening
brace depending on configuration.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | space
SupportedStyles | space, no_space


## Style/SpaceBeforeComma

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for comma (,) preceded by space.

## Style/SpaceBeforeComment

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for missing space between a token and a comment on the
same line.

## Style/SpaceBeforeFirstArg

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks that exactly one space is used between a method name and the
first argument for method calls without parentheses.

Alternatively, extra spaces can be added to align the argument with
something on a preceding or following line, if the AllowForAlignment
config parameter is true.

### Example

```ruby
# bad
something  x
something   y, z
```

### Important attributes

Attribute | Value
--- | ---
AllowForAlignment | true


## Style/SpaceBeforeSemicolon

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for semicolon (;) preceded by space.

## Style/SpaceInLambdaLiteral

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for spaces between -> and opening parameter
brace in lambda literals.

### Example

```ruby
EnforcedStyle: require_no_space (default)

  # bad
  a = -> (x, y) { x + y }

  # good
  a = ->(x, y) { x + y }
```
```ruby
EnforcedStyle: require_space

  # bad
  a = ->(x, y) { x + y }

  # good
  a = -> (x, y) { x + y }
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | require_no_space
SupportedStyles | require_no_space, require_space


## Style/SpaceInsideArrayPercentLiteral

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for unnecessary additional spaces inside array percent literals
(i.e. %i/%w).

### Example

```ruby
# good
%i(foo bar baz)

# bad
%w(foo  bar  baz)
```

## Style/SpaceInsideBlockBraces

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks that block braces have or don't have surrounding space inside
them on configuration. For blocks taking parameters, it checks that the
left brace has or doesn't have trailing space depending on
configuration.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | space
SupportedStyles | space, no_space
EnforcedStyleForEmptyBraces | no_space
SupportedStylesForEmptyBraces | space, no_space
SpaceBeforeBlockParameters | true


## Style/SpaceInsideBrackets

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for spaces inside square brackets.

## Style/SpaceInsideHashLiteralBraces

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks that braces used for hash literals have or don't have
surrounding space depending on configuration.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | space
SupportedStyles | space, no_space, compact
EnforcedStyleForEmptyBraces | no_space
SupportedStylesForEmptyBraces | space, no_space


## Style/SpaceInsideParens

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for spaces inside ordinary round parentheses.

## Style/SpaceInsidePercentLiteralDelimiters

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for unnecessary additional spaces inside the delimiters of
%i/%w/%x literals.

### Example

```ruby
# good
%i(foo bar baz)

# bad
%w( foo bar baz )

# bad
%x(  ls -l )
```

## Style/SpaceInsideRangeLiteral

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for spaces inside range literals.

### Example

```ruby
# bad
1 .. 3

# good
1..3

# bad
'a' .. 'z'

# good
'a'..'z'
```

## Style/SpaceInsideStringInterpolation

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for whitespace within string interpolations.

### Example

```ruby
# Good if EnforcedStyle is no_space, bad if space.
   var = "This is the #{no_space} example"

# Good if EnforceStyle is space, bad if no_space.
   var = "This is the #{ space } example"
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | no_space
SupportedStyles | space, no_space


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


## Style/StringLiteralsInInterpolation

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks if uses of quotes match the configured preference.

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

## Style/SymbolArray

Enabled by default | Supports autocorrection
--- | ---
Disabled | Yes

This cop can check for array literals made up of symbols that are not
using the %i() syntax.

Alternatively, it checks for symbol arrays using the %i() syntax on
projects which do not want to use that syntax, perhaps because they
support a version of Ruby lower than 2.0.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | percent
SupportedStyles | percent, brackets


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


## Style/Tab

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for tabs inside the source code.

## Style/TernaryParentheses

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for the presence of parentheses around ternary
conditions. It is configurable to enforce inclusion or omission of
parentheses using `EnforcedStyle`.

### Example

```ruby
EnforcedStyle: require_no_parentheses (default)

# bad
foo = (bar?) ? a : b
foo = (bar.baz) ? a : b
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
foo = (bar.baz) ? a : b
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
foo = bar.baz ? a : b
foo = (bar && baz) ? a : b
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | require_no_parentheses
SupportedStyles | require_parentheses, require_no_parentheses, require_parentheses_when_complex
AllowSafeAssignment | true


## Style/TrailingBlankLines

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop looks for trailing blank lines and a final newline in the
source code.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | final_newline
SupportedStyles | final_newline, final_blank_line


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

#good
a, b, = foo()
a, = foo()
*a, b, _ = foo()  => We need to know to not include 2 variables in a
a, *b, _ = foo()  => The correction `a, *b, = foo()` is a syntax error
```

### Important attributes

Attribute | Value
--- | ---
AllowNamedUnderscoreVariables | true


## Style/TrailingWhitespace

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop looks for trailing whitespace in the source code.

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


## Style/UnlessElse

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop looks for *unless* expressions with *else* clauses.

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

## Style/VariableInterpolation

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for variable interpolation (like "#@ivar").

## Style/VariableName

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop makes sure that all variables use the configured style,
snake_case or camelCase, for their names.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | snake_case
SupportedStyles | snake_case, camelCase


## Style/VariableNumber

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop makes sure that all numbered variables use the
configured style, snake_case, normalcase or non_integer,
for their numbering.

### Example

```ruby
"EnforcedStyle => 'snake_case'"

# bad

variable1 = 1

# good

variable_1 = 1
```
```ruby
"EnforcedStyle => 'normalcase'"

# bad

variable_1 = 1

# good

variable1 = 1
```
```ruby
"EnforcedStyle => 'non_integer'"

#bad

variable1 = 1

variable_1 = 1

#good

variableone = 1

variable_one = 1
```

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | normalcase
SupportedStyles | snake_case, normalcase, non_integer


## Style/WhenThen

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for *when;* uses in *case* expressions.

## Style/WhileUntilDo

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for uses of `do` in multi-line `while/until` statements.

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


## Style/WordArray

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop can check for array literals made up of word-like
strings, that are not using the %w() syntax.

Alternatively, it can check for uses of the %w() syntax, in projects
which do not want to include that syntax.

### Important attributes

Attribute | Value
--- | ---
EnforcedStyle | percent
SupportedStyles | percent, brackets
MinSize | 0
WordRegex | (?-mix:\A[\p{Word}\n\t]+\z)


## Style/ZeroLengthPredicate

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for receiver.length == 0 predicates and the
negated versions receiver.length > 0 and receiver.length != 0.
These can be replaced with receiver.empty? and
!receiver.empty? respectively.

### Example

```ruby
# bad
[1, 2, 3].length == 0
0 == "foobar".length
hash.size > 0

# good
[1, 2, 3].empty?
"foobar".empty?
!hash.empty?
```
