# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::NodeMatcherDirective, :config do
  %i[def_node_matcher def_node_search].each do |method|
    it 'does not register an offense if the node matcher already has a directive' do
      expect_no_offenses(<<~RUBY)
        # @!method foo?(node)
        #{method} :foo?, '(str)'
      RUBY
    end

    it 'does not register an offense if the directive is in a comment block' do
      expect_no_offenses(<<~RUBY)
        # @!method foo?(node)
        # foo? matcher
        #{method} :foo?, '(str)'
      RUBY
    end

    it 'registers an offense if the matcher does not have a directive' do
      expect_offense(<<~RUBY, method: method)
        #{method} :foo?, '(str)'
        ^{method}^^^^^^^^^^^^^^^ Precede `#{method}` with a `@!method` YARD directive.
      RUBY

      expect_correction(<<~RUBY)
        # @!method foo?(node)
        #{method} :foo?, '(str)'
      RUBY
    end

    it 'registers an offense if the matcher does not have a directive and a method call is used for a pattern argument' do
      expect_offense(<<~RUBY, method: method)
        #{method} :foo?, format(PATTERN, type: 'const')
        ^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Precede `#{method}` with a `@!method` YARD directive.
      RUBY

      expect_correction(<<~RUBY)
        # @!method foo?(node)
        #{method} :foo?, format(PATTERN, type: 'const')
      RUBY
    end

    it 'registers an offense if the matcher does not have a directive but has preceding comments' do
      expect_offense(<<~RUBY, method: method)
        # foo
        #{method} :foo?, '(str)'
        ^{method}^^^^^^^^^^^^^^^ Precede `#{method}` with a `@!method` YARD directive.

        # foo bar baz
        # foo bar baz
        # foo bar baz
        #{method} :bar?, '(sym)'
        ^{method}^^^^^^^^^^^^^^^ Precede `#{method}` with a `@!method` YARD directive.
      RUBY

      expect_correction(<<~RUBY)
        # foo
        # @!method foo?(node)
        #{method} :foo?, '(str)'

        # foo bar baz
        # foo bar baz
        # foo bar baz
        # @!method bar?(node)
        #{method} :bar?, '(sym)'
      RUBY
    end

    it 'registers an offense if the directive name does not match the actual name' do
      expect_offense(<<~RUBY, method: method)
        # @!method bar?(node)
        #{method} :foo?, '(str)'
        ^{method}^^^^^^^^^^^^^^^ `@!method` YARD directive has invalid method name, use `foo?` instead of `bar?`.
      RUBY

      expect_correction(<<~RUBY)
        # @!method foo?(node)
        #{method} :foo?, '(str)'
      RUBY
    end

    it 'registers an offense if the matcher has multiple directives' do
      expect_offense(<<~RUBY, method: method)
        # @!method foo?(node)
        # @!method foo?(node)
        #{method} :foo?, '(str)'
        ^{method}^^^^^^^^^^^^^^^ Multiple `@!method` YARD directives found for this matcher.
      RUBY

      expect_no_corrections
    end

    it 'autocorrects with the right arguments if the pattern includes arguments' do
      expect_offense(<<~RUBY, method: method)
        #{method} :foo?, '(str %1)'
        ^{method}^^^^^^^^^^^^^^^^^^ Precede `#{method}` with a `@!method` YARD directive.
      RUBY

      expect_correction(<<~RUBY)
        # @!method foo?(node, arg1)
        #{method} :foo?, '(str %1)'
      RUBY
    end

    it 'autocorrects with the right arguments if the pattern references a non-contiguous argument' do
      expect_offense(<<~RUBY, method: method)
        #{method} :foo?, '(str %4)'
        ^{method}^^^^^^^^^^^^^^^^^^ Precede `#{method}` with a `@!method` YARD directive.
      RUBY

      expect_correction(<<~RUBY)
        # @!method foo?(node, arg1, arg2, arg3, arg4)
        #{method} :foo?, '(str %4)'
      RUBY
    end

    it 'does not register an offense if called with a dynamic method name' do
      expect_no_offenses(<<~'RUBY')
        #{method} matcher_name, '(str)'
        #{method} "#{matcher_name}", '(str)'
      RUBY
    end

    it 'retains indentation properly when inserting' do
      expect_offense(<<~RUBY, method: method)
        class MyCop
          #{method} :foo?, '(str)'
          ^{method}^^^^^^^^^^^^^^^ Precede `#{method}` with a `@!method` YARD directive.
        end
      RUBY

      expect_correction(<<~RUBY)
        class MyCop
          # @!method foo?(node)
          #{method} :foo?, '(str)'
        end
      RUBY
    end

    it 'retains indentation properly when correcting' do
      expect_offense(<<~RUBY, method: method)
        class MyCop
          # @!method bar?(node)
          #{method} :foo?, '(str)'
          ^{method}^^^^^^^^^^^^^^^ `@!method` YARD directive has invalid method name, use `foo?` instead of `bar?`.
        end
      RUBY

      expect_correction(<<~RUBY)
        class MyCop
          # @!method foo?(node)
          #{method} :foo?, '(str)'
        end
      RUBY
    end

    it 'inserts a blank line between multiple pattern matchers' do
      expect_offense(<<~RUBY, method: method)
        #{method} :foo?, '(str)'
        ^{method}^^^^^^^^^^^^^^^ Precede `#{method}` with a `@!method` YARD directive.
        #{method} :bar?, '(str)'
        ^{method}^^^^^^^^^^^^^^^ Precede `#{method}` with a `@!method` YARD directive.
      RUBY

      expect_correction(<<~RUBY)
        # @!method foo?(node)
        #{method} :foo?, '(str)'

        # @!method bar?(node)
        #{method} :bar?, '(str)'
      RUBY
    end

    it 'inserts a blank line between multiple multi-line pattern matchers' do
      expect_offense(<<~RUBY, method: method)
        #{method} :foo?, <<~PATTERN
        ^{method}^^^^^^^^^^^^^^^^^^ Precede `#{method}` with a `@!method` YARD directive.
          (str)
        PATTERN
        #{method} :bar?, <<~PATTERN
        ^{method}^^^^^^^^^^^^^^^^^^ Precede `#{method}` with a `@!method` YARD directive.
          (str)
        PATTERN
      RUBY

      expect_correction(<<~RUBY)
        # @!method foo?(node)
        #{method} :foo?, <<~PATTERN
          (str)
        PATTERN

        # @!method bar?(node)
        #{method} :bar?, <<~PATTERN
          (str)
        PATTERN
      RUBY
    end

    it 'does not insert a blank line if one already exists' do
      expect_offense(<<~RUBY, method: method)
        #{method} :foo?, <<~PATTERN
        ^{method}^^^^^^^^^^^^^^^^^^ Precede `#{method}` with a `@!method` YARD directive.
          (str)
        PATTERN

        #{method} :bar?, <<~PATTERN
        ^{method}^^^^^^^^^^^^^^^^^^ Precede `#{method}` with a `@!method` YARD directive.
          (str)
        PATTERN
      RUBY

      expect_correction(<<~RUBY)
        # @!method foo?(node)
        #{method} :foo?, <<~PATTERN
          (str)
        PATTERN

        # @!method bar?(node)
        #{method} :bar?, <<~PATTERN
          (str)
        PATTERN
      RUBY
    end
  end
end
