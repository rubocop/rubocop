# frozen_string_literal: true

describe RuboCop::Cop::Style::VariableInterpolation do
  subject(:cop) { described_class.new }

  it 'registers an offense for interpolated global variables in string' do
    expect_offense(<<-'RUBY'.strip_indent)
      puts "this is a #$test"
                       ^^^^^ Replace interpolated variable `$test` with expression `#{$test}`.
    RUBY
  end

  it 'registers an offense for interpolated global variables in regexp' do
    expect_offense(<<-'RUBY'.strip_indent)
      puts /this is a #$test/
                       ^^^^^ Replace interpolated variable `$test` with expression `#{$test}`.
    RUBY
  end

  it 'registers an offense for interpolated global variables in backticks' do
    expect_offense(<<-'RUBY'.strip_indent)
      puts `this is a #$test`
                       ^^^^^ Replace interpolated variable `$test` with expression `#{$test}`.
    RUBY
  end

  it 'registers an offense for interpolated regexp nth back references' do
    expect_offense(<<-'RUBY'.strip_indent)
      puts "this is a #$1"
                       ^^ Replace interpolated variable `$1` with expression `#{$1}`.
    RUBY
  end

  it 'registers an offense for interpolated regexp back references' do
    expect_offense(<<-'RUBY'.strip_indent)
      puts "this is a #$+"
                       ^^ Replace interpolated variable `$+` with expression `#{$+}`.
    RUBY
  end

  it 'registers an offense for interpolated instance variables' do
    expect_offense(<<-'RUBY'.strip_indent)
      puts "this is a #@test"
                       ^^^^^ Replace interpolated variable `@test` with expression `#{@test}`.
    RUBY
  end

  it 'registers an offense for interpolated class variables' do
    expect_offense(<<-'RUBY'.strip_indent)
      puts "this is a #@@t"
                       ^^^ Replace interpolated variable `@@t` with expression `#{@@t}`.
    RUBY
  end

  it 'does not register an offense for variables in expressions' do
    expect_no_offenses('puts "this is a #{@test} #{@@t} #{$t} #{$1} #{$+}"')
  end

  it 'autocorrects by adding the missing {}' do
    corrected = autocorrect_source(cop, ['"some #@var"'])
    expect(corrected).to eq '"some #{@var}"'
  end
end
