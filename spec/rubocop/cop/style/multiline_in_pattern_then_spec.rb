# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MultilineInPatternThen, :config do
  context '>= Ruby 2.7', :ruby27 do
    it 'registers an offense for empty `in` statement with `then`' do
      expect_offense(<<~RUBY)
        case foo
        in bar then
               ^^^^ Do not use `then` for multiline `in` statement.
        end
      RUBY

      expect_correction(<<~RUBY)
        case foo
        in bar
        end
      RUBY
    end

    it 'registers an offense for multiline (one line in a body) `in` statement with `then`' do
      expect_offense(<<~RUBY)
        case foo
        in bar then
               ^^^^ Do not use `then` for multiline `in` statement.
        do_something
        end
      RUBY

      expect_correction(<<~RUBY)
        case foo
        in bar
        do_something
        end
      RUBY
    end

    it 'registers an offense for multiline (two lines in a body) `in` statement with `then`' do
      expect_offense(<<~RUBY)
        case foo
        in bar then
               ^^^^ Do not use `then` for multiline `in` statement.
        do_something1
        do_something2
        end
      RUBY

      expect_correction(<<~RUBY)
        case foo
        in bar
        do_something1
        do_something2
        end
      RUBY
    end

    it "doesn't register an offense for singleline `in` statement with `then`" do
      expect_no_offenses(<<~RUBY)
        case foo
        in bar then do_something
        end
      RUBY
    end

    it "doesn't register an offense when `then` required for a body of `in` is used" do
      expect_no_offenses(<<~RUBY)
        case cond
        in foo then do_something(arg1,
                                 arg2)
        end
      RUBY
    end

    it "doesn't register an offense for multiline `in` statement with `then` followed by other lines" do
      expect_no_offenses(<<~RUBY)
        case foo
        in bar then do_something
                    do_another_thing
        end
      RUBY
    end

    it "doesn't register an offense for empty `in` statement without `then`" do
      expect_no_offenses(<<~RUBY)
        case foo
        in bar
        end
      RUBY
    end

    it "doesn't register an offense for multiline `in` statement without `then`" do
      expect_no_offenses(<<~RUBY)
        case foo
        in bar
        do_something
        end
      RUBY
    end

    it 'does not register an offense for hash `in` statement with `then`' do
      expect_no_offenses(<<~RUBY)
        case condition
        in foo then {
            key: 'value'
          }
        end
      RUBY
    end

    it 'does not register an offense for array `when` statement with `then`' do
      expect_no_offenses(<<~RUBY)
        case condition
        in foo then [
            'element'
          ]
        end
      RUBY
    end

    it 'autocorrects when the body of `in` branch starts with `then`' do
      expect_offense(<<~RUBY)
        case foo
        in bar
          then do_something
          ^^^^ Do not use `then` for multiline `in` statement.
        end
      RUBY

      expect_correction(<<~RUBY)
        case foo
        in bar
         do_something
        end
      RUBY
    end

    it 'registers an offense when one line for multiple candidate values of `in`' do
      expect_offense(<<~RUBY)
        case foo
        in bar, baz then
                    ^^^^ Do not use `then` for multiline `in` statement.
        end
      RUBY

      expect_correction(<<~RUBY)
        case foo
        in bar, baz
        end
      RUBY
    end

    it 'does not register an offense when line break for multiple candidate values of `in`' do
      expect_no_offenses(<<~RUBY)
        case foo
        in bar,
           baz then do_something
        end
      RUBY
    end
  end
end
