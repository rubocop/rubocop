# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::BlockEndNewline do
  subject(:cop) { described_class.new }

  it 'accepts a one-liner' do
    expect_no_offenses('test do foo end')
  end

  it 'accepts multiline blocks with newlines before the end' do
    expect_no_offenses(<<~RUBY)
      test do
        foo
      end
    RUBY
  end

  it 'registers an offense and corrects when multiline block end ' \
    'is not on its own line' do
    expect_offense(<<~RUBY)
      test do
        foo end
            ^^^ Expression at 2, 7 should be on its own line.
    RUBY

    expect_correction(<<~RUBY)
      test do
        foo
      end
    RUBY
  end

  it 'registers an offense and corrects when multiline block } ' \
    'is not on its own line' do
    expect_offense(<<~RUBY)
      test {
        foo }
            ^ Expression at 2, 7 should be on its own line.
    RUBY

    expect_correction(<<~RUBY)
      test {
        foo
      }
    RUBY
  end
end
