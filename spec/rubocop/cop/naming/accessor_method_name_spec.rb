# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::AccessorMethodName, :config do
  it 'registers an offense for method get_something with no args' do
    expect_offense(<<~RUBY)
      def get_something
          ^^^^^^^^^^^^^ Do not prefix reader method names with `get_`.
        # ...
      end
    RUBY
  end

  it 'registers an offense for singleton method get_something with no args' do
    expect_offense(<<~RUBY)
      def self.get_something
               ^^^^^^^^^^^^^ Do not prefix reader method names with `get_`.
        # ...
      end
    RUBY
  end

  it 'accepts method get_something with args' do
    expect_no_offenses(<<~RUBY)
      def get_something(arg)
        # ...
      end
    RUBY
  end

  it 'accepts singleton method get_something with args' do
    expect_no_offenses(<<~RUBY)
      def self.get_something(arg)
        # ...
      end
    RUBY
  end

  it 'registers an offense for method set_something with one arg' do
    expect_offense(<<~RUBY)
      def set_something(arg)
          ^^^^^^^^^^^^^ Do not prefix writer method names with `set_`.
        # ...
      end
    RUBY
  end

  it 'accepts method set_something with optarg' do
    expect_no_offenses(<<~RUBY)
      def set_something(arg = :default)
        # ...
      end
    RUBY
  end

  it 'accepts method set_something with restarg' do
    expect_no_offenses(<<~RUBY)
      def set_something(*args)
        # ...
      end
    RUBY
  end

  it 'accepts method set_something with kwoptarg' do
    expect_no_offenses(<<~RUBY)
      def set_something(k: v)
        # ...
      end
    RUBY
  end

  it 'accepts method set_something with kwarg' do
    expect_no_offenses(<<~RUBY)
      def set_something(k:)
        # ...
      end
    RUBY
  end

  it 'accepts method set_something with kwrestarg' do
    expect_no_offenses(<<~RUBY)
      def set_something(**options)
        # ...
      end
    RUBY
  end

  it 'accepts method set_something with blockarg' do
    expect_no_offenses(<<~RUBY)
      def set_something(&block)
        # ...
      end
    RUBY
  end

  context '>= Ruby 2.7', :ruby27 do
    it 'accepts method set_something with arguments forwarding' do
      expect_no_offenses(<<~RUBY)
        def set_something(...)
          # ...
        end
      RUBY
    end
  end

  it 'registers an offense for singleton method set_something with one args' do
    expect_offense(<<~RUBY)
      def self.set_something(arg)
               ^^^^^^^^^^^^^ Do not prefix writer method names with `set_`.
        # ...
      end
    RUBY
  end

  it 'accepts method set_something with no args' do
    expect_no_offenses(<<~RUBY)
      def set_something
        # ...
      end
    RUBY
  end

  it 'accepts singleton method set_something with no args' do
    expect_no_offenses(<<~RUBY)
      def self.set_something
        # ...
      end
    RUBY
  end

  it 'accepts method set_something with two args' do
    expect_no_offenses(<<~RUBY)
      def set_something(arg1, arg2)
        # ...
      end
    RUBY
  end

  it 'accepts singleton method set_something with two args' do
    expect_no_offenses(<<~RUBY)
      def self.get_something(arg1, arg2)
        # ...
      end
    RUBY
  end
end
