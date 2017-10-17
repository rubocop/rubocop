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

RuboCop uses [parser](https://github.com/whitequark/parser) to create the
Abstract Syntax Tree representation of the code.

You can install `parser` gem and use `ruby-parse` command line utility to check
what the AST looks like in the output.

```sh
$ gem install parser
```

And then try to parse a simple integer representation with `ruby-parse`:

```sh
$ ruby-parse -e '1'
(int 1)
```

Each expression surrounded by parens represents a node. The first
element is the node type and the tail contains the children with all
information needed to represent the code.

Another example of a local variable `name` being assigned with the "John"
string value:

```sh
$ ruby-parse -e 'name = "John"'                                                                                                                09:45:59
(lvasgn :name
  (str "John"))
```

### Inspecting the AST representation

Let's imagine we want to simplify statements from `!array.empty?` to
`array.any?`:

First, check what the bad code returns in the Abstract Syntax Tree
representation.

```sh
$ ruby-parse -e '!array.empty?                                                                                                                 12:59:47
(send
  (send
    (send nil :array) :empty?) :!)
```

Now, it's time to debug our expression using the REPL from RuboCop:

```sh
$ rake repl
```

First we need to declare the code that we want to match, and use the
[ProcessedSource](http://www.rubydoc.info/gems/rubocop/RuboCop/ProcessedSource)
that is a simple wrap to make the parser interpret the code and build the AST:

```ruby
code = '!something.empty?'
source = RuboCop::ProcessedSource.new(code, RUBY_VERSION.to_f)
node = source.ast
# => s(:send, s(:send, s(:send, nil, :something), :empty?), :!)
```

The node has a few attributes that can be useful in the journey:

```ruby
node.type # => :send
node.children # => [s(:send, s(:send, nil, :something), :empty?), :!]
node.source # => "!something.empty?"
```

### Writing rules to make node pattern matches:

Now that you're familiar with AST, you can learn a bit about the
[node pattern](http://www.rubydoc.info/gems/rubocop/RuboCop/NodePattern)
and use patterns to match with specific nodes that you want to match.

Node pattern matches something very similar to the current output from AST
representation, then let's start with something very generic:

```ruby
NodePattern.new('send').match(node) # => true
```

It matches because the root is a `send` type. Now lets match it deeply using
parens to define details for sub-nodes. If you don't care about what a internal
node is, you can use `...` to skip it and just consider " a node".

```ruby
NodePattern.new('(send ...)').match(node) # => true
NodePattern.new('(send (send ...) :!)').match(node) # => true
NodePattern.new('(send (send (send ...) :empty?) :!)').match(node) # => true
```

Sometimes it's hard to comprehend complex expressions you're building with the
pattern, then, if you got lost with the node pattern parens surrounding deeply,
try to use the `$` to capture the internal expression and check exactly each
piece of the expression:

```ruby
NodePattern.new('(send (send (send $...) :empty?) :!)').match(node) # => [nil, :something]
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
