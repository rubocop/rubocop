# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SuperWithArgsParentheses, :config do
  it 'registers an offense when using `super` without parenthesized arguments' do
    expect_offense(<<~RUBY)
      super name, age
      ^^^^^^^^^^^^^^^ Use parentheses for `super` with arguments.
    RUBY

    expect_correction(<<~RUBY)
      super(name, age)
    RUBY
  end

  it 'does not register an offense when using `super` with parenthesized arguments' do
    expect_no_offenses(<<~RUBY)
      super(name, age)
    RUBY
  end

  it 'does not register an offense when using `super` without arguments' do
    expect_no_offenses(<<~RUBY)
      super()
    RUBY
  end

  it 'does not register an offense when using zero arity `super`' do
    expect_no_offenses(<<~RUBY)
      super
    RUBY
  end
end
