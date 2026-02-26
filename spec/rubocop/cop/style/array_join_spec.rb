# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ArrayJoin, :config do
  it 'registers an offense for an array followed by string' do
    expect_offense(<<~RUBY)
      %w(one two three) * ", "
                        ^ Favor `Array#join` over `Array#*`.
    RUBY

    expect_correction(<<~RUBY)
      %w(one two three).join(", ")
    RUBY
  end

  it "autocorrects '*' to 'join' when there are no spaces" do
    expect_offense(<<~RUBY)
      %w(one two three)*", "
                       ^ Favor `Array#join` over `Array#*`.
    RUBY

    expect_correction(<<~RUBY)
      %w(one two three).join(", ")
    RUBY
  end

  it "autocorrects '*' to 'join' when setting to a variable" do
    expect_offense(<<~RUBY)
      foo = %w(one two three)*", "
                             ^ Favor `Array#join` over `Array#*`.
    RUBY

    expect_correction(<<~RUBY)
      foo = %w(one two three).join(", ")
    RUBY
  end

  it 'does not register an offense for numbers' do
    expect_no_offenses('%w(one two three) * 4')
  end

  it 'does not register an offense for ambiguous cases' do
    expect_no_offenses('%w(one two three) * test')
  end
end
