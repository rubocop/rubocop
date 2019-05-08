# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::InterpolationCheck do
  subject(:cop) { described_class.new }

  it 'registers an offense for interpolation in single quoted string' do
    expect_offense(<<~'RUBY')
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
end
