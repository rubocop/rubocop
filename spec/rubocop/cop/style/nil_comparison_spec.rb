# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NilComparison, :config do
  context 'configured with predicate preferred' do
    let(:cop_config) { { 'EnforcedStyle' => 'predicate' } }

    it 'registers an offense for == nil' do
      expect_offense(<<~RUBY)
        x == nil
          ^^ Prefer the use of the `nil?` predicate.
      RUBY

      expect_correction(<<~RUBY)
        x.nil?
      RUBY
    end

    it 'registers an offense for === nil' do
      expect_offense(<<~RUBY)
        x === nil
          ^^^ Prefer the use of the `nil?` predicate.
      RUBY

      expect_correction(<<~RUBY)
        x.nil?
      RUBY
    end

    it 'registers and corrects an offense when using `x == nil` as a guard condition' do
      expect_offense(<<~RUBY)
        bar if x == nil
                 ^^ Prefer the use of the `nil?` predicate.
      RUBY

      expect_correction(<<~RUBY)
        bar if x.nil?
      RUBY
    end
  end

  context 'configured with comparison preferred' do
    let(:cop_config) { { 'EnforcedStyle' => 'comparison' } }

    it 'registers an offense for nil?' do
      expect_offense(<<~RUBY)
        x.nil?
          ^^^^ Prefer the use of the `==` comparison.
      RUBY

      expect_correction(<<~RUBY)
        x == nil
      RUBY
    end

    it 'registers and corrects an offense for `!x.nil?`' do
      expect_offense(<<~RUBY)
        !x.nil?
           ^^^^ Prefer the use of the `==` comparison.
      RUBY

      expect_correction(<<~RUBY)
        !(x == nil)
      RUBY
    end

    # FIXME: `undefined method `[]' for nil` occurs Prism 0.24.0. It has been resolved in
    # the development line. This will be resolved in Prism > 0.24.0 and higher releases.
    it 'registers no offense when there is no receiver', broken_on: :prism do
      expect_no_offenses('nil?')
    end
  end
end
