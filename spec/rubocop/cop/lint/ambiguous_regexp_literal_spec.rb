# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::AmbiguousRegexpLiteral do
  subject(:cop) { described_class.new }

  context 'with a regexp literal in the first argument' do
    context 'without parentheses' do
      it 'registers an offense and corrects when single argument' do
        expect_offense(<<~RUBY)
          p /pattern/
            ^ Ambiguous regexp literal. Parenthesize the method arguments if it's surely a regexp literal, or add a whitespace to the right of the `/` if it should be a division.
        RUBY

        expect_correction(<<~RUBY)
          p(/pattern/)
        RUBY
      end

      it 'registers an offense and corrects when multiple arguments' do
        expect_offense(<<~RUBY)
          p /pattern/, foo
            ^ Ambiguous regexp literal. Parenthesize the method arguments if it's surely a regexp literal, or add a whitespace to the right of the `/` if it should be a division.
        RUBY

        expect_correction(<<~RUBY)
          p(/pattern/, foo)
        RUBY
      end

      it 'registers an offense and corrects when using block argument' do
        expect_offense(<<~RUBY)
          p /pattern/, foo do |arg|
            ^ Ambiguous regexp literal. Parenthesize the method arguments if it's surely a regexp literal, or add a whitespace to the right of the `/` if it should be a division.
          end
        RUBY

        expect_correction(<<~RUBY)
          p(/pattern/, foo) do |arg|
          end
        RUBY
      end

      it 'registers an offense and corrects when nesting' do
        expect_offense(<<~RUBY)
          p /pattern/ do
            ^ Ambiguous regexp literal. Parenthesize the method arguments if it's surely a regexp literal, or add a whitespace to the right of the `/` if it should be a division.
            p /pattern/
              ^ Ambiguous regexp literal. Parenthesize the method arguments if it's surely a regexp literal, or add a whitespace to the right of the `/` if it should be a division.
          end
        RUBY

        expect_correction(<<~RUBY)
          p(/pattern/) do
            p(/pattern/)
          end
        RUBY
      end
    end

    context 'with parentheses' do
      it 'accepts' do
        expect_no_offenses('p(/pattern/)')
      end
    end
  end
end
