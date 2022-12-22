# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::LocationExpression, :config do
  it 'registers and corrects an offense when using `location.expression`' do
    expect_offense(<<~RUBY)
      node.location.expression
           ^^^^^^^^^^^^^^^^^^^ Use `source_range` instead.
    RUBY

    expect_correction(<<~RUBY)
      node.source_range
    RUBY
  end

  it 'registers and corrects an offense when using `loc.expression`' do
    expect_offense(<<~RUBY)
      node.loc.expression
           ^^^^^^^^^^^^^^ Use `source_range` instead.
    RUBY

    expect_correction(<<~RUBY)
      node.source_range
    RUBY
  end

  it 'registers and corrects an offense when using `loc.expression.end_pos`' do
    expect_offense(<<~RUBY)
      node.loc.expression.end_pos
           ^^^^^^^^^^^^^^ Use `source_range` instead.
    RUBY

    expect_correction(<<~RUBY)
      node.source_range.end_pos
    RUBY
  end

  it 'does not register an offense when using `location.expression` without a receiver' do
    expect_no_offenses(<<~RUBY)
      location.expression
    RUBY
  end

  it 'does not register an offense when using `loc.expression` without a receiver' do
    expect_no_offenses(<<~RUBY)
      loc.expression
    RUBY
  end

  it 'does not register an offense when assigning `node.location`' do
    expect_no_offenses(<<~RUBY)
      loc = node.location
    RUBY
  end
end
