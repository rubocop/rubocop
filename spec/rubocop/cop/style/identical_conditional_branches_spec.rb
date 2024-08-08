# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::IdenticalConditionalBranches, :config do
  context 'on if..else with identical bodies' do
    it 'registers and corrects an offense' do
      expect_offense(<<~RUBY)
        if something
          do_x
          ^^^^ Move `do_x` out of the conditional.
        else
          do_x
          ^^^^ Move `do_x` out of the conditional.
        end
      RUBY

      expect_correction(<<~RUBY)
        if something
        else
        end
        do_x
      RUBY
    end
  end

  context 'on if..else with identical trailing lines' do
    it 'registers and corrects an offense' do
      expect_offense(<<~RUBY)
        if something
          method_call_here(1, 2, 3)
          do_x
          ^^^^ Move `do_x` out of the conditional.
        else
          1 + 2 + 3
          do_x
          ^^^^ Move `do_x` out of the conditional.
        end
      RUBY

      expect_correction(<<~RUBY)
        if something
          method_call_here(1, 2, 3)
        else
          1 + 2 + 3
        end
        do_x
      RUBY
    end
  end

  context 'on if..else with identical leading lines' do
    it 'registers and corrects an offense' do
      expect_offense(<<~RUBY)
        if something
          do_x
          ^^^^ Move `do_x` out of the conditional.
          method_call_here(1, 2, 3)
        else
          do_x
          ^^^^ Move `do_x` out of the conditional.
          1 + 2 + 3
        end
      RUBY

      expect_correction(<<~RUBY)
        do_x
        if something
          method_call_here(1, 2, 3)
        else
          1 + 2 + 3
        end
      RUBY
    end
  end

  context 'on if...else with identical leading lines and using index assign' do
    it 'registers and corrects an offense' do
      expect_offense(<<~RUBY)
        if condition
          h[:key] = foo
          ^^^^^^^^^^^^^ Move `h[:key] = foo` out of the conditional.
          bar
        else
          h[:key] = foo
          ^^^^^^^^^^^^^ Move `h[:key] = foo` out of the conditional.
          baz
        end
      RUBY

      expect_correction(<<~RUBY)
        h[:key] = foo
        if condition
          bar
        else
          baz
        end
      RUBY
    end
  end

  context 'on if...else with identical leading lines and index assign to condition value' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        if h[:key]
          h[:key] = foo
          bar
        else
          h[:key] = foo
          baz
        end
      RUBY
    end
  end

  context 'on if...else with identical leading lines and assign to `self.foo`' do
    it 'registers and corrects an offense' do
      expect_offense(<<~RUBY)
        if something
          self.foo ||= default
          ^^^^^^^^^^^^^^^^^^^^ Move `self.foo ||= default` out of the conditional.
          do_x
        else
          self.foo ||= default
          ^^^^^^^^^^^^^^^^^^^^ Move `self.foo ||= default` out of the conditional.
          do_y
        end
      RUBY

      expect_correction(<<~RUBY)
        self.foo ||= default
        if something
          do_x
        else
          do_y
        end
      RUBY
    end
  end

  context 'on if..else with identical leading lines and assign to condition value of method call receiver' do
    it "doesn't register an offense" do
      expect_no_offenses(<<~RUBY)
        if x.condition
          x = do_something
          foo
        else
          x = do_something
          bar
        end
      RUBY
    end
  end

  context 'on if..else with identical leading lines and assign to condition value of safe navigation call receiver' do
    it "doesn't register an offense" do
      expect_no_offenses(<<~RUBY)
        if x&.condition
          x = do_something
          foo
        else
          x = do_something
          bar
        end
      RUBY
    end
  end

  context 'on if..else with identical leading lines and assign to condition value of method call' do
    it "doesn't register an offense" do
      expect_no_offenses(<<~RUBY)
        if x
          x = do_something
          foo
        else
          x = do_something
          bar
        end
      RUBY
    end
  end

  context 'on if..else with identical leading lines and assign to condition local variable' do
    it "doesn't register an offense" do
      expect_no_offenses(<<~RUBY)
        x = 42

        if x
          x = do_something
          foo
        else
          x = do_something
          bar
        end
      RUBY
    end
  end

  context 'on if..else with identical leading lines and assign to condition instance variable' do
    it "doesn't register an offense" do
      expect_no_offenses(<<~RUBY)
        if @x
          @x = do_something
          foo
        else
          @x = do_something
          bar
        end
      RUBY
    end
  end

  context 'on if..else with identical trailing lines and assign to condition value' do
    it 'registers and corrects an offense' do
      expect_offense(<<~RUBY)
        if x.condition
          foo
          x = do_something
          ^^^^^^^^^^^^^^^^ Move `x = do_something` out of the conditional.
        else
          bar
          x = do_something
          ^^^^^^^^^^^^^^^^ Move `x = do_something` out of the conditional.
        end
      RUBY

      expect_correction(<<~RUBY)
        if x.condition
          foo
        else
          bar
        end
        x = do_something
      RUBY
    end
  end

  context 'on if..else with identical leading lines, single child branch and last node of the parent' do
    it "doesn't register an offense" do
      expect_no_offenses(<<~RUBY)
        def foo
          if something
            do_x
          else
            do_x
            1 + 2 + 3
          end
        end

        def bar
          y = if something
                do_x
              else
                do_x
                1 + 2 + 3
              end
          do_something_else
        end
      RUBY
    end
  end

  context 'on if..elsif with no else' do
    it "doesn't register an offense" do
      expect_no_offenses(<<~RUBY)
        if something
          do_x
        elsif something_else
          do_x
        end
      RUBY
    end
  end

  context 'on if..else with slightly different trailing lines' do
    it "doesn't register an offense" do
      expect_no_offenses(<<~RUBY)
        if something
          do_x(1)
        else
          do_x(2)
        end
      RUBY
    end
  end

  context 'on if..else with identical bodies and assigning to a variable used in `if` condition' do
    it "doesn't register an offense" do
      expect_no_offenses(<<~RUBY)
        x = 0
        if x == 0
          x += 1
          foo
        else
          x += 1
          bar
        end
      RUBY
    end
  end

  context 'on case with identical bodies' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        case something
        when :a
          do_x
          ^^^^ Move `do_x` out of the conditional.
        when :b
          do_x
          ^^^^ Move `do_x` out of the conditional.
        else
          do_x
          ^^^^ Move `do_x` out of the conditional.
        end
      RUBY

      expect_correction(<<~RUBY)
        case something
        when :a
        when :b
        else
        end
        do_x
      RUBY
    end
  end

  # Regression: https://github.com/rubocop/rubocop/issues/3868
  context 'when one of the case branches is empty' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        case value
        when cond1
        else
          if cond2
          else
          end
        end
      RUBY
    end
  end

  context 'on case with identical trailing lines' do
    it 'registers and corrects an offense' do
      expect_offense(<<~RUBY)
        case something
        when :a
          x1
          do_x
          ^^^^ Move `do_x` out of the conditional.
        when :b
          x2
          do_x
          ^^^^ Move `do_x` out of the conditional.
        else
          x3
          do_x
          ^^^^ Move `do_x` out of the conditional.
        end
      RUBY

      expect_correction(<<~RUBY)
        case something
        when :a
          x1
        when :b
          x2
        else
          x3
        end
        do_x
      RUBY
    end
  end

  context 'on case with identical leading lines' do
    it 'registers and corrects an offense' do
      expect_offense(<<~RUBY)
        case something
        when :a
          do_x
          ^^^^ Move `do_x` out of the conditional.
          x1
        when :b
          do_x
          ^^^^ Move `do_x` out of the conditional.
          x2
        else
          do_x
          ^^^^ Move `do_x` out of the conditional.
          x3
        end
      RUBY

      expect_correction(<<~RUBY)
        do_x
        case something
        when :a
          x1
        when :b
          x2
        else
          x3
        end
      RUBY
    end
  end

  context 'on case with identical leading lines when handling nil case branches' do
    it 'registers and corrects an offense' do
      expect_no_offenses(<<~RUBY)
        case something
        when :a
          nil
        when :b
          do_x
          x1
        else
          do_x
          x2
        end
      RUBY
    end
  end

  context 'on case with identical leading lines when handling empty case branches' do
    it 'registers and corrects an offense' do
      expect_no_offenses(<<~RUBY)
        case something
        when :a
          ()
        when :b
          do_x
          x1
        else
          do_x
          x2
        end
      RUBY
    end
  end

  context 'on case with identical leading lines, single child branch and last node of the parent' do
    it "doesn't register an offense" do
      expect_no_offenses(<<~RUBY)
        def foo
          case something
          when :a
            do_x
          when :b
            do_x
            x2
          else
            do_x
            x3
          end
        end

        def bar
          x = case something
              when :a
                do_x
              when :b
                do_x
                x2
              else
                do_x
                x3
              end
          do_something
        end
      RUBY
    end
  end

  context 'on case without else' do
    it "doesn't register an offense" do
      expect_no_offenses(<<~RUBY)
        case something
        when :a
          do_x
        when :b
          do_x
        end
      RUBY
    end
  end

  context 'on case with empty when' do
    it "doesn't register an offense" do
      expect_no_offenses(<<~RUBY)
        case something
        when :a
          do_x
          do_y
        when :b
        else
          do_x
          do_z
        end
      RUBY
    end
  end

  context 'on case..when with identical bodies and assigning to a variable used in `case` condition' do
    it "doesn't register an offense" do
      expect_no_offenses(<<~RUBY)
        x = 0
        case x
        when 1
          x += 1
          foo
        when 42
          x += 1
          bar
        end
      RUBY
    end
  end

  context 'when using pattern matching', :ruby27 do
    context 'on case-match with identical bodies' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          case something
          in :a
            do_x
            ^^^^ Move `do_x` out of the conditional.
          in :b
            do_x
            ^^^^ Move `do_x` out of the conditional.
          else
            do_x
            ^^^^ Move `do_x` out of the conditional.
          end
        RUBY

        expect_correction(<<~RUBY)
          case something
          in :a
          in :b
          else
          end
          do_x
        RUBY
      end

      context 'on case..in with identical bodies and assigning to a variable used in `case` condition' do
        it "doesn't register an offense" do
          expect_no_offenses(<<~RUBY)
            x = 0
            case x
            in 1
              x += 1
              foo
            in 42
              x += 1
              bar
            end
          RUBY
        end
      end
    end

    context 'when one of the case-match branches is empty' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          case value
          in cond1
          else
            if cond2
            else
            end
          end
        RUBY
      end
    end

    context 'on case-match with identical trailing lines' do
      it 'registers and corrects an offense' do
        expect_offense(<<~RUBY)
          case something
          in :a
            x1
            do_x
            ^^^^ Move `do_x` out of the conditional.
          in :b
            x2
            do_x
            ^^^^ Move `do_x` out of the conditional.
          else
            x3
            do_x
            ^^^^ Move `do_x` out of the conditional.
          end
        RUBY

        expect_correction(<<~RUBY)
          case something
          in :a
            x1
          in :b
            x2
          else
            x3
          end
          do_x
        RUBY
      end
    end

    context 'on case-match with identical leading lines' do
      it 'registers and corrects an offense' do
        expect_offense(<<~RUBY)
          case something
          in :a
            do_x
            ^^^^ Move `do_x` out of the conditional.
            x1
          in :b
            do_x
            ^^^^ Move `do_x` out of the conditional.
            x2
          else
            do_x
            ^^^^ Move `do_x` out of the conditional.
            x3
          end
        RUBY

        expect_correction(<<~RUBY)
          do_x
          case something
          in :a
            x1
          in :b
            x2
          else
            x3
          end
        RUBY
      end
    end

    context 'on case-match with identical leading lines, single child branch and last node of the parent' do
      it "doesn't register an offense" do
        expect_no_offenses(<<~RUBY)
          def foo
            case something
            in :a
              do_x
            in :b
              do_x
              x2
            else
              do_x
              x3
            end
          end

          def bar
            y = case something
                in :a
                  do_x
                in :b
                  do_x
                  x2
                else
                  do_x
                  x3
                end
            do_something
          end
        RUBY
      end
    end

    context 'on case-match without else' do
      it "doesn't register an offense" do
        expect_no_offenses(<<~RUBY)
          case something
          in :a
            do_x
          in :b
            do_x
          end
        RUBY
      end
    end

    context 'on case-match with empty when' do
      it "doesn't register an offense" do
        expect_no_offenses(<<~RUBY)
          case something
          in :a
            do_x
            do_y
          in :b
          else
            do_x
            do_z
          end
        RUBY
      end
    end
  end

  context 'with empty parentheses' do
    it 'does not raise any error when using empty brace in the both parentheses' do
      expect_no_offenses(<<~RUBY)
        if condition
          ()
        else
          ()
        end
      RUBY
    end

    it 'does not raise any error when using empty parentheses in the `if` branch' do
      expect_no_offenses(<<~RUBY)
        if condition
          ()
        else
          foo
        end
      RUBY
    end

    it 'does not raise any error when using empty parentheses in the `else` branch' do
      expect_no_offenses(<<~RUBY)
        if condition
          foo
        else
          ()
        end
      RUBY
    end
  end

  context 'with a ternary' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        x ? y : y
                ^ Move `y` out of the conditional.
            ^ Move `y` out of the conditional.
      RUBY

      expect_no_corrections
    end
  end
end
