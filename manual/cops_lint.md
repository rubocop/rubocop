# Lint

## Lint/AmbiguousBlockAssociation

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for ambiguous block association with method
when param passed without parentheses.

### Examples

```ruby
# bad
some_method a { |val| puts val }
```
```ruby
# good
# With parentheses, there's no ambiguity.
some_method(a) { |val| puts val }

# good
# Operator methods require no disambiguation
foo == bar { |b| b.baz }

# good
# Lambda arguments require no disambiguation
foo = ->(bar) { bar.baz }
```

### References

* [https://github.com/bbatsov/ruby-style-guide#syntax](https://github.com/bbatsov/ruby-style-guide#syntax)

## Lint/AmbiguousOperator

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for ambiguous operators in the first argument of a
method invocation without parentheses.

### Examples

```ruby
# bad

# The `*` is interpreted as a splat operator but it could possibly be
# a `*` method invocation (i.e. `do_something.*(some_array)`).
do_something *some_array
```
```ruby
# good

# With parentheses, there's no ambiguity.
do_something(*some_array)
```

### References

* [https://github.com/bbatsov/ruby-style-guide#method-invocation-parens](https://github.com/bbatsov/ruby-style-guide#method-invocation-parens)

## Lint/AmbiguousRegexpLiteral

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for ambiguous regexp literals in the first argument of
a method invocation without parentheses.

### Examples

```ruby
# bad

# This is interpreted as a method invocation with a regexp literal,
# but it could possibly be `/` method invocations.
# (i.e. `do_something./(pattern)./(i)`)
do_something /pattern/i
```
```ruby
# good

# With parentheses, there's no ambiguity.
do_something(/pattern/i)
```

## Lint/AssignmentInCondition

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for assignments in the conditions of
if/while/until.

### Examples

```ruby
# bad

if some_var = true
  do_something
end
```
```ruby
# good

if some_var == true
  do_something
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
AllowSafeAssignment | `true` | Boolean

### References

* [https://github.com/bbatsov/ruby-style-guide#safe-assignment-in-condition](https://github.com/bbatsov/ruby-style-guide#safe-assignment-in-condition)

## Lint/BlockAlignment

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks whether the end keywords are aligned properly for do
end blocks.

Three modes are supported through the `EnforcedStyleAlignWith`
configuration parameter:

`start_of_block` : the `end` shall be aligned with the
start of the line where the `do` appeared.

`start_of_line` : the `end` shall be aligned with the
start of the line where the expression started.

`either` (which is the default) : the `end` is allowed to be in either
location. The autofixer will default to `start_of_line`.

### Examples

#### EnforcedStyleAlignWith: either (default)

```ruby
# bad

foo.bar
   .each do
     baz
       end

# good

variable = lambda do |i|
  i
end
```
#### EnforcedStyleAlignWith: start_of_block

```ruby
# bad

foo.bar
   .each do
     baz
       end

# good

foo.bar
  .each do
     baz
   end
```
#### EnforcedStyleAlignWith: start_of_line

```ruby
# bad

foo.bar
   .each do
     baz
       end

# good

foo.bar
  .each do
     baz
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
EnforcedStyleAlignWith | `either` | `either`, `start_of_block`, `start_of_line`

## Lint/BooleanSymbol

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for `:true` and `:false` symbols.
In most cases it would be a typo.

### Examples

```ruby
# bad
:true

# good
true
```
```ruby
# bad
:false

# good
false
```

## Lint/CircularArgumentReference

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for circular argument references in optional keyword
arguments and optional ordinal arguments.

This cop mirrors a warning produced by MRI since 2.2.

### Examples

```ruby
# bad

def bake(pie: pie)
  pie.heat_up
end
```
```ruby
# good

def bake(pie:)
  pie.refrigerate
end
```
```ruby
# good

def bake(pie: self.pie)
  pie.feed_to(user)
end
```
```ruby
# bad

def cook(dry_ingredients = dry_ingredients)
  dry_ingredients.reduce(&:+)
end
```
```ruby
# good

def cook(dry_ingredients = self.dry_ingredients)
  dry_ingredients.combine
end
```

## Lint/ConditionPosition

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for conditions that are not on the same line as
if/while/until.

### Examples

```ruby
# bad

if
  some_condition
  do_something
end
```
```ruby
# good

if some_condition
  do_something
end
```

### References

* [https://github.com/bbatsov/ruby-style-guide#same-line-condition](https://github.com/bbatsov/ruby-style-guide#same-line-condition)

## Lint/Debugger

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for calls to debugger or pry.

### Examples

```ruby
# bad (ok during development)

# using pry
def some_method
  binding.pry
  do_something
end
```
```ruby
# bad (ok during development)

# using byebug
def some_method
  byebug
  do_something
end
```
```ruby
# good

def some_method
  do_something
end
```

## Lint/DefEndAlignment

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks whether the end keywords of method definitions are
aligned properly.

Two modes are supported through the EnforcedStyleAlignWith configuration
parameter. If it's set to `start_of_line` (which is the default), the
`end` shall be aligned with the start of the line where the `def`
keyword is. If it's set to `def`, the `end` shall be aligned with the
`def` keyword.

### Examples

#### EnforcedStyleAlignWith: start_of_line (default)

```ruby
# bad

private def foo
            end

# good

private def foo
end
```
#### EnforcedStyleAlignWith: def

```ruby
# bad

private def foo
            end

# good

private def foo
        end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
EnforcedStyleAlignWith | `start_of_line` | `start_of_line`, `def`
AutoCorrect | `false` | Boolean

## Lint/DeprecatedClassMethods

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for uses of the deprecated class method usages.

### Examples

```ruby
# bad

File.exists?(some_path)
```
```ruby
# good

File.exist?(some_path)
```

## Lint/DuplicateCaseCondition

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks that there are no repeated conditions
used in case 'when' expressions.

### Examples

```ruby
# bad

case x
when 'first'
  do_something
when 'first'
  do_something_else
end
```
```ruby
# good

case x
when 'first'
  do_something
when 'second'
  do_something_else
end
```

## Lint/DuplicateMethods

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for duplicated instance (or singleton) method
definitions.

### Examples

```ruby
# bad

def duplicated
  1
end

def duplicated
  2
end
```
```ruby
# bad

def duplicated
  1
end

alias duplicated other_duplicated
```
```ruby
# good

def duplicated
  1
end

def other_duplicated
  2
end
```

## Lint/DuplicatedKey

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for duplicated keys in hash literals.

This cop mirrors a warning in Ruby 2.2.

### Examples

```ruby
# bad

hash = { food: 'apple', food: 'orange' }
```
```ruby
# good

hash = { food: 'apple', other_food: 'orange' }
```

## Lint/EachWithObjectArgument

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks if each_with_object is called with an immutable
argument. Since the argument is the object that the given block shall
make calls on to build something based on the enumerable that
each_with_object iterates over, an immutable argument makes no sense.
It's definitely a bug.

### Examples

```ruby
# bad

sum = numbers.each_with_object(0) { |e, a| a += e }
```
```ruby
# good

num = 0
sum = numbers.each_with_object(num) { |e, a| a += e }
```

## Lint/ElseLayout

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for odd else block layout - like
having an expression on the same line as the else keyword,
which is usually a mistake.

### Examples

```ruby
# bad

if something
  # ...
else do_this
  do_that
end
```
```ruby
# good

if something
  # ...
else
  do_this
  do_that
end
```

## Lint/EmptyEnsure

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for empty `ensure` blocks

### Examples

```ruby
# bad

def some_method
  do_something
ensure
end
```
```ruby
# bad

begin
  do_something
ensure
end
```
```ruby
# good

def some_method
  do_something
ensure
  do_something_else
end
```
```ruby
# good

begin
  do_something
ensure
  do_something_else
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
AutoCorrect | `false` | Boolean

## Lint/EmptyExpression

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for the presence of empty expressions.

### Examples

```ruby
# bad

foo = ()
if ()
  bar
end
```
```ruby
# good

foo = (some_expression)
if (some_expression)
  bar
end
```

## Lint/EmptyInterpolation

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for empty interpolation.

### Examples

```ruby
# bad

"result is #{}"
```
```ruby
# good

"result is #{some_result}"
```

## Lint/EmptyWhen

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for the presence of `when` branches without a body.

### Examples

```ruby
# bad

case foo
when bar then 1
when baz then # nothing
end
```
```ruby
# good

case foo
when bar then 1
when baz then 2
end
```

## Lint/EndAlignment

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks whether the end keywords are aligned properly.

Three modes are supported through the `EnforcedStyleAlignWith`
configuration parameter:

If it's set to `keyword` (which is the default), the `end`
shall be aligned with the start of the keyword (if, class, etc.).

If it's set to `variable` the `end` shall be aligned with the
left-hand-side of the variable assignment, if there is one.

If it's set to `start_of_line`, the `end` shall be aligned with the
start of the line where the matching keyword appears.

### Examples

#### EnforcedStyleAlignWith: keyword (default)

```ruby
# bad

variable = if true
    end

# good

variable = if true
           end
```
#### EnforcedStyleAlignWith: variable

```ruby
# bad

variable = if true
    end

# good

variable = if true
end
```
#### EnforcedStyleAlignWith: start_of_line

```ruby
# bad

variable = if true
    end

# good

puts(if true
end)
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
EnforcedStyleAlignWith | `keyword` | `keyword`, `variable`, `start_of_line`
AutoCorrect | `false` | Boolean

## Lint/EndInMethod

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for END blocks in method definitions.

### Examples

```ruby
# bad

def some_method
  END { do_something }
end
```
```ruby
# good

def some_method
  at_exit { do_something }
end
```
```ruby
# good

# outside defs
END { do_something }
```

## Lint/EnsureReturn

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for *return* from an *ensure* block.

### Examples

```ruby
# bad

begin
  do_something
ensure
  do_something_else
  return
end
```
```ruby
# good

begin
  do_something
ensure
  do_something_else
end
```

### References

* [https://github.com/bbatsov/ruby-style-guide#no-return-ensure](https://github.com/bbatsov/ruby-style-guide#no-return-ensure)

## Lint/FloatOutOfRange

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop identifies Float literals which are, like, really really really
really really really really really big. Too big. No-one needs Floats
that big. If you need a float that big, something is wrong with you.

### Examples

```ruby
# bad

float = 3.0e400
```
```ruby
# good

float = 42.9
```

## Lint/FormatParameterMismatch

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This lint sees if there is a mismatch between the number of
expected fields for format/sprintf/#% and what is actually
passed as arguments.

### Examples

```ruby
# bad

format('A value: %s and another: %i', a_value)
```
```ruby
# good

format('A value: %s and another: %i', a_value, another)
```

## Lint/HandleExceptions

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for *rescue* blocks with no body.

### Examples

```ruby
# bad

def some_method
  do_something
rescue
  # do nothing
end
```
```ruby
# bad

begin
  do_something
rescue
  # do nothing
end
```
```ruby
# good

def some_method
  do_something
rescue
  handle_exception
end
```
```ruby
# good

begin
  do_something
rescue
  handle_exception
end
```

### References

* [https://github.com/bbatsov/ruby-style-guide#dont-hide-exceptions](https://github.com/bbatsov/ruby-style-guide#dont-hide-exceptions)

## Lint/ImplicitStringConcatenation

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for implicit string concatenation of string literals
which are on the same line.

### Examples

```ruby
# bad

array = ['Item 1' 'Item 2']
```
```ruby
# good

array = ['Item 1Item 2']
array = ['Item 1' + 'Item 2']
array = [
  'Item 1' \
  'Item 2'
]
```

## Lint/IneffectiveAccessModifier

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for `private` or `protected` access modifiers which are
applied to a singleton method. These access modifiers do not make
singleton methods private/protected. `private_class_method` can be
used for that.

### Examples

```ruby
# bad

class C
  private

  def self.method
    puts 'hi'
  end
end
```
```ruby
# good

class C
  def self.method
    puts 'hi'
  end

  private_class_method :method
end
```
```ruby
# good

class C
  class << self
    private

    def method
      puts 'hi'
    end
  end
end
```

## Lint/InheritException

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop looks for error classes inheriting from `Exception`
and its standard library subclasses, excluding subclasses of
`StandardError`. It is configurable to suggest using either
`RuntimeError` (default) or `StandardError` instead.

### Examples

#### EnforcedStyle: runtime_error (default)

```ruby
# bad

class C < Exception; end

# good

class C < RuntimeError; end
```
#### EnforcedStyle: standard_error

```ruby
# bad

class C < Exception; end

# good

class C < StandardError; end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
EnforcedStyle | `runtime_error` | `runtime_error`, `standard_error`

## Lint/InterpolationCheck

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for interpolation in a single quoted string.

### Examples

```ruby
# bad

foo = 'something with #{interpolation} inside'
```
```ruby
# good

foo = "something with #{interpolation} inside"
```

## Lint/LiteralAsCondition

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for literals used as the conditions or as
operands in and/or expressions serving as the conditions of
if/while/until.

### Examples

```ruby
# bad

if 20
  do_something
end
```
```ruby
# bad

if some_var && true
  do_something
end
```
```ruby
# good

if some_var && some_condition
  do_something
end
```

## Lint/LiteralInInterpolation

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for interpolated literals.

### Examples

```ruby
# bad

"result is #{10}"
```
```ruby
# good

"result is 10"
```

## Lint/Loop

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for uses of *begin...end while/until something*.

### Examples

```ruby
# bad

# using while
begin
  do_something
end while some_condition
```
```ruby
# bad

# using until
begin
  do_something
end until some_condition
```
```ruby
# good

# using while
while some_condition
  do_something
end
```
```ruby
# good

# using until
until some_condition
  do_something
end
```

### References

* [https://github.com/bbatsov/ruby-style-guide#loop-with-break](https://github.com/bbatsov/ruby-style-guide#loop-with-break)

## Lint/MissingCopEnableDirective

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks that there is an `# rubocop:enable ...` statement
after a `# rubocop:disable ...` statement. This will prevent leaving
cop disables on wide ranges of code, that latter contributors to
a file wouldn't be aware of.

### Examples

```ruby
# Lint/MissingCopEnableDirective:
#   MaximumRangeSize: .inf

# good
# rubocop:disable Layout/SpaceAroundOperators
x= 0
# rubocop:enable Layout/SpaceAroundOperators
# y = 1
# EOF

# bad
# rubocop:disable Layout/SpaceAroundOperators
x= 0
# EOF
```
```ruby
# Lint/MissingCopEnableDirective:
#   MaximumRangeSize: 2

# good
# rubocop:disable Layout/SpaceAroundOperators
x= 0
# With the previous, there are 2 lines on which cop is disabled.
# rubocop:enable Layout/SpaceAroundOperators

# bad
# rubocop:disable Layout/SpaceAroundOperators
x= 0
x += 1
# Including this, that's 3 lines on which the cop is disabled.
# rubocop:enable Layout/SpaceAroundOperators
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
MaximumRangeSize | `Infinity` | Float

## Lint/MultipleCompare

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

In math and Python, we can use `x < y < z` style comparison to compare
multiple value. However, we can't use the comparison in Ruby. However,
the comparison is not syntax error. This cop checks the bad usage of
comparison operators.

### Examples

```ruby
# bad

x < y < z
10 <= x <= 20
```
```ruby
# good

x < y && y < z
10 <= x && x <= 20
```

## Lint/NestedMethodDefinition

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for nested method definitions.

### Examples

```ruby
# bad

# `bar` definition actually produces methods in the same scope
# as the outer `foo` method. Furthermore, the `bar` method
# will be redefined every time `foo` is invoked.
def foo
  def bar
  end
end
```
```ruby
# good

def foo
  bar = -> { puts 'hello' }
  bar.call
end
```
```ruby
# good

def foo
  self.class_eval do
    def bar
    end
  end
end

def foo
  self.module_exec do
    def bar
    end
  end
end
```
```ruby
# good

def foo
  class << self
    def bar
    end
  end
end
```

### References

* [https://github.com/bbatsov/ruby-style-guide#no-nested-methods](https://github.com/bbatsov/ruby-style-guide#no-nested-methods)

## Lint/NestedPercentLiteral

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for nested percent literals.

### Examples

```ruby
# bad

# The percent literal for nested_attributes is parsed as four tokens,
# yielding the array [:name, :content, :"%i[incorrectly", :"nested]"].
attributes = {
  valid_attributes: %i[name content],
  nested_attributes: %i[name content %i[incorrectly nested]]
}
```

## Lint/NextWithoutAccumulator

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

Don't omit the accumulator when calling `next` in a `reduce` block.

### Examples

```ruby
# bad

result = (1..4).reduce(0) do |acc, i|
  next if i.odd?
  acc + i
end
```
```ruby
# good

result = (1..4).reduce(0) do |acc, i|
  next acc if i.odd?
  acc + i
end
```

## Lint/NonLocalExitFromIterator

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for non-local exits from iterators without a return
value. It registers an offense under these conditions:

 - No value is returned,
 - the block is preceded by a method chain,
 - the block has arguments,
 - the method which receives the block is not `define_method`
   or `define_singleton_method`,
 - the return is not contained in an inner scope, e.g. a lambda or a
   method definition.

### Examples

```ruby
class ItemApi
  rescue_from ValidationError do |e| # non-iteration block with arg
    return { message: 'validation error' } unless e.errors # allowed
    error_array = e.errors.map do |error| # block with method chain
      return if error.suppress? # warned
      return "#{error.param}: invalid" unless error.message # allowed
      "#{error.param}: #{error.message}"
    end
    { message: 'validation error', errors: error_array }
  end

  def update_items
    transaction do # block without arguments
      return unless update_necessary? # allowed
      find_each do |item| # block without method chain
        return if item.stock == 0 # false-negative...
        item.update!(foobar: true)
      end
    end
  end
end
```

## Lint/ParenthesesAsGroupedExpression

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

Checks for space between the name of a called method and a left
parenthesis.

### Examples

```ruby
# bad

puts (x + y)
```
```ruby
# good

puts(x + y)
```

### References

* [https://github.com/bbatsov/ruby-style-guide#parens-no-spaces](https://github.com/bbatsov/ruby-style-guide#parens-no-spaces)

## Lint/PercentStringArray

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for quotes and commas in %w, e.g. `%w('foo', "bar")`

It is more likely that the additional characters are unintended (for
example, mistranslating an array of literals to percent string notation)
rather than meant to be part of the resulting strings.

### Examples

```ruby
# bad

%w('foo', "bar")
```
```ruby
# good

%w(foo bar)
```

## Lint/PercentSymbolArray

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for colons and commas in %i, e.g. `%i(:foo, :bar)`

It is more likely that the additional characters are unintended (for
example, mistranslating an array of literals to percent string notation)
rather than meant to be part of the resulting symbols.

### Examples

```ruby
# bad

%i(:foo, :bar)
```
```ruby
# good

%i(foo bar)
```

## Lint/RandOne

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for `rand(1)` calls.
Such calls always return `0`.

### Examples

```ruby
# bad

rand 1
Kernel.rand(-1)
rand 1.0
rand(-1.0)
```
```ruby
# good

0 # just use 0 instead
```

## Lint/RedundantWithIndex

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for redundant `with_index`.

### Examples

```ruby
# bad
ary.each_with_index do |v|
  v
end

# good
ary.each do |v|
  v
end

# bad
ary.each.with_index do |v|
  v
end

# good
ary.each do |v|
  v
end
```

## Lint/RedundantWithObject

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for redundant `with_object`.

### Examples

```ruby
# bad
ary.each_with_object([]) do |v|
  v
end

# good
ary.each do |v|
  v
end

# bad
ary.each.with_object([]) do |v|
  v
end

# good
ary.each do |v|
  v
end
```

## Lint/RegexpAsCondition

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for regexp literals used as `match-current-line`.
If a regexp literal is in condition, the regexp matches `$_` implicitly.

### Examples

```ruby
# bad
if /foo/
  do_something
end

# good
if /foo/ =~ $_
  do_something
end
```

## Lint/RequireParentheses

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for expressions where there is a call to a predicate
method with at least one argument, where no parentheses are used around
the parameter list, and a boolean operator, && or ||, is used in the
last argument.

The idea behind warning for these constructs is that the user might
be under the impression that the return value from the method call is
an operand of &&/||.

### Examples

```ruby
# bad

if day.is? :tuesday && month == :jan
  # ...
end
```
```ruby
# good

if day.is?(:tuesday) && month == :jan
  # ...
end
```

## Lint/RescueException

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for *rescue* blocks targeting the Exception class.

### Examples

```ruby
# bad

begin
  do_something
rescue Exception
  handle_exception
end
```
```ruby
# good

begin
  do_something
rescue ArgumentError
  handle_exception
end
```

### References

* [https://github.com/bbatsov/ruby-style-guide#no-blind-rescues](https://github.com/bbatsov/ruby-style-guide#no-blind-rescues)

## Lint/RescueType

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Check for arguments to `rescue` that will result in a `TypeError`
if an exception is raised.

### Examples

```ruby
# bad
begin
  bar
rescue nil
  baz
end

# bad
def foo
  bar
rescue 1, 'a', "#{b}", 0.0, [], {}
  baz
end

# good
begin
  bar
rescue
  baz
end

# good
def foo
  bar
rescue NameError
  baz
end
```

## Lint/ReturnInVoidContext

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for the use of a return with a value in a context
where the value will be ignored. (initialize and setter methods)

### Examples

```ruby
# bad
def initialize
  foo
  return :qux if bar?
  baz
end

def foo=(bar)
  return 42
end
```
```ruby
# good
def initialize
  foo
  return if bar?
  baz
end

def foo=(bar)
  return
end
```

## Lint/SafeNavigationChain

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

The safe navigation operator returns nil if the receiver is
nil.  If you chain an ordinary method call after a safe
navigation operator, it raises NoMethodError.  We should use a
safe navigation operator after a safe navigation operator.
This cop checks for the problem outlined above.

### Examples

```ruby
# bad

x&.foo.bar
x&.foo + bar
x&.foo[bar]
```
```ruby
# good

x&.foo&.bar
x&.foo || bar
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Whitelist | `present?`, `blank?`, `presence`, `try` | Array

## Lint/ScriptPermission

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks if a file which has a shebang line as
its first line is granted execute permission.

## Lint/ShadowedArgument

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for shadowed arguments.

### Examples

```ruby
# bad

do_something do |foo|
  foo = 42
  puts foo
end

def do_something(foo)
  foo = 42
  puts foo
end
```
```ruby
# good

do_something do |foo|
  foo = foo + 42
  puts foo
end

def do_something(foo)
  foo = foo + 42
  puts foo
end

def do_something(foo)
  puts foo
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
IgnoreImplicitReferences | `false` | Boolean

## Lint/ShadowedException

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for a rescued exception that get shadowed by a
less specific exception being rescued before a more specific
exception is rescued.

### Examples

```ruby
# bad

begin
  something
rescue Exception
  handle_exception
rescue StandardError
  handle_standard_error
end

# good

begin
  something
rescue StandardError
  handle_standard_error
rescue Exception
  handle_exception
end

# good, however depending on runtime environment.
#
# This is a special case for system call errors.
# System dependent error code depends on runtime environment.
# For example, whether `Errno::EAGAIN` and `Errno::EWOULDBLOCK` are
# the same error code or different error code depends on environment.
# This good case is for `Errno::EAGAIN` and `Errno::EWOULDBLOCK` with
# the same error code.
begin
  something
rescue Errno::EAGAIN, Errno::EWOULDBLOCK
  handle_standard_error
end
```

## Lint/ShadowingOuterLocalVariable

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop looks for use of the same name as outer local variables
for block arguments or block local variables.
This is a mimic of the warning
"shadowing outer local variable - foo" from `ruby -cw`.

### Examples

```ruby
# bad

def some_method
  foo = 1

  2.times do |foo| # shadowing outer `foo`
    do_something(foo)
  end
end
```
```ruby
# good

def some_method
  foo = 1

  2.times do |bar|
    do_something(bar)
  end
end
```

## Lint/StringConversionInInterpolation

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for string conversion in string interpolation,
which is redundant.

### Examples

```ruby
# bad

"result is #{something.to_s}"
```
```ruby
# good

"result is #{something}"
```

### References

* [https://github.com/bbatsov/ruby-style-guide#no-to-s](https://github.com/bbatsov/ruby-style-guide#no-to-s)

## Lint/Syntax

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This is actually not a cop and inspects nothing. It just provides
methods to repack Parser's diagnostics/errors into RuboCop's offenses.

## Lint/UnderscorePrefixedVariableName

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for underscore-prefixed variables that are actually
used.

### Examples

```ruby
# bad

[1, 2, 3].each do |_num|
  do_something(_num)
end
```
```ruby
# good

[1, 2, 3].each do |num|
  do_something(num)
end
```
```ruby
# good

[1, 2, 3].each do |_num|
  do_something # not using `_num`
end
```

## Lint/UnifiedInteger

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for using Fixnum or Bignum constant.

### Examples

```ruby
# bad

1.is_a?(Fixnum)
1.is_a?(Bignum)
```
```ruby
# good

1.is_a?(Integer)
```

## Lint/UnneededDisable

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop detects instances of rubocop:disable comments that can be
removed without causing any offenses to be reported. It's implemented
as a cop in that it inherits from the Cop base class and calls
add_offense. The unusual part of its implementation is that it doesn't
have any on_* methods or an investigate method. This means that it
doesn't take part in the investigation phase when the other cops do
their work. Instead, it waits until it's called in a later stage of the
execution. The reason it can't be implemented as a normal cop is that
it depends on the results of all other cops to do its work.

### Examples

```ruby
# bad
# rubocop:disable Metrics/LineLength
x += 1
# rubocop:enable Metrics/LineLength

# good
x += 1
```

## Lint/UnneededRequireStatement

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

Checks for unnecessary `require` statement.

The following features are unnecessary `require` statement because
they are already loaded.

ruby -ve 'p $LOADED_FEATURES.reject { |feature| %r|/| =~ feature }'
ruby 2.2.8p477 (2017-09-14 revision 59906) [x86_64-darwin13]
["enumerator.so", "rational.so", "complex.so", "thread.rb"]

This cop targets Ruby 2.2 or higher containing these 4 features.

### Examples

```ruby
# bad
require 'unloaded_feature'
require 'thread'

# good
require 'unloaded_feature'
```

## Lint/UnneededSplatExpansion

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for unneeded usages of splat expansion

### Examples

```ruby
# bad

a = *[1, 2, 3]
a = *'a'
a = *1

begin
  foo
rescue *[StandardError, ApplicationError]
  bar
end

case foo
when *[1, 2, 3]
  bar
else
  baz
end
```
```ruby
# good

c = [1, 2, 3]
a = *c
a, b = *c
a, *b = *c
a = *1..10
a = ['a']

begin
  foo
rescue StandardError, ApplicationError
  bar
end

case foo
when *[1, 2, 3]
  bar
else
  baz
end
```

## Lint/UnreachableCode

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for unreachable code.
The check are based on the presence of flow of control
statement in non-final position in *begin*(implicit) blocks.

### Examples

```ruby
# bad

def some_method
  return
  do_something
end

# bad

def some_method
  if cond
    return
  else
    return
  end
  do_something
end
```
```ruby
# good

def some_method
  do_something
end
```

## Lint/UnusedBlockArgument

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for unused block arguments.

### Examples

```ruby
# bad

do_something do |used, unused|
  puts used
end

do_something do |bar|
  puts :foo
end

define_method(:foo) do |bar|
  puts :baz
end
```
```ruby
#good

do_something do |used, _unused|
  puts used
end

do_something do
  puts :foo
end

define_method(:foo) do |_bar|
  puts :baz
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
IgnoreEmptyBlocks | `true` | Boolean
AllowUnusedKeywordArguments | `false` | Boolean

### References

* [https://github.com/bbatsov/ruby-style-guide#underscore-unused-vars](https://github.com/bbatsov/ruby-style-guide#underscore-unused-vars)

## Lint/UnusedMethodArgument

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop checks for unused method arguments.

### Examples

```ruby
# bad

def some_method(used, unused, _unused_but_allowed)
  puts used
end
```
```ruby
# good

def some_method(used, _unused, _unused_but_allowed)
  puts used
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
AllowUnusedKeywordArguments | `false` | Boolean
IgnoreEmptyMethods | `true` | Boolean

### References

* [https://github.com/bbatsov/ruby-style-guide#underscore-unused-vars](https://github.com/bbatsov/ruby-style-guide#underscore-unused-vars)

## Lint/UriEscapeUnescape

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop identifies places where `URI.escape` can be replaced by
`CGI.escape`, `URI.encode_www_form` or `URI.encode_www_form_component`
depending on your specific use case.
Also this cop identifies places where `URI.unescape` can be replaced by
`CGI.unescape`, `URI.decode_www_form` or `URI.decode_www_form_component`
depending on your specific use case.

### Examples

```ruby
# bad
URI.escape('http://example.com')
URI.encode('http://example.com')

# good
CGI.escape('http://example.com')
URI.encode_www_form('http://example.com')
URI.encode_www_form_component('http://example.com')

# bad
URI.unescape(enc_uri)
URI.decode(enc_uri)

# good
CGI.unescape(enc_uri)
URI.decode_www_form(enc_uri)
URI.decode_www_form_component(enc_uri)
```

## Lint/UriRegexp

Enabled by default | Supports autocorrection
--- | ---
Enabled | Yes

This cop identifies places where `URI.regexp` is obsolete and should
not be used. Instead, use `URI::DEFAULT_PARSER.make_regexp`.

### Examples

```ruby
# bad
URI.regexp('http://example.com')

# good
URI::DEFAULT_PARSER.make_regexp('http://example.com')
```

## Lint/UselessAccessModifier

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for redundant access modifiers, including those with no
code, those which are repeated, and leading `public` modifiers in a
class or module body. Conditionally-defined methods are considered as
always being defined, and thus access modifiers guarding such methods
are not redundant.

### Examples

```ruby
class Foo
  public # this is redundant (default access is public)

  def method
  end

  private # this is not redundant (a method is defined)
  def method2
  end

  private # this is redundant (no following methods are defined)
end
```
```ruby
class Foo
  # The following is not redundant (conditionally defined methods are
  # considered as always defining a method)
  private

  if condition?
    def method
    end
  end

  protected # this is not redundant (method is defined)

  define_method(:method2) do
  end

  protected # this is redundant (repeated from previous modifier)

  [1,2,3].each do |i|
    define_method("foo#{i}") do
    end
  end

  # The following is redundant (methods defined on the class'
  # singleton class are not affected by the public modifier)
  public

  def self.method3
  end
end
```
```ruby
# Lint/UselessAccessModifier:
#   ContextCreatingMethods:
#     - concerning
require 'active_support/concern'
class Foo
  concerning :Bar do
    def some_public_method
    end

    private

    def some_private_method
    end
  end

  # this is not redundant because `concerning` created its own context
  private

  def some_other_private_method
  end
end
```
```ruby
# Lint/UselessAccessModifier:
#   MethodCreatingMethods:
#     - delegate
require 'active_support/core_ext/module/delegation'
class Foo
  # this is not redundant because `delegate` creates methods
  private

  delegate :method_a, to: :method_b
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
ContextCreatingMethods | `[]` | Array
MethodCreatingMethods | `[]` | Array

## Lint/UselessAssignment

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for every useless assignment to local variable in every
scope.
The basic idea for this cop was from the warning of `ruby -cw`:

  assigned but unused variable - foo

Currently this cop has advanced logic that detects unreferenced
reassignments and properly handles varied cases such as branch, loop,
rescue, ensure, etc.

### Examples

```ruby
# bad

def some_method
  some_var = 1
  do_something
end
```
```ruby
# good

def some_method
  some_var = 1
  do_something(some_var)
end
```

### References

* [https://github.com/bbatsov/ruby-style-guide#underscore-unused-vars](https://github.com/bbatsov/ruby-style-guide#underscore-unused-vars)

## Lint/UselessComparison

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for comparison of something with itself.

### Examples

```ruby
# bad

x.top >= x.top
```

## Lint/UselessElseWithoutRescue

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for useless `else` in `begin..end` without `rescue`.

### Examples

```ruby
# bad

begin
  do_something
else
  do_something_else # This will never be run.
end
```
```ruby
# good

begin
  do_something
rescue
  handle_errors
else
  do_something_else
end
```

## Lint/UselessSetterCall

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for setter call to local variable as the final
expression of a function definition.

### Examples

```ruby
# bad

def something
  x = Something.new
  x.attr = 5
end
```
```ruby
# good

def something
  x = Something.new
  x.attr = 5
  x
end
```

## Lint/Void

Enabled by default | Supports autocorrection
--- | ---
Enabled | No

This cop checks for operators, variables and literals used
in void context.

### Examples

```ruby
# bad

def some_method
  some_num * 10
  do_something
end
```
```ruby
# bad

def some_method(some_var)
  some_var
  do_something
end
```
```ruby
# good

def some_method
  do_something
  some_num * 10
end
```
```ruby
# good

def some_method(some_var)
  do_something
  some_var
end
```
