## Add a new cop

Use a rake task to generate a cop template.

```sh
$ bundle exec rake new_cop[Department/Name]
Files created:
  - lib/rubocop/cop/department/name.rb
  - spec/rubocop/cop/department/name_spec.rb
File modified:
  - `require_relative 'rubocop/cop/department/name'` added into lib/rubocop.rb
  - A configuration for the cop is added into config/enabled.yml
    - If you want to disable the cop by default, move the added config to config/disabled.yml

Do 3 steps:
  1. Add an entry to the "New features" section in CHANGELOG.md,
     e.g. "Add new `Department/Name` cop. ([@your_id][])"
  2. Modify the description of Department/Name in config/enabled.yml
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
$ ruby-parse -e 'name = "John"'
(lvasgn :name
  (str "John"))
```

### Inspecting the AST representation

Let's imagine we want to simplify statements from `!array.empty?` to
`array.any?`:

First, check what the bad code returns in the Abstract Syntax Tree
representation.

```sh
$ ruby-parse -e '!array.empty?'
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

You can learn more about Node Pattern [here](https://rubocop.readthedocs.io/en/latest/node_pattern/).

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

### Configuration

Each cop can hold a configuration and you can refer to `cop_config` in the
instance and it will bring a hash with options declared in the `.rubocop.yml`
file.

For example, lets imagine we want to make configurable to make the replacement
works with other method than `.any?`:

```yml
Style/SimplifyNotEmptyWithAny:
  Enabled: true
  ReplaceAnyWith: "size > 0"
```

And then on the autocorrect method, you just need to use the `cop_config` it:

```ruby
def autocorrect(node)
  lambda do |corrector|
    internal_expression = node.children[0].children[0].source
    replacement = cop_config['ReplaceAnyWith'] || "any?"
    new_expression = "#{internal_expression}.#{replacement}"
    corrector.replace(node.loc.expression, new_expression)
  end
end
```

### Documentation

Every new cop requires explanation and examples to make it easy for the community
to understand its purpose. This documentation is generated by `yard` and is added
directly into the `cop.rb` file. For every `SupportedStyle` and unique
configuration you have included in the cop, there needs to be examples. Examples must
have valid Ruby syntax. Do not use upticks.

```ruby
module Department
  # Description of your cop. Include description of ALL config options. Particularly
  # ones that take booleans and arrays, because we generally do not show examples for
  # configs with these value types.
  #
  # @example EnforcedStyle: bar
  #    # Description about this particular option
  #
  #    # bad
  #    bad_example1
  #    bad_example2
  #
  #    # good
  #    good_example1
  #    good_example2
  #
  # @example EnforcedStyle: foo (default)
  #    # Description about this particular option
  #
  #    # bad
  #    bad_example1
  #    bad_example2
  #
  #    # good
  #    good_example1
  #    good_example2
  #
  # @example AnyUniqueConfigKeyThatIsAString: qux (default)
  #    # Description about this particular option
  #
  #    # bad
  #    bad_example1
  #    bad_example2
  #
  #    # good
  #    good_example1
  #    good_example2
  #
  # @example AnyUniqueConfigKeyThatIsAString: thud
  #    # Description about this particular option
  #
  #    # bad
  #    bad_example1
  #    bad_example2
  #
  #    # good
  #    good_example1
  #    good_example2
  #
  class YourCop
    # ...
```

Take note of the placement and spacing of all the documentation pieces. Such as config
keys being in alphabetical order, the `(default)` being specified, and one empty line
before `class YourCop`. While not all examples in the codebase follow this exact format,
we strive to make this consistent. PRs improving RuboCop documentation are very welcome.

Run `rake generate_cops_documentation` to apply your `yard` documentation into the manual.
CI will fail if the manual and `yard` comments do not match exactly. `rake default` and
`rake parralel` will also generate the new documentation.

### Testing your cop in a real codebase

Generally, is a good practice to check if your cop is working properly over a
huge codebase to guarantee it's working in a range of different syntaxes.

To make it fast and do not get confused with other cops in action,  you can use
`--only` parameter in the command line to filter by your cop name:

```sh
rubocop --only Style/SimplifyNotEmptyWithAny
```

In the end, do not forget to run `rake generate_cops_documentation` to update
the docs.
