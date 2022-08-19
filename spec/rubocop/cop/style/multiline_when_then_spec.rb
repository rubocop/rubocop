# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MultilineWhenThen, :config do
  it 'registers an offense for empty when statement with then' do
    expect_offense(<<~RUBY)
      case foo
      when bar then
               ^^^^ Do not use `then` for multiline `when` statement.
      end
    RUBY

    expect_correction(<<~RUBY)
      case foo
      when bar
      end
    RUBY
  end

  it 'registers an offense for multiline (one line in a body) when statement with then' do
    expect_offense(<<~RUBY)
      case foo
      when bar then
               ^^^^ Do not use `then` for multiline `when` statement.
      do_something
      end
    RUBY

    expect_correction(<<~RUBY)
      case foo
      when bar
      do_something
      end
    RUBY
  end

  it 'registers an offense for multiline (two lines in a body) when statement with then' do
    expect_offense(<<~RUBY)
      case foo
      when bar then
               ^^^^ Do not use `then` for multiline `when` statement.
      do_something1
      do_something2
      end
    RUBY

    expect_correction(<<~RUBY)
      case foo
      when bar
      do_something1
      do_something2
      end
    RUBY
  end

  it "doesn't register an offense for singleline when statement with then" do
    expect_no_offenses(<<~RUBY)
      case foo
      when bar then do_something
      end
    RUBY
  end

  it "doesn't register an offense when `then` required for a body of `when` is used" do
    expect_no_offenses(<<~RUBY)
      case cond
      when foo then do_something(arg1,
                                 arg2)
      end
    RUBY
  end

  it "doesn't register an offense for multiline when statement" \
     'with then followed by other lines' do
    expect_no_offenses(<<~RUBY)
      case foo
      when bar then do_something
                    do_another_thing
      end
    RUBY
  end

  it "doesn't register an offense for empty when statement without then" do
    expect_no_offenses(<<~RUBY)
      case foo
      when bar
      end
    RUBY
  end

  it "doesn't register an offense for multiline when statement without then" do
    expect_no_offenses(<<~RUBY)
      case foo
      when bar
      do_something
      end
    RUBY
  end

  it 'does not register an offense for hash when statement with then' do
    expect_no_offenses(<<~RUBY)
      case condition
      when foo then {
          key: 'value'
        }
      end
    RUBY
  end

  it 'does not register an offense for array when statement with then' do
    expect_no_offenses(<<~RUBY)
      case condition
      when foo then [
          'element'
        ]
      end
    RUBY
  end

  it 'autocorrects when the body of `when` branch starts with `then`' do
    expect_offense(<<~RUBY)
      case foo
      when bar
        then do_something
        ^^^^ Do not use `then` for multiline `when` statement.
      end
    RUBY

    expect_correction(<<~RUBY)
      case foo
      when bar
       do_something
      end
    RUBY
  end

  it 'registers an offense when one line for multiple candidate values of `when`' do
    expect_offense(<<~RUBY)
      case foo
      when bar, baz then
                    ^^^^ Do not use `then` for multiline `when` statement.
      end
    RUBY

    expect_correction(<<~RUBY)
      case foo
      when bar, baz
      end
    RUBY
  end

  it 'does not register an offense when line break for multiple candidate values of `when`' do
    expect_no_offenses(<<~RUBY)
      case foo
      when bar,
           baz then do_something
      end
    RUBY
  end
end
