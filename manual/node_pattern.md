# Node Pattern

Node pattern is a DSL to help find specific nodes in the Abstract Syntax Tree
using a simple string.

It reminds the simplicity of regular expressions but used to find specific
nodes of Ruby code.

## History

The Node Pattern was introduced by [Alex Dowad](https://github.com/alexdowad)
and solves a problem that RuboCop contributors were facing for a long time:

- Ability to declaratively define rules for node search, matching, and capture.

The code below belongs to [Style/ArrayJoin](https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/Style/ArrayJoin)
cop and it's in favor of `Array#join` over `Array#*`. Then it tries to find
code like `%w(one two three) * ", "` and suggest to use `#join` instead.

It can also be an array of integers, and the code doesn't check it. However,
it checks if the argument sent is a string.

```ruby
def on_send(node)
  receiver_node, method_name, *arg_nodes = *node
  return unless receiver_node && receiver_node.array_type? &&
    method_name == :* && arg_nodes.first.str_type?

  add_offense(node, location: :selector)
end
```

This code was replaced in the cop defining a new matcher that does the same as the code above:

```ruby
def_node_matcher :join_candidate?, '(send $array :* $str)'
```

And the `on_send` method is simplified to a method usage:

```ruby
def on_send(node)
  join_candidate?(node) { add_offense(node, location: :selector) }
end
```

## `(` and `)` Navigate deeply with Parens

Parens delimits navigation inside node and its children.

A simple integer like `1` is represented by `(int 1)` in the AST.

```sh
$ ruby-parse -e '1'
(int 1)
```

- `int` will match exactly the node, looking only the node type.
- `(int 1)` will match precisely the node

## `_` for any single node

`_` will check if there's something present in the specific position, no matter the
value:

- `(int _)` will match any number
- `(int _ _)` will not match because `int` types have just one child that
  contains the value.


## `...` for several subsequent nodes

Where `_` matches any single node, `...` matches any number of nodes.

Say for example you want to find instances of calls to the method `sum` with any
number of arguments, be it `sum(1, 2)` or `sum(1, 2, 3, n)`.
First, let's check how it looks like in the AST:

```sh
$ ruby-parse -e 'sum(1, 2)'
(send nil :sum
  (int 1)
  (int 2))
```

Or with more children:

```sh
$ ruby-parse -e 'sum(1, 2, 3, n)'
(send nil :sum
  (int 1)
  (int 2)
  (int 3)
  (send nil :n))
```

The following expression would only match a call with 2 arguments:

```
(send nil? :sum _ _)
```

Instead, the following expression will any number of arguments (and thus both examples above):

```
(send nil? :sum ...)
```

Note that `...` can be appear anywhere in a sequence, for example `(send nil? :sum ... int)`
would no longer match the second example, as the last argument is not an integer.

Nesting `...` is also supported; the only limitation is that `...` and
other "variable length" patterns can only appear once within a sequence.
For example `(send ... :sum ...)` is not supported.

## `*`, `+`, `?` for repetitions

Another way to handle a variable number of nodes is by using `*`, `+`, `?` to signify
a particular pattern should match any number of times, at least once and at most once respectively.

Following on the previous example, to find sums of integer literals, we could use:

```
(send nil? :sum int*)
```

This would match our first example `sum(1, 2)` but not the other `sum(1, 2, 3, n)`

This pattern would also match a call to `sum` without any argument, which might not be desirable.

Using `+` would insure that only sums with at least one argument would be matched.

```
(send nil? :sum int+)
```

The `?` can limit the match only 0 or 1 nodes.
The following example would match any sum of three integer literals
optionally followed by a method call:

```
(send nil? :sum int int int send ?)
```

Note that we have to put a space between `send` and `?`,
since `send?` would be considered as a predicate (described below).

## `<>` for match in any order

You may not care about the exact order of the nodes you want to match.
In this case you can put the nodes without brackets:

```
(send nil? :sum <(int 2) int>)
```

This will match our first example (`sum(1, 2)`).

It won't match our second example though, as it specifies that there must be
exactly two arguments to the method call `sum`.

You can add `...` before the closing bracket to allow for additional parameters:

```
(send nil? :sum <(int 2) int ...>)
```

This will match both our examples, but not `sum(1.0, 2)` or `sum(2)`,
since the first node in the brackets is found, but not the second (`int`).

## `{}` for "OR"

Lets make it a bit more complex and introduce floats:

```sh
$ ruby-parse -e '1'
(int 1)
$ ruby-parse -e '1.0'
(float 1.0)
```

- `({int float} _)` - int or float types, no matter the value

## `$` for captures

You can capture elements or nodes along with your search, prefixing the expression
with `$`. For example, in a tuple like `(int 1)`, you can capture the value using `(int $_)`.

You can also capture multiple things like:

```
(${int float} $_)
```

The tuple can be entirely captured using the `$` before the open parens:

```
$({int float} _)
```

Or remove the parens and match directly from node head:

```
${int float}
```

All variable length patterns (`...`, `*`, `+`, `?`, `<>`) are captured as arrays.

The following pattern will have two captures, both arrays:

```
(send nil? $int+ (send $...))
```

## Predicate methods

Words which end with a `?` are predicate methods, are called on the target
to see if it matches any Ruby method which the matched object supports can be
used.

Example:

- `int_type?` can be used herein replacement of `(int _)`.

And refactoring the expression to allow both int or float types:

- `{int_type? float_type?}` can be used herein replacement of `({int float} _)`

You can also use it at the node level, asking for each child:

- `(int odd?)` will match only with odd numbers, asking it to the current
  number.

## `[]` for "AND"

Imagine you want to check if the number is `odd?` and also positive numbers:

`(int [odd? positive?])` - is an int and the value should be odd and positive.


## `#` to call external methods

Sometimes, we want to add extra logic. Let's imagine we're searching for
prime numbers, so we have a method to detect it:

```ruby
def prime?(n)
  if n <= 1
    false
  elsif n == 2
    true
  else
    (2..n/2).none? { |i| n % i == 0 }
  end
end
```

We can use the `#prime?` method directly in the expression:

```
(int #prime?)
```

## Using node matcher macros

The RuboCop base includes two useful methods to use the node pattern with Ruby in a
simple way. You can use the macros to define methods. The basics are
[def_node_matcher](https://www.rubydoc.info/gems/rubocop/RuboCop/NodePattern/Macros#def_node_matcher-instance_method)
and [def_node_search](https://www.rubydoc.info/gems/rubocop/RuboCop/NodePattern/Macros#def_node_search-instance_method).

When you define a pattern, it creates a method that accepts a node and tries to match.

Lets create an example where we're trying to find the symbols `user` and
`current_user` in expressions like: `user: current_user` or
`current_user: User.first`, so the objective here is pick all keys:

```sh
$ ruby-parse -e ':current_user'
(sym :current_user)
$ ruby-parse -e ':user'
(sym :user)
$ ruby-parse -e '{ user: current_user }'
(hash
  (pair
    (sym :user)
    (send nil :current_user)))
```

Our minimal matcher can get it in the simple node `sym`:

```ruby
def_node_matcher :user_symbol?, '(sym {:current_user :user})'
```

### Composing complex expressions with multiple matchers

Now let's go deeply combining the previous expression and also match if the
current symbol is being called from an initialization method, like:

```sh
$ ruby-parse -e 'Comment.new(user: current_user)'
(send
  (const nil :Comment) :new
  (hash
    (pair
      (sym :user)
      (send nil :current_user))))
```

And we can also reuse this and check if it's a constructor:

```ruby
def_node_matcher :initializing_with_user?, <<~PATTERN
  (send _ :new (hash (pair #user_symbol?)))
PATTERN
```

## `nil` or `nil?`

Take a special attention to nil behavior:

```sh
$ ruby-parse -e 'nil'
(nil)
```
In this case, the `nil` implicit matches with expressions like: `nil`, `(nil)`, or `nil_type?`.

But, nil is also used to represent a call from `nothing` from a simple method call:

```sh
$ ruby-parse -e 'method'
(send nil :method)
```

Then, for such case you can use the predicate `nil?`. And the code can be
matched with an expression like:

```
(send nil? :method)
```

## More resources

Curious about how it works?

Check more details in the
[documentation](https://www.rubydoc.info/gems/rubocop/RuboCop/NodePattern)
or browse the [source code](https://github.com/rubocop-hq/rubocop/blob/master/lib/rubocop/node_pattern.rb)
directly. It's easy to read and hack on.

The [specs](https://github.com/rubocop-hq/rubocop/blob/master/spec/rubocop/node_pattern_spec.rb)
are also very useful to comprehend each feature.
