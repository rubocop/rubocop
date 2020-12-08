# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SoleNestedConditional, :config do
  let(:cop_config) do
    { 'AllowModifier' => false }
  end

  it 'registers an offense and corrects when using nested `if` within `if`' do
    expect_offense(<<~RUBY)
      if foo
        if bar
        ^^ Consider merging nested conditions into outer `if` conditions.
          do_something
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      if foo && bar
          do_something
        end
    RUBY
  end

  it 'registers an offense and corrects when using nested `unless` within `if`' do
    expect_offense(<<~RUBY)
      if foo
        unless bar
        ^^^^^^ Consider merging nested conditions into outer `if` conditions.
          do_something
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      if foo && !bar
          do_something
        end
    RUBY
  end

  it 'registers an offense and corrects when using nested `if` within `unless`' do
    expect_offense(<<~RUBY)
      unless foo
        if bar
        ^^ Consider merging nested conditions into outer `unless` conditions.
          do_something
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      if !foo && bar
          do_something
        end
    RUBY
  end

  it 'registers an offense and corrects when using nested `unless` within `unless`' do
    expect_offense(<<~RUBY)
      unless foo
        unless bar
        ^^^^^^ Consider merging nested conditions into outer `unless` conditions.
          do_something
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      if !foo && !bar
          do_something
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

  it 'registers an offense and corrects when using nested `if` modifier conditional' do
    expect_offense(<<~RUBY)
      if foo
        do_something if bar
                     ^^ Consider merging nested conditions into outer `if` conditions.
      end
    RUBY

    expect_correction(<<~RUBY)
      if foo && bar
        do_something
      end
    RUBY
  end

  it 'registers an offense and corrects when using nested `unless` modifier conditional' do
    expect_offense(<<~RUBY)
      if foo
        do_something unless bar
                     ^^^^^^ Consider merging nested conditions into outer `if` conditions.
      end
    RUBY

    expect_correction(<<~RUBY)
      if foo && !bar
        do_something
      end
    RUBY
  end

  it 'registers an offense and corrects when nested `||` operator condition' do
    expect_offense(<<~RUBY)
      if foo
        if bar || baz
        ^^ Consider merging nested conditions into outer `if` conditions.
          do_something
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      if foo && (bar || baz)
          do_something
        end
    RUBY
  end

  it 'registers an offense and corrects when nested `||` operator modifier condition' do
    expect_offense(<<~RUBY)
      if foo
        do_something if bar || baz
                     ^^ Consider merging nested conditions into outer `if` conditions.
      end
    RUBY

    expect_correction(<<~RUBY)
      if foo && (bar || baz)
        do_something
      end
    RUBY
  end

  it 'registers an offense and corrects when using `||` in the outer condition' do
    expect_offense(<<~RUBY)
      if foo || bar
        if baz || qux
        ^^ Consider merging nested conditions into outer `if` conditions.
          do_something
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      if (foo || bar) && (baz || qux)
          do_something
        end
    RUBY
  end

  it 'registers an offense and corrects when using `||` in the outer condition' \
     'and nested modifier condition ' do
    expect_offense(<<~RUBY)
      if foo || bar
        do_something if baz || qux
                     ^^ Consider merging nested conditions into outer `if` conditions.
      end
    RUBY

    expect_correction(<<~RUBY)
      if (foo || bar) && (baz || qux)
        do_something
      end
    RUBY
  end

  it 'registers an offense and corrects for multiple nested conditionals' do
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

    expect_correction(<<~RUBY)
      if foo && bar && baz
            do_something
          end
    RUBY
  end

  context 'when disabling `Style/IfUnlessModifier`' do
    let(:config) do
      RuboCop::Config.new('Style/IfUnlessModifier' => { 'Enabled' => false })
    end

    it 'registers an offense and corrects when using nested conditional and branch contains a comment' do
      expect_offense(<<~RUBY)
        if foo
          # Comment.
          if bar
          ^^ Consider merging nested conditions into outer `if` conditions.
            do_something
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        # Comment.
        if foo && bar
            do_something
          end
      RUBY
    end
  end

  it 'registers an offense and corrects when using guard conditional with outer comment' do
    expect_offense(<<~RUBY)
      # Comment.
      if foo
        do_something if bar
                     ^^ Consider merging nested conditions into outer `if` conditions.
      end
    RUBY

    expect_correction(<<~RUBY)
      # Comment.
      if foo && bar
        do_something
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

  context 'when the inner condition has a send node without parens' do
    context 'in guard style' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          if foo
            do_something if ok? bar
                         ^^ Consider merging nested conditions into outer `if` conditions.
          end
        RUBY

        expect_correction(<<~RUBY)
          if foo && (ok? bar)
            do_something
          end
        RUBY
      end
    end

    context 'in modifier style' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          if foo
            if ok? bar
            ^^ Consider merging nested conditions into outer `if` conditions.
              do_something
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          if foo && (ok? bar)
              do_something
            end
        RUBY
      end
    end
  end

  context 'when the inner condition has a send node with parens' do
    context 'in guard style' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          if foo
            do_something if ok?(bar)
                         ^^ Consider merging nested conditions into outer `if` conditions.
          end
        RUBY

        expect_correction(<<~RUBY)
          if foo && ok?(bar)
            do_something
          end
        RUBY
      end
    end

    context 'in modifier style' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          if foo
            if ok?(bar)
            ^^ Consider merging nested conditions into outer `if` conditions.
              do_something
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          if foo && ok?(bar)
              do_something
            end
        RUBY
      end
    end
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
