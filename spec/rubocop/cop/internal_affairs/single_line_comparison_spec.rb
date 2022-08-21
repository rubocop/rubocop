# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::SingleLineComparison, :config do
  it 'registers and corrects an offense when comparing `loc.first_line` with `loc.last_line`' do
    expect_offense(<<~RUBY)
      node.loc.first_line == node.loc.last_line
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.single_line?`.
    RUBY

    expect_correction(<<~RUBY)
      node.single_line?
    RUBY
  end

  it 'registers and corrects an offense when comparing `loc.last_line` with `loc.first_line`' do
    expect_offense(<<~RUBY)
      node.loc.last_line == node.loc.first_line
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.single_line?`.
    RUBY

    expect_correction(<<~RUBY)
      node.single_line?
    RUBY
  end

  it 'registers and corrects an offense when comparing `loc.line` with `loc.last_line`' do
    expect_offense(<<~RUBY)
      node.loc.line == node.loc.last_line
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.single_line?`.
    RUBY

    expect_correction(<<~RUBY)
      node.single_line?
    RUBY
  end

  it 'registers and corrects an offense when comparing `loc.last_line` with `loc.line`' do
    expect_offense(<<~RUBY)
      node.loc.last_line == node.loc.line
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.single_line?`.
    RUBY

    expect_correction(<<~RUBY)
      node.single_line?
    RUBY
  end

  it 'registers and corrects an offense when comparing `source_range.first_line` with `source_range.last_line`' do
    expect_offense(<<~RUBY)
      node.source_range.first_line == node.source_range.last_line
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.single_line?`.
    RUBY

    expect_correction(<<~RUBY)
      node.single_line?
    RUBY
  end

  it 'registers and corrects an offense when comparing `source_range.last_line` with `source_range.first_line`' do
    expect_offense(<<~RUBY)
      node.source_range.last_line == node.source_range.first_line
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.single_line?`.
    RUBY

    expect_correction(<<~RUBY)
      node.single_line?
    RUBY
  end

  it 'registers and corrects an offense when comparing `first_line` with `last_line`' do
    expect_offense(<<~RUBY)
      node.first_line == node.last_line
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.single_line?`.
    RUBY

    expect_correction(<<~RUBY)
      node.single_line?
    RUBY
  end

  it 'registers and corrects an offense when comparing `last_line` with `first_line`' do
    expect_offense(<<~RUBY)
      node.last_line == node.first_line
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.single_line?`.
    RUBY

    expect_correction(<<~RUBY)
      node.single_line?
    RUBY
  end

  it 'registers and corrects an offense when negative comparing `first_line` with `last_line`' do
    expect_offense(<<~RUBY)
      node.first_line != node.last_line
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `!node.single_line?`.
    RUBY

    expect_correction(<<~RUBY)
      !node.single_line?
    RUBY
  end

  it 'registers and corrects an offense when negative comparing `last_line` with `first_line`' do
    expect_offense(<<~RUBY)
      node.last_line != node.first_line
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `!node.single_line?`.
    RUBY

    expect_correction(<<~RUBY)
      !node.single_line?
    RUBY
  end

  it 'does not register an offense when comparing the same line' do
    expect_no_offenses(<<~RUBY)
      node.loc.first_line == node.loc.line
    RUBY
  end

  it 'does not register an offense when the receivers are not a match' do
    expect_no_offenses(<<~RUBY)
      nodes.first.first_line == nodes.last.last_line
    RUBY
  end
end
