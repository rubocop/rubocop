# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::LambdaOrProc, :config do
  it 'registers an offense when using `node.lambda? || node.proc?`' do
    expect_offense(<<~RUBY)
      node.lambda? || node.proc?
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.lambda_or_proc?`.
    RUBY

    expect_correction(<<~RUBY)
      node.lambda_or_proc?
    RUBY
  end

  it 'registers an offense when using `node.proc? || node.lambda?`' do
    expect_offense(<<~RUBY)
      node.proc? || node.lambda?
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.lambda_or_proc?`.
    RUBY

    expect_correction(<<~RUBY)
      node.lambda_or_proc?
    RUBY
  end

  it 'registers an offense when using `node.parenthesized? || node.lambda? || node.proc?`' do
    expect_offense(<<~RUBY)
      node.parenthesized? || node.lambda? || node.proc?
                             ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.lambda_or_proc?`.
    RUBY

    expect_correction(<<~RUBY)
      node.parenthesized? || node.lambda_or_proc?
    RUBY
  end

  it 'registers an offense when using `node.parenthesized? || node.proc? || node.lambda?`' do
    expect_offense(<<~RUBY)
      node.parenthesized? || node.proc? || node.lambda?
                             ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `node.lambda_or_proc?`.
    RUBY

    expect_correction(<<~RUBY)
      node.parenthesized? || node.lambda_or_proc?
    RUBY
  end

  it 'does not register an offense when using `node.lambda_or_proc?`' do
    expect_no_offenses(<<~RUBY)
      node.lambda_or_proc?
    RUBY
  end

  it 'does not register an offense when LHS and RHS have different receivers' do
    expect_no_offenses(<<~RUBY)
      node1.lambda? || node2.proc?
    RUBY
  end
end
