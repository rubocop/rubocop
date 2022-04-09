# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::EmptyConditionalBody, :config do
  let(:cop_config) { { 'AllowComments' => true } }

  it 'registers an offense for missing `if` body' do
    expect_offense(<<~RUBY)
      if condition
      ^^^^^^^^^^^^ Avoid `if` branches without a body.
      end
    RUBY
  end

  it 'does not register an offense for missing `if` body with a comment' do
    expect_no_offenses(<<~RUBY)
      if condition
        # noop
      end
    RUBY
  end

  it 'registers an offense for missing `elsif` body' do
    expect_offense(<<~RUBY)
      if condition
        do_something
      elsif other_condition
      ^^^^^^^^^^^^^^^^^^^^^ Avoid `elsif` branches without a body.
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
  end

  it 'registers an offense for missing `unless` body' do
    expect_offense(<<~RUBY)
      unless condition
      ^^^^^^^^^^^^^^^^ Avoid `unless` branches without a body.
      end
    RUBY
  end

  it 'does not register an offense for missing `unless` body with a comment' do
    expect_no_offenses(<<~RUBY)
      unless condition
        # noop
      end
    RUBY
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
    end

    it 'registers an offense for missing `unless` body with a comment' do
      expect_offense(<<~RUBY)
        unless condition
        ^^^^^^^^^^^^^^^^ Avoid `unless` branches without a body.
          # noop
        end
      RUBY
    end
  end
end
