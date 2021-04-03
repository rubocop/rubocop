# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::MultilineAssignmentLayout, :config do
  let(:supported_types) { %w[if] }

  let(:cop_config) { { 'EnforcedStyle' => enforced_style, 'SupportedTypes' => supported_types } }

  context 'new_line style' do
    let(:enforced_style) { 'new_line' }

    it 'registers an offense when the rhs is on the same line' do
      expect_offense(<<~RUBY)
        blarg = if true
        ^^^^^^^^^^^^^^^ Right hand side of multi-line assignment is on the same line as the assignment operator `=`.
        end
      RUBY

      expect_correction(<<~RUBY)
        blarg =
         if true
        end
      RUBY
    end

    it 'registers an offense when the rhs is on the same line in []=' do
      expect_offense(<<~RUBY)
        hash[:foo] = if true
        ^^^^^^^^^^^^^^^^^^^^ Right hand side of multi-line assignment is on the same line as the assignment operator `=`.
        end
      RUBY

      expect_correction(<<~RUBY)
        hash[:foo] =
         if true
        end
      RUBY
    end

    it 'registers an offense when the rhs is on the same line in setters' do
      expect_offense(<<~RUBY)
        foo.bar = if true
        ^^^^^^^^^^^^^^^^^ Right hand side of multi-line assignment is on the same line as the assignment operator `=`.
        end
      RUBY

      expect_correction(<<~RUBY)
        foo.bar =
         if true
        end
      RUBY
    end

    it 'ignores arrays' do
      expect_no_offenses(<<~RUBY)
        a, b = 4,
        5
      RUBY
    end

    context 'configured supported types' do
      let(:supported_types) { %w[array] }

      it 'allows supported types to be configured' do
        expect_offense(<<~RUBY)
          a, b = 4,
          ^^^^^^^^^ Right hand side of multi-line assignment is on the same line as the assignment operator `=`.
          5
        RUBY
      end
    end

    it 'allows multi-line assignments on separate lines' do
      expect_no_offenses(<<~RUBY)
        blarg=
        if true
        end
      RUBY
    end

    it 'registers an offense for masgn with multi-line lhs' do
      expect_offense(<<~RUBY)
        a,
        ^^ Right hand side of multi-line assignment is on the same line as the assignment operator `=`.
        b = if foo
        end
      RUBY
    end

    context 'when supported types is block' do
      let(:supported_types) { %w[block] }

      it 'registers an offense when multi-line assignments ' \
         'using block definition is on the same line' do
        expect_offense(<<~RUBY)
          lambda = -> {
          ^^^^^^^^^^^^^ Right hand side of multi-line assignment is on the same line as the assignment operator `=`.
            puts 'hello'
          }
        RUBY
      end

      it 'allows multi-line assignments when using block definition on separate lines' do
        expect_no_offenses(<<~RUBY)
          lambda =
            -> {
              puts 'hello'
            }
        RUBY
      end

      it 'allows multi-line block defines on separate lines' do
        expect_no_offenses(<<~RUBY)
          default_scope -> {
            where(foo: "bar")
          }
        RUBY
      end

      it 'allows multi-line assignments when using shovel operator' do
        expect_no_offenses(<<~'RUBY')
          foo << items.map do |item|
            "#{item}!"
          end
        RUBY
      end
    end
  end

  context 'same_line style' do
    let(:enforced_style) { 'same_line' }

    it 'registers an offense when the rhs is a different line' do
      expect_offense(<<~RUBY)
        blarg =
        ^^^^^^^ Right hand side of multi-line assignment is not on the same line as the assignment operator `=`.
        if true
        end
      RUBY

      expect_correction(<<~RUBY)
        blarg = if true
        end
      RUBY
    end

    it 'registers an offense when the rhs is a different line in []=' do
      expect_offense(<<~RUBY)
        hash[:foo] =
        ^^^^^^^^^^^^ Right hand side of multi-line assignment is not on the same line as the assignment operator `=`.
        if true
        end
      RUBY

      expect_correction(<<~RUBY)
        hash[:foo] = if true
        end
      RUBY
    end

    it 'registers an offense when the rhs is a different line in setters' do
      expect_offense(<<~RUBY)
        foo.bar =
        ^^^^^^^^^ Right hand side of multi-line assignment is not on the same line as the assignment operator `=`.
        if true
        end
      RUBY

      expect_correction(<<~RUBY)
        foo.bar = if true
        end
      RUBY
    end

    it 'ignores arrays' do
      expect_no_offenses(<<~RUBY)
        a, b =
        4,
        5
      RUBY
    end

    context 'configured supported types' do
      let(:supported_types) { %w[array] }

      it 'allows supported types to be configured' do
        expect_offense(<<~RUBY)
          a, b =
          ^^^^^^ Right hand side of multi-line assignment is not on the same line as the assignment operator `=`.
          4,
          5
        RUBY
      end
    end

    it 'allows multi-line assignments on the same line' do
      expect_no_offenses(<<~RUBY)
        blarg= if true
        end
      RUBY
    end

    it 'registers an offense for masgn with multi-line lhs' do
      expect_offense(<<~RUBY)
        a,
        ^^ Right hand side of multi-line assignment is not on the same line as the assignment operator `=`.
        b =
        if foo
        end
      RUBY
    end

    context 'when supported types is block' do
      let(:supported_types) { %w[block] }

      it 'allows when multi-line assignments using block definition is on the same line' do
        expect_no_offenses(<<~RUBY)
          lambda = -> {
            puts 'hello'
          }
        RUBY
      end

      it 'registers an offense when multi-line assignments ' \
         'using block definition on separate lines' do
        expect_offense(<<~RUBY)
          lambda =
          ^^^^^^^^ Right hand side of multi-line assignment is not on the same line as the assignment operator `=`.
            -> {
              puts 'hello'
            }
        RUBY
      end

      it 'allows multi-line block defines on separate lines' do
        expect_no_offenses(<<~RUBY)
          default_scope -> {
            where(foo: "bar")
          }
        RUBY
      end

      it 'allows multi-line assignments when using shovel operator' do
        expect_no_offenses(<<~'RUBY')
          foo << items.map do |item|
            "#{item}!"
          end
        RUBY
      end
    end
  end
end
