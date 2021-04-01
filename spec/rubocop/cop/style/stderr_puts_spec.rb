# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::StderrPuts, :config do
  it "registers an offense when using `$stderr.puts('hello')`" do
    expect_offense(<<~RUBY)
      $stderr.puts('hello')
      ^^^^^^^^^^^^ Use `warn` instead of `$stderr.puts` to allow such output to be disabled.
    RUBY

    expect_correction(<<~RUBY)
      warn('hello')
    RUBY
  end

  it 'registers no offense when using `$stderr.puts` with no arguments' do
    expect_no_offenses(<<~RUBY)
      $stderr.puts
    RUBY
  end

  it "registers an offense when using `STDERR.puts('hello')`" do
    expect_offense(<<~RUBY)
      STDERR.puts('hello')
      ^^^^^^^^^^^ Use `warn` instead of `STDERR.puts` to allow such output to be disabled.
    RUBY

    expect_correction(<<~RUBY)
      warn('hello')
    RUBY
  end

  it "registers an offense when using `::STDERR.puts('hello')`" do
    expect_offense(<<~RUBY)
      ::STDERR.puts('hello')
      ^^^^^^^^^^^^^ Use `warn` instead of `::STDERR.puts` to allow such output to be disabled.
    RUBY

    expect_correction(<<~RUBY)
      warn('hello')
    RUBY
  end

  it 'registers no offense when using `STDERR.puts` with no arguments' do
    expect_no_offenses(<<~RUBY)
      STDERR.puts
    RUBY
  end
end
