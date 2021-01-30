# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::HashConversion, :config do
  it 'reports an offense for single-argument Hash[]' do
    expect_offense(<<~RUBY)
      Hash[ary]
      ^^^^^^^^^ Prefer ary.to_h to Hash[ary].
    RUBY

    expect_correction(<<~RUBY)
      ary.to_h
    RUBY
  end

  it 'reports different offense for multi-argument Hash[]' do
    expect_offense(<<~RUBY)
      Hash[a, b, c, d]
      ^^^^^^^^^^^^^^^^ Prefer literal hash to Hash[arg1, arg2, ...].
    RUBY

    expect_correction(<<~RUBY)
      {a => b, c => d}
    RUBY
  end

  it 'reports different offense for empty Hash[]' do
    expect_offense(<<~RUBY)
      Hash[]
      ^^^^^^ Prefer literal hash to Hash[arg1, arg2, ...].
    RUBY

    expect_correction(<<~RUBY)
      {}
    RUBY
  end

  it 'does not try to correct multi-argument Hash with odd number of arguments' do
    expect_offense(<<~RUBY)
      Hash[a, b, c]
      ^^^^^^^^^^^^^ Prefer literal hash to Hash[arg1, arg2, ...].
    RUBY

    expect_no_corrections
  end

  it 'reports uncorrectable offense for unpacked ary' do
    expect_offense(<<~RUBY)
      Hash[*ary]
      ^^^^^^^^^^ Prefer array_of_pairs.to_h to Hash[*array].
    RUBY

    expect_no_corrections
  end
end
