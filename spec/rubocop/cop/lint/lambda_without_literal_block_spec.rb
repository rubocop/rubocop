# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::LambdaWithoutLiteralBlock, :config do
  it 'registers and corrects an offense when using lambda with `&proc {}` block argument' do
    expect_offense(<<~RUBY)
      lambda(&proc { do_something })
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ lambda without a literal block is deprecated; use the proc without lambda instead.
    RUBY

    expect_correction(<<~RUBY)
      proc { do_something }
    RUBY
  end

  it 'registers and corrects an offense when using lambda with `&Proc.new {}` block argument' do
    expect_offense(<<~RUBY)
      lambda(&Proc.new { do_something })
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ lambda without a literal block is deprecated; use the proc without lambda instead.
    RUBY

    expect_correction(<<~RUBY)
      Proc.new { do_something }
    RUBY
  end

  it 'registers and corrects an offense when using lambda with a proc variable block argument' do
    expect_offense(<<~RUBY)
      pr = Proc.new { do_something }
      lambda(&pr)
      ^^^^^^^^^^^ lambda without a literal block is deprecated; use the proc without lambda instead.
    RUBY

    expect_correction(<<~RUBY)
      pr = Proc.new { do_something }
      pr
    RUBY
  end

  it 'does not register an offense when using lambda with a literal block' do
    expect_no_offenses(<<~RUBY)
      lambda { do_something }
    RUBY
  end

  it 'does not register an offense when using `lambda.call`' do
    expect_no_offenses(<<~RUBY)
      lambda.call
    RUBY
  end

  it 'does not register an offense when using lambda with a symbol proc' do
    expect_no_offenses(<<~RUBY)
      lambda(&:do_something)
    RUBY
  end
end
