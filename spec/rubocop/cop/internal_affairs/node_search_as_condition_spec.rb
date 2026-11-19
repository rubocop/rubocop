# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::NodeSearchAsCondition, :config do
  it 'registers an offense when a search is the condition of a modifier `unless`' do
    expect_offense(<<~RUBY)
      def_node_search :assignments, '(lvasgn ...)'

      def on_def(node)
        return unless assignments(node)
                      ^^^^^^^^^^^^^^^^^ `assignments` returns an enumerator, which is always truthy. Use `assignments(...).any?`, or define the search with a name that ends in `?`.
      end
    RUBY
  end

  it 'registers an offense when a search is the condition of an `if`' do
    expect_offense(<<~RUBY)
      def_node_search :assignments, '(lvasgn ...)'

      def on_def(node)
        if assignments(node)
           ^^^^^^^^^^^^^^^^^ `assignments` returns an enumerator, which is always truthy. Use `assignments(...).any?`, or define the search with a name that ends in `?`.
          add_offense(node)
        end
      end
    RUBY
  end

  it 'registers an offense when a search is the left operand of `&&`' do
    expect_offense(<<~RUBY)
      def_node_search :assignments, '(lvasgn ...)'

      def offense?(node)
        assignments(node) && node.arguments?
        ^^^^^^^^^^^^^^^^^ `assignments` returns an enumerator, which is always truthy. Use `assignments(...).any?`, or define the search with a name that ends in `?`.
      end
    RUBY
  end

  it 'registers an offense when a search is negated' do
    expect_offense(<<~RUBY)
      def_node_search :assignments, '(lvasgn ...)'

      def offense?(node)
        !assignments(node)
         ^^^^^^^^^^^^^^^^^ `assignments` returns an enumerator, which is always truthy. Use `assignments(...).any?`, or define the search with a name that ends in `?`.
      end
    RUBY
  end

  it 'registers an offense when the search is defined after it is used' do
    expect_offense(<<~RUBY)
      def on_def(node)
        return if assignments(node)
                  ^^^^^^^^^^^^^^^^^ `assignments` returns an enumerator, which is always truthy. Use `assignments(...).any?`, or define the search with a name that ends in `?`.
      end

      def_node_search :assignments, '(lvasgn ...)'
    RUBY
  end

  it 'does not register an offense when the name of the search ends in `?`' do
    expect_no_offenses(<<~RUBY)
      def_node_search :assignments?, '(lvasgn ...)'

      def on_def(node)
        return unless assignments?(node)
      end
    RUBY
  end

  it 'does not register an offense when what the search returns is used' do
    expect_no_offenses(<<~RUBY)
      def_node_search :assignments, '(lvasgn ...)'

      def on_def(node)
        return unless assignments(node).any?
        return if assignments(node).count > 1

        assignments(node) { |assignment| add_offense(assignment) }
        assignments(node, &block)
        found = assignments(node)
        node.arguments? && assignments(node)
      end
    RUBY
  end

  it 'does not register an offense for a matcher' do
    expect_no_offenses(<<~RUBY)
      def_node_matcher :assignment, '(lvasgn $_ _)'

      def on_lvasgn(node)
        return unless assignment(node)
      end
    RUBY
  end

  it 'does not register an offense for a method that is not a search of the file' do
    expect_no_offenses(<<~RUBY)
      def on_def(node)
        return unless assignments(node)
      end
    RUBY
  end
end
