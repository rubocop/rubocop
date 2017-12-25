# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Performance::RedundantBlockCall do
  subject(:cop) { described_class.new }

  it 'autocorrects block.call without arguments' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      def method(&block)
        block.call
      end
    RUBY
    expect(new_source).to eq(<<-RUBY.strip_indent)
      def method(&block)
        yield
      end
    RUBY
  end

  it 'autocorrects block.call with empty parentheses' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      def method(&block)
        block.call()
      end
    RUBY
    expect(new_source).to eq(<<-RUBY.strip_indent)
      def method(&block)
        yield
      end
    RUBY
  end

  it 'autocorrects block.call with arguments' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      def method(&block)
        block.call 1, 2
      end
    RUBY
    expect(new_source).to eq(<<-RUBY.strip_indent)
      def method(&block)
        yield 1, 2
      end
    RUBY
  end

  it 'autocorrects multiple occurrences of block.call with arguments' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      def method(&block)
        block.call 1
        block.call 2
      end
    RUBY
    expect(new_source).to eq(<<-RUBY.strip_indent)
      def method(&block)
        yield 1
        yield 2
      end
    RUBY
  end

  it 'autocorrects even when block arg has a different name' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      def method(&func)
        func.call
      end
    RUBY
    expect(new_source).to eq(<<-RUBY.strip_indent)
      def method(&func)
        yield
      end
    RUBY
  end

  it 'accepts a block that is not `call`ed' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def method(&block)
       something.call
      end
    RUBY
  end

  it 'accepts an empty method body' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def method(&block)
      end
    RUBY
  end

  it 'accepts another block being passed as the only arg' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def method(&block)
        block.call(&some_proc)
      end
    RUBY
  end

  it 'accepts another block being passed along with other args' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def method(&block)
        block.call(1, &some_proc)
      end
    RUBY
  end

  it 'accepts another block arg in at least one occurrence of block.call' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def method(&block)
        block.call(1, &some_proc)
        block.call(2)
      end
    RUBY
  end

  it 'accepts an optional block that is defaulted' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def method(&block)
        block ||= ->(i) { puts i }
        block.call(1)
      end
    RUBY
  end

  it 'accepts an optional block that is overridden' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def method(&block)
        block = ->(i) { puts i }
        block.call(1)
      end
    RUBY
  end

  it 'formats the error message for func.call(1) correctly' do
    expect_offense(<<-RUBY.strip_indent)
      def method(&func)
        func.call(1)
        ^^^^^^^^^^^^ Use `yield` instead of `func.call`.
      end
    RUBY
  end

  it 'autocorrects using parentheses when block.call uses parentheses' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      def method(&block)
        block.call(a, b)
      end
    RUBY

    expect(new_source).to eq(<<-RUBY.strip_indent)
      def method(&block)
        yield(a, b)
      end
    RUBY
  end

  it 'autocorrects when the result of the call is used in a scope that ' \
     'requires parentheses' do
    source = <<-RUBY.strip_indent
      def method(&block)
        each_with_object({}) do |(key, value), acc|
          acc.merge!(block.call(key) => rhs[value])
        end
      end
    RUBY

    new_source = autocorrect_source(source)

    expect(new_source).to eq(<<-RUBY.strip_indent)
      def method(&block)
        each_with_object({}) do |(key, value), acc|
          acc.merge!(yield(key) => rhs[value])
        end
      end
    RUBY
  end
end
