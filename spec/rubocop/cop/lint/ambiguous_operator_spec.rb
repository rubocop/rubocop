# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::AmbiguousOperator, :config do
  context 'with `+` unary operator in the first argument' do
    context 'without parentheses' do
      context 'without whitespaces on the right of the operator' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            do_something(+24)
            do_something +42
                         ^ Ambiguous positive number operator. Parenthesize the method arguments if it's surely a positive number operator, or add a whitespace to the right of the `+` if it should be an addition.
          RUBY

          expect_correction(<<~RUBY)
            do_something(+24)
            do_something(+42)
          RUBY
        end
      end

      context 'without whitespaces on the right of the operator when a method with no arguments is used in advance' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            do_something
            do_something +42
                         ^ Ambiguous positive number operator. Parenthesize the method arguments if it's surely a positive number operator, or add a whitespace to the right of the `+` if it should be an addition.
          RUBY

          expect_correction(<<~RUBY)
            do_something
            do_something(+42)
          RUBY
        end
      end

      context 'with a whitespace on the right of the operator' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            do_something + 42
          RUBY
        end
      end
    end

    context 'with parentheses around the operator' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          do_something(+42)
        RUBY
      end
    end
  end

  context 'with `-` unary operator in the first argument' do
    context 'without parentheses' do
      context 'without whitespaces on the right of the operator' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            do_something(-24)
            do_something -42
                         ^ Ambiguous negative number operator. Parenthesize the method arguments if it's surely a negative number operator, or add a whitespace to the right of the `-` if it should be a subtraction.
          RUBY

          expect_correction(<<~RUBY)
            do_something(-24)
            do_something(-42)
          RUBY
        end
      end

      context 'with a whitespace on the right of the operator' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            do_something - 42
          RUBY
        end
      end
    end

    context 'with parentheses around the operator' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          do_something(-42)
        RUBY
      end
    end
  end

  context 'with a splat operator in the first argument' do
    context 'without parentheses' do
      context 'without whitespaces on the right of the operator' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            array = [1, 2, 3]
            puts *array
                 ^ Ambiguous splat operator. Parenthesize the method arguments if it's surely a splat operator, or add a whitespace to the right of the `*` if it should be a multiplication.
          RUBY

          expect_correction(<<~RUBY)
            array = [1, 2, 3]
            puts(*array)
          RUBY
        end
      end

      context 'with a whitespace on the right of the operator' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            array = [1, 2, 3]
            puts * array
          RUBY
        end
      end
    end

    context 'with parentheses around the splatted argument' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          array = [1, 2, 3]
          puts(*array)
        RUBY
      end
    end
  end

  context 'with a block ampersand in the first argument' do
    context 'without parentheses' do
      context 'without whitespaces on the right of the operator' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            process = proc { do_something }
            2.times &process
                    ^ Ambiguous block operator. Parenthesize the method arguments if it's surely a block operator, or add a whitespace to the right of the `&` if it should be a binary AND.
          RUBY

          expect_correction(<<~RUBY)
            process = proc { do_something }
            2.times(&process)
          RUBY
        end
      end

      context 'with a whitespace on the right of the operator' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            process = proc { do_something }
            2.times & process
          RUBY
        end
      end
    end

    context 'with parentheses around the block argument' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          process = proc { do_something }
          2.times(&process)
        RUBY
      end
    end
  end

  context 'with a keyword splat operator in the first argument' do
    context 'without parentheses' do
      context 'without whitespaces on the right of the operator' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            do_something **kwargs
                         ^^ Ambiguous keyword splat operator. Parenthesize the method arguments if it's surely a keyword splat operator, or add a whitespace to the right of the `**` if it should be an exponent.
          RUBY

          expect_correction(<<~RUBY)
            do_something(**kwargs)
          RUBY
        end
      end

      context 'with a whitespace on the right of the operator' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            do_something ** kwargs
          RUBY
        end
      end
    end

    context 'with parentheses around the keyword splat operator' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          do_something(**kwargs)
        RUBY
      end
    end
  end

  context 'when using safe navigation operator with a unary operator' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        do_something&.* -1
      RUBY
    end
  end
end
