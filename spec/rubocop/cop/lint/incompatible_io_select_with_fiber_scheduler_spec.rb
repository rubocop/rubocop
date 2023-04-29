# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::IncompatibleIoSelectWithFiberScheduler, :config do
  it 'registers and corrects an offense when using `IO.select` with single read argument' do
    expect_offense(<<~RUBY)
      IO.select([io], [], [])
      ^^^^^^^^^^^^^^^^^^^^^^^ Use `io.wait_readable` instead of `IO.select([io], [], [])`.
    RUBY

    expect_correction(<<~RUBY)
      io.wait_readable
    RUBY
  end

  it 'registers and corrects an offense when using `IO.select` with single read argument and specify the first argument only' do
    expect_offense(<<~RUBY)
      IO.select([io])
      ^^^^^^^^^^^^^^^ Use `io.wait_readable` instead of `IO.select([io])`.
    RUBY

    expect_correction(<<~RUBY)
      io.wait_readable
    RUBY
  end

  it 'registers and corrects an offense when using `IO.select` with single read and timeout arguments' do
    expect_offense(<<~RUBY)
      IO.select([io], [], [], timeout)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `io.wait_readable(timeout)` instead of `IO.select([io], [], [], timeout)`.
    RUBY

    expect_correction(<<~RUBY)
      io.wait_readable(timeout)
    RUBY
  end

  it 'registers and corrects an offense when using `::IO.select` with single read argument' do
    expect_offense(<<~RUBY)
      ::IO.select([io], [], [])
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `io.wait_readable` instead of `::IO.select([io], [], [])`.
    RUBY

    expect_correction(<<~RUBY)
      io.wait_readable
    RUBY
  end

  it 'registers and corrects an offense when using `::IO.select` with single read and timeout arguments' do
    expect_offense(<<~RUBY)
      ::IO.select([io], [], [], timeout)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `io.wait_readable(timeout)` instead of `::IO.select([io], [], [], timeout)`.
    RUBY

    expect_correction(<<~RUBY)
      io.wait_readable(timeout)
    RUBY
  end

  it 'registers and corrects an offense when using `IO.select` with single read, `nil`, and timeout arguments' do
    expect_offense(<<~RUBY)
      IO.select([io], nil, nil, timeout)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `io.wait_readable(timeout)` instead of `IO.select([io], nil, nil, timeout)`.
    RUBY

    expect_correction(<<~RUBY)
      io.wait_readable(timeout)
    RUBY
  end

  it 'registers and corrects an offense when using `IO.select` with single write, `nil`, and timeout arguments' do
    expect_offense(<<~RUBY)
      IO.select(nil, [io], nil, timeout)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `io.wait_writable(timeout)` instead of `IO.select(nil, [io], nil, timeout)`.
    RUBY

    expect_correction(<<~RUBY)
      io.wait_writable(timeout)
    RUBY
  end

  it 'registers and corrects an offense when using `IO.select` with single write argument' do
    expect_offense(<<~RUBY)
      IO.select([], [io], [])
      ^^^^^^^^^^^^^^^^^^^^^^^ Use `io.wait_writable` instead of `IO.select([], [io], [])`.
    RUBY

    expect_correction(<<~RUBY)
      io.wait_writable
    RUBY
  end

  it 'registers and corrects an offense when using `IO.select` with single write and timeout arguments' do
    expect_offense(<<~RUBY)
      IO.select([], [io], [], timeout)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `io.wait_writable(timeout)` instead of `IO.select([], [io], [], timeout)`.
    RUBY

    expect_correction(<<~RUBY)
      io.wait_writable(timeout)
    RUBY
  end

  it 'registers and corrects an offense when using `IO.select` with single read as `self` and timeout arguments' do
    expect_offense(<<~RUBY)
      IO.select([self], nil, nil, timeout)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `self.wait_readable(timeout)` instead of `IO.select([self], nil, nil, timeout)`.
    RUBY

    expect_correction(<<~RUBY)
      self.wait_readable(timeout)
    RUBY
  end

  it 'registers and corrects an offense when using `IO.select` with single write as `self` and timeout arguments' do
    expect_offense(<<~RUBY)
      IO.select(nil, [self], nil, timeout)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `self.wait_writable(timeout)` instead of `IO.select(nil, [self], nil, timeout)`.
    RUBY

    expect_correction(<<~RUBY)
      self.wait_writable(timeout)
    RUBY
  end

  it 'registers an offense when using `IO.select` with read argument and using return value but does not autocorrect' do
    expect_offense(<<~RUBY)
      rs, _ = IO.select([rp], [])
              ^^^^^^^^^^^^^^^^^^^ Use `rp.wait_readable` instead of `IO.select([rp], [])`.
    RUBY

    expect_no_corrections
  end

  it 'registers an offense when using `IO.select` with write argument and using return value but does not autocorrect' do
    expect_offense(<<~RUBY)
      _, ws = IO.select([], [wp])
              ^^^^^^^^^^^^^^^^^^^ Use `wp.wait_writable` instead of `IO.select([], [wp])`.
    RUBY

    expect_no_corrections
  end

  it 'does not register an offense when using `IO.select` with multiple read arguments' do
    expect_no_offenses(<<~RUBY)
      IO.select([foo, bar], [], [])
    RUBY
  end

  it 'registers and corrects an offense when using `IO.select` with multiple read argument and specify the first argument only' do
    expect_no_offenses(<<~RUBY)
      IO.select([foo, bar])
    RUBY
  end

  it 'does not register an offense when using `IO.select` with multiple write arguments' do
    expect_no_offenses(<<~RUBY)
      IO.select([], [foo, bar], [])
    RUBY
  end

  it 'does not register an offense when using `IO.select` with read and write arguments' do
    expect_no_offenses(<<~RUBY)
      IO.select([rp], [wp], [])
    RUBY
  end

  it 'does not register an offense when using `IO.select` with read and excepts arguments' do
    expect_no_offenses(<<~RUBY)
      IO.select([rp], [], [excepts])
    RUBY
  end

  it 'does not register an offense when using `Enumerable#select`' do
    expect_no_offenses(<<~RUBY)
      collection.select { |item| item.do_something? }
    RUBY
  end
end
