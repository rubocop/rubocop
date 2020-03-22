# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::Loop do
  subject(:cop) { described_class.new }

  it 'registers an offense for begin/end/while' do
    expect_offense(<<~RUBY)
      begin something; top; end while test
                                ^^^^^ Use `Kernel#loop` with `break` rather than `begin/end/until`(or `while`).
    RUBY
  end

  it 'registers an offense for begin/end/until' do
    expect_offense(<<~RUBY)
      begin something; top; end until test
                                ^^^^^ Use `Kernel#loop` with `break` rather than `begin/end/until`(or `while`).
    RUBY
  end

  it 'accepts loop/break unless' do
    expect_no_offenses('loop do; one; two; break unless test; end')
  end

  it 'accepts loop/break if' do
    expect_no_offenses('loop do; one; two; break if test; end')
  end
end
