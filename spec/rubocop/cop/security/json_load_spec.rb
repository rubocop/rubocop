# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Security::JSONLoad, :config do
  subject(:cop) { described_class.new(config) }

  it 'registers an offense for JSON.load' do
    expect_offense(<<~RUBY)
      JSON.load(arg)
           ^^^^ Prefer `JSON.parse` over `JSON.load`.
      ::JSON.load(arg)
             ^^^^ Prefer `JSON.parse` over `JSON.load`.
    RUBY
  end

  it 'registers an offense for JSON.restore' do
    expect_offense(<<~RUBY)
      JSON.restore(arg)
           ^^^^^^^ Prefer `JSON.parse` over `JSON.restore`.
      ::JSON.restore(arg)
             ^^^^^^^ Prefer `JSON.parse` over `JSON.restore`.
    RUBY
  end

  it 'does not register an offense for JSON under another namespace' do
    expect_no_offenses(<<~RUBY)
      SomeModule::JSON.load(arg)
      SomeModule::JSON.restore(arg)
    RUBY
  end

  it 'allows JSON.parse' do
    expect_no_offenses(<<~RUBY)
      JSON.parse(arg)
      ::JSON.parse(arg)
    RUBY
  end

  it 'allows JSON.dump' do
    expect_no_offenses(<<~RUBY)
      JSON.dump(arg)
      ::JSON.dump(arg)
    RUBY
  end

  it 'autocorrects .load to .parse' do
    expect(autocorrect_source('JSON.load(arg)')).to eq 'JSON.parse(arg)'
  end
end
