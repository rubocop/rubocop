# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::SelfAssignment, :config do
  it 'registers an offense when using local var self-assignment' do
    expect_offense(<<~RUBY)
      foo = foo
      ^^^^^^^^^ Self-assignment detected.
    RUBY
  end

  it 'does not register an offense when using local var assignment' do
    expect_no_offenses(<<~RUBY)
      foo = bar
    RUBY
  end

  it 'registers an offense when using instance var self-assignment' do
    expect_offense(<<~RUBY)
      @foo = @foo
      ^^^^^^^^^^^ Self-assignment detected.
    RUBY
  end

  it 'does not register an offense when using instance var assignment' do
    expect_no_offenses(<<~RUBY)
      @foo = @bar
    RUBY
  end

  it 'registers an offense when using class var self-assignment' do
    expect_offense(<<~RUBY)
      @@foo = @@foo
      ^^^^^^^^^^^^^ Self-assignment detected.
    RUBY
  end

  it 'does not register an offense when using class var assignment' do
    expect_no_offenses(<<~RUBY)
      @@foo = @@bar
    RUBY
  end

  it 'registers an offense when using global var self-assignment' do
    expect_offense(<<~RUBY)
      $foo = $foo
      ^^^^^^^^^^^ Self-assignment detected.
    RUBY
  end

  it 'does not register an offense when using global var assignment' do
    expect_no_offenses(<<~RUBY)
      $foo = $bar
    RUBY
  end

  it 'registers an offense when using constant var self-assignment' do
    expect_offense(<<~RUBY)
      Foo = Foo
      ^^^^^^^^^ Self-assignment detected.
    RUBY
  end

  it 'does not register an offense when using constant var assignment for constant from another scope' do
    expect_no_offenses(<<~RUBY)
      Foo = ::Foo
    RUBY
  end

  it 'does not register an offense when using constant var or-assignment for constant from another scope' do
    expect_no_offenses(<<~RUBY)
      Foo ||= ::Foo
    RUBY
  end

  it 'registers an offense when using multiple var self-assignment' do
    expect_offense(<<~RUBY)
      foo, bar = foo, bar
      ^^^^^^^^^^^^^^^^^^^ Self-assignment detected.
    RUBY
  end

  it 'registers an offense when using multiple var self-assignment through array' do
    expect_offense(<<~RUBY)
      foo, bar = [foo, bar]
      ^^^^^^^^^^^^^^^^^^^^^ Self-assignment detected.
    RUBY
  end

  it 'does not register an offense when using multiple var assignment' do
    expect_no_offenses(<<~RUBY)
      foo, bar = bar, foo
    RUBY
  end

  it 'does not register an offense when using multiple var assignment through splat' do
    expect_no_offenses(<<~RUBY)
      foo, bar = *something
    RUBY
  end

  it 'does not register an offense when using multiple var assignment through method call' do
    expect_no_offenses(<<~RUBY)
      foo, bar = something
    RUBY
  end

  it 'registers an offense when using shorthand-or var self-assignment' do
    expect_offense(<<~RUBY)
      foo ||= foo
      ^^^^^^^^^^^ Self-assignment detected.
    RUBY
  end

  it 'does not register an offense when using shorthand-or var assignment' do
    expect_no_offenses(<<~RUBY)
      foo ||= bar
    RUBY
  end

  it 'registers an offense when using shorthand-and var self-assignment' do
    expect_offense(<<~RUBY)
      foo &&= foo
      ^^^^^^^^^^^ Self-assignment detected.
    RUBY
  end

  it 'does not register an offense when using shorthand-and var assignment' do
    expect_no_offenses(<<~RUBY)
      foo &&= bar
    RUBY
  end
end
