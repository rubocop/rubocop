# frozen_string_literal: true

describe RuboCop::Cop::Naming::AccessorMethodName do
  subject(:cop) { described_class.new }

  it 'registers an offense for method get_... with no args' do
    expect_offense(<<-RUBY.strip_indent)
      def get_attr
          ^^^^^^^^ Do not prefix reader method names with `get_`.
        # ...
      end
    RUBY
  end

  it 'registers an offense for singleton method get_... with no args' do
    expect_offense(<<-RUBY.strip_indent)
      def self.get_attr
               ^^^^^^^^ Do not prefix reader method names with `get_`.
        # ...
      end
    RUBY
  end

  it 'accepts method get_something with args' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def get_something(arg)
        # ...
      end
    RUBY
  end

  it 'accepts singleton method get_something with args' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def self.get_something(arg)
        # ...
      end
    RUBY
  end

  it 'registers an offense for method set_something with one arg' do
    expect_offense(<<-RUBY.strip_indent)
      def set_attr(arg)
          ^^^^^^^^ Do not prefix writer method names with `set_`.
        # ...
      end
    RUBY
  end

  it 'registers an offense for singleton method set_... with one args' do
    expect_offense(<<-RUBY.strip_indent)
      def self.set_attr(arg)
               ^^^^^^^^ Do not prefix writer method names with `set_`.
        # ...
      end
    RUBY
  end

  it 'accepts method set_something with no args' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def set_something
        # ...
      end
    RUBY
  end

  it 'accepts singleton method set_something with no args' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def self.set_something
        # ...
      end
    RUBY
  end

  it 'accepts method set_something with two args' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def set_something(arg1, arg2)
        # ...
      end
    RUBY
  end

  it 'accepts singleton method set_something with two args' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def self.get_something(arg1, arg2)
        # ...
      end
    RUBY
  end
end
