# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::AmbiguousRange, :config do
  { 'irange' => '..', 'erange' => '...' }.each do |node_type, operator|
    context "for an #{node_type}" do
      it 'registers an offense and corrects when not parenthesized' do
        expect_offense(<<~RUBY)
          x || 1#{operator}2
          ^^^^^^ Wrap complex range boundaries with parentheses to avoid ambiguity.
        RUBY

        expect_correction(<<~RUBY)
          (x || 1)#{operator}2
        RUBY
      end

      it 'registers an offense and corrects when the entire range is parenthesized but contains complex boundaries' do
        expect_offense(<<~RUBY)
          (x || 1#{operator}2)
           ^^^^^^ Wrap complex range boundaries with parentheses to avoid ambiguity.
        RUBY

        expect_correction(<<~RUBY)
          ((x || 1)#{operator}2)
        RUBY
      end

      it 'registers an offense and corrects when there are clauses on both sides' do
        expect_offense(<<~RUBY, operator: operator)
          x || 1#{operator}y || 2
                _{operator}^^^^^^ Wrap complex range boundaries with parentheses to avoid ambiguity.
          ^^^^^^ Wrap complex range boundaries with parentheses to avoid ambiguity.
        RUBY

        expect_correction(<<~RUBY)
          (x || 1)#{operator}(y || 2)
        RUBY
      end

      it 'registers an offense and corrects when one side is parenthesized but the other is not' do
        expect_offense(<<~RUBY, operator: operator)
          (x || 1)#{operator}y || 2
                  _{operator}^^^^^^ Wrap complex range boundaries with parentheses to avoid ambiguity.
        RUBY

        expect_correction(<<~RUBY)
          (x || 1)#{operator}(y || 2)
        RUBY
      end

      it 'does not register an offense if the range is parenthesized' do
        expect_no_offenses(<<~RUBY)
          x || (1#{operator}2)
          (x || 1)#{operator}2
        RUBY
      end

      it 'does not register an offense if the range is composed of literals' do
        expect_no_offenses(<<~RUBY)
          1#{operator}2
          'a'#{operator}'z'
          "\#{foo}-\#{bar}"#{operator}'123-4567'
          `date`#{operator}'foobar'
          :"\#{foo}-\#{bar}"#{operator}:baz
          /a/#{operator}/b/
          42#{operator}nil
        RUBY
      end

      it 'does not register an offense for a variable' do
        expect_no_offenses(<<~RUBY)
          @a#{operator}@b
        RUBY
      end

      it 'does not register an offense for a constant' do
        expect_no_offenses(<<~RUBY)
          Foo::MIN#{operator}Foo::MAX
        RUBY
      end

      it 'does not register an offense for `self`' do
        expect_no_offenses(<<~RUBY)
          self#{operator}42
          42#{operator}self
        RUBY
      end

      it 'can handle an endless range', :ruby26 do
        expect_offense(<<~RUBY)
          x || 1#{operator}
          ^^^^^^ Wrap complex range boundaries with parentheses to avoid ambiguity.
        RUBY

        expect_correction(<<~RUBY)
          (x || 1)#{operator}
        RUBY
      end

      it 'can handle a beginningless range', :ruby27 do
        expect_offense(<<~RUBY, operator: operator)
          #{operator}y || 1
          _{operator}^^^^^^ Wrap complex range boundaries with parentheses to avoid ambiguity.
        RUBY

        expect_correction(<<~RUBY)
          #{operator}(y || 1)
        RUBY
      end

      context 'method calls' do
        shared_examples_for 'common behavior' do
          it 'does not register an offense for a non-chained method call' do
            expect_no_offenses(<<~RUBY)
              a#{operator}b
            RUBY
          end

          it 'does not register an offense for a unary +' do
            expect_no_offenses(<<~RUBY)
              +a#{operator}10
            RUBY
          end

          it 'does not register an offense for a unary -' do
            expect_no_offenses(<<~RUBY)
              -a#{operator}10
            RUBY
          end

          it 'requires parens when calling a method on a basic literal' do
            expect_offense(<<~RUBY, operator: operator)
              1#{operator}2.to_a
               _{operator}^^^^^^ Wrap complex range boundaries with parentheses to avoid ambiguity.
            RUBY

            expect_correction(<<~RUBY)
              1#{operator}(2.to_a)
            RUBY
          end
        end

        context 'with RequireParenthesesForMethodChains: true' do
          let(:cop_config) { { 'RequireParenthesesForMethodChains' => true } }

          it_behaves_like 'common behavior'

          it 'registers an offense for a chained method call without parens' do
            expect_offense(<<~RUBY)
              foo.bar#{operator}10
              ^^^^^^^ Wrap complex range boundaries with parentheses to avoid ambiguity.
            RUBY

            expect_correction(<<~RUBY)
              (foo.bar)#{operator}10
            RUBY
          end

          it 'does not register an offense for a chained method call with parens' do
            expect_no_offenses(<<~RUBY)
              (foo.bar)#{operator}10
            RUBY
          end
        end

        context 'with RequireParenthesesForMethodChains: false' do
          let(:cop_config) { { 'RequireParenthesesForMethodChains' => false } }

          it_behaves_like 'common behavior'

          it 'does not register an offense for a chained method call without parens' do
            expect_no_offenses(<<~RUBY)
              foo.bar#{operator}10
            RUBY
          end

          it 'does not register an offense for a chained method call with parens' do
            expect_no_offenses(<<~RUBY)
              (foo.bar)#{operator}10
            RUBY
          end
        end
      end
    end
  end
end
