# frozen_string_literal: true

describe RuboCop::Cop::Layout::SpaceAfterMethodName do
  subject(:cop) { described_class.new }

  it 'registers an offense for def with space before the parenthesis' do
    expect_offense(<<-RUBY.strip_indent)
      def func (x)
              ^ Do not put a space between a method name and the opening parenthesis.
        a
      end
    RUBY
  end

  it 'registers an offense for defs with space before the parenthesis' do
    expect_offense(<<-RUBY.strip_indent)
      def self.func (x)
                   ^ Do not put a space between a method name and the opening parenthesis.
        a
      end
    RUBY
  end

  it 'accepts a def without arguments' do
    expect_no_offenses(<<-END.strip_indent)
      def func
        a
      end
    END
  end

  it 'accepts a defs without arguments' do
    expect_no_offenses(<<-END.strip_indent)
      def self.func
        a
      end
    END
  end

  it 'accepts a def with arguments but no parentheses' do
    expect_no_offenses(<<-END.strip_indent)
      def func x
        a
      end
    END
  end

  it 'accepts a defs with arguments but no parentheses' do
    expect_no_offenses(<<-END.strip_indent)
      def self.func x
        a
      end
    END
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
