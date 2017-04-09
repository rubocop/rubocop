# frozen_string_literal: true

describe RuboCop::Cop::Style::SpaceAfterMethodName do
  subject(:cop) { described_class.new }

  it 'registers an offense for def with space before the parenthesis' do
    inspect_source(cop, <<-END.strip_indent)
      def func (x)
        a
      end
    END
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for defs with space before the parenthesis' do
    inspect_source(cop, <<-END.strip_indent)
      def self.func (x)
        a
      end
    END
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts a def without arguments' do
    inspect_source(cop, <<-END.strip_indent)
      def func
        a
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'accepts a defs without arguments' do
    inspect_source(cop, <<-END.strip_indent)
      def self.func
        a
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'accepts a def with arguments but no parentheses' do
    inspect_source(cop, <<-END.strip_indent)
      def func x
        a
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'accepts a defs with arguments but no parentheses' do
    inspect_source(cop, <<-END.strip_indent)
      def self.func x
        a
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects unwanted space' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      def func (x)
        a
      end
      def self.func (x)
        a
      end
    END
    expect(new_source).to eq(<<-END.strip_indent)
      def func(x)
        a
      end
      def self.func(x)
        a
      end
    END
  end
end
