# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ToJson, :config do
  it 'registers an offense when using JSON.generate' do
    expect_offense(<<~RUBY)
      JSON.generate(foo)
      ^^^^^^^^^^^^^^^^^^ Use `.to_json` instead of `JSON.generate`.
    RUBY

    expect_correction(<<~RUBY)
      foo.to_json
    RUBY
  end

  it 'recognizes fully qualified reference to JSON' do
    expect_offense(<<~RUBY)
      ::JSON.generate(foo)
      ^^^^^^^^^^^^^^^^^^^^ Use `.to_json` instead of `JSON.generate`.
    RUBY
  end

  it 'correctly autocorrects calls with implicit hashes' do
    expect_offense(<<~RUBY)
      JSON.generate(hello: :world)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `.to_json` instead of `JSON.generate`.
    RUBY

    expect_correction(<<~RUBY)
      { hello: :world }.to_json
    RUBY
  end

  it 'correctly autocorrects calls with serialization options' do
    expect_offense(<<~RUBY)
      JSON.generate(foo, space_before: '  ', space_after: ' ')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `.to_json` instead of `JSON.generate`.
    RUBY

    expect_correction(<<~RUBY)
      foo.to_json(space_before: '  ', space_after: ' ')
    RUBY
  end

  it 'correctly autocorrects calls with serialization options as variable' do
    expect_offense(<<~RUBY)
      JSON.generate(foo, opts)
      ^^^^^^^^^^^^^^^^^^^^^^^^ Use `.to_json` instead of `JSON.generate`.
    RUBY

    expect_correction(<<~RUBY)
      foo.to_json(opts)
    RUBY
  end

  it 'ignores calls to JSON.generate with unexpected arguments' do
    expect_no_offenses(<<~RUBY)
      JSON.generate(foo, bar, baz)
      JSON.generate(one, two, three: true)
      JSON.generate
    RUBY
  end
end
