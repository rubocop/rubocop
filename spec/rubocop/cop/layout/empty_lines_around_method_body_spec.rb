# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EmptyLinesAroundMethodBody, :config do
  let(:beginning_offense_annotation) { '^{} Extra empty line detected at method body beginning.' }
  let(:end_offense_annotation) { '^{} Extra empty line detected at method body end.' }

  it 'registers an offense for method body starting with a blank' do
    expect_offense(<<~RUBY)
      def some_method

      #{beginning_offense_annotation}
        do_something
      end
    RUBY

    expect_correction(<<~RUBY)
      def some_method
        do_something
      end
    RUBY
  end

  # The cop only registers an offense if the extra line is completely empty. If
  # there is trailing whitespace, then that must be dealt with first. Having
  # two cops registering offense for the line with only spaces would cause
  # havoc in autocorrection.
  it 'accepts method body starting with a line with spaces' do
    expect_no_offenses(['def some_method', '  ', '  do_something', 'end'].join("\n"))
  end

  it 'registers an offense for class method body starting with a blank' do
    expect_offense(<<~RUBY)
      def Test.some_method

      #{beginning_offense_annotation}
        do_something
      end
    RUBY

    expect_correction(<<~RUBY)
      def Test.some_method
        do_something
      end
    RUBY
  end

  it 'registers an offense for method body ending with a blank' do
    expect_offense(<<~RUBY)
      def some_method
        do_something

      #{end_offense_annotation}
      end
    RUBY
  end

  it 'registers an offense for class method body ending with a blank' do
    expect_offense(<<~RUBY)
      def Test.some_method
        do_something

      #{end_offense_annotation}
      end
    RUBY
  end

  it 'is not fooled by single line methods' do
    expect_no_offenses(<<~RUBY)
      def some_method; do_something; end

      something_else
    RUBY
  end
end
