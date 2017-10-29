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

  it 'registers offense for class def with space before parenthesis' do
    expect_offense(<<-RUBY.strip_indent)
      def self.func (x)
                   ^ Do not put a space between a method name and the opening parenthesis.
        a
      end
    RUBY
  end

  it 'registers offense for assignment def with space before parenthesis' do
    expect_offense(<<-RUBY.strip_indent)
      def func= (x)
               ^ Do not put a space between a method name and the opening parenthesis.
        a
      end
    RUBY
  end

  it 'accepts a def without arguments' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def func
        a
      end
    RUBY
  end

  it 'accepts a defs without arguments' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def self.func
        a
      end
    RUBY
  end

  it 'accepts a def with arguments but no parentheses' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def func x
        a
      end
    RUBY
  end

  it 'accepts class method def with arguments but no parentheses' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def self.func x
        a
      end
    RUBY
  end

  it 'accepts an assignment def with arguments but no parentheses' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def func= x
        a
      end
    RUBY
  end

  it 'auto-corrects unwanted space' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      def func (x)
        a
      end
      def self.func (x)
        a
      end
      def func= (x)
        a
      end
    RUBY
    expect(new_source).to eq(<<-RUBY.strip_indent)
      def func(x)
        a
      end
      def self.func(x)
        a
      end
      def func=(x)
        a
      end
    RUBY
  end
end
