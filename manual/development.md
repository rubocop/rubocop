## Add a new cop

Use a rake task to generate a cop template.

```sh
$ bundle exec rake new_cop[Department/Name]
Files created:
  - lib/rubocop/cop/department/name.rb
  - spec/rubocop/cop/department/name_spec.rb
File modified:
  - `require 'rubocop/cop/department/name_cop'` added into lib/rubocop.rb

Do 3 steps:
  1. Add an entry to the "New features" section in CHANGELOG.md,
     e.g. "Add new `Department/Name` cop. ([@your_id][])"
  2. Add an entry into config/enabled.yml or config/disabled.yml
  3. Implement your new cop in the generated file!
```

## Implementing the cop

You can start by learning the
[node pattern](http://www.rubydoc.info/gems/rubocop/RuboCop/NodePattern)
and using the pattern to match with specific nodes that you want to match.

If you're not familiar with node pattern, try to investigate how it goes by
creating a few examples with code that you want to match. Let's start with a
simple cop to simplify conditions with arrays:

### Inspecting the AST representation

Let's imagine we want to simplify statements from `!array.empty?` to
`array.any?`:

First, check what the bad code returns in the Abstract Syntax Tree
representation. Let's debug our expression using the REPL from RuboCop:

```sh
$ rake repl
```

Now, we need to create an AST representation to match with it:


```ruby
code = '!something.empty?'
source = RuboCop::ProcessedSource.new(code, RUBY_VERSION.to_f)
node = source.ast
# => s(:send, s(:send, s(:send, nil, :something), :empty?), :!)
```

### Writing rules for node pattern matches:

Node pattern matches something very similar to what is on the node
representation, then let's start with something very generic:

```ruby
NodePattern.new('send').match(node) # => true
```

It matches because the root is a `send` type. Now lets match it deeply:

```ruby
NodePattern.new('(send ...)').match(node) # => true
NodePattern.new('(send (send ...) :!)').match(node) # => true
NodePattern.new('(send (send (send ...) :empty?) :!)').match(node) # => true
```

It's not needed to strictly receive a send in the internal node because maybe 
it can also be a literal array like:

```ruby
![].empty?
```

The code above has the following representation:

```ruby
=> s(:send, s(:send, s(:array), :empty?), :!)
```

It's possible to skip the internal node with `...` to make sure that it's just
another internal node:

```ruby
NodePattern.new('(send (send (...) :empty?) :!)').match(node) # => true
```

In other words, it says: "Match code calling `!<expression>.empty?`".

Great! Now, lets implement our cop to simplifly such statements:

```sh
$ rake new_cop[Style/SimplifyNotEmptyWithAny]
```

After the cop scaffold is generated, change the node matcher to match with
the expression achieved previously:

```ruby
def_node_matcher :not_empty_call?, <<-PATTERN
  (send (send (...) :empty?) :!)
PATTERN
```

As it starts with a `send` type, it's needed to implement the `on_send` method, as the
cop scaffold already suggested:

```ruby
def on_send(node)
  return unless not_empty_call?(node)
  add_offense(node)
end
```

And the final cop code will look like something like this:

```ruby
module RuboCop
  module Cop
    module Style
      # `array.any?` is a simplified way to say `!array.empty?`
      #
      # @example
      #   # bad
      #   !array.empty?
      #
      #   # good
      #   array.any?
      class SimplifyNotEmptyWithAny < Cop
        MSG = 'Use `.any?` and remove the negation part.'.freeze

        def_node_matcher :not_empty_call?, <<-PATTERN
          (send (send (...) :empty?) :!)
        PATTERN

        def on_send(node)
          return unless not_empty_call?(node)
          add_offense(node)
        end
      end
    end
  end
end
```

Update the spec to cover the expected syntax:

```ruby
describe RuboCop::Cop::Style::SimplifyNotEmptyWithAny do
  let(:config) { RuboCop::Config.new }
  subject(:cop) { described_class.new(config) }

  it 'registers an offense when using `!a.empty?`' do
    expect_offense(<<-RUBY.strip_indent)
      !array.empty?
      ^^^^^^^^^^^^^ Use `.any?` and remove the negation part.
    RUBY
  end

  it 'does not register an offense when using `.any?` or `.empty?`' do
    expect_no_offenses(<<-RUBY.strip_indent)
      array.any?
      array.empty?
    RUBY
  end
end
```

### Autocorrect feature

The autocorrect can help humans automatically fixing offenses earlier detected.
It's necessary to define the `autocorrect` method that returns a lambda 
[rewriter](https://github.com/whitequark/parser/blob/master/lib/parser/rewriter.rb)
with the corrector where you can give instructions about what to do with the
offensive node.

Let's start with a simple spec to cover it:

```ruby
it 'autocorrect `!a.empty?` to `a.any?` ' do
  expect(autocorrect_source('!a.empty?')).to eq('a.any?')
end
```

And then define the `autocorrect` method on the cop side:

```ruby
def autocorrect(node)
  lambda do |corrector|
    internal_expression = node.children[0].children[0].source
    corrector.replace(node.loc.expression, "#{internal_expression}.any?")
  end
end
```

The corrector allows you to `insert_after` and `insert_before` or
`replace` in a specific range of the code.

The range can be determined on `node.location` where it brings specific
ranges for expression or other internal information that the node holds.

In the end, don't forget to run `rake generate_cops_documentation` to update
the docs.
