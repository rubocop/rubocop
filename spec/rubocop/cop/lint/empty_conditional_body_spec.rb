# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::EmptyConditionalBody, :config do
  let(:cop_config) { { 'AllowComments' => true } }

  it 'registers an offense for missing `if` body' do
    expect_offense(<<~RUBY)
      if condition
      ^^^^^^^^^^^^ Avoid `if` branches without a body.
      end
    RUBY

    expect_correction('')
  end

  it 'registers an offense for missing `if` and `else` body' do
    expect_offense(<<~RUBY)
      if condition
      ^^^^^^^^^^^^ Avoid `if` branches without a body.
      else
      end
    RUBY

    expect_correction('')
  end

  it 'registers an offense for missing `if` and `else` body with some indentation' do
    expect_offense(<<~RUBY)
      def foo
        if condition
        ^^^^^^^^^^^^ Avoid `if` branches without a body.
        else
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
          end
    RUBY
  end

  it 'registers an offense for missing `if` body with present `else` body' do
    expect_offense(<<~RUBY)
      class Foo
        if condition
        ^^^^^^^^^^^^ Avoid `if` branches without a body.
        else
          do_something
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        unless condition
          do_something
        end
      end
    RUBY
  end

  # This case is registered by `Style/IfWithSemicolon` cop. Therefore, this cop does not handle it.
  it 'does not register an offense for missing `if` body with present `else` body on single line' do
    expect_no_offenses(<<~RUBY)
      if condition; else do_something end
    RUBY
  end

  it 'does not register an offense for missing `if` body with a comment' do
    expect_no_offenses(<<~RUBY)
      if condition
        # noop
      end
    RUBY
  end

  it 'does not register an offense for missing 2nd `elsif` body with a comment' do
    expect_no_offenses(<<~RUBY)
      if condition1
        do_something1
      elsif condition2
        do_something2
      elsif condition3
        # noop
      end
    RUBY
  end

  it 'does not register an offense for missing 3rd `elsif` body with a comment' do
    expect_no_offenses(<<~RUBY)
      if condition1
        do_something1
      elsif condition2
        do_something2
      elsif condition3
        do_something3
      elsif condition4
        # noop
      end
    RUBY
  end

  it 'registers an offense for missing `elsif` body' do
    expect_offense(<<~RUBY)
      if condition
        do_something1
      elsif other_condition1
      ^^^^^^^^^^^^^^^^^^^^^^ Avoid `elsif` branches without a body.
      elsif other_condition2
        do_something2
      end
    RUBY

    expect_correction(<<~RUBY)
      if condition
        do_something1
      elsif other_condition2
        do_something2
      end
    RUBY
  end

  it 'registers an offense for missing `if` and `elsif` body' do
    expect_offense(<<~RUBY)
      if condition
      ^^^^^^^^^^^^ Avoid `if` branches without a body.
      elsif other_condition1
      ^^^^^^^^^^^^^^^^^^^^^^ Avoid `elsif` branches without a body.
      elsif other_condition2
        do_something
      end
    RUBY

    expect_correction(<<~RUBY)
      if other_condition2
        do_something
      end
    RUBY
  end

  it 'registers an offense for missing all branches of `if` and `elsif` body' do
    expect_offense(<<~RUBY)
      if condition
      ^^^^^^^^^^^^ Avoid `if` branches without a body.
      elsif other_condition
      ^^^^^^^^^^^^^^^^^^^^^ Avoid `elsif` branches without a body.
      end
    RUBY

    expect_correction('')
  end

  it 'registers an offense for missing all branches of `if` and multiple `elsif` body' do
    expect_offense(<<~RUBY)
      if condition
      ^^^^^^^^^^^^ Avoid `if` branches without a body.
      elsif other_condition1
      ^^^^^^^^^^^^^^^^^^^^^^ Avoid `elsif` branches without a body.
      elsif other_condition2
      ^^^^^^^^^^^^^^^^^^^^^^ Avoid `elsif` branches without a body.
      end
    RUBY

    expect_correction('')
  end

  it 'registers an offense for missing `if` body with `else`' do
    expect_offense(<<~RUBY)
      if condition
      ^^^^^^^^^^^^ Avoid `if` branches without a body.
      else
        do_something
      end
    RUBY

    expect_correction(<<~RUBY)
      unless condition
        do_something
      end
    RUBY
  end

  it 'registers an offense for missing `unless` body with `else`' do
    expect_offense(<<~RUBY)
      unless condition
      ^^^^^^^^^^^^^^^^ Avoid `unless` branches without a body.
      else
        do_something
      end
    RUBY

    expect_correction(<<~RUBY)
      if condition
        do_something
      end
    RUBY
  end

  it 'registers an offense for missing `unless` and `else` body' do
    expect_offense(<<~RUBY)
      unless condition
      ^^^^^^^^^^^^^^^^ Avoid `unless` branches without a body.
      else
      end
    RUBY

    expect_correction('')
  end

  it 'registers an offense for missing `if` body with `elsif`' do
    expect_offense(<<~RUBY)
      if condition
      ^^^^^^^^^^^^ Avoid `if` branches without a body.
      elsif other_condition
        do_something
      elsif another_condition
        do_something_else
      end
    RUBY

    expect_correction(<<~RUBY)
      if other_condition
        do_something
      elsif another_condition
        do_something_else
      end
    RUBY
  end

  it 'does not register an offense for missing `elsif` body with a comment' do
    expect_no_offenses(<<~RUBY)
      if condition
        do_something
      elsif other_condition
        # noop
      end
    RUBY
  end

  it 'registers an offense for missing `elsif` body that is not the one with a comment' do
    expect_offense(<<~RUBY)
      if condition
        do_something
      elsif other_condition
      ^^^^^^^^^^^^^^^^^^^^^ Avoid `elsif` branches without a body.
      else
        # noop
      end
    RUBY

    expect_correction(<<~RUBY)
      if condition
        do_something
      else
        # noop
      end
    RUBY
  end

  it 'does not register an offense for missing `elsif` body with an inline comment' do
    expect_no_offenses(<<~RUBY)
      if condition
        do_something
      elsif other_condition # no op, but avoid going into the else
      else
        do_other_things
      end
    RUBY
  end

  it 'registers an offense for missing second `elsif` body without an inline comment' do
    expect_offense(<<~RUBY)
      if foo
        do_foo
      elsif bar
        do_bar
      elsif baz
      ^^^^^^^^^ Avoid `elsif` branches without a body.
      end
    RUBY

    expect_correction(<<~RUBY)
      if foo
        do_foo
      elsif bar
        do_bar
      end
    RUBY
  end

  it 'registers an offense for missing `unless` body' do
    expect_offense(<<~RUBY)
      unless condition
      ^^^^^^^^^^^^^^^^ Avoid `unless` branches without a body.
      end
    RUBY

    expect_correction('')
  end

  it 'registers an offense when missing `if` body and using method call for return value' do
    expect_offense(<<~RUBY)
      if condition
      ^^^^^^^^^^^^ Avoid `if` branches without a body.
      end.do_something
    RUBY

    expect_no_corrections
  end

  it 'registers an offense when missing `if` body and using safe navigation method call for return value' do
    expect_offense(<<~RUBY)
      if condition
      ^^^^^^^^^^^^ Avoid `if` branches without a body.
      end&.do_something
    RUBY

    expect_no_corrections
  end

  it 'does not register an offense for missing `unless` body with a comment' do
    expect_no_offenses(<<~RUBY)
      unless condition
        # noop
      end
    RUBY
  end

  it 'autocorrects properly when the if is assigned to a variable' do
    expect_offense(<<~RUBY)
      x = if foo
          ^^^^^^ Avoid `if` branches without a body.
      elsif bar
        5
      end
    RUBY

    expect_correction(<<~RUBY)
      x = if bar
        5
      end
    RUBY
  end

  context '>= Ruby 3.1', :ruby31 do
    it 'registers an offense for multi-line value omission in `unless`' do
      expect_offense(<<~RUBY)
        var =
          unless object.action value:, other:
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` branches without a body.
            condition || other_condition # This is the value of `other:`, like so:
                                         # `other: condition || other_condition`
          end
      RUBY
    end
  end

  context 'when AllowComments is false' do
    let(:cop_config) { { 'AllowComments' => false } }

    it 'registers an offense for missing `if` body with a comment' do
      expect_offense(<<~RUBY)
        if condition
        ^^^^^^^^^^^^ Avoid `if` branches without a body.
          # noop
        end
      RUBY

      expect_correction('')
    end

    it 'registers an offense for missing `elsif` body with a comment' do
      expect_offense(<<~RUBY)
        if condition
          do_something
        elsif other_condition
        ^^^^^^^^^^^^^^^^^^^^^ Avoid `elsif` branches without a body.
          # noop
        end
      RUBY

      expect_correction(<<~RUBY)
        if condition
          do_something
        end
      RUBY
    end

    it 'registers an offense for missing `unless` body with a comment' do
      expect_offense(<<~RUBY)
        unless condition
        ^^^^^^^^^^^^^^^^ Avoid `unless` branches without a body.
          # noop
        end
      RUBY

      expect_correction('')
    end
  end
end
