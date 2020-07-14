# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::EmptyConditionalBody, :config do
  let(:cop_config) do
    { 'AllowComments' => true }
  end

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
    let(:cop_config) do
      { 'AllowComments' => false }
    end

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
