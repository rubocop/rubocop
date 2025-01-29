# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::NodeTypeMultiplePredicates, :config do
  context 'in an `or` node with multiple node type predicate branches' do
    it 'does not register an offense for type predicates called without a receiver' do
      expect_no_offenses(<<~RUBY)
        str_type? || sym_type?
      RUBY
    end

    it 'does not register an offense for type predicates called with different receivers' do
      expect_no_offenses(<<~RUBY)
        foo.str_type? || bar.sym_type?
      RUBY
    end

    it 'does not register an offense when all method calls are not type predicates' do
      expect_no_offenses(<<~RUBY)
        foo.bar? || foo.sym_type?
      RUBY
    end

    it 'does not register an offense for negated predicates' do
      expect_no_offenses(<<~RUBY)
        !node.str_type? || !node.sym_type?
      RUBY
    end

    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        node.str_type? || node.sym_type?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.type?(:str, :sym)` instead of checking for multiple node types.
      RUBY

      expect_correction(<<~RUBY)
        node.type?(:str, :sym)
      RUBY
    end

    it 'registers an offense and corrects with `defined_type?`' do
      expect_offense(<<~RUBY)
        node.call_type? || node.defined_type?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.type?(:call, :defined?)` instead of checking for multiple node types.
      RUBY

      expect_correction(<<~RUBY)
        node.type?(:call, :defined?)
      RUBY
    end

    it 'registers an offense and corrects for nested `or` nodes' do
      expect_offense(<<~RUBY)
        node.str_type? || node.sym_type? || node.boolean_type?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.type?(:str, :sym)` instead of checking for multiple node types.
      RUBY

      expect_correction(<<~RUBY)
        node.type?(:str, :sym, :boolean)
      RUBY
    end

    it 'registers an offense and corrects when the LHS is a `type?` call' do
      expect_offense(<<~RUBY)
        node.type?(:str, :sym) || node.boolean_type?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.type?(:str, :sym, :boolean)` instead of checking for multiple node types.
      RUBY

      expect_correction(<<~RUBY)
        node.type?(:str, :sym, :boolean)
      RUBY
    end

    it 'registers an offense and corrects when the RHS is a `type?` call' do
      expect_offense(<<~RUBY)
        node.boolean_type? || node.type?(:str, :sym)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.type?(:boolean, :str, :sym)` instead of checking for multiple node types.
      RUBY

      expect_correction(<<~RUBY)
        node.type?(:boolean, :str, :sym)
      RUBY
    end

    it 'registers an offense and corrects with safe navigation' do
      expect_offense(<<~RUBY)
        node&.str_type? || node&.sym_type?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node&.type?(:str, :sym)` instead of checking for multiple node types.
      RUBY

      expect_correction(<<~RUBY)
        node&.type?(:str, :sym)
      RUBY
    end
  end

  context 'in an `and` node with multiple negated type predicate branches' do
    it 'does not register an offense for type predicates called without a receiver' do
      expect_no_offenses(<<~RUBY)
        !str_type? && !sym_type?
      RUBY
    end

    it 'does not register an offense for type predicates called with different receivers' do
      expect_no_offenses(<<~RUBY)
        !foo.str_type? && !bar.sym_type?
      RUBY
    end

    it 'does not register an offense when all method calls are not type predicates' do
      expect_no_offenses(<<~RUBY)
        !foo.bar? && !foo.sym_type?
      RUBY
    end

    it 'does not register an offense for type predicates called without negation' do
      expect_no_offenses(<<~RUBY)
        node.str_type? && node.sym_type?
      RUBY
    end

    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        !node.str_type? && !node.sym_type?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `!node.type?(:str, :sym)` instead of checking against multiple node types.
      RUBY

      expect_correction(<<~RUBY)
        !node.type?(:str, :sym)
      RUBY
    end

    it 'registers an offense and corrects with `defined_type?`' do
      expect_offense(<<~RUBY)
        !node.call_type? && !node.defined_type?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `!node.type?(:call, :defined?)` instead of checking against multiple node types.
      RUBY

      expect_correction(<<~RUBY)
        !node.type?(:call, :defined?)
      RUBY
    end

    it 'registers an offense and corrects for nested `and` nodes' do
      expect_offense(<<~RUBY)
        !node.str_type? && !node.sym_type? && !node.boolean_type?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `!node.type?(:str, :sym)` instead of checking against multiple node types.
      RUBY

      expect_correction(<<~RUBY)
        !node.type?(:str, :sym, :boolean)
      RUBY
    end

    it 'registers an offense and corrects when the LHS is a `type?` call' do
      expect_offense(<<~RUBY)
        !node.type?(:str, :sym) && !node.boolean_type?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `!node.type?(:str, :sym, :boolean)` instead of checking against multiple node types.
      RUBY

      expect_correction(<<~RUBY)
        !node.type?(:str, :sym, :boolean)
      RUBY
    end

    it 'registers an offense and corrects when the RHS is a `type?` call' do
      expect_offense(<<~RUBY)
        !node.boolean_type? && !node.type?(:str, :sym)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `!node.type?(:boolean, :str, :sym)` instead of checking against multiple node types.
      RUBY

      expect_correction(<<~RUBY)
        !node.type?(:boolean, :str, :sym)
      RUBY
    end

    it 'registers an offense and corrects with safe navigation' do
      expect_offense(<<~RUBY)
        !node&.str_type? && !node&.sym_type?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `!node&.type?(:str, :sym)` instead of checking against multiple node types.
      RUBY

      expect_correction(<<~RUBY)
        !node&.type?(:str, :sym)
      RUBY
    end
  end
end
