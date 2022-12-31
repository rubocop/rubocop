# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::YodaExpression, :config do
  let(:cop_config) { { 'SupportedOperators' => ['*', '+'] } }

  it 'registers an offense when using simple offended example' do
    expect_offense(<<~RUBY)
      1 + x
      ^^^^^ Non-literal operand (`x`) should be first.
    RUBY

    expect_correction(<<~RUBY)
      x + 1
    RUBY
  end

  it 'registers an offense and corrects when using complex offended example' do
    expect_offense(<<~RUBY)
      2 + (1 + x)
      ^^^^^^^^^^^ Non-literal operand (`(1 + x)`) should be first.
    RUBY

    expect_correction(<<~RUBY)
      (x + 1) + 2
    RUBY
  end

  it 'accepts numeric on the right' do
    expect_no_offenses(<<~RUBY)
      1 + 2
      1 + 2.2
    RUBY
  end

  it 'accepts non integer' do
    expect_no_offenses(<<~RUBY)
      x + 1
    RUBY
  end

  it 'accepts `|`' do
    expect_no_offenses(<<~RUBY)
      1 | x
    RUBY
  end
end
