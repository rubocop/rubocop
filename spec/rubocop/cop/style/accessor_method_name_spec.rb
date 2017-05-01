# frozen_string_literal: true

describe RuboCop::Cop::Style::AccessorMethodName do
  subject(:cop) { described_class.new }

  it 'registers an offense for method get_... with no args' do
    inspect_source(cop, <<-END.strip_indent)
      def get_attr
        # ...
      end
    END
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['get_attr'])
  end

  it 'registers an offense for singleton method get_... with no args' do
    inspect_source(cop, <<-END.strip_indent)
      def self.get_attr
        # ...
      end
    END
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['get_attr'])
  end

  it 'accepts method get_something with args' do
    expect_no_offenses(<<-END.strip_indent)
      def get_something(arg)
        # ...
      end
    END
  end

  it 'accepts singleton method get_something with args' do
    expect_no_offenses(<<-END.strip_indent)
      def self.get_something(arg)
        # ...
      end
    END
  end

  it 'registers an offense for method set_something with one arg' do
    inspect_source(cop, <<-END.strip_indent)
      def set_attr(arg)
        # ...
      end
    END
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['set_attr'])
  end

  it 'registers an offense for singleton method set_... with one args' do
    inspect_source(cop, <<-END.strip_indent)
      def self.set_attr(arg)
        # ...
      end
    END
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['set_attr'])
  end

  it 'accepts method set_something with no args' do
    expect_no_offenses(<<-END.strip_indent)
      def set_something
        # ...
      end
    END
  end

  it 'accepts singleton method set_something with no args' do
    expect_no_offenses(<<-END.strip_indent)
      def self.set_something
        # ...
      end
    END
  end

  it 'accepts method set_something with two args' do
    expect_no_offenses(<<-END.strip_indent)
      def set_something(arg1, arg2)
        # ...
      end
    END
  end

  it 'accepts singleton method set_something with two args' do
    expect_no_offenses(<<-END.strip_indent)
      def self.get_something(arg1, arg2)
        # ...
      end
    END
  end
end
