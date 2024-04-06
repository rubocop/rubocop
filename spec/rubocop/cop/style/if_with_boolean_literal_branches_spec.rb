# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::IfWithBooleanLiteralBranches, :config do
  context 'when condition is a comparison method' do
    RuboCop::AST::Node::COMPARISON_OPERATORS.each do |comparison_operator|
      it 'registers and corrects an offense when using `if foo == bar` with boolean literal branches' do
        expect_offense(<<~RUBY)
          if foo #{comparison_operator} bar
          ^^ Remove redundant `if` with boolean literal branches.
            true
          else
            false
          end
        RUBY

        expect_correction(<<~RUBY)
          foo #{comparison_operator} bar
        RUBY
      end

      it 'registers and corrects an offense when using `unless foo == bar` with boolean literal branches' do
        expect_offense(<<~RUBY)
          unless foo #{comparison_operator} bar
          ^^^^^^ Remove redundant `unless` with boolean literal branches.
            false
          else
            true
          end
        RUBY

        expect_correction(<<~RUBY)
          foo #{comparison_operator} bar
        RUBY
      end

      it 'registers and corrects an offense when using ternary operator with boolean literal branches' do
        expect_offense(<<~RUBY, comparison_operator: comparison_operator)
          foo #{comparison_operator} bar ? true : false
              _{comparison_operator}    ^^^^^^^^^^^^^^^ Remove redundant ternary operator with boolean literal branches.
        RUBY

        expect_correction(<<~RUBY)
          foo #{comparison_operator} bar
        RUBY
      end

      it 'registers and corrects an offense when using `if foo == bar` with opposite boolean literal branches' do
        expect_offense(<<~RUBY)
          if foo #{comparison_operator} bar
          ^^ Remove redundant `if` with boolean literal branches.
            false
          else
            true
          end
        RUBY

        expect_correction(<<~RUBY)
          !(foo #{comparison_operator} bar)
        RUBY
      end

      it 'registers and corrects an offense when using `unless foo == bar` with opposite boolean literal branches' do
        expect_offense(<<~RUBY)
          unless foo #{comparison_operator} bar
          ^^^^^^ Remove redundant `unless` with boolean literal branches.
            true
          else
            false
          end
        RUBY

        expect_correction(<<~RUBY)
          !(foo #{comparison_operator} bar)
        RUBY
      end

      it 'registers and corrects an offense when using opposite ternary operator with boolean literal branches' do
        expect_offense(<<~RUBY, comparison_operator: comparison_operator)
          foo #{comparison_operator} bar ? false : true
              _{comparison_operator}    ^^^^^^^^^^^^^^^ Remove redundant ternary operator with boolean literal branches.
        RUBY

        expect_correction(<<~RUBY)
          !(foo #{comparison_operator} bar)
        RUBY
      end

      it 'registers and corrects an offense when using `if` with boolean literal branches directly under `def`' do
        expect_offense(<<~RUBY, comparison_operator: comparison_operator)
          def foo
            if bar > baz
            ^^ Remove redundant `if` with boolean literal branches.
              true
            else
              false
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo
            bar > baz
          end
        RUBY
      end

      it 'does not register an offense when using a branch that is not boolean literal' do
        expect_no_offenses(<<~RUBY)
          if foo #{comparison_operator} bar
            do_something
          else
            false
          end
        RUBY
      end
    end
  end

  context 'when condition is a predicate method' do
    it 'registers and corrects an offense when using `if foo.do_something?` with boolean literal branches' do
      expect_offense(<<~RUBY)
        if foo.do_something?
        ^^ Remove redundant `if` with boolean literal branches.
          true
        else
          false
        end
      RUBY

      expect_correction(<<~RUBY)
        foo.do_something?
      RUBY
    end

    it 'registers and corrects an offense when using `unless foo.do_something?` with boolean literal branches' do
      expect_offense(<<~RUBY)
        unless foo.do_something?
        ^^^^^^ Remove redundant `unless` with boolean literal branches.
          false
        else
          true
        end
      RUBY

      expect_correction(<<~RUBY)
        foo.do_something?
      RUBY
    end

    it 'registers and corrects an offense when using `if foo.do_something?` with opposite boolean literal branches' do
      expect_offense(<<~RUBY)
        if foo.do_something?
        ^^ Remove redundant `if` with boolean literal branches.
          false
        else
          true
        end
      RUBY

      expect_correction(<<~RUBY)
        !foo.do_something?
      RUBY
    end

    it 'registers and corrects an offense when using `unless foo.do_something?` with opposite boolean literal branches' do
      expect_offense(<<~RUBY)
        unless foo.do_something?
        ^^^^^^ Remove redundant `unless` with boolean literal branches.
          true
        else
          false
        end
      RUBY

      expect_correction(<<~RUBY)
        !foo.do_something?
      RUBY
    end

    it 'registers and corrects an offense when using `elsif foo.do_something?` with boolean literal branches' do
      expect_offense(<<~RUBY)
        if condition
          bar
          false
        elsif foo.do_something?
        ^^^^^ Use `else` instead of redundant `elsif` with boolean literal branches.
          true
        else
          false
        end
      RUBY

      expect_correction(<<~RUBY)
        if condition
          bar
          false
        else
          foo.do_something?
        end
      RUBY
    end

    it 'registers and corrects an offense when using `elsif foo.do_something?` with opposite boolean literal branches' do
      expect_offense(<<~RUBY)
        if condition
          bar
          false
        elsif foo.do_something?
        ^^^^^ Use `else` instead of redundant `elsif` with boolean literal branches.
          false
        else
          true
        end
      RUBY

      expect_correction(<<~RUBY)
        if condition
          bar
          false
        else
          !foo.do_something?
        end
      RUBY
    end
  end

  context 'when double negative is used in condition' do
    it 'registers and corrects an offense when using `if !!condition` with boolean literal branches' do
      expect_offense(<<~RUBY)
        if !!condition
        ^^ Remove redundant `if` with boolean literal branches.
          true
        else
          false
        end
      RUBY

      expect_correction(<<~RUBY)
        !!condition
      RUBY
    end

    it 'registers and corrects an offense when using `if !!condition` with opposite boolean literal branches' do
      expect_offense(<<~RUBY)
        if !!condition
        ^^ Remove redundant `if` with boolean literal branches.
          false
        else
          true
        end
      RUBY

      expect_correction(<<~RUBY)
        !!!condition
      RUBY
    end
  end

  context 'when condition is a method that does not known whether to return boolean value' do
    it 'does not register an offense when using `if condition` with boolean literal branches' do
      expect_no_offenses(<<~RUBY)
        if condition
          true
        else
          false
        end
      RUBY
    end

    it 'does not register an offense when using `unless condition` with boolean literal branches' do
      expect_no_offenses(<<~RUBY)
        unless condition
          false
        else
          true
        end
      RUBY
    end

    it 'does not register an offense when using `if condition` with opposite boolean literal branches' do
      expect_no_offenses(<<~RUBY)
        if condition
          false
        else
          true
        end
      RUBY
    end

    it 'does not register an offense when using `unless condition` with opposite boolean literal branches' do
      expect_no_offenses(<<~RUBY)
        unless condition
          true
        else
          false
        end
      RUBY
    end
  end

  context 'when condition is a logical operator and operands do not known whether to return boolean value' do
    it 'does not register an offense when using `if foo && bar` with boolean literal branches' do
      expect_no_offenses(<<~RUBY)
        if foo && bar
          true
        else
          false
        end
      RUBY
    end

    it 'does not register an offense when using `if foo || bar` with boolean literal branches' do
      expect_no_offenses(<<~RUBY)
        if foo || bar
          true
        else
          false
        end
      RUBY
    end

    it 'does not register an offense when using `unless foo && bar` with boolean literal branches' do
      expect_no_offenses(<<~RUBY)
        unless foo && bar
          false
        else
          true
        end
      RUBY
    end

    it 'does not register an offense when using `unless foo || bar` with boolean literal branches' do
      expect_no_offenses(<<~RUBY)
        unless foo || bar
          false
        else
          true
        end
      RUBY
    end

    it 'does not register an offense when using `if foo && bar` with opposite boolean literal branches' do
      expect_no_offenses(<<~RUBY)
        if foo && bar
          false
        else
          true
        end
      RUBY
    end

    it 'does not register an offense when using `if foo || bar` with opposite boolean literal branches' do
      expect_no_offenses(<<~RUBY)
        if foo || bar
          false
        else
          true
        end
      RUBY
    end

    it 'does not register an offense when using `unless foo && bar` with opposite boolean literal branches' do
      expect_no_offenses(<<~RUBY)
        unless foo && bar
          true
        else
          false
        end
      RUBY
    end

    it 'does not register an offense when using `unless foo || bar` with opposite boolean literal branches' do
      expect_no_offenses(<<~RUBY)
        unless foo || bar
          true
        else
          false
        end
      RUBY
    end
  end

  context 'when complex condition' do
    it 'registers and corrects an offense when using `if foo? && bar && baz?` with boolean literal branches' do
      expect_offense(<<~RUBY)
        if foo? && bar && baz?
        ^^ Remove redundant `if` with boolean literal branches.
          true
        else
          false
        end
      RUBY

      expect_correction(<<~RUBY)
        foo? && bar && baz?
      RUBY
    end

    it 'does not register an offense when using `if foo? || bar || baz?` with boolean literal branches' do
      expect_no_offenses(<<~RUBY)
        if foo? || bar || baz?
          true
        else
          false
        end
      RUBY
    end

    it 'registers and corrects an offense when using `if foo? || bar && baz?` with boolean literal branches' do
      expect_offense(<<~RUBY)
        if foo? || bar && baz?
        ^^ Remove redundant `if` with boolean literal branches.
          true
        else
          false
        end
      RUBY

      expect_correction(<<~RUBY)
        foo? || bar && baz?
      RUBY
    end

    it 'registers and corrects an offense when using `if foo? || (bar && baz)?` with boolean literal branches' do
      expect_offense(<<~RUBY)
        if foo? || (bar && baz?)
        ^^ Remove redundant `if` with boolean literal branches.
          true
        else
          false
        end
      RUBY

      expect_correction(<<~RUBY)
        foo? || (bar && baz?)
      RUBY
    end

    it 'register and corrects an offense when using `if (foo? || bar) && baz?` with boolean literal branches' do
      expect_offense(<<~RUBY)
        if (foo? || bar) && baz?
        ^^ Remove redundant `if` with boolean literal branches.
          true
        else
          false
        end
      RUBY

      expect_correction(<<~RUBY)
        (foo? || bar) && baz?
      RUBY
    end

    it 'does not register an offense when using `if foo? && bar || baz?` with boolean literal branches' do
      expect_no_offenses(<<~RUBY)
        if foo? && bar || baz?
          true
        else
          false
        end
      RUBY
    end

    it 'does not register an offense when using `if foo? && (bar || baz)?` with boolean literal branches' do
      expect_no_offenses(<<~RUBY)
        if foo? && (bar || baz?)
          true
        else
          false
        end
      RUBY
    end

    it 'does not register an offense when using `if (foo? && bar) || baz?` with boolean literal branches' do
      expect_no_offenses(<<~RUBY)
        if (foo? && bar) || baz?
          true
        else
          false
        end
      RUBY
    end
  end

  context 'when condition is a logical operator and all operands are predicate methods' do
    it 'registers and corrects an offense when using `if foo? && bar?` with boolean literal branches' do
      expect_offense(<<~RUBY)
        if foo? && bar?
        ^^ Remove redundant `if` with boolean literal branches.
          true
        else
          false
        end
      RUBY

      expect_correction(<<~RUBY)
        foo? && bar?
      RUBY
    end

    it 'registers and corrects an offense when using `if foo? && bar?` with opposite boolean literal branches' do
      expect_offense(<<~RUBY)
        if foo? && bar?
        ^^ Remove redundant `if` with boolean literal branches.
          false
        else
          true
        end
      RUBY

      expect_correction(<<~RUBY)
        !(foo? && bar?)
      RUBY
    end

    it 'registers and corrects an offense when using `unless foo? || bar?` with boolean literal branches' do
      expect_offense(<<~RUBY)
        unless foo? || bar?
        ^^^^^^ Remove redundant `unless` with boolean literal branches.
          false
        else
          true
        end
      RUBY

      expect_correction(<<~RUBY)
        foo? || bar?
      RUBY
    end

    it 'registers and corrects an offense when using `unless foo? || bar?` with opposite boolean literal branches' do
      expect_offense(<<~RUBY)
        unless foo? || bar?
        ^^^^^^ Remove redundant `unless` with boolean literal branches.
          true
        else
          false
        end
      RUBY

      expect_correction(<<~RUBY)
        !(foo? || bar?)
      RUBY
    end

    it 'registers and corrects an offense when using `if foo? && bar? && baz?` with boolean literal branches' do
      expect_offense(<<~RUBY)
        if foo? && bar? && baz?
        ^^ Remove redundant `if` with boolean literal branches.
          true
        else
          false
        end
      RUBY

      expect_correction(<<~RUBY)
        foo? && bar? && baz?
      RUBY
    end

    it 'registers and corrects an offense when using `if foo? && bar? || baz?` with boolean literal branches' do
      expect_offense(<<~RUBY)
        if foo? && bar? || baz?
        ^^ Remove redundant `if` with boolean literal branches.
          true
        else
          false
        end
      RUBY

      expect_correction(<<~RUBY)
        foo? && bar? || baz?
      RUBY
    end
  end

  context 'when using `elsif` with boolean literal branches' do
    it 'registers and corrects an offense when using single `elsif` with boolean literal branches' do
      expect_offense(<<~RUBY)
        if foo
          true
        elsif bar > baz
        ^^^^^ Use `else` instead of redundant `elsif` with boolean literal branches.
          true
        else
          false
        end
      RUBY

      expect_correction(<<~RUBY)
        if foo
          true
        else
          bar > baz
        end
      RUBY
    end

    it 'does not register an offense when using multiple `elsif` with boolean literal branches' do
      expect_no_offenses(<<~RUBY)
        if foo
          true
        elsif bar > baz
          true
        elsif qux > quux
          true
        else
          false
        end
      RUBY
    end
  end

  it 'does not crash when using `()` as a condition' do
    expect_no_offenses(<<~RUBY)
      if ()
      else
      end
    RUBY
  end

  context 'when `AllowedMethods: nonzero?`' do
    let(:cop_config) { { 'AllowedMethods' => ['nonzero?'] } }

    it 'does not register an offense when using `nonzero?`' do
      expect_no_offenses(<<~RUBY)
        num.nonzero? ? true : false
      RUBY
    end
  end
end
