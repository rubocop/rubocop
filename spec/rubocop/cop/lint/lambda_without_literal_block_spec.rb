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

  it 'does not drop a heredoc body before the block argument' do
    expect_offense(<<~RUBY)
      dispatch(<<~TEXT, lambda(
                        ^^^^^^^ lambda without a literal block is deprecated; use the proc without lambda instead.
        hello
      TEXT
        &callback))
    RUBY

    expect_no_corrections
  end

  it 'does not drop a comment after the block argument' do
    expect_offense(<<~RUBY)
      lambda(&callback # keep
      ^^^^^^^^^^^^^^^^^^^^^^^ lambda without a literal block is deprecated; use the proc without lambda instead.
      )
    RUBY

    expect_no_corrections
  end

  it 'preserves a comment inside the proc' do
    expect_offense(<<~RUBY)
      lambda(&proc {
      ^^^^^^^^^^^^^^ lambda without a literal block is deprecated; use the proc without lambda instead.
        # keep
        work
      })
    RUBY

    expect_correction(<<~RUBY)
      proc {
        # keep
        work
      }
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

  it 'registers an offense and keeps safe navigation in the block argument when correcting' do
    expect_offense(<<~RUBY)
      lambda(&obj&.foo)
      ^^^^^^^^^^^^^^^^^ lambda without a literal block is deprecated; use the proc without lambda instead.
    RUBY

    expect_correction(<<~RUBY)
      obj&.foo
    RUBY
  end
end
