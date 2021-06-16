# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::InterpolationCheck, :config do
  it 'registers an offense and corrects for interpolation in single quoted string' do
    expect_offense(<<~'RUBY')
      'foo #{bar}'
      ^^^^^^^^^^^^ Interpolation in single quoted string detected. Use double quoted strings if you need interpolation.
    RUBY

    expect_correction(<<~'RUBY')
      "foo #{bar}"
    RUBY
  end

  it 'registers an offense and corrects when including interpolation and double quoted string in single quoted string' do
    expect_offense(<<~'RUBY')
      'foo "#{bar}"'
      ^^^^^^^^^^^^^^ Interpolation in single quoted string detected. Use double quoted strings if you need interpolation.
    RUBY

    expect_correction(<<~'RUBY')
      %{foo "#{bar}"}
    RUBY
  end

  it 'registers an offense for interpolation in single quoted split string' do
    expect_offense(<<~'RUBY')
      'x' \
        'foo #{bar}'
        ^^^^^^^^^^^^ Interpolation in single quoted string detected. Use double quoted strings if you need interpolation.
    RUBY
  end

  it 'registers an offense for interpolation in double + single quoted split string' do
    expect_offense(<<~'RUBY')
      "x" \
        'foo #{bar}'
        ^^^^^^^^^^^^ Interpolation in single quoted string detected. Use double quoted strings if you need interpolation.
    RUBY
  end

  it 'does not register an offense for properly interpolation strings' do
    expect_no_offenses(<<~'RUBY')
      hello = "foo #{bar}"
    RUBY
  end

  it 'does not register an offense for interpolation in nested strings' do
    expect_no_offenses(<<~'RUBY')
      foo = "bar '#{baz}' qux"
    RUBY
  end

  it 'does not register an offense for interpolation in a regexp' do
    expect_no_offenses(<<~'RUBY')
      /\#{20}/
    RUBY
  end

  it 'does not register an offense for an escaped interpolation' do
    expect_no_offenses(<<~'RUBY')
      "\#{msg}"
    RUBY
  end

  it 'does not crash for \xff' do
    expect_no_offenses(<<~'RUBY')
      foo = "\xff"
    RUBY
  end

  it 'does not register an offense for escaped crab claws in dstr' do
    expect_no_offenses(<<~'RUBY')
      foo = "alpha #{variable} beta \#{gamma}\" delta"
    RUBY
  end

  it 'does not register offense for strings in %w()' do
    expect_no_offenses(<<~'RUBY')
      %w("#{a}-foo")
    RUBY
  end
end
