# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::LambdaCall, :config do
  context 'when style is set to call' do
    let(:cop_config) { { 'EnforcedStyle' => 'call' } }

    it 'registers an offense for x.()' do
      expect_offense(<<~RUBY)
        x.(a, b)
        ^^^^^^^^ Prefer the use of `x.call(a, b)` over `x.(a, b)`.
      RUBY

      expect_correction(<<~RUBY)
        x.call(a, b)
      RUBY
    end

    it 'registers an offense for correct + opposite' do
      expect_offense(<<~RUBY)
        x.call(a, b)
        x.(a, b)
        ^^^^^^^^ Prefer the use of `x.call(a, b)` over `x.(a, b)`.
      RUBY

      expect_correction(<<~RUBY)
        x.call(a, b)
        x.call(a, b)
      RUBY
    end

    it 'registers an offense for correct + multiple opposite styles' do
      expect_offense(<<~RUBY)
        x.call(a, b)
        x.(a, b)
        ^^^^^^^^ Prefer the use of `x.call(a, b)` over `x.(a, b)`.
        x.(a, b)
        ^^^^^^^^ Prefer the use of `x.call(a, b)` over `x.(a, b)`.
      RUBY

      expect_correction(<<~RUBY)
        x.call(a, b)
        x.call(a, b)
        x.call(a, b)
      RUBY
    end
  end

  context 'when style is set to braces' do
    let(:cop_config) { { 'EnforcedStyle' => 'braces' } }

    it 'registers an offense for x.call()' do
      expect_offense(<<~RUBY)
        x.call(a, b)
        ^^^^^^^^^^^^ Prefer the use of `x.(a, b)` over `x.call(a, b)`.
      RUBY

      expect_correction(<<~RUBY)
        x.(a, b)
      RUBY
    end

    it 'registers an offense for opposite + correct' do
      expect_offense(<<~RUBY)
        x.call(a, b)
        ^^^^^^^^^^^^ Prefer the use of `x.(a, b)` over `x.call(a, b)`.
        x.(a, b)
      RUBY

      expect_correction(<<~RUBY)
        x.(a, b)
        x.(a, b)
      RUBY
    end

    it 'registers an offense for correct + multiple opposite styles' do
      expect_offense(<<~RUBY)
        x.call(a, b)
        ^^^^^^^^^^^^ Prefer the use of `x.(a, b)` over `x.call(a, b)`.
        x.(a, b)
        x.call(a, b)
        ^^^^^^^^^^^^ Prefer the use of `x.(a, b)` over `x.call(a, b)`.
      RUBY

      expect_correction(<<~RUBY)
        x.(a, b)
        x.(a, b)
        x.(a, b)
      RUBY
    end

    it 'accepts a call without receiver' do
      expect_no_offenses('call(a, b)')
    end

    it 'autocorrects x.call to x.()' do
      expect_offense(<<~RUBY)
        a.call
        ^^^^^^ Prefer the use of `a.()` over `a.call`.
      RUBY

      expect_correction(<<~RUBY)
        a.()
      RUBY
    end

    it 'autocorrects x.call asdf, x123 to x.(asdf, x123)' do
      expect_offense(<<~RUBY)
        a.call asdf, x123
        ^^^^^^^^^^^^^^^^^ Prefer the use of `a.(asdf, x123)` over `a.call asdf, x123`.
      RUBY

      expect_correction(<<~RUBY)
        a.(asdf, x123)
      RUBY
    end
  end
end
