# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UnexpectedBlockArity, :config do
  let(:cop_config) { { 'Methods' => { 'reduce' => 2, 'inject' => 2 } } }

  context 'with a block' do
    context 'when given two parameters' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          values.reduce { |a, b| a + b }
        RUBY
      end
    end

    context 'when given three parameters' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          values.reduce { |a, b, c| a + b }
        RUBY
      end
    end

    context 'when given a splat parameter' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          values.reduce { |*x| x }
        RUBY
      end
    end

    context 'when given no parameters' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          values.reduce { }
          ^^^^^^^^^^^^^^^^^ `reduce` expects at least 2 positional arguments, got 0.
        RUBY
      end
    end

    context 'when given one parameter' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          values.reduce { |a| a }
          ^^^^^^^^^^^^^^^^^^^^^^^ `reduce` expects at least 2 positional arguments, got 1.
        RUBY
      end
    end

    context 'with keyword args' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          values.reduce { |a:, b:| a + b }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `reduce` expects at least 2 positional arguments, got 0.
        RUBY
      end
    end

    context 'with a keyword splat' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          values.reduce { |**kwargs| kwargs }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `reduce` expects at least 2 positional arguments, got 0.
        RUBY
      end
    end

    context 'when destructuring' do
      context 'with arity 1' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            values.reduce { |(a, b)| a + b }
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `reduce` expects at least 2 positional arguments, got 1.
          RUBY
        end
      end

      context 'with arity 2' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            values.reduce { |(a, b), c| a + b + c }
          RUBY
        end
      end
    end

    context 'with optargs' do
      context 'with arity 1' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            values.reduce { |a = 1| a }
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^ `reduce` expects at least 2 positional arguments, got 1.
          RUBY
        end
      end

      context 'with arity 2' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            values.reduce { |a = 1, b = 2| a + b }
          RUBY
        end
      end
    end

    context 'with shadow args' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          values.reduce { |a; b| a + b }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `reduce` expects at least 2 positional arguments, got 1.
        RUBY
      end
    end

    context 'with no receiver' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          reduce { }
        RUBY
      end
    end
  end

  context 'with a numblock', :ruby27 do
    context 'when given no parameters' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          values.reduce { }
          ^^^^^^^^^^^^^^^^^ `reduce` expects at least 2 positional arguments, got 0.
        RUBY
      end
    end

    context 'when given one parameter' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          values.reduce { _1 }
          ^^^^^^^^^^^^^^^^^^^^ `reduce` expects at least 2 positional arguments, got 1.
        RUBY
      end
    end

    context 'when given two parameters' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          values.reduce { _1 + _2 }
        RUBY
      end
    end

    context 'when given three parameters' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          values.reduce { _1 + _2 + _3 }
        RUBY
      end
    end

    context 'when using enough parameters, but not all explicitly' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          values.reduce { _2 }
        RUBY
      end
    end

    context 'with no receiver' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          reduce { _1 }
        RUBY
      end
    end
  end

  it 'registers multiple offenses' do
    expect_offense(<<~RUBY)
      values.reduce { |a| a }
      ^^^^^^^^^^^^^^^^^^^^^^^ `reduce` expects at least 2 positional arguments, got 1.
      values.inject { }
      ^^^^^^^^^^^^^^^^^ `inject` expects at least 2 positional arguments, got 0.
    RUBY
  end
end
