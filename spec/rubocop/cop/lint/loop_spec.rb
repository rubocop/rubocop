# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::Loop do
  subject(:cop) { described_class.new }

  it 'registers an offense for begin/end/while' do
    expect_offense(<<-RUBY.strip_indent)
      begin something; top; end while test
                                ^^^^^ Use `Kernel#loop` with `break` rather than `begin/end/until`(or `while`).
    RUBY
  end

  it 'registers an offense for begin/end/until' do
    expect_offense(<<-RUBY.strip_indent)
      begin something; top; end until test
                                ^^^^^ Use `Kernel#loop` with `break` rather than `begin/end/until`(or `while`).
    RUBY
  end

  it 'accepts normal while' do
    expect_no_offenses('while test; one; two; end')
  end

  it 'accepts normal until' do
    expect_no_offenses('until test; one; two; end')
  end
end
