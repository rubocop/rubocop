# frozen_string_literal: true

describe RuboCop::Cop::Lint::InterpolationCheck do
  subject(:cop) { described_class.new }

  it 'registers an offense for interpolation in single quoted string' do
    expect_offense(<<-'RUBY'.strip_indent)
      'foo #{bar}'
      ^^^^^^^^^^^^ Interpolation in single quoted string detected. Use double quoted strings if you need interpolation.
    RUBY
  end

  it 'does not register an offense for interpolation in heredoc' do
    expect_no_offenses(<<-'RUBY'.strip_indent)
      hello = <<-TEXT
        foo #{bar}
      TEXT
    RUBY
  end

  it 'does not register an offense for an escaped interpolation in heredoc' do
    expect_no_offenses(<<-'RUBY'.strip_indent)
      hello = <<-TEXT
        foo \#{bar}
      TEXT
    RUBY
  end

  it 'does not register an offense for properly interpolation strings' do
    expect_no_offenses(<<-'RUBY'.strip_indent)
      hello = "foo #{bar}"
    RUBY
  end

  it 'does not register an offense for interpolation in nested strings' do
    expect_no_offenses(<<-'RUBY'.strip_indent)
      foo = "bar '#{baz}' qux"
    RUBY
  end

  it 'does not crash for \xff' do
    expect_no_offenses(<<-'RUBY'.strip_indent)
      foo = "\xff"
    RUBY
  end
end
