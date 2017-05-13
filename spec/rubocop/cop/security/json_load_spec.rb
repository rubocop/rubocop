# frozen_string_literal: true

describe RuboCop::Cop::Security::JSONLoad, :config do
  subject(:cop) { described_class.new(config) }

  it 'registers an offense for JSON.load' do
    expect_offense(<<-RUBY.strip_indent)
      JSON.load(arg)
           ^^^^ Prefer `JSON.parse` over `JSON.load`.
      ::JSON.load(arg)
             ^^^^ Prefer `JSON.parse` over `JSON.load`.
    RUBY
  end

  it 'registers an offense for JSON.restore' do
    expect_offense(<<-RUBY.strip_indent)
      JSON.restore(arg)
           ^^^^^^^ Prefer `JSON.parse` over `JSON.restore`.
      ::JSON.restore(arg)
             ^^^^^^^ Prefer `JSON.parse` over `JSON.restore`.
    RUBY
  end

  it 'does not register an offense for JSON under another namespace' do
    expect_no_offenses(<<-RUBY.strip_indent)
      SomeModule::JSON.load(arg)
      SomeModule::JSON.restore(arg)
    RUBY
  end

  it 'allows JSON.parse' do
    expect_no_offenses(<<-RUBY.strip_indent)
      JSON.parse(arg)
      ::JSON.parse(arg)
    RUBY
  end

  it 'allows JSON.dump' do
    expect_no_offenses(<<-RUBY.strip_indent)
      JSON.dump(arg)
      ::JSON.dump(arg)
    RUBY
  end
end
