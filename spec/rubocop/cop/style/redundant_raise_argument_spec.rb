# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantRaiseArgument, :config do
  it 'registers an offense when re-raising rescued error explicitly' do
    expect_offense(<<~RUBY)
      begin
      rescue StandardError => e
        foo

        raise e
              ^ Remove redundant argument to `raise`.
      end
    RUBY

    # INFO: Lint/UselessAssignment removes the assignment to `e`
    expect_correction(<<~RUBY)
      begin
      rescue StandardError => e
        foo

        raise
      end
    RUBY
  end

  it 'registers an offense when re-raising rescued error explicitly with `fail`' do
    expect_offense(<<~RUBY)
      begin
      rescue StandardError => e
        foo

        fail e
             ^ Remove redundant argument to `fail`.
      end
    RUBY

    expect_correction(<<~RUBY)
      begin
      rescue StandardError => e
        foo

        fail
      end
    RUBY
  end

  it 'registers an offense when reassigning rescued error after `raise`' do
    expect_offense(<<~RUBY)
      begin
      rescue StandardError => e
        raise e if foo
              ^ Remove redundant argument to `raise`.
        e = MyError.new
        raise e
      end
    RUBY

    expect_correction(<<~RUBY)
      begin
      rescue StandardError => e
        raise if foo
        e = MyError.new
        raise e
      end
    RUBY
  end

  it 'does not register an offense when re-raising rescued error implicitly' do
    expect_no_offenses(<<~RUBY)
      begin
      rescue StandardError => e
        foo

        raise
      end
    RUBY
  end

  # INFO: this is handled by Lint/UselessRescue
  it 'does not register an offense only when re-raising the error in `rescue` block' do
    expect_no_offenses(<<~RUBY)
      begin
      rescue StandardError => e
        raise e
      end
    RUBY
  end

  it 'does not register an offense when `raise` is given more than one argument' do
    expect_no_offenses(<<~RUBY)
      begin
      rescue StandardError => e
        foo

        raise e, 'a different message'
      end
    RUBY
  end

  it 'does not register an offense when raising with a different argument' do
    expect_no_offenses(<<~RUBY)
      begin
      rescue StandardError => e
        foo

        raise bar
      end
    RUBY
  end

  it 'does not register an offense when reassigning the rescued error' do
    expect_no_offenses(<<~RUBY)
      begin
      rescue StandardError => e
        e = MyError.new

        raise e
      end
    RUBY
  end

  it 'does not register an offense when reassigning rescued error in parallel assignment' do
    expect_no_offenses(<<~RUBY)
      begin
      rescue StandardError => e
        e, foo = MyError.new, :foo

        raise e
      end
    RUBY
  end

  it 'does not register an offense with empty `rescue` body' do
    expect_no_offenses(<<~RUBY)
      begin
      rescue StandardError => e
      end
    RUBY
  end

  it 'does not register an offense when exception variable is not assigned' do
    expect_no_offenses(<<~RUBY)
      begin
      rescue StandardError
        foo

        raise bar
      end
    RUBY
  end
end
