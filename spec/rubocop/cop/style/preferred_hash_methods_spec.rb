# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::PreferredHashMethods, :config do
  context 'with enforced `short` style' do
    let(:cop_config) { { 'EnforcedStyle' => 'short' } }

    it 'registers an offense for has_key? with one arg' do
      expect_offense(<<~RUBY)
        o.has_key?(o)
          ^^^^^^^^ Use `Hash#key?` instead of `Hash#has_key?`.
      RUBY

      expect_correction(<<~RUBY)
        o.key?(o)
      RUBY
    end

    it 'accepts has_key? with no args' do
      expect_no_offenses('o.has_key?')
    end

    it 'registers an offense for has_value? with one arg' do
      expect_offense(<<~RUBY)
        o.has_value?(o)
          ^^^^^^^^^^ Use `Hash#value?` instead of `Hash#has_value?`.
      RUBY

      expect_correction(<<~RUBY)
        o.value?(o)
      RUBY
    end

    context 'when using safe navigation operator' do
      it 'registers an offense for has_value? with one arg' do
        expect_offense(<<~RUBY)
          o&.has_value?(o)
             ^^^^^^^^^^ Use `Hash#value?` instead of `Hash#has_value?`.
        RUBY

        expect_correction(<<~RUBY)
          o&.value?(o)
        RUBY
      end
    end

    it 'accepts has_value? with no args' do
      expect_no_offenses('o.has_value?')
    end
  end

  context 'with enforced `verbose` style' do
    let(:cop_config) { { 'EnforcedStyle' => 'verbose' } }

    it 'registers an offense for key? with one arg' do
      expect_offense(<<~RUBY)
        o.key?(o)
          ^^^^ Use `Hash#has_key?` instead of `Hash#key?`.
      RUBY

      expect_correction(<<~RUBY)
        o.has_key?(o)
      RUBY
    end

    it 'accepts key? with no args' do
      expect_no_offenses('o.key?')
    end

    it 'registers an offense for value? with one arg' do
      expect_offense(<<~RUBY)
        o.value?(o)
          ^^^^^^ Use `Hash#has_value?` instead of `Hash#value?`.
      RUBY

      expect_correction(<<~RUBY)
        o.has_value?(o)
      RUBY
    end

    it 'accepts value? with no args' do
      expect_no_offenses('o.value?')
    end
  end
end
