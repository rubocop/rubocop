# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MultilineTernaryOperator do
  subject(:cop) { described_class.new }

  it 'registers offense and corrects when the if branch and the else branch are ' \
     'on a separate line from the condition' do
    expect_offense(<<~RUBY)
      a = cond ?
          ^^^^^^ Avoid multi-line ternary operators, use `if` or `unless` instead.
        b : c
    RUBY

    expect_correction(<<~RUBY)
      a = if cond
        b
      else
        c
      end
    RUBY
  end

  it 'registers an offense and corrects when the false branch is on a separate line' do
    expect_offense(<<~RUBY)
      a = cond ? b :
          ^^^^^^^^^^ Avoid multi-line ternary operators, use `if` or `unless` instead.
          c
    RUBY

    expect_correction(<<~RUBY)
      a = if cond
        b
      else
        c
      end
    RUBY
  end

  it 'registers an offense and corrects when everything is on a separate line' do
    expect_offense(<<~RUBY)
      a = cond ?
          ^^^^^^ Avoid multi-line ternary operators, use `if` or `unless` instead.
          b :
          c
    RUBY

    expect_correction(<<~RUBY)
      a = if cond
        b
      else
        c
      end
    RUBY
  end

  it 'accepts a single line ternary operator expression' do
    expect_no_offenses('a = cond ? b : c')
  end
end
