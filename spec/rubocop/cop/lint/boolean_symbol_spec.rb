# frozen_string_literal: true

describe RuboCop::Cop::Lint::BooleanSymbol, :config do
  subject(:cop) { described_class.new(config) }

  it 'registers an offense when using `:true`' do
    expect_offense(<<-RUBY.strip_indent)
      :true
      ^^^^^ Symbol with a boolean name - you probably meant to use `true`.
    RUBY
  end

  it 'registers an offense when using `:false`' do
    expect_offense(<<-RUBY.strip_indent)
      :false
      ^^^^^^ Symbol with a boolean name - you probably meant to use `false`.
    RUBY
  end

  it 'does not register an offense when using regular symbol' do
    expect_no_offenses(<<-RUBY.strip_indent)
      :something
    RUBY
  end

  it 'does not register an offense when using `true`' do
    expect_no_offenses(<<-RUBY.strip_indent)
      true
    RUBY
  end

  it 'does not register an offense when using `false`' do
    expect_no_offenses(<<-RUBY.strip_indent)
      false
    RUBY
  end
end
