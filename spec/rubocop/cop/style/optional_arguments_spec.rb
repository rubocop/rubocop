# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::OptionalArguments, :config do
  it 'registers an offense when an optional argument is followed by a required argument' do
    expect_offense(<<~RUBY)
      def foo(a = 1, b)
              ^^^^^ Optional arguments should appear at the end of the argument list.
      end
    RUBY
  end

  it 'registers an offense for each optional argument when multiple ' \
     'optional arguments are followed by a required argument' do
    expect_offense(<<~RUBY)
      def foo(a = 1, b = 2, c)
              ^^^^^ Optional arguments should appear at the end of the argument list.
                     ^^^^^ Optional arguments should appear at the end of the argument list.
      end
    RUBY
  end

  it 'allows methods without arguments' do
    expect_no_offenses(<<~RUBY)
      def foo
      end
    RUBY
  end

  it 'allows methods with only one required argument' do
    expect_no_offenses(<<~RUBY)
      def foo(a)
      end
    RUBY
  end

  it 'allows methods with only required arguments' do
    expect_no_offenses(<<~RUBY)
      def foo(a, b, c)
      end
    RUBY
  end

  it 'allows methods with only one optional argument' do
    expect_no_offenses(<<~RUBY)
      def foo(a = 1)
      end
    RUBY
  end

  it 'allows methods with only optional arguments' do
    expect_no_offenses(<<~RUBY)
      def foo(a = 1, b = 2, c = 3)
      end
    RUBY
  end

  it 'allows methods with multiple optional arguments at the end' do
    expect_no_offenses(<<~RUBY)
      def foo(a, b = 2, c = 3)
      end
    RUBY
  end

  context 'named params' do
    context 'with default values' do
      it 'allows optional arguments before an optional named argument' do
        expect_no_offenses(<<~RUBY)
          def foo(a = 1, b: 2)
          end
        RUBY
      end
    end

    context 'required params', :ruby21 do
      it 'registers an offense for optional arguments that come before ' \
         'required arguments where there are name arguments' do
        expect_offense(<<~RUBY)
          def foo(a = 1, b, c:, d: 4)
                  ^^^^^ Optional arguments should appear at the end of the argument list.
          end
        RUBY
      end

      it 'allows optional arguments before required named arguments' do
        expect_no_offenses(<<~RUBY)
          def foo(a = 1, b:)
          end
        RUBY
      end

      it 'allows optional arguments to come before a mix of required and optional named argument' do
        expect_no_offenses(<<~RUBY)
          def foo(a = 1, b:, c: 3)
          end
        RUBY
      end
    end
  end
end
