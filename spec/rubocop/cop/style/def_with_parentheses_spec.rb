# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::DefWithParentheses, :config do
  it 'reports an offense for def with empty parens' do
    expect_offense(<<~RUBY)
      def func()
              ^^ Omit the parentheses in defs when the method doesn't accept any arguments.
      end
    RUBY

    expect_correction(<<~RUBY)
      def func
      end
    RUBY
  end

  it 'reports an offense for class def with empty parens' do
    expect_offense(<<~RUBY)
      def Test.func()
                   ^^ Omit the parentheses in defs when the method doesn't accept any arguments.
        something
      end
    RUBY

    expect_correction(<<~RUBY)
      def Test.func
        something
      end
    RUBY
  end

  context 'Ruby >= 3.0', :ruby30 do
    it 'reports an offense for endless method definition with empty parens' do
      expect_offense(<<~RUBY)
        def foo() = do_something
               ^^ Omit the parentheses in defs when the method doesn't accept any arguments.
      RUBY

      expect_correction(<<~RUBY)
        def foo = do_something
      RUBY
    end
  end

  it 'accepts def with arg and parens' do
    expect_no_offenses(<<~RUBY)
      def func(a)
      end
    RUBY
  end

  it 'accepts def without arguments' do
    expect_no_offenses(<<~RUBY)
      def func
      end
    RUBY
  end

  it 'accepts empty parentheses in one liners' do
    expect_no_offenses("def to_s() join '/' end")
  end
end
