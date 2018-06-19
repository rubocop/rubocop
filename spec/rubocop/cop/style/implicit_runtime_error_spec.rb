# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ImplicitRuntimeError do
  subject(:cop) { described_class.new }

  it 'registers an offense for `raise` without error class' do
    expect_offense(<<-RUBY.strip_indent)
      raise 'message'
      ^^^^^^^^^^^^^^^ Use `raise` with an explicit exception class and message, rather than just a message.
    RUBY
  end

  it 'registers an offense for `fail` without error class' do
    expect_offense(<<-RUBY.strip_indent)
      fail 'message'
      ^^^^^^^^^^^^^^ Use `fail` with an explicit exception class and message, rather than just a message.
    RUBY
  end

  it 'registers an offense for `raise` with a multiline string' do
    expect_offense(<<-RUBY.strip_indent)
      raise 'message' \\
      ^^^^^^^^^^^^^^^^^ Use `raise` with an explicit exception class and message, rather than just a message.
            '2nd line'
    RUBY
  end

  it 'registers an offense for `fail` with a multiline string' do
    expect_offense(<<-RUBY.strip_indent)
      fail 'message' \\
      ^^^^^^^^^^^^^^^^ Use `fail` with an explicit exception class and message, rather than just a message.
            '2nd line'
    RUBY
  end

  it 'does not register an offense for `raise` with an error class' do
    expect_no_offenses(<<-RUBY.strip_indent)
      raise StandardError, 'message'
    RUBY
  end

  it 'does not register an offense for `fail` with an error class' do
    expect_no_offenses(<<-RUBY.strip_indent)
      fail StandardError, 'message'
    RUBY
  end

  it 'does not register an offense for `raise` without arguments' do
    expect_no_offenses('raise')
  end

  it 'does not register an offense for `fail` without arguments' do
    expect_no_offenses('fail')
  end
end
