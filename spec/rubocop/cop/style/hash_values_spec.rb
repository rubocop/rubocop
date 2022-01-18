# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::HashValues, :config do
  let(:ruby_version) { 3.1 }

  it 'registers an offense when using legacy hash literal value syntax' do
    expect_offense(<<~RUBY)
      { foo: foo, bar: bar }
                  ^^^^^^^^ Use the Ruby 3.1 hash literal value syntax when your hash key and value are the same.
        ^^^^^^^^ Use the Ruby 3.1 hash literal value syntax when your hash key and value are the same.
    RUBY

    expect_correction(<<~RUBY)
      { foo:, bar: }
    RUBY
  end

  it 'registers an offense when using a mixture of legacy and Ruby 3.1 hash literal value syntax' do
    expect_offense(<<~RUBY)
      { foo:, bar: bar }
              ^^^^^^^^ Use the Ruby 3.1 hash literal value syntax when your hash key and value are the same.
    RUBY

    expect_correction(<<~RUBY)
      { foo:, bar: }
    RUBY
  end

  it 'registers an offense when using legacy hash literal value syntax in a multiline hash literal' do
    expect_offense(<<~RUBY)
      {
        foo: foo,
        ^^^^^^^^ Use the Ruby 3.1 hash literal value syntax when your hash key and value are the same.
        bar: bar
        ^^^^^^^^ Use the Ruby 3.1 hash literal value syntax when your hash key and value are the same.
      }
    RUBY

    expect_correction(<<~RUBY)
      {
        foo:,
        bar:
      }
    RUBY
  end

  it 'does not register an offense when Ruby 3.1 hash literal syntax' do
    expect_no_offenses(<<~RUBY)
      { foo:, bar: }
    RUBY
  end
end
