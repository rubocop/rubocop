# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ModuleMemberExistenceCheck, :config do
  it 'registers an offense when using `.instance_methods.include?(method)`' do
    expect_offense(<<~RUBY)
      x.instance_methods.include?(method)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `method_defined?(method)` instead.
    RUBY

    expect_correction(<<~RUBY)
      x.method_defined?(method)
    RUBY
  end

  it 'registers an offense when using `.instance_methods.include? method`' do
    expect_offense(<<~RUBY)
      x.instance_methods.include? method
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `method_defined?(method)` instead.
    RUBY

    expect_correction(<<~RUBY)
      x.method_defined?(method)
    RUBY
  end

  it 'registers an offense when using `.instance_methods.member?(method)`' do
    expect_offense(<<~RUBY)
      x.instance_methods.member?(method)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `method_defined?(method)` instead.
    RUBY

    expect_correction(<<~RUBY)
      x.method_defined?(method)
    RUBY
  end

  it 'registers an offense when using `&.instance_methods&.include?(method)`' do
    expect_offense(<<~RUBY)
      x&.instance_methods&.include?(method)
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `method_defined?(method)` instead.
    RUBY

    expect_correction(<<~RUBY)
      x&.method_defined?(method)
    RUBY
  end

  it 'registers an offense when using `instance_methods.include?(method)`' do
    expect_offense(<<~RUBY)
      instance_methods.include?(method)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `method_defined?(method)` instead.
    RUBY

    expect_correction(<<~RUBY)
      method_defined?(method)
    RUBY
  end

  it 'registers an offense when using `.instance_methods(false).include?(method)`' do
    expect_offense(<<~RUBY)
      x.instance_methods(false).include?(method)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `method_defined?(method, false)` instead.
    RUBY

    expect_correction(<<~RUBY)
      x.method_defined?(method, false)
    RUBY
  end

  it 'registers an offense when using `.instance_methods(true).include?(method)`' do
    expect_offense(<<~RUBY)
      x.instance_methods(true).include?(method)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `method_defined?(method)` instead.
    RUBY

    expect_correction(<<~RUBY)
      x.method_defined?(method)
    RUBY
  end

  it 'registers an offense when using `.instance_methods(inherit).include?(method)`' do
    expect_offense(<<~RUBY)
      x.instance_methods(inherit).include?(method)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `method_defined?(method, inherit)` instead.
    RUBY

    expect_correction(<<~RUBY)
      x.method_defined?(method, inherit)
    RUBY
  end

  it 'does not register an offense when passing more than one argument to `instance_methods`' do
    expect_no_offenses(<<~RUBY)
      x.instance_methods(true, false).include?(method)
    RUBY
  end

  it 'does not register an offense when passing more than one argument to `include?`' do
    expect_no_offenses(<<~RUBY)
      x.instance_methods.include?(foo, bar)
    RUBY
  end

  it 'does not register an offense when passing a splat argument to `include?`' do
    expect_no_offenses(<<~RUBY)
      x.instance_methods.include?(*foo)
    RUBY
  end

  it 'does not register an offense when passing a kwargs argument to `include?`' do
    expect_no_offenses(<<~RUBY)
      x.instance_methods.include?(**foo)
    RUBY
  end

  it 'does not register an offense when passing a block argument to `include?`' do
    expect_no_offenses(<<~RUBY)
      x.instance_methods.include?(&foo)
    RUBY
  end

  it 'does not register an offense when passing a splat argument to `instance_methods`' do
    expect_no_offenses(<<~RUBY)
      x.instance_methods(*foo).include?(method)
    RUBY
  end
end
