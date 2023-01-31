# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::EmptyInterpolation, :config do
  it 'registers an offense and corrects #{} in interpolation' do
    expect_offense(<<~'RUBY')
      "this is the #{}"
                   ^^^ Empty interpolation detected.
    RUBY

    expect_correction(<<~RUBY)
      "this is the "
    RUBY
  end

  it 'registers an offense and corrects #{ } in interpolation' do
    expect_offense(<<~'RUBY')
      "this is the #{ }"
                   ^^^^ Empty interpolation detected.
    RUBY

    expect_correction(<<~RUBY)
      "this is the "
    RUBY
  end

  it 'finds interpolations in string-like contexts' do
    expect_offense(<<~'RUBY')
      /regexp #{}/
              ^^^ Empty interpolation detected.
      `backticks #{}`
                 ^^^ Empty interpolation detected.
      :"symbol #{}"
               ^^^ Empty interpolation detected.
    RUBY
  end

  it 'accepts non-empty interpolation' do
    expect_no_offenses('"this is #{top} silly"')
  end
end
