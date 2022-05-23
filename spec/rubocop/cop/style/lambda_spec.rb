# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::Lambda, :config do
  context 'with enforced `lambda` style' do
    let(:cop_config) { { 'EnforcedStyle' => 'lambda' } }

    context 'with a single line lambda literal' do
      context 'with arguments' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            f = ->(x) { x }
                ^^ Use the `lambda` method for all lambdas.
          RUBY

          expect_correction(<<~RUBY)
            f = lambda { |x| x }
          RUBY
        end
      end

      context 'without arguments' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            f = -> { x }
                ^^ Use the `lambda` method for all lambdas.
          RUBY

          expect_correction(<<~RUBY)
            f = lambda { x }
          RUBY
        end
      end

      context 'without argument parens and spaces' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            f = ->x{ p x }
                ^^ Use the `lambda` method for all lambdas.
          RUBY

          expect_correction(<<~RUBY)
            f = lambda{ |x| p x }
          RUBY
        end
      end
    end

    context 'with a multiline lambda literal' do
      context 'with arguments' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            f = ->(x) do
                ^^ Use the `lambda` method for all lambdas.
              x
            end
          RUBY

          expect_correction(<<~RUBY)
            f = lambda do |x|
              x
            end
          RUBY
        end
      end

      context 'without arguments' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            f = -> do
                ^^ Use the `lambda` method for all lambdas.
              x
            end
          RUBY

          expect_correction(<<~RUBY)
            f = lambda do
              x
            end
          RUBY
        end
      end
    end
  end

  context 'with enforced `literal` style' do
    let(:cop_config) { { 'EnforcedStyle' => 'literal' } }

    context 'with a single line lambda method call' do
      context 'with arguments' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            f = lambda { |x| x }
                ^^^^^^ Use the `-> { ... }` lambda literal syntax for all lambdas.
          RUBY

          expect_correction(<<~RUBY)
            f = ->(x) { x }
          RUBY
        end
      end

      context 'without arguments' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            f = lambda { x }
                ^^^^^^ Use the `-> { ... }` lambda literal syntax for all lambdas.
          RUBY

          expect_correction(<<~RUBY)
            f = -> { x }
          RUBY
        end
      end
    end

    context 'with a multiline lambda method call' do
      context 'with arguments' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            f = lambda do |x|
                ^^^^^^ Use the `-> { ... }` lambda literal syntax for all lambdas.
              x
            end
          RUBY

          expect_correction(<<~RUBY)
            f = ->(x) do
              x
            end
          RUBY
        end
      end

      context 'without arguments' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            f = lambda do
                ^^^^^^ Use the `-> { ... }` lambda literal syntax for all lambdas.
              x
            end
          RUBY

          expect_correction(<<~RUBY)
            f = -> do
              x
            end
          RUBY
        end
      end
    end
  end

  context 'with default `line_count_dependent` style' do
    let(:cop_config) { { 'EnforcedStyle' => 'line_count_dependent' } }

    context 'with a single line lambda method call' do
      context 'with arguments' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            f = lambda { |x| x }
                ^^^^^^ Use the `-> { ... }` lambda literal syntax for single line lambdas.
          RUBY

          expect_correction(<<~RUBY)
            f = ->(x) { x }
          RUBY
        end
      end

      context 'without arguments' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            f = lambda { x }
                ^^^^^^ Use the `-> { ... }` lambda literal syntax for single line lambdas.
          RUBY

          expect_correction(<<~RUBY)
            f = -> { x }
          RUBY
        end
      end
    end

    context 'with a multiline lambda method call' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          l = lambda do |x|
            x
          end
        RUBY
      end
    end

    context 'with a single line lambda literal' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          lambda = ->(x) { x }
          lambda.(1)
        RUBY
      end
    end

    context '>= Ruby 2.7', :ruby27 do
      context 'when using numbered parameter' do
        context 'with a single line lambda method call' do
          it 'registers an offense' do
            expect_offense(<<~RUBY)
              f = lambda { _1 }
                  ^^^^^^ Use the `-> { ... }` lambda literal syntax for single line lambdas.
            RUBY

            expect_correction(<<~RUBY)
              f = -> { _1 }
            RUBY
          end
        end

        context 'with a multiline lambda method call' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              l = lambda do
                _1
              end
            RUBY
          end
        end

        context 'with a single line lambda literal' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              lambda = -> { _1 }
              lambda.(1)
            RUBY
          end
        end
      end
    end

    context 'with a multiline lambda literal' do
      context 'with arguments' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            f = ->(x) do
                ^^ Use the `lambda` method for multiline lambdas.
              x
            end
          RUBY

          expect_correction(<<~RUBY)
            f = lambda do |x|
              x
            end
          RUBY
        end
      end

      context 'without arguments' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            f = -> do
                ^^ Use the `lambda` method for multiline lambdas.
              x
            end
          RUBY

          expect_correction(<<~RUBY)
            f = lambda do
              x
            end
          RUBY
        end
      end
    end

    context 'unusual lack of spacing' do
      # The lack of spacing shown here is valid ruby syntax,
      # and can be the result of previous autocorrects re-writing
      # a multi-line `->(x){ ... }` to `->(x)do ... end`.
      # See rubocop/cop/style/block_delimiters.rb.
      # Tests correction of an issue resulting in `lambdado` syntax errors.
      context 'without any spacing' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            ->(x)do
            ^^ Use the `lambda` method for multiline lambdas.
              x
            end
          RUBY

          expect_correction(<<~RUBY)
            lambda do |x|
              x
            end
          RUBY
        end
      end

      context 'without spacing after arguments' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            -> (x)do
            ^^ Use the `lambda` method for multiline lambdas.
              x
            end
          RUBY

          expect_correction(<<~RUBY)
            lambda do |x|
              x
            end
          RUBY
        end
      end

      context 'without spacing before arguments' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            ->(x) do
            ^^ Use the `lambda` method for multiline lambdas.
              x
            end
          RUBY

          expect_correction(<<~RUBY)
            lambda do |x|
              x
            end
          RUBY
        end
      end

      context 'with a multiline lambda literal' do
        context 'with empty arguments' do
          it 'registers an offense' do
            expect_offense(<<~RUBY)
              ->()do
              ^^ Use the `lambda` method for multiline lambdas.
                x
              end
            RUBY

            expect_correction(<<~RUBY)
              lambda do
                x
              end
            RUBY
          end
        end

        context 'with no arguments and bad spacing' do
          it 'registers an offense' do
            expect_offense(<<~RUBY)
              -> ()do
              ^^ Use the `lambda` method for multiline lambdas.
                x
              end
            RUBY

            expect_correction(<<~RUBY)
              lambda do
                x
              end
            RUBY
          end
        end

        context 'with no arguments and no spacing' do
          it 'registers an offense' do
            expect_offense(<<~RUBY)
              ->do
              ^^ Use the `lambda` method for multiline lambdas.
                x
              end
            RUBY

            expect_correction(<<~RUBY)
              lambda do
                x
              end
            RUBY
          end
        end

        context 'without parentheses' do
          it 'registers an offense' do
            expect_offense(<<~RUBY)
              -> hello do
              ^^ Use the `lambda` method for multiline lambdas.
                puts hello
              end
            RUBY

            expect_correction(<<~RUBY)
              lambda do |hello|
                puts hello
              end
            RUBY
          end
        end

        context 'with no parentheses and bad spacing' do
          it 'registers an offense' do
            expect_offense(<<~RUBY)
              ->   hello  do
              ^^ Use the `lambda` method for multiline lambdas.
                puts hello
              end
            RUBY

            expect_correction(<<~RUBY)
              lambda do |hello|
                puts hello
              end
            RUBY
          end
        end

        context 'with no parentheses and many args' do
          it 'registers an offense' do
            expect_offense(<<~RUBY)
              ->   hello, user  do
              ^^ Use the `lambda` method for multiline lambdas.
                puts hello
              end
            RUBY

            expect_correction(<<~RUBY)
              lambda do |hello, user|
                puts hello
              end
            RUBY
          end
        end
      end
    end

    context 'when calling a lambda method without a block' do
      it 'does not register an offense' do
        expect_no_offenses('l = lambda.test')
      end
    end

    context 'with a multiline lambda literal as an argument' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          has_many :kittens, -> do
                             ^^ Use the `lambda` method for multiline lambdas.
            where(cats: Cat.young.where_values_hash)
          end, source: cats
        RUBY

        expect_correction(<<~RUBY)
          has_many :kittens, lambda {
            where(cats: Cat.young.where_values_hash)
          }, source: cats
        RUBY
      end
    end

    context 'with a multiline braces lambda literal as a keyword argument' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          has_many opt: -> do
                        ^^ Use the `lambda` method for multiline lambdas.
            where(cats: Cat.young.where_values_hash)
          end
        RUBY

        expect_correction(<<~RUBY)
          has_many opt: lambda {
            where(cats: Cat.young.where_values_hash)
          }
        RUBY
      end
    end

    context 'with a multiline do-end lambda literal as a keyword argument' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          has_many opt: -> {
                        ^^ Use the `lambda` method for multiline lambdas.
            where(cats: Cat.young.where_values_hash)
          }
        RUBY

        expect_correction(<<~RUBY)
          has_many opt: lambda {
            where(cats: Cat.young.where_values_hash)
          }
        RUBY
      end
    end

    context 'with a multiline do-end lambda as a parenthesized kwarg' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          has_many(
            opt: -> do
                 ^^ Use the `lambda` method for multiline lambdas.
              where(cats: Cat.young.where_values_hash)
            end
          )
        RUBY

        expect_correction(<<~RUBY)
          has_many(
            opt: lambda do
              where(cats: Cat.young.where_values_hash)
            end
          )
        RUBY
      end
    end
  end

  context 'when using safe navigation operator', :ruby23 do
    it 'does not break' do
      expect_no_offenses(<<~RUBY)
        foo&.bar do |_|
          baz
        end
      RUBY
    end
  end
end
