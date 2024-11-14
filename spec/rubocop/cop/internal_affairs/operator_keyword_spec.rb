# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::OperatorKeyword, :config do
  it 'registers an offense when using `node.and_type? || node.or_type?`' do
    expect_offense(<<~RUBY)
      node.and_type? || node.or_type?
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.operator_keyword?`.
    RUBY

    expect_correction(<<~RUBY)
      node.operator_keyword?
    RUBY
  end

  it 'registers an offense when using `node.or_type? || node.and_type?`' do
    expect_offense(<<~RUBY)
      node.or_type? || node.and_type?
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.operator_keyword?`.
    RUBY

    expect_correction(<<~RUBY)
      node.operator_keyword?
    RUBY
  end

  it 'registers an offense when using `node.parenthesized? || node.and_type? || node.or_type?`' do
    expect_offense(<<~RUBY)
      node.parenthesized? || node.and_type? || node.or_type?
                             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.operator_keyword?`.
    RUBY

    expect_correction(<<~RUBY)
      node.parenthesized? || node.operator_keyword?
    RUBY
  end

  it 'registers an offense when using `node.parenthesized? || node.or_type? || node.and_type?`' do
    expect_offense(<<~RUBY)
      node.parenthesized? || node.or_type? || node.and_type?
                             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.operator_keyword?`.
    RUBY

    expect_correction(<<~RUBY)
      node.parenthesized? || node.operator_keyword?
    RUBY
  end

  it 'does not register an offense when using `node.operator_keyword?`' do
    expect_no_offenses(<<~RUBY)
      node.operator_keyword?
    RUBY
  end

  it 'does not register an offense when LHS and RHS have different receivers' do
    expect_no_offenses(<<~RUBY)
      node1.and_type? || node2.or_type?
    RUBY
  end
end
