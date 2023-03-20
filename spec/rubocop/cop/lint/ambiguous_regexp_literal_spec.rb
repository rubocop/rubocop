# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::AmbiguousRegexpLiteral, :config do
  shared_examples 'with a regexp literal in the first argument' do
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

      it 'registers an offense and corrects when sending method to regexp without argument' do
        expect_offense(<<~RUBY)
          p /pattern/.do_something
            ^ Ambiguous regexp literal. Parenthesize the method arguments if it's surely a regexp literal, or add a whitespace to the right of the `/` if it should be a division.
        RUBY

        expect_correction(<<~RUBY)
          p(/pattern/.do_something)
        RUBY
      end

      it 'registers an offense and corrects when sending method to regexp with argument' do
        expect_offense(<<~RUBY)
          p /pattern/.do_something(42)
            ^ Ambiguous regexp literal. Parenthesize the method arguments if it's surely a regexp literal, or add a whitespace to the right of the `/` if it should be a division.
        RUBY

        expect_correction(<<~RUBY)
          p(/pattern/.do_something(42))
        RUBY
      end

      it 'registers an offense and corrects when sending method chain to regexp' do
        expect_offense(<<~RUBY)
          p /pattern/.do_something.do_something
            ^ Ambiguous regexp literal. Parenthesize the method arguments if it's surely a regexp literal, or add a whitespace to the right of the `/` if it should be a division.
        RUBY

        expect_correction(<<~RUBY)
          p(/pattern/.do_something.do_something)
        RUBY
      end

      it 'registers an offense and corrects when using regexp without method call in a nested structure' do
        expect_offense(<<~RUBY)
          class MyTest
            test '#foo' do
              assert_match /expected/, actual
                           ^ Ambiguous regexp literal. Parenthesize the method arguments if it's surely a regexp literal, or add a whitespace to the right of the `/` if it should be a division.
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class MyTest
            test '#foo' do
              assert_match(/expected/, actual)
            end
          end
        RUBY
      end

      it 'registers an offense and corrects when sending method inside parens without receiver takes a regexp argument' do
        expect_offense(<<~RUBY)
          expect('RuboCop').to(match /Cop/)
                                     ^ Ambiguous regexp literal. Parenthesize the method arguments if it's surely a regexp literal, or add a whitespace to the right of the `/` if it should be a division.
        RUBY

        expect_correction(<<~RUBY)
          expect('RuboCop').to(match(/Cop/))
        RUBY
      end

      it 'registers an offense and corrects when sending method without receiver takes a regexp argument' do
        expect_offense(<<~RUBY)
          expect('RuboCop').to match /Robo/
                                     ^ Ambiguous regexp literal. Parenthesize the method arguments if it's surely a regexp literal, or add a whitespace to the right of the `/` if it should be a division.
        RUBY

        expect_correction(<<~RUBY)
          expect('RuboCop').to match(/Robo/)
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

      it 'registers an offense and corrects when using nested method arguments without parentheses' do
        expect_offense(<<~RUBY)
          puts line.grep /pattern/
                         ^ Ambiguous regexp literal. Parenthesize the method arguments if it's surely a regexp literal, or add a whitespace to the right of the `/` if it should be a division.
        RUBY

        expect_correction(<<~RUBY)
          puts line.grep(/pattern/)
        RUBY
      end
    end

    context 'with parentheses' do
      it 'accepts' do
        expect_no_offenses('p(/pattern/)')
      end
    end

    context 'with `match_with_lvasgn` node' do
      context 'with parentheses' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            assert(/some pattern/ =~ some_string)
          RUBY
        end
      end

      context 'with different parentheses' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            assert(/some pattern/) =~ some_string
          RUBY
        end
      end

      context 'without parentheses' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            assert /some pattern/ =~ some_string
                   ^ Ambiguous regexp literal. Parenthesize the method arguments if it's surely a regexp literal, or add a whitespace to the right of the `/` if it should be a division.
          RUBY

          # Spacing will be fixed by `Lint/ParenthesesAsGroupedExpression`.
          expect_correction(<<~RUBY)
            assert (/some pattern/ =~ some_string)
          RUBY
        end
      end
    end
  end

  context 'Ruby <= 2.7', :ruby27 do
    include_examples 'with a regexp literal in the first argument'
  end

  context 'Ruby >= 3.0', :ruby30 do
    include_examples 'with a regexp literal in the first argument'
  end
end
