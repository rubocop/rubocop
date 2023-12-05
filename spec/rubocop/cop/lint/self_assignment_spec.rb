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

  it 'registers an offense when using attribute self-assignment' do
    expect_offense(<<~RUBY)
      foo.bar = foo.bar
      ^^^^^^^^^^^^^^^^^ Self-assignment detected.
    RUBY
  end

  it 'registers an offense when using attribute self-assignment with a safe navigation call' do
    expect_offense(<<~RUBY)
      foo&.bar = foo&.bar
      ^^^^^^^^^^^^^^^^^^^ Self-assignment detected.
    RUBY
  end

  it 'does not register an offense when using attribute assignment with different attributes' do
    expect_no_offenses(<<~RUBY)
      foo.bar = foo.baz
    RUBY
  end

  it 'does not register an offense when using attribute assignment with different receivers' do
    expect_no_offenses(<<~RUBY)
      bar.foo = baz.foo
    RUBY
  end

  it 'does not register an offense when using attribute assignment with extra expression' do
    expect_no_offenses(<<~RUBY)
      foo.bar = foo.bar + 1
    RUBY
  end

  it 'does not register an offense when using attribute assignment with method call with arguments' do
    expect_no_offenses(<<~RUBY)
      foo.bar = foo.bar(arg)
    RUBY
  end

  it 'does not register an offense when using attribute assignment with literals' do
    expect_no_offenses(<<~RUBY)
      foo.bar = true
    RUBY
  end

  it 'registers an offense when using []= self-assignment with same string literals' do
    expect_offense(<<~RUBY)
      foo["bar"] = foo["bar"]
      ^^^^^^^^^^^^^^^^^^^^^^^ Self-assignment detected.
    RUBY
  end

  it 'does not register an offense when using []= self-assignment with different string literals' do
    expect_no_offenses(<<~RUBY)
      foo["bar"] = foo["baz"]
    RUBY
  end

  it 'registers an offense when using []= self-assignment with same integer literals' do
    expect_offense(<<~RUBY)
      foo[1] = foo[1]
      ^^^^^^^^^^^^^^^ Self-assignment detected.
    RUBY
  end

  it 'does not register an offense when using []= self-assignment with different integer literals' do
    expect_no_offenses(<<~RUBY)
      foo[1] = foo[2]
    RUBY
  end

  it 'registers an offense when using []= self-assignment with same float literals' do
    expect_offense(<<~RUBY)
      foo[1.2] = foo[1.2]
      ^^^^^^^^^^^^^^^^^^^ Self-assignment detected.
    RUBY
  end

  it 'does not register an offense when using []= self-assignment with different float literals' do
    expect_no_offenses(<<~RUBY)
      foo[1.2] = foo[2.2]
    RUBY
  end

  it 'registers an offense when using []= self-assignment with same constant reference' do
    expect_offense(<<~RUBY)
      foo[Foo] = foo[Foo]
      ^^^^^^^^^^^^^^^^^^^ Self-assignment detected.
    RUBY
  end

  it 'does not register an offense when using []= self-assignment with different constant references' do
    expect_no_offenses(<<~RUBY)
      foo[Foo] = foo[Bar]
    RUBY
  end

  it 'registers an offense when using []= self-assignment with same symbol literals' do
    expect_offense(<<~RUBY)
      foo[:bar] = foo[:bar]
      ^^^^^^^^^^^^^^^^^^^^^ Self-assignment detected.
    RUBY
  end

  it 'does not register an offense when using []= self-assignment with different symbol literals' do
    expect_no_offenses(<<~RUBY)
      foo[:foo] = foo[:bar]
    RUBY
  end

  it 'registers an offense when using []= self-assignment with same local variables' do
    expect_offense(<<~RUBY)
      var = 1
      foo[var] = foo[var]
      ^^^^^^^^^^^^^^^^^^^ Self-assignment detected.
    RUBY
  end

  it 'does not register an offense when using []= self-assignment with different local variables' do
    expect_no_offenses(<<~RUBY)
      var1 = 1
      var2 = 2
      foo[var1] = foo[var2]
    RUBY
  end

  it 'registers an offense when using []= self-assignment with same instance variables' do
    expect_offense(<<~RUBY)
      foo[@var] = foo[@var]
      ^^^^^^^^^^^^^^^^^^^^^ Self-assignment detected.
    RUBY
  end

  it 'does not register an offense when using []= self-assignment with different instance variables' do
    expect_no_offenses(<<~RUBY)
      foo[@var1] = foo[@var2]
    RUBY
  end

  it 'registers an offense when using []= self-assignment with same class variables' do
    expect_offense(<<~RUBY)
      foo[@@var] = foo[@@var]
      ^^^^^^^^^^^^^^^^^^^^^^^ Self-assignment detected.
    RUBY
  end

  it 'does not register an offense when using []= self-assignment with different class variables' do
    expect_no_offenses(<<~RUBY)
      foo[@@var1] = foo[@@var2]
    RUBY
  end

  it 'registers an offense when using []= self-assignment with same global variables' do
    expect_offense(<<~RUBY)
      foo[$var] = foo[$var]
      ^^^^^^^^^^^^^^^^^^^^^ Self-assignment detected.
    RUBY
  end

  it 'does not register an offense when using []= self-assignment with different global variables' do
    expect_no_offenses(<<~RUBY)
      foo[$var1] = foo[$var2]
    RUBY
  end

  it 'does not register an offense when using []= assignment with method calls' do
    expect_no_offenses(<<~RUBY)
      foo[bar] = foo[bar]
    RUBY
  end

  it 'does not register an offense when using []= assignment with different receivers' do
    expect_no_offenses(<<~RUBY)
      bar["foo"] = baz["foo"]
    RUBY
  end

  it 'does not register an offense when using []= assignment with extra expression' do
    expect_no_offenses(<<~RUBY)
      foo["bar"] = foo["bar"] + 1
    RUBY
  end

  it 'registers an offense when using []= self-assignment with a safe navigation method call' do
    expect_offense(<<~RUBY)
      foo&.[]=("bar", foo["bar"])
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Self-assignment detected.
    RUBY
  end
end
