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

  it 'reports different offense for hash argument Hash[]' do
    expect_offense(<<~RUBY)
      Hash[a: b, c: d]
      ^^^^^^^^^^^^^^^^ Prefer literal hash to Hash[key: value, ...].
    RUBY

    expect_correction(<<~RUBY)
      {a: b, c: d}
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

  context 'AllowSplatArgument: true' do
    let(:cop_config) { { 'AllowSplatArgument' => true } }

    it 'does not register an offense for unpacked array' do
      expect_no_offenses(<<~RUBY)
        Hash[*ary]
      RUBY
    end
  end

  context 'AllowSplatArgument: false' do
    let(:cop_config) { { 'AllowSplatArgument' => false } }

    it 'reports uncorrectable offense for unpacked array' do
      expect_offense(<<~RUBY)
        Hash[*ary]
        ^^^^^^^^^^ Prefer array_of_pairs.to_h to Hash[*array].
      RUBY

      expect_no_corrections
    end
  end
end
