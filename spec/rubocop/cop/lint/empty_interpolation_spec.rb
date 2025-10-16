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

  it 'registers an offense and corrects #{\'\'} in interpolation' do
    expect_offense(<<~'RUBY')
      "this is the #{''}"
                   ^^^^^ Empty interpolation detected.
    RUBY

    expect_correction(<<~RUBY)
      "this is the "
    RUBY
  end

  it 'registers an offense and corrects #{""} in interpolation' do
    expect_offense(<<~'RUBY')
      "this is the #{""}"
                   ^^^^^ Empty interpolation detected.
    RUBY

    expect_correction(<<~RUBY)
      "this is the "
    RUBY
  end

  it 'registers an offense and corrects #{nil} in interpolation' do
    expect_offense(<<~'RUBY')
      "this is the #{nil}"
                   ^^^^^^ Empty interpolation detected.
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

  it 'does not register an offense when using an integer inside interpolation' do
    expect_no_offenses(<<~'RUBY')
      "this is the #{1}"
    RUBY
  end

  it 'does not register an offense when using a boolean literal inside interpolation' do
    expect_no_offenses(<<~'RUBY')
      "this is the #{true}"
    RUBY
  end

  it 'does not register an offense for an empty string interpolation inside a `%W` literal' do
    expect_no_offenses(<<~'RUBY')
      %W[#{''} one two]
    RUBY
  end

  it 'does not register an offense for an empty string interpolation inside a `%I` literal' do
    expect_no_offenses(<<~'RUBY')
      %I[#{''} one two]
    RUBY
  end

  it 'registers an offense for an empty string interpolation inside an array' do
    expect_offense(<<~'RUBY')
      ["#{''}", one, two]
        ^^^^^ Empty interpolation detected.
    RUBY

    expect_correction(<<~RUBY)
      ["", one, two]
    RUBY
  end
end
