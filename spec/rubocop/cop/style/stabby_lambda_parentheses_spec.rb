# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::StabbyLambdaParentheses, :config do
  shared_examples 'common' do
    it 'does not check the old lambda syntax' do
      expect_no_offenses('lambda(&:nil?)')
    end

    it 'does not check a stabby lambda without arguments' do
      expect_no_offenses('-> { true }')
    end

    it 'does not check a method call named lambda' do
      expect_no_offenses('o.lambda')
    end
  end

  context 'require_parentheses' do
    let(:cop_config) { { 'EnforcedStyle' => 'require_parentheses' } }

    it_behaves_like 'common'

    it 'registers an offense for a stabby lambda without parentheses' do
      expect_offense(<<~RUBY)
        ->a,b,c { a + b + c }
          ^^^^^ Wrap stabby lambda arguments with parentheses.
      RUBY

      expect_correction(<<~RUBY)
        ->(a,b,c) { a + b + c }
      RUBY
    end

    it 'does not register an offense for a stabby lambda with parentheses' do
      expect_no_offenses('->(a,b,c) { a + b + c }')
    end
  end

  context 'require_no_parentheses' do
    let(:cop_config) { { 'EnforcedStyle' => 'require_no_parentheses' } }

    it_behaves_like 'common'

    it 'registers an offense for a stabby lambda with parentheses' do
      expect_offense(<<~RUBY)
        ->(a,b,c) { a + b + c }
          ^^^^^^^ Do not wrap stabby lambda arguments with parentheses.
      RUBY

      expect_correction(<<~RUBY)
        ->a,b,c { a + b + c }
      RUBY
    end

    it 'registers an offense for a stabby lambda with splat and block arguments' do
      expect_offense(<<~RUBY)
        ->(*a, **kw, &b) { a }
          ^^^^^^^^^^^^^^ Do not wrap stabby lambda arguments with parentheses.
      RUBY

      expect_correction(<<~RUBY)
        ->*a, **kw, &b { a }
      RUBY
    end

    it 'registers an offense for a stabby lambda with a plain default value' do
      expect_offense(<<~RUBY)
        ->(a = 1) { a }
          ^^^^^^^ Do not wrap stabby lambda arguments with parentheses.
      RUBY

      expect_correction(<<~RUBY)
        ->a = 1 { a }
      RUBY
    end

    it 'registers an offense when a default value contains a hash without braces' do
      expect_offense(<<~RUBY)
        ->(a = foo(b: 1)) { a }
          ^^^^^^^^^^^^^^^ Do not wrap stabby lambda arguments with parentheses.
      RUBY

      expect_correction(<<~RUBY)
        ->a = foo(b: 1) { a }
      RUBY
    end

    it 'registers an offense and corrects a multiline argument list' do
      expect_offense(<<~RUBY)
        y = ->(
              ^ Do not wrap stabby lambda arguments with parentheses.
          a
        ) { a }
      RUBY

      expect_correction(<<~RUBY)
        y = ->a { a }
      RUBY
    end

    it 'registers an offense and keeps a line break that follows a comma' do
      expect_offense(<<~RUBY)
        y = ->(a,
              ^^^ Do not wrap stabby lambda arguments with parentheses.
          b) { a }
      RUBY

      expect_correction(<<~RUBY)
        y = ->a,
          b { a }
      RUBY
    end

    it 'does not register an offense when a comment follows the opening parenthesis' do
      expect_no_offenses(<<~RUBY)
        y = ->( # comment
          a) { a }
      RUBY
    end

    it 'does not register an offense when a comment precedes the closing parenthesis' do
      expect_no_offenses(<<~RUBY)
        y = ->(a # comment
        ) { a }
      RUBY
    end

    it 'does not register an offense when a default value is a hash with braces' do
      expect_no_offenses('->(options = {}) { options }')
    end

    it 'does not register an offense when a default value contains a hash behind a method call' do
      expect_no_offenses('->(a = {}.freeze) { a }')
    end

    it 'does not register an offense when a default value contains a `do`-`end` block' do
      expect_no_offenses('->(a = foo do end) { a }')
    end

    it 'does not register an offense when a keyword argument default value is a hash with braces' do
      expect_no_offenses('->(options: {}) { options }')
    end
  end
end
