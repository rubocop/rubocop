# Node Pattern

Node pattern is a DSL to help find specific nodes in
the Abstract Syntax Tree using a simple string.

It reminds the simplicity of regular expressions but used to find specific
nodes of Ruby code.

## History

The Node Pattern was introduced by [Alex Dowad](https://github.com/alexdowad)
and solves a problem that RuboCop contributors was facing for a long time:
Specify all the logic around what kind of nodes we have and put it in rule
methods.

The code bellow belongs to [Style/ArrayJoin](http://www.rubydoc.info/github/bbatsov/rubocop/Rubocop/Cop/Style/ArrayJoin)
cop and it's in favor of `Array#join` over `Array#*`. Then it tries to find
code like `%w(one two three) * ", "` and suggest to use `#join` instead.

It checks if the code is an array of strings and call `*` in the end:

```ruby
def on_send(node)
  receiver_node, method_name, *arg_nodes = *node
  return unless receiver_node && receiver_node.array_type? &&
    method_name == :* && arg_nodes.first.str_type?

  add_offense(node, location: :selector)
end
```

This code was replaced in the cop defining a new matcher that means the same as the code above:

```ruby
def_node_matcher :join_candidate?, '(send $array :* $str)'
```

And the `on_send` method is simplified to a simple method usage:

```ruby
def on_send(node)
  join_candidate?(node) { add_offense(node, location: :selector) }
end
```

## Simple match

A simple integer like `1` represents `(int 1)` in the AST.

```
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

Where `_` matches a single node, `...` eagerly matches one or more subsequent nodes.

It's useful when you want to check some variable internal nodes but with a
final with the same results. For example, let's use a classic `sum(1,2)`.

We can also have `sum(1,2,3,n)` and the arguments can vary. The objective is
match all. So, let's check how it looks like in the AST:

```
$ ruby-parse -e 'sum(1,2)'
(send nil :sum
  (int 1)
  (int 2))
```

Or with more children:

```
$ ruby-parse -e 'sum(1,2,3,n)'
(send nil :sum
  (int 1)
  (int 2)
  (int 3)
  (send nil :n))
```

The first case can be addressed with an expression like:

```
(send nil? :sum ...)
```

## `{}` for any `<expression>`

Lets make it a bit more complex and introduce floats:

```
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

It will return an array with `[:int, 1]` for a tuple like (int 1).
The tuple can be entirely captured using the `$` before the open parens:

```
$({int float} _)
```

Or remove the parens and match directly from node head:

```
${int float}
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

## `[]` for or `<expression>`

Imagine you want to check if the number is `odd?` and also not `zero?`:

`(int [odd? !zero?])` - is an int and the value should be odd and not zero.

Sometimes, we want to add an extra logic. Let's imagine we're searching for
prime numbers, so we have a method to define it:

```ruby
def prime?(n)
  if n <= 1
    false
  elsif n == 2
    true
  else
    (2..n/2).none? { |i| n % i == 0}
  end
end
```

We can incorporate this using `#prime?` in the expression:

```
(int [odd? !zero? #prime?])
```

It will match only `odd?`, non zero and prime numbers.

## Using node matcher macros

The RuboCop base includes two useful methods to use the node pattern with Ruby in a
simple way. You can use the macros to define methods. The basics are
[def_node_matcher](http://www.rubydoc.info/github/bbatsov/RuboCop/RuboCop/NodePattern/Macros#def_node_matcher-instance_method)
and [def_node_search](http://www.rubydoc.info/github/bbatsov/RuboCop/RuboCop/NodePattern/Macros#def_node_search-instance_method).

When you define a pattern, it creates a method that accepts a node and tries to match.

Lets create an example where we're trying to find the symbols `user` and
`current_user` in expressions like: `user: current_user` or
`current_user: User.first`, so the objective here is pick all keys:

```
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

```
$ ruby-parse -e 'Comment.new(user: current_user)'
(send
  (const nil :Comment) :new
  (hash
    (pair
      (sym :user)
      (send nil :current_user))))
```

And we can also reuse this and check if it's a constructor:

```
def_node_matcher :initializing_with_user?, <<~PATTERN
  (send ... :new (hash (pair #user_symbol?)))
PATTERN
```

Improving a bit more, let's make it accepts `update`, and `create`.

Instead of make our call more complex, we can define another matcher:

```ruby
def_node_matcher :model_methods?, '{:new :create :update}'
```

And combine again:

```ruby
def_node_matcher :model_method_called_with_user?, <<~PATTERN
  (send ... #model_methods? (hash (pair #user_symbol?)))
PATTERN
```

## `nil` or `nil?`

Take a special attention to nil behavior:

```
$ ruby-parse -e 'nil'
(nil)
```
In this case, the `nil` implicit matches with expressions like: `nil` or `(nil)` or `nil_type?`.

But, nil is also used to represent a call from `nothing` from a simple method call:

```
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
[documentation](http://www.rubydoc.info/gems/rubocop/RuboCop/NodePattern)
or you can go directly and hack the
[source code](https://github.com/bbatsov/rubocop/blob/master/lib/rubocop/node_pattern.rb).

The [specs](https://github.com/bbatsov/rubocop/blob/master/spec/rubocop/node_pattern_spec.rb)
are also very useful to comprehend each feature.

