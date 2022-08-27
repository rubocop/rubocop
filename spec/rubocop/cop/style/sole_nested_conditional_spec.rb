# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SoleNestedConditional, :config do
  let(:cop_config) { { 'AllowModifier' => false } }

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

  it 'registers an offense and corrects when using nested `if` within `unless foo == bar`' do
    expect_offense(<<~RUBY)
      unless foo == bar
        if baz
        ^^ Consider merging nested conditions into outer `unless` conditions.
          do_something
        end
      end
    RUBY

    # NOTE: `Style/InverseMethods` cop autocorrects from `(!foo == bar)` to `foo != bar`.
    expect_correction(<<~RUBY)
      if !(foo == bar) && baz
          do_something
        end
    RUBY
  end

  it 'registers an offense and corrects when using nested `if` within `if foo = bar`' do
    expect_offense(<<~RUBY)
      if foo = bar
        if baz
        ^^ Consider merging nested conditions into outer `if` conditions.
          do_something
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      if (foo = bar) && baz
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

  it 'registers an offense and corrects when using nested `unless` modifier with a single expression condition' do
    expect_offense(<<~RUBY)
      class A
        def foo
          if h[:a]
            h[:b] = true unless h.has_key?(:b)
                         ^^^^^^ Consider merging nested conditions into outer `if` conditions.
          end
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class A
        def foo
          if h[:a] && !h.has_key?(:b)
            h[:b] = true
          end
        end
      end
    RUBY
  end

  it 'registers an offense and corrects when using nested `unless` modifier multiple conditional' do
    expect_offense(<<~RUBY)
      if foo
        do_something unless bar && baz
                     ^^^^^^ Consider merging nested conditions into outer `if` conditions.
      end
    RUBY

    expect_correction(<<~RUBY)
      if foo && !(bar && baz)
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

  it 'registers an offense and corrects when using `||` in the outer condition and nested modifier condition' do
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

  it 'registers an offense and corrects when using `unless` and `||` and parens in the outer condition ' \
     'and nested modifier condition' do
    expect_offense(<<~RUBY)
      unless (foo || bar)
        do_something if baz
                     ^^ Consider merging nested conditions into outer `unless` conditions.
      end
    RUBY

    expect_correction(<<~RUBY)
      if !(foo || bar) && baz
        do_something
      end
    RUBY
  end

  it 'registers an offense and corrects when using `unless` and `||` without parens in the outer condition ' \
     'and nested modifier condition' do
    expect_offense(<<~RUBY)
      unless foo || bar
        do_something if baz
                     ^^ Consider merging nested conditions into outer `unless` conditions.
      end
    RUBY

    expect_correction(<<~RUBY)
      if !(foo || bar) && baz
        do_something
      end
    RUBY
  end

  it 'registers an offense and corrects when using `unless` and `&&` without parens in the outer condition ' \
     'and nested modifier condition' do
    expect_offense(<<~RUBY)
      unless foo && bar && baz
        do_something unless qux
                     ^^^^^^ Consider merging nested conditions into outer `unless` conditions.
      end
    RUBY

    expect_correction(<<~RUBY)
      if !foo && !bar && !baz && !qux
        do_something
      end
    RUBY
  end

  it 'registers an offense and corrects when using `unless` and method arguments without parentheses ' \
     'in the outer condition and nested modifier condition' do
    expect_offense(<<~RUBY)
      unless foo.is_a? Foo
        do_something if bar
                     ^^ Consider merging nested conditions into outer `unless` conditions.
      end
    RUBY

    expect_correction(<<~RUBY)
      if !foo.is_a?(Foo) && bar
        do_something
      end
    RUBY
  end

  it 'registers an offense and corrects when using `unless` and method arguments with parentheses ' \
     'in the outer condition and nested modifier condition' do
    expect_offense(<<~RUBY)
      unless foo.is_a?(Foo)
        do_something if bar
                     ^^ Consider merging nested conditions into outer `unless` conditions.
      end
    RUBY

    expect_correction(<<~RUBY)
      if !foo.is_a?(Foo) && bar
        do_something
      end
    RUBY
  end

  it 'registers an offense and corrects when using `unless` and multiple method arguments with parentheses' \
     'in the outer condition and nested modifier condition' do
    expect_offense(<<~RUBY)
      unless foo.bar arg1, arg2
        do_something if baz
                     ^^ Consider merging nested conditions into outer `unless` conditions.
      end
    RUBY

    expect_correction(<<~RUBY)
      if !foo.bar(arg1, arg2) && baz
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

  it 'registers an offense and corrects for multiple nested conditionals with using method call outer condition by omitting parentheses' do
    expect_offense(<<~RUBY)
      if foo.is_a? Foo
        if bar && baz
        ^^ Consider merging nested conditions into outer `if` conditions.
          do_something if quux
                       ^^ Consider merging nested conditions into outer `if` conditions.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      if foo.is_a?(Foo) && (bar && baz) && quux
          do_something
        end
    RUBY
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

  it 'registers an offense and corrects when there are outer and inline comments' do
    expect_offense(<<~RUBY)
      # Outer comment.
      if foo
        # Comment.
        if bar # nested condition
        ^^ Consider merging nested conditions into outer `if` conditions.
          do_something
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      # Outer comment.
      # Comment.
      if foo && bar # nested condition
          do_something
        end
    RUBY
  end

  context 'when disabling `Style/IfUnlessModifier`' do
    let(:config) { RuboCop::Config.new('Style/IfUnlessModifier' => { 'Enabled' => false }) }

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

    it 'registers an offense and corrects when there are outer and inline comments' do
      expect_offense(<<~RUBY)
        # Outer comment.
        if foo
          # Comment.
          if bar # nested condition
          ^^ Consider merging nested conditions into outer `if` conditions.
            do_something
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        # Outer comment.
        # Comment.
        if foo && bar # nested condition
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

  it 'registers an offense and corrects when `if` foo do_something end `if` bar' do
    expect_offense(<<~RUBY)
      if foo
      ^^ Consider merging nested conditions into outer `if` conditions.
        do_something
      end if bar
    RUBY

    expect_correction(<<~RUBY)
      if bar && foo
        do_something
      end
    RUBY
  end

  it 'registers an offense and corrects when `if` foo do_something end `unless` bar' do
    expect_offense(<<~RUBY)
      if foo
      ^^ Consider merging nested conditions into outer `unless` conditions.
        do_something
      end unless bar
    RUBY

    expect_correction(<<~RUBY)
      if !bar && foo
        do_something
      end
    RUBY
  end

  it 'registers an offense and corrects when `unless` foo do_something end `if` bar' do
    expect_offense(<<~RUBY)
      unless foo
      ^^^^^^ Consider merging nested conditions into outer `if` conditions.
        do_something
      end if bar
    RUBY

    expect_correction(<<~RUBY)
      if bar && !foo
        do_something
      end
    RUBY
  end

  it 'registers an offense and corrects when `if` foo do_something end `if` bar && baz' do
    expect_offense(<<~RUBY)
      if foo
      ^^ Consider merging nested conditions into outer `if` conditions.
        do_something
      end if bar && baz
    RUBY

    expect_correction(<<~RUBY)
      if (bar && baz) && foo
        do_something
      end
    RUBY
  end

  it 'registers an offense and corrects when `if` foo && bar do_something end `if` baz' do
    expect_offense(<<~RUBY)
      if foo && bar
      ^^ Consider merging nested conditions into outer `if` conditions.
        do_something
      end if baz
    RUBY

    expect_correction(<<~RUBY)
      if baz && foo && bar
        do_something
      end
    RUBY
  end

  it 'registers an offense and corrects when `if` foo do_something end `unless` bar && baz' do
    expect_offense(<<~RUBY)
      if foo
      ^^ Consider merging nested conditions into outer `unless` conditions.
        do_something
      end unless bar && baz
    RUBY

    expect_correction(<<~RUBY)
      if !(bar && baz) && foo
        do_something
      end
    RUBY
  end

  it 'registers an offense and corrects when `if` foo && bar do_something end `unless` baz' do
    expect_offense(<<~RUBY)
      if foo && bar
      ^^ Consider merging nested conditions into outer `unless` conditions.
        do_something
      end unless baz
    RUBY

    expect_correction(<<~RUBY)
      if !baz && foo && bar
        do_something
      end
    RUBY
  end

  it 'registers an offense and corrects when `unless` foo && bar do_something end `if` baz' do
    expect_offense(<<~RUBY)
      unless foo && bar
      ^^^^^^ Consider merging nested conditions into outer `if` conditions.
        do_something
      end if baz
    RUBY

    expect_correction(<<~RUBY)
      if baz && !(foo && bar)
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

  it 'does not register an offense when using nested modifier on value assigned in single condition' do
    expect_no_offenses(<<~RUBY)
      if var = foo
        do_something if var
      end
    RUBY
  end

  it 'does not register an offense when using nested modifier on value assigned in multiple conditions' do
    expect_no_offenses(<<~RUBY)
      if cond && var = foo
        do_something if var
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

      context 'with a `csend` node' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            if foo
              if bar&.baz quux
              ^^ Consider merging nested conditions into outer `if` conditions.
                do_something
              end
            end
          RUBY

          expect_correction(<<~RUBY)
            if foo && (bar&.baz quux)
                do_something
              end
          RUBY
        end
      end

      context 'with a block' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            if foo
              if ok? bar do
              ^^ Consider merging nested conditions into outer `if` conditions.
                  do_something
                end
              end
            end
          RUBY

          expect_correction(<<~RUBY)
            if foo && (ok? bar do
                  do_something
                end)
              end
          RUBY
        end
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
    let(:cop_config) { { 'AllowModifier' => true } }

    it 'does not register an offense when using nested modifier conditional' do
      expect_no_offenses(<<~RUBY)
        if foo
          do_something if bar
        end if baz
      RUBY
    end
  end
end
