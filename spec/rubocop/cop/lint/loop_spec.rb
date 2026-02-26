# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::Loop, :config do
  it 'registers an offense and corrects for begin/end/while' do
    expect_offense(<<~RUBY)
      begin
        something
      end while test
          ^^^^^ Use `Kernel#loop` with `break` rather than `begin/end/until`(or `while`).
    RUBY

    expect_correction(<<~RUBY)
      loop do
        something
      break unless test
      end
    RUBY
  end

  it 'registers an offense for begin/end/until' do
    expect_offense(<<~RUBY)
      begin
        something
      end until test
          ^^^^^ Use `Kernel#loop` with `break` rather than `begin/end/until`(or `while`).
    RUBY

    expect_correction(<<~RUBY)
      loop do
        something
      break if test
      end
    RUBY
  end

  it 'accepts loop/break unless' do
    expect_no_offenses('loop do; one; two; break unless test; end')
  end

  it 'accepts loop/break if' do
    expect_no_offenses('loop do; one; two; break if test; end')
  end
end
