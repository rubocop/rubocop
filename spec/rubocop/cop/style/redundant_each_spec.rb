# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantEach, :config do
  it 'registers an offense when using `each.each`' do
    expect_offense(<<~RUBY)
      array.each.each { |v| do_something(v) }
           ^^^^^ Remove redundant `each`.
    RUBY

    expect_correction(<<~RUBY)
      array.each { |v| do_something(v) }
    RUBY
  end

  it 'registers an offense when using `each.each(&:foo)`' do
    expect_offense(<<~RUBY)
      array.each.each(&:foo)
           ^^^^^ Remove redundant `each`.
    RUBY

    expect_correction(<<~RUBY)
      array.each(&:foo)
    RUBY
  end

  it 'registers an offense when using `each.each_with_index`' do
    expect_offense(<<~RUBY)
      array.each.each_with_index { |v| do_something(v) }
           ^^^^^ Remove redundant `each`.
    RUBY

    expect_correction(<<~RUBY)
      array.each.with_index { |v| do_something(v) }
    RUBY
  end

  it 'registers an offense when using `each.each_with_object`' do
    expect_offense(<<~RUBY)
      array.each.each_with_object([]) { |v, o| do_something(v, o) }
           ^^^^^ Remove redundant `each`.
    RUBY

    expect_correction(<<~RUBY)
      array.each.with_object([]) { |v, o| do_something(v, o) }
    RUBY
  end

  it 'registers an offense when using a method starting with `each_` with `each_with_index`' do
    expect_offense(<<~RUBY)
      context.each_child_node.each_with_index.any? do |node, index|
                              ^^^^^^^^^^^^^^^ Use `with_index` to remove redundant `each`.
      end
    RUBY

    expect_correction(<<~RUBY)
      context.each_child_node.with_index.any? do |node, index|
      end
    RUBY
  end

  it 'registers an offense when using a method starting with `each_` with `each_with_object`' do
    expect_offense(<<~RUBY)
      context.each_child_node.each_with_object([]) do |node, object|
                              ^^^^^^^^^^^^^^^^ Use `with_object` to remove redundant `each`.
      end
    RUBY

    expect_correction(<<~RUBY)
      context.each_child_node.with_object([]) do |node, object|
      end
    RUBY
  end

  it 'registers an offense when using `reverse_each.each`' do
    expect_offense(<<~RUBY)
      context.reverse_each.each { |i| do_something(i) }
                          ^^^^^ Remove redundant `each`.
    RUBY

    expect_correction(<<~RUBY)
      context.reverse_each { |i| do_something(i) }
    RUBY
  end

  it 'registers an offense when using `each.reverse_each`' do
    expect_offense(<<~RUBY)
      context.each.reverse_each { |i| do_something(i) }
             ^^^^^ Remove redundant `each`.
    RUBY

    expect_correction(<<~RUBY)
      context.reverse_each { |i| do_something(i) }
    RUBY
  end

  it 'registers an offense when using `reverse_each.each_with_index`' do
    expect_offense(<<~RUBY)
      context.reverse_each.each_with_index.any? do |node, index|
                           ^^^^^^^^^^^^^^^ Use `with_index` to remove redundant `each`.
      end
    RUBY

    expect_correction(<<~RUBY)
      context.reverse_each.with_index.any? do |node, index|
      end
    RUBY
  end

  it 'registers an offense when using `reverse_each.each_with_object`' do
    expect_offense(<<~RUBY)
      scope_stack.reverse_each.each_with_object([]) do |scope, variables|
                               ^^^^^^^^^^^^^^^^ Use `with_object` to remove redundant `each`.
      end
    RUBY

    expect_correction(<<~RUBY)
      scope_stack.reverse_each.with_object([]) do |scope, variables|
      end
    RUBY
  end

  it 'does not register an offense when using only single `each`' do
    expect_no_offenses(<<~RUBY)
      array.each { |v| do_something(v) }
    RUBY
  end

  it 'does not register an offense when using `each` as enumerator' do
    expect_no_offenses(<<~RUBY)
      array.each
    RUBY
  end

  it 'does not register an offense when using `each.with_index`' do
    expect_no_offenses(<<~RUBY)
      array.each.with_index { |v, i| do_something(v, i) }
    RUBY
  end

  it 'does not register an offense when using `each_with_index`' do
    expect_no_offenses(<<~RUBY)
      array.each_with_index { |v, i| do_something(v, i) }
    RUBY
  end

  it 'does not register an offense when any method is used between methods with `each` in the method name' do
    expect_no_offenses(<<~RUBY)
      string.each_char.map(&:to_i).reverse.each_with_index.map { |v, i| do_something(v, i) }
    RUBY
  end

  it 'does not register an offense when using `each.with_object`' do
    expect_no_offenses(<<~RUBY)
      array.each.with_object { |v, o| do_something(v, o) }
    RUBY
  end

  it 'does not register an offense when using `each_with_object`' do
    expect_no_offenses(<<~RUBY)
      array.each_with_object { |v, o| do_something(v, o) }
    RUBY
  end

  it 'does not register an offense when using `each_with_index.reverse_each`' do
    expect_no_offenses(<<~RUBY)
      array.each_with_index.reverse_each do |value, index|
      end
    RUBY
  end

  it 'does not register an offense when using `each_ancestor.each`' do
    expect_no_offenses(<<~RUBY)
      node.each_ancestor(:def, :defs, :block).each do |ancestor|
      end
    RUBY
  end

  it 'does not register an offense when using `reverse_each {}.each {}`' do
    expect_no_offenses(<<~RUBY)
      array.reverse_each { |i| foo(i) }.each { |i| bar(i) }
    RUBY
  end

  it 'does not register an offense when using `each {}.reverse_each {}`' do
    expect_no_offenses(<<~RUBY)
      array.each { |i| foo(i) }.reverse_each { |i| bar(i) }
    RUBY
  end

  it 'does not register an offense when using `each {}.each_with_index {}`' do
    expect_no_offenses(<<~RUBY)
      array.each { |i| foo(i) }.each_with_index { |i| bar(i) }
    RUBY
  end

  it 'does not register an offense when using `each {}.each_with_object([]) {}`' do
    expect_no_offenses(<<~RUBY)
      array.each { |i| foo(i) }.each_with_object([]) { |i| bar(i) }
    RUBY
  end

  it 'does not register an offense when using `each_foo {}.each_with_object([]) {}`' do
    expect_no_offenses(<<~RUBY)
      array.each_foo { |i| foo(i) }.each_with_object([]) { |i| bar(i) }
    RUBY
  end

  it 'does not register an offense when not chaining `each_` calls' do
    expect_no_offenses(<<~RUBY)
      [foo.each].each
    RUBY
  end

  it 'does not register an offense when using `each` with a symbol proc argument' do
    expect_no_offenses(<<~RUBY)
      array.each(&:foo).each do |i|
      end
    RUBY
  end

  it 'does not register an offense when using `each` with a symbol proc for last argument' do
    expect_no_offenses(<<~RUBY)
      array.each(foo, &:bar).each do |i|
      end
    RUBY
  end

  it 'does not register an offense when using `reverse_each(&:foo).each {...}`' do
    expect_no_offenses(<<~RUBY)
      array.reverse_each(&:foo).each { |i| bar(i) }
    RUBY
  end
end
