# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::OptionalBooleanParameter do
  subject(:cop) { described_class.new }

  it 'registers an offense when defining method with optional boolean arg' do
    expect_offense(<<~RUBY)
      def some_method(bar = false)
                      ^^^^^^^^^^^ Use keyword arguments when defining method with boolean argument.
      end
    RUBY
  end

  it 'registers an offense when defining class method with optional boolean arg' do
    expect_offense(<<~RUBY)
      def self.some_method(bar = false)
                           ^^^^^^^^^^^ Use keyword arguments when defining method with boolean argument.
      end
    RUBY
  end

  it 'registers an offense when defining method with multiple optional boolean args' do
    expect_offense(<<~RUBY)
      def some_method(foo = true, bar = 1, baz = false, quux: true)
                      ^^^^^^^^^^ Use keyword arguments when defining method with boolean argument.
                                           ^^^^^^^^^^^ Use keyword arguments when defining method with boolean argument.
      end
    RUBY
  end

  it 'does not register an offense when defining method with keyword boolean arg' do
    expect_no_offenses(<<~RUBY)
      def some_method(bar: false)
      end
    RUBY
  end

  it 'does not register an offense when defining method without args' do
    expect_no_offenses(<<~RUBY)
      def some_method
      end
    RUBY
  end

  it 'does not register an offense when defining method with optonal non-boolean arg' do
    expect_no_offenses(<<~RUBY)
      def some_method(bar = 'foo')
      end
    RUBY
  end
end
