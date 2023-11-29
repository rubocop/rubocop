# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::LiteralAssignmentInCondition, :config do
  it 'registers an offense when assigning literal to local variable in `if` condition' do
    expect_offense(<<~RUBY)
      if test = 42
              ^^^^ Don't use literal assignment `= 42` in conditional, should be `==` or non-literal operand.
      end
    RUBY
  end

  it 'does not register an offense when assigning non-literal to local variable in `if` condition' do
    expect_no_offenses(<<~RUBY)
      if test = do_something
      end
    RUBY
  end

  it 'registers an offense when assigning literal to local variable in `while` condition' do
    expect_offense(<<~RUBY)
      while test = 42
                 ^^^^ Don't use literal assignment `= 42` in conditional, should be `==` or non-literal operand.
      end
    RUBY
  end

  it 'registers an offense when assigning literal to local variable in `until` condition' do
    expect_offense(<<~RUBY)
      until test = 42
                 ^^^^ Don't use literal assignment `= 42` in conditional, should be `==` or non-literal operand.
      end
    RUBY
  end

  it 'registers an offense when assigning literal to instance variable in condition' do
    expect_offense(<<~RUBY)
      if @test = 42
               ^^^^ Don't use literal assignment `= 42` in conditional, should be `==` or non-literal operand.
      end
    RUBY
  end

  it 'registers an offense when assigning literal to class variable in condition' do
    expect_offense(<<~RUBY)
      if @@test = 42
                ^^^^ Don't use literal assignment `= 42` in conditional, should be `==` or non-literal operand.
      end
    RUBY
  end

  it 'registers an offense when assigning literal to global variable in condition' do
    expect_offense(<<~RUBY)
      if $test = 42
               ^^^^ Don't use literal assignment `= 42` in conditional, should be `==` or non-literal operand.
      end
    RUBY
  end

  it 'registers an offense when assigning literal to constant in condition' do
    expect_offense(<<~RUBY)
      if TEST = 42
              ^^^^ Don't use literal assignment `= 42` in conditional, should be `==` or non-literal operand.
      end
    RUBY
  end

  it 'does not register an offense when assigning literal to collection element in condition' do
    expect_no_offenses(<<~RUBY)
      if collection[index] = 42
      end
    RUBY
  end

  it 'does not register an offense when `==` in condition' do
    expect_no_offenses(<<~RUBY)
      if test == 10
      end
    RUBY
  end

  it 'registers an offense when assigning after `== `in condition' do
    expect_offense(<<~RUBY)
      if test == 10 || foo = 1
                           ^^^ Don't use literal assignment `= 1` in conditional, should be `==` or non-literal operand.
      end
    RUBY
  end

  it 'does not register an offense when `=` in a block that is called in a condition' do
    expect_no_offenses('return 1 if any_errors? { o = inspect(file) }')
  end

  it 'does not register an offense when `=` in a block followed by method call' do
    expect_no_offenses('return 1 if any_errors? { o = file }.present?')
  end

  it 'does not register an offense when assignment in a block after `||`' do
    expect_no_offenses(<<~RUBY)
      if x?(bar) || y? { z = baz }
        foo
      end
    RUBY
  end

  it 'registers an offense when `=` in condition inside a block' do
    expect_offense(<<~RUBY)
      foo { x if y = 42 }
                   ^^^^ Don't use literal assignment `= 42` in conditional, should be `==` or non-literal operand.
    RUBY
  end

  it 'does not register an offense when `=` in condition inside a block' do
    expect_no_offenses(<<~RUBY)
      foo { x if y = z }
    RUBY
  end

  it 'does not register an offense when `||=` in condition' do
    expect_no_offenses('raise StandardError unless foo ||= bar')
  end

  it 'registers an offense when literal assignment after `||=` in condition' do
    expect_offense(<<~RUBY)
      raise StandardError unless (foo ||= bar) || a = 42
                                                    ^^^^ Don't use literal assignment `= 42` in conditional, should be `==` or non-literal operand.
    RUBY
  end

  it 'does not register an offense when assigning non-literal after `||=` in condition' do
    expect_no_offenses(<<~RUBY)
      raise StandardError unless (foo ||= bar) || a = b
    RUBY
  end

  it 'does not register an offense when assignment method in condition' do
    expect_no_offenses(<<~RUBY)
      if test.method = 42
      end
    RUBY
  end

  it 'does not blow up when empty `if` condition' do
    expect_no_offenses(<<~RUBY)
      if ()
      end
    RUBY
  end

  it 'does not blow up when empty `unless` condition' do
    expect_no_offenses(<<~RUBY)
      unless ()
      end
    RUBY
  end

  it 'registers when `=` in condition surrounded with braces' do
    expect_offense(<<~RUBY)
      if (test = 42)
               ^^^^ Don't use literal assignment `= 42` in conditional, should be `==` or non-literal operand.
      end
    RUBY
  end
end
