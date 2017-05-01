# frozen_string_literal: true

describe RuboCop::Cop::Performance::RedundantBlockCall do
  subject(:cop) { described_class.new }

  it 'autocorrects block.call without arguments' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      def method(&block)
        block.call
      end
    END
    expect(new_source).to eq(<<-END.strip_indent)
      def method(&block)
        yield
      end
    END
  end

  it 'autocorrects block.call with empty parentheses' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      def method(&block)
        block.call()
      end
    END
    expect(new_source).to eq(<<-END.strip_indent)
      def method(&block)
        yield
      end
    END
  end

  it 'autocorrects block.call with arguments' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      def method(&block)
        block.call 1, 2
      end
    END
    expect(new_source).to eq(<<-END.strip_indent)
      def method(&block)
        yield 1, 2
      end
    END
  end

  it 'autocorrects multiple occurances of block.call with arguments' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      def method(&block)
        block.call 1
        block.call 2
      end
    END
    expect(new_source).to eq(<<-END.strip_indent)
      def method(&block)
        yield 1
        yield 2
      end
    END
  end

  it 'autocorrects even when block arg has a different name' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      def method(&func)
        func.call
      end
    END
    expect(new_source).to eq(<<-END.strip_indent)
      def method(&func)
        yield
      end
    END
  end

  it 'accepts a block that is not `call`ed' do
    inspect_source(cop, <<-END.strip_indent)
      def method(&block)
       something.call
      end
    END
    expect(cop.messages).to be_empty
  end

  it 'accepts an empty method body' do
    inspect_source(cop, <<-END.strip_indent)
      def method(&block)
      end
    END
    expect(cop.messages).to be_empty
  end

  it 'accepts another block being passed as the only arg' do
    inspect_source(cop, <<-END.strip_indent)
      def method(&block)
        block.call(&some_proc)
      end
    END
    expect(cop.messages).to be_empty
  end

  it 'accepts another block being passed along with other args' do
    inspect_source(cop, <<-END.strip_indent)
      def method(&block)
        block.call(1, &some_proc)
      end
    END
    expect(cop.messages).to be_empty
  end

  it 'accepts another block arg in at least one occurance of block.call' do
    inspect_source(cop, <<-END.strip_indent)
      def method(&block)
        block.call(1, &some_proc)
        block.call(2)
      end
    END
    expect(cop.messages).to be_empty
  end

  it 'accepts an optional block that is defaulted' do
    inspect_source(cop, <<-END.strip_indent)
      def method(&block)
        block ||= ->(i) { puts i }
        block.call(1)
      end
    END
    expect(cop.messages).to be_empty
  end

  it 'accepts an optional block that is overridden' do
    inspect_source(cop, <<-END.strip_indent)
      def method(&block)
        block = ->(i) { puts i }
        block.call(1)
      end
    END
    expect(cop.messages).to be_empty
  end

  it 'formats the error message for func.call(1) correctly' do
    expect_offense(<<-END.strip_indent)
      def method(&func)
        func.call(1)
        ^^^^^^^^^^^^ Use `yield` instead of `func.call`.
      end
    END
  end

  it 'autocorrects using parentheses when block.call uses parentheses' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      def method(&block)
        block.call(a, b)
      end
    END

    expect(new_source).to eq(<<-END.strip_indent)
      def method(&block)
        yield(a, b)
      end
    END
  end

  it 'autocorrects when the result of the call is used in a scope that ' \
     'requires parentheses' do
    source = <<-END.strip_indent
      def method(&block)
        each_with_object({}) do |(key, value), acc|
          acc.merge!(block.call(key) => rhs[value])
        end
      end
    END

    new_source = autocorrect_source(cop, source)

    expect(new_source).to eq(<<-END.strip_indent)
      def method(&block)
        each_with_object({}) do |(key, value), acc|
          acc.merge!(yield(key) => rhs[value])
        end
      end
    END
  end
end
