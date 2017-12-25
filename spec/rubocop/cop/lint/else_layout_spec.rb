# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ElseLayout do
  subject(:cop) { described_class.new }

  it 'registers an offense for expr on same line as else' do
    expect_offense(<<-RUBY.strip_indent)
      if something
        test
      else ala
           ^^^ Odd `else` layout detected. Did you mean to use `elsif`?
        something
        test
      end
    RUBY
  end

  it 'accepts proper else' do
    expect_no_offenses(<<-RUBY.strip_indent)
      if something
        test
      else
        something
        test
      end
    RUBY
  end

  it 'accepts single-expr else regardless of layout' do
    expect_no_offenses(<<-RUBY.strip_indent)
      if something
        test
      else bala
      end
    RUBY
  end

  it 'can handle elsifs' do
    expect_offense(<<-RUBY.strip_indent)
      if something
        test
      elsif something
        bala
      else ala
           ^^^ Odd `else` layout detected. Did you mean to use `elsif`?
        something
        test
      end
    RUBY
  end

  it 'handles ternary ops' do
    expect_no_offenses('x ? a : b')
  end

  it 'handles modifier forms' do
    expect_no_offenses('x if something')
  end
end
