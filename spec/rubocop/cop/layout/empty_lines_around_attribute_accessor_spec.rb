# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EmptyLinesAroundAttributeAccessor do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense and corrects for code ' \
     'that immediately follows accessor' do
    expect_offense(<<~RUBY)
      attr_accessor :foo
      ^^^^^^^^^^^^^^^^^^ Add an empty line after attribute accessor.
      def do_something
      end
    RUBY

    expect_correction(<<~RUBY)
      attr_accessor :foo

      def do_something
      end
    RUBY
  end

  it 'registers an offense and corrects for code ' \
     'that immediately follows accessor with comment' do
    expect_offense(<<~RUBY)
      attr_accessor :foo # comment
      ^^^^^^^^^^^^^^^^^^ Add an empty line after attribute accessor.
      def do_something
      end
    RUBY

    expect_correction(<<~RUBY)
      attr_accessor :foo # comment

      def do_something
      end
    RUBY
  end

  it 'accepts code that separates a attribute accessor from the code ' \
     'with a newline' do
    expect_no_offenses(<<~RUBY)
      attr_accessor :foo

      def do_something
      end
    RUBY
  end

  it 'accepts code that separates attribute accessors from the code ' \
     'with a newline' do
    expect_no_offenses(<<~RUBY)
      attr_accessor :foo
      attr_reader :bar
      attr_writer :baz

      def do_something
      end
    RUBY
  end

  it 'accepts code when used in class definition' do
    expect_no_offenses(<<~RUBY)
      class Foo
        attr_accessor :foo
      end
    RUBY
  end
end
