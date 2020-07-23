# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SoleNestedConditional, :config do
  let(:cop_config) do
    { 'AllowModifier' => false }
  end

  it 'registers an offense when using nested `if` within `if`' do
    expect_offense(<<~RUBY)
      if foo
        if bar
        ^^ Consider merging nested conditions into outer `if` conditions.
          do_something
        end
      end
    RUBY
  end

  it 'registers an offense when using nested `unless` within `if`' do
    expect_offense(<<~RUBY)
      if foo
        unless bar
        ^^^^^^ Consider merging nested conditions into outer `if` conditions.
          do_something
        end
      end
    RUBY
  end

  it 'registers an offense when using nested `if` within `unless`' do
    expect_offense(<<~RUBY)
      unless foo
        if bar
        ^^ Consider merging nested conditions into outer `unless` conditions.
          do_something
        end
      end
    RUBY
  end

  it 'registers an offense when using nested `unless` within `unless`' do
    expect_offense(<<~RUBY)
      unless foo
        unless bar
        ^^^^^^ Consider merging nested conditions into outer `unless` conditions.
          do_something
        end
      end
    RUBY
  end

  it 'does not register an offense when using nested conditional within `elsif`' do
    expect_no_offenses(<<~RUBY)
      if foo
      elsif bar
        if baz
        end
      end
    RUBY
  end

  it 'registers an offense when using nested modifier conditional' do
    expect_offense(<<~RUBY)
      if foo
        do_something if bar
                     ^^ Consider merging nested conditions into outer `if` conditions.
      end
    RUBY
  end

  it 'registers an offense for multiple nested conditionals' do
    expect_offense(<<~RUBY)
      if foo
        if bar
        ^^ Consider merging nested conditions into outer `if` conditions.
          if baz
          ^^ Consider merging nested conditions into outer `if` conditions.
            do_something
          end
        end
      end
    RUBY
  end

  it 'registers an offense when using nested conditional and branch contains a comment' do
    expect_offense(<<~RUBY)
      if foo
        # Comment.
        if bar
        ^^ Consider merging nested conditions into outer `if` conditions.
          do_something
        end
      end
    RUBY
  end

  it 'does not register an offense when using nested ternary within conditional' do
    expect_no_offenses(<<~RUBY)
      if foo
        bar ? baz : quux
      end
    RUBY
  end

  it 'does not register an offense when no nested conditionals' do
    expect_no_offenses(<<~RUBY)
      if foo
        do_something
      end
    RUBY
  end

  it 'does not register an offense when using nested conditional is not the whole body' do
    expect_no_offenses(<<~RUBY)
      if foo
        if bar
          do_something
        end
        do_something_more
      end
    RUBY
  end

  it 'does not register an offense when nested conditional has an `else` branch' do
    expect_no_offenses(<<~RUBY)
      if foo
        if bar
          do_something
        else
          do_something_else
        end
      end
    RUBY
  end

  it 'does not register an offense for nested conditionals when outer conditional has an `else` branch' do
    expect_no_offenses(<<~RUBY)
      if foo
        do_something if bar
      else
        do_something_else
      end
    RUBY
  end

  context 'when AllowModifier is true' do
    let(:cop_config) do
      { 'AllowModifier' => true }
    end

    it 'does not register an offense when using nested modifier conditional' do
      expect_no_offenses(<<~RUBY)
        if foo
          do_something if bar
        end
      RUBY
    end
  end
end
