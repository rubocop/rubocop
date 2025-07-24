# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::NodeTypeGroup, :config do
  it 'registers an offense when using `type?` with entire `numeric` group' do
    expect_offense(<<~RUBY)
      node.type?(:int, :float, :rational, :complex)
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `:numeric` instead of individually listing group types.
    RUBY

    expect_correction(<<~RUBY)
      node.numeric_type?
    RUBY
  end

  it 'registers an offense when using `type?` with entire `numeric` group in any order' do
    expect_offense(<<~RUBY)
      node.type?(:rational, :complex, :int, :float)
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `:numeric` instead of individually listing group types.
    RUBY

    expect_correction(<<~RUBY)
      node.numeric_type?
    RUBY
  end

  it 'registers an offense when using `type?` with entire `numeric` when other types are present' do
    expect_offense(<<~RUBY)
      node.type?(:rational, :complex, :send, :int, :float, :def)
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `:numeric` instead of individually listing group types.
    RUBY

    expect_correction(<<~RUBY)
      node.type?(:numeric, :send, :def)
    RUBY
  end

  it 'registers an offense when using `type?` with multiple groups' do
    expect_offense(<<~RUBY)
      node.type?(:rational, :complex, :irange, :int, :float, :erange)
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `:numeric` instead of individually listing group types.
    RUBY

    expect_correction(<<~RUBY)
      node.type?(:numeric, :range)
    RUBY
  end

  it 'registers an offense when using `type?` and other node types as argument' do
    expect_offense(<<~RUBY)
      node.type?(bar, :irange, foo, :erange)
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `:range` instead of individually listing group types.
    RUBY

    expect_correction(<<~RUBY)
      node.type?(bar, :range, foo)
    RUBY
  end

  it 'registers an offense for save navigation' do
    expect_offense(<<~RUBY)
      node&.type?(:irange, :erange)
                  ^^^^^^^^^^^^^^^^ Use `:range` instead of individually listing group types.
    RUBY

    expect_correction(<<~RUBY)
      node&.range_type?
    RUBY
  end

  it 'registers an offense when chained to a method call' do
    expect_offense(<<~RUBY)
      node.each_child_node(:irange, :erange).any?
                           ^^^^^^^^^^^^^^^^ Use `:range` instead of individually listing group types.
    RUBY

    expect_correction(<<~RUBY)
      node.each_child_node(:range).any?
    RUBY
  end

  it 'registers an offense when chained to a method call with block' do
    expect_offense(<<~RUBY)
      node.each_child_node(:irange, :erange).any? do |node|
                           ^^^^^^^^^^^^^^^^ Use `:range` instead of individually listing group types.
        foo?(node)
      end
    RUBY

    expect_correction(<<~RUBY)
      node.each_child_node(:range).any? do |node|
        foo?(node)
      end
    RUBY
  end

  it 'registers no offense when the group is incomplete' do
    expect_no_offenses(<<~RUBY)
      node.type?(:int, :float, :complex)
    RUBY
  end

  it 'registers no offense with no arguments' do
    expect_no_offenses(<<~RUBY)
      node.type?
    RUBY
  end

  it 'registers no offense when there is no receiver' do
    expect_no_offenses(<<~RUBY)
      type?(:irange, :erange)
    RUBY
  end

  %i[each_ancestor each_child_node each_descendant each_node].each do |method|
    it "registers an offense for #{method}" do
      expect_offense(<<~RUBY, method: method)
        node.#{method}(:irange, :erange)
             _{method} ^^^^^^^^^^^^^^^^ Use `:range` instead of individually listing group types.
      RUBY

      expect_correction(<<~RUBY)
        node.#{method}(:range)
      RUBY
    end
  end
end
