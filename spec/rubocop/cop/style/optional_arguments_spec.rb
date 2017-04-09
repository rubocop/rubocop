# frozen_string_literal: true

describe RuboCop::Cop::Style::OptionalArguments do
  subject(:cop) { described_class.new }

  it 'registers an offense when an optional argument is followed by a ' \
     'required argument' do
    inspect_source(cop, <<-END.strip_indent)
      def foo(a = 1, b)
      end
    END

    expect(cop.messages)
      .to eq([described_class::MSG])
    expect(cop.highlights).to eq(['a = 1'])
  end

  it 'registers an offense for each optional argument when multiple ' \
     'optional arguments are followed by a required argument' do
    inspect_source(cop, <<-END.strip_indent)
      def foo(a = 1, b = 2, c)
      end
    END

    expect(cop.messages).to eq([described_class::MSG, described_class::MSG])
    expect(cop.highlights).to eq(['a = 1', 'b = 2'])
  end

  it 'allows methods without arguments' do
    inspect_source(cop, <<-END.strip_indent)
      def foo
      end
    END

    expect(cop.messages).to be_empty
  end

  it 'allows methods with only one required argument' do
    inspect_source(cop, <<-END.strip_indent)
      def foo(a)
      end
    END

    expect(cop.messages).to be_empty
  end

  it 'allows methods with only required arguments' do
    inspect_source(cop, <<-END.strip_indent)
      def foo(a, b, c)
      end
    END

    expect(cop.messages).to be_empty
  end

  it 'allows methods with only one optional argument' do
    inspect_source(cop, <<-END.strip_indent)
      def foo(a = 1)
      end
    END

    expect(cop.messages).to be_empty
  end

  it 'allows methods with only optional arguments' do
    inspect_source(cop, <<-END.strip_indent)
      def foo(a = 1, b = 2, c = 3)
      end
    END

    expect(cop.messages).to be_empty
  end

  it 'allows methods with multiple optional arguments at the end' do
    inspect_source(cop, <<-END.strip_indent)
      def foo(a, b = 2, c = 3)
      end
    END

    expect(cop.messages).to be_empty
  end

  context 'named params' do
    context 'with default values', :ruby20 do
      it 'allows optional arguments before an optional named argument' do
        inspect_source(cop, <<-END.strip_indent)
          def foo(a = 1, b: 2)
          end
        END

        expect(cop.messages).to be_empty
      end
    end

    context 'required params', :ruby21 do
      it 'registers an offense for optional arguments that come before ' \
         'required arguments where there are name arguments' do
        inspect_source(cop, <<-END.strip_indent)
          def foo(a = 1, b, c:, d: 4)
          end
        END

        expect(cop.messages).to eq([described_class::MSG])
        expect(cop.highlights).to eq(['a = 1'])
      end

      it 'allows optional arguments before required named arguments' do
        inspect_source(cop, <<-END.strip_indent)
          def foo(a = 1, b:)
          end
        END

        expect(cop.messages).to be_empty
      end

      it 'allows optional arguments to come before a mix of required and ' \
         'optional named argument' do
        inspect_source(cop, <<-END.strip_indent)
          def foo(a = 1, b:, c: 3)
          end
        END

        expect(cop.messages).to be_empty
      end
    end
  end
end
