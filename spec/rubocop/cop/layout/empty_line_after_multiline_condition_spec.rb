# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EmptyLineAfterMultilineCondition, :config do
  it 'registers an offense when no new line after `if` with multiline condition' do
    expect_offense(<<~RUBY)
      if multiline &&
         ^^^^^^^^^^^^ Use empty line after multiline condition.
         condition
        do_something
      end
    RUBY
  end

  it 'does not register an offense when new line after `if` with multiline condition' do
    expect_no_offenses(<<~RUBY)
      if multiline &&
         condition

        do_something
      end
    RUBY
  end

  it 'does not register an offense for `if` with single line condition' do
    expect_no_offenses(<<~RUBY)
      if singleline
        do_something
      end
    RUBY
  end

  it 'registers an offense when no new line after modifier `if` with multiline condition' do
    expect_offense(<<~RUBY)
      do_something if multiline &&
                      ^^^^^^^^^^^^ Use empty line after multiline condition.
                      condition
      do_something_else
    RUBY
  end

  it 'does not register an offense when new line after modifier `if` with multiline condition' do
    expect_no_offenses(<<~RUBY)
      do_something if multiline &&
                      condition

      do_something_else
    RUBY
  end

  it 'does not register an offense when modifier `if` with multiline condition' \
     'is the last child of its parent' do
    expect_no_offenses(<<~RUBY)
      def m
        do_something if multiline &&
                      condition
      end
    RUBY
  end

  it 'does not register an offense when `if` at the top level' do
    expect_no_offenses(<<~RUBY)
      do_something if condition
    RUBY
  end

  it 'registers an offense when no new line after `elsif` with multiline condition' do
    expect_offense(<<~RUBY)
      if condition
        do_something
      elsif multiline &&
            ^^^^^^^^^^^^ Use empty line after multiline condition.
         condition
        do_something_else
      end
    RUBY
  end

  it 'does not register an offense when new line after `elsif` with multiline condition' do
    expect_no_offenses(<<~RUBY)
      if condition
        do_something
      elsif multiline &&
         condition

        do_something_else
      end
    RUBY
  end

  it 'registers an offense when no new line after `while` with multiline condition' do
    expect_offense(<<~RUBY)
      while multiline &&
            ^^^^^^^^^^^^ Use empty line after multiline condition.
         condition
        do_something
      end
    RUBY
  end

  it 'registers an offense when no new line after `until` with multiline condition' do
    expect_offense(<<~RUBY)
      until multiline &&
            ^^^^^^^^^^^^ Use empty line after multiline condition.
         condition
        do_something
      end
    RUBY
  end

  it 'does not register an offense when new line after `while` with multiline condition' do
    expect_no_offenses(<<~RUBY)
      while multiline &&
         condition

        do_something
      end
    RUBY
  end

  it 'does not register an offense for `while` with single line condition' do
    expect_no_offenses(<<~RUBY)
      while singleline
        do_something
      end
    RUBY
  end

  it 'registers an offense when no new line after modifier `while` with multiline condition' do
    expect_offense(<<~RUBY)
      begin
        do_something
      end while multiline &&
                ^^^^^^^^^^^^ Use empty line after multiline condition.
            condition
      do_something_else
    RUBY
  end

  it 'does not register an offense when new line after modifier `while` with multiline condition' do
    expect_no_offenses(<<~RUBY)
      begin
        do_something
      end while multiline &&
            condition

      do_something_else
    RUBY
  end

  it 'does not register an offense when modifier `while` with multiline condition' \
     'is the last child of its parent' do
    expect_no_offenses(<<~RUBY)
      def m
        begin
          do_something
        end while multiline &&
              condition
      end
    RUBY
  end

  it 'registers an offense when no new line after `when` with multiline condition' do
    expect_offense(<<~RUBY)
      case x
      when foo,
      ^^^^^^^^^ Use empty line after multiline condition.
          bar
        do_something
      end
    RUBY
  end

  it 'does not register an offense when new line after `when` with multiline condition' do
    expect_no_offenses(<<~RUBY)
      case x
      when foo,
          bar

        do_something
      end
    RUBY
  end

  it 'does not register an offense for `when` with singleline condition' do
    expect_no_offenses(<<~RUBY)
      case x
      when foo, bar
        do_something
      end
    RUBY
  end

  it 'registers an offense when no new line after `rescue` with multiline exceptions' do
    expect_offense(<<~RUBY)
      begin
        do_something
      rescue FooError,
      ^^^^^^^^^^^^^^^^ Use empty line after multiline condition.
        BarError
        handle_error
      end
    RUBY
  end

  it 'does not register an offense when new line after `rescue` with multiline exceptions' do
    expect_no_offenses(<<~RUBY)
      begin
        do_something
      rescue FooError,
        BarError

        handle_error
      end
    RUBY
  end

  it 'does not register an offense for `rescue` with singleline exceptions' do
    expect_no_offenses(<<~RUBY)
      begin
        do_something
      rescue FooError
        handle_error
      end
    RUBY
  end
end
