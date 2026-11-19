# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::InvalidNodePattern, :config do
  it 'registers an offense for a node type that does not exist' do
    expect_offense(<<~RUBY)
      def_node_matcher :my_matcher, '(sned nil? :foo)'
                                      ^^^^ Unknown node type `sned`.
    RUBY
  end

  it 'registers an offense for a sequence with the wrong number of children' do
    expect_offense(<<~RUBY)
      def_node_matcher :my_matcher, '(def _name _args)'
                                     ^^^^^^^^^^^^^^^^^ `def` nodes have 3 children, not 2.
    RUBY
  end

  it 'registers an offense for a value where a node of that type has a node' do
    expect_offense(<<~RUBY)
      def_node_matcher :my_matcher, '(pair :foo _)'
                                           ^^^^ This never matches child 1 of `pair` nodes, which is a node.
    RUBY
  end

  it 'registers an offense for a node where a node of that type has a value' do
    expect_offense(<<~RUBY)
      def_node_search :my_matcher, '(send _ (sym :foo))'
                                            ^^^^^^^^^^ This never matches child 2 of `send` nodes, which is a symbol.
    RUBY
  end

  it 'registers an offense for a predicate that nothing responds to' do
    expect_offense(<<~RUBY)
      def_node_matcher :my_matcher, '(send _ :foo frobnicate?)'
                                                  ^^^^^^^^^^^ Neither a node nor a child of one responds to `frobnicate?`.
    RUBY
  end

  it 'registers an offense for an alternative that is in a union twice' do
    expect_offense(<<~RUBY)
      def_node_matcher :my_matcher, '(send _ {:foo :bar :foo})'
                                             ^^^^^^^^^^^^^^^^ `:foo` is in the union more than once.
    RUBY
  end

  it 'registers an offense in a heredoc' do
    expect_offense(<<~RUBY)
      def_node_matcher :my_matcher, <<~PATTERN
        (send
          (str :foo) :bar) # comment
               ^^^^ This never matches child 1 of `str` nodes, which is a string.
      PATTERN
    RUBY
  end

  it 'registers an offense that spans lines' do
    expect_offense(<<~RUBY)
      def_node_matcher :my_matcher, <<~PATTERN
        (send nil? :foo
          (pair
          ^^^^^ `pair` nodes have 2 children, not 1.
            _))
      PATTERN
    RUBY
  end

  it 'registers all the offenses of a pattern' do
    expect_offense(<<~RUBY)
      def_node_matcher :my_matcher, '{(frob ...) (int)}'
                                                 ^^^^^ `int` nodes have 1 child, not 0.
                                       ^^^^ Unknown node type `frob`.
    RUBY
  end

  it 'registers an offense in a string with other delimiters' do
    expect_offense(<<~RUBY)
      def_node_matcher :my_matcher, %q[(true _)]
                                       ^^^^^^^^ `true` nodes have no children, not 1.
    RUBY
  end

  it 'does not register an offense for a pattern that can match' do
    expect_no_offenses(<<~RUBY)
      def_node_matcher :my_matcher, <<~PATTERN
        (send {nil? (const {nil? cbase} :Foo)} ${:bar :baz} (hash <(pair (sym :qux) $_) ...>))
      PATTERN
      def_node_search :my_search, '(any_block (send nil? :foo) _ nil?)'
    RUBY
  end

  it 'does not register an offense for a pattern with interpolation' do
    expect_no_offenses(<<~'RUBY')
      def_node_matcher :my_matcher, <<~PATTERN
        (def #{NAME} _)
      PATTERN
      def_node_matcher :my_matcher, "(def #{NAME} _)"
    RUBY
  end

  it 'does not register an offense for a string whose value is not its source' do
    expect_no_offenses(<<~'RUBY')
      def_node_matcher :my_matcher, "(def\t_ _)"
    RUBY
  end

  it 'does not register an offense for a pattern that is not valid' do
    expect_no_offenses(<<~RUBY)
      def_node_matcher :my_matcher, '(def _ _'
    RUBY
  end

  it 'does not register an offense when there is no pattern' do
    expect_no_offenses(<<~RUBY)
      def_node_matcher :my_matcher
      def_node_matcher :my_matcher, PATTERN
    RUBY
  end
end
