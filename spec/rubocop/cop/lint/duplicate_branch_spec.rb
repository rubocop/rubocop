# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::DuplicateBranch do
  subject(:cop) { described_class.new }

  it 'registers an offense when `if` has duplicate `else` branch' do
    expect_offense(<<~RUBY)
      if foo
        do_foo
      else
      ^^^^ Duplicate branch body detected.
        do_foo
      end

      if foo
        do_foo
        do_something_else
      else
      ^^^^ Duplicate branch body detected.
        do_foo
        do_something_else
      end
    RUBY
  end

  it 'registers an offense when `unless` has duplicate `else` branch' do
    expect_offense(<<~RUBY)
      unless foo
        do_bar
      else
      ^^^^ Duplicate branch body detected.
        do_bar
      end
    RUBY
  end

  it 'registers an offense when `if` has duplicate `elsif` branch' do
    expect_offense(<<~RUBY)
      if foo
        do_foo
      elsif bar
      ^^^^^^^^^ Duplicate branch body detected.
        do_foo
      end
    RUBY
  end

  it 'registers an offense when `if` has multiple duplicate branches' do
    expect_offense(<<~RUBY)
      if foo
        do_foo
      elsif bar
        do_bar
      elsif baz
      ^^^^^^^^^ Duplicate branch body detected.
        do_foo
      elsif quux
      ^^^^^^^^^^ Duplicate branch body detected.
        do_bar
      end
    RUBY
  end

  it 'does not register an offense when `if` has no duplicate branches' do
    expect_no_offenses(<<~RUBY)
      if foo
        do_foo
      elsif bar
        do_bar
      end
    RUBY
  end

  it 'does not register an offense when `unless` has no duplicate branches' do
    expect_no_offenses(<<~RUBY)
      unless foo
        do_bar
      else
        do_foo
      end
    RUBY
  end

  it 'does not register an offense for simple `if` without other branches' do
    expect_no_offenses(<<~RUBY)
      if foo
        do_foo
      end
    RUBY
  end

  it 'does not register an offense for simple `unless` without other branches' do
    expect_no_offenses(<<~RUBY)
      unless foo
        do_bar
      end
    RUBY
  end

  it 'does not register an offense for empty `if`' do
    expect_no_offenses(<<~RUBY)
      if foo
        # Comment.
      end
    RUBY
  end

  it 'does not register an offense for empty `unless`' do
    expect_no_offenses(<<~RUBY)
      unless foo
        # Comment.
      end
    RUBY
  end

  it 'does not register an offense for modifier `if`' do
    expect_no_offenses(<<~RUBY)
      do_foo if foo
    RUBY
  end

  it 'does not register an offense for modifier `unless`' do
    expect_no_offenses(<<~RUBY)
      do_bar unless foo
    RUBY
  end

  it 'registers an offense when ternary has duplicate branches' do
    expect_offense(<<~RUBY)
      res = foo ? do_foo : do_foo
                           ^^^^^^ Duplicate branch body detected.
    RUBY
  end

  it 'does not register an offense when ternary has no duplicate branches' do
    expect_no_offenses(<<~RUBY)
      res = foo ? do_foo : do_bar
    RUBY
  end

  it 'registers an offense when `case` has duplicate `when` branch' do
    expect_offense(<<~RUBY)
      case x
      when foo
        do_foo
      when bar
      ^^^^^^^^ Duplicate branch body detected.
        do_foo
      end
    RUBY
  end

  it 'registers an offense when `case` has duplicate `else` branch' do
    expect_offense(<<~RUBY)
      case x
      when foo
        do_foo
      else
      ^^^^ Duplicate branch body detected.
        do_foo
      end
    RUBY
  end

  it 'registers an offense when `case` has multiple duplicate branches' do
    expect_offense(<<~RUBY)
      case x
      when foo
        do_foo
      when bar
        do_bar
      when baz
      ^^^^^^^^ Duplicate branch body detected.
        do_foo
      when quux
      ^^^^^^^^^ Duplicate branch body detected.
        do_bar
      end
    RUBY
  end

  it 'does not register an offense when `case` has no duplicate branches' do
    expect_no_offenses(<<~RUBY)
      case x
      when foo
        do_foo
      when bar
        do_bar
      end
    RUBY
  end

  it 'registers an offense when `rescue` has duplicate `resbody` branch' do
    expect_offense(<<~RUBY)
      begin
        do_something
      rescue FooError
        handle_error(x)
      rescue BarError
      ^^^^^^^^^^^^^^^ Duplicate branch body detected.
        handle_error(x)
      end
    RUBY
  end

  it 'registers an offense when `rescue` has duplicate `else` branch' do
    expect_offense(<<~RUBY)
      begin
        do_something
      rescue FooError
        handle_error(x)
      else
      ^^^^ Duplicate branch body detected.
        handle_error(x)
      end
    RUBY
  end

  it 'registers an offense when `rescue` has multiple duplicate `resbody` branches' do
    expect_offense(<<~RUBY)
      begin
        do_something
      rescue FooError
        handle_foo_error(x)
      rescue BarError
        handle_bar_error(x)
      rescue BazError
      ^^^^^^^^^^^^^^^ Duplicate branch body detected.
        handle_foo_error(x)
      rescue QuuxError
      ^^^^^^^^^^^^^^^^ Duplicate branch body detected.
        handle_bar_error(x)
      end
    RUBY
  end

  it 'does not register an offense when `rescue` has no duplicate branches' do
    expect_no_offenses(<<~RUBY)
      begin
        do_something
      rescue FooError
        handle_foo_error(x)
      rescue BarError
        handle_bar_error(x)
      end
    RUBY
  end
end
