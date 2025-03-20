# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::EnvFetchStringDefault, :config do
  # let(:config) { RuboCop::Config.new }

  it 'registers an offense when using non-string literals as default values' do
    expect_offense(<<~RUBY)
      ENV.fetch("some_key", 0)
                            ^ Use a string as default value for ENV.fetch.
      ENV.fetch("version", 1.2)
                           ^^^ Use a string as default value for ENV.fetch.
      ENV.fetch("version", :foo)
                           ^^^^ Use a string as default value for ENV.fetch.
    RUBY
  end

  it 'does not register an offense when using string as default value' do
    expect_no_offenses(<<~RUBY)
      ENV.fetch("some_key", "0")
    RUBY
  end

  it 'does not register an offense when using non-literals as default value' do
    expect_no_offenses(<<~RUBY)
      ENV.fetch("some_key", a)
      ENV.fetch("some_key", Foo.new(1))
    RUBY
  end

  it 'does not register an offense when using a nil default value' do
    expect_no_offenses(<<~RUBY)
      ENV.fetch("some_key", nil)
    RUBY
  end

  it 'does not register an offense when not using ENV' do
    expect_no_offenses(<<~RUBY)
      Env.fetch("foo", a)
      env.fetch("bar", A.new(1))
      Foo.fetch(a)
      {a: 1}.fetch(:a)
    RUBY
  end
end
