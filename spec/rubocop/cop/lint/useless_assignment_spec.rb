# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UselessAssignment, :config do
  context 'when a variable is assigned and assigned again in a modifier condition' do
    it 'accepts with parentheses' do
      expect_no_offenses(<<~RUBY)
        a = nil
        puts a if (a = 123)
      RUBY
    end

    it 'accepts without parentheses' do
      expect_no_offenses(<<~RUBY)
        a = nil
        puts a unless a = 123
      RUBY
    end
  end

  context 'when a variable is assigned and assigned again in a modifier loop condition' do
    it 'accepts with parentheses' do
      expect_no_offenses(<<~RUBY)
        a = nil
        puts a while (a = false)
      RUBY
    end

    it 'accepts without parentheses' do
      expect_no_offenses(<<~RUBY)
        a = nil
        puts a until a = true
      RUBY
    end
  end

  context 'when a variable is assigned and unreferenced in a method' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class SomeClass
          foo = 1
          puts foo
          def some_method
            foo = 2
            ^^^ Useless assignment to variable - `foo`.
            bar = 3
            puts bar
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class SomeClass
          foo = 1
          puts foo
          def some_method
            2
            bar = 3
            puts bar
          end
        end
      RUBY
    end
  end

  context 'when a variable is assigned and unreferenced ' \
          'in a singleton method defined with self keyword' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class SomeClass
          foo = 1
          puts foo
          def self.some_method
            foo = 2
            ^^^ Useless assignment to variable - `foo`.
            bar = 3
            puts bar
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class SomeClass
          foo = 1
          puts foo
          def self.some_method
            2
            bar = 3
            puts bar
          end
        end
      RUBY
    end
  end

  context 'when a variable is assigned and unreferenced ' \
          'in a singleton method defined with variable name' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        1.times do
          foo = 1
          puts foo
          instance = Object.new
          def instance.some_method
            foo = 2
            ^^^ Useless assignment to variable - `foo`.
            bar = 3
            puts bar
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        1.times do
          foo = 1
          puts foo
          instance = Object.new
          def instance.some_method
            2
            bar = 3
            puts bar
          end
        end
      RUBY
    end
  end

  context 'when a variable is assigned and unreferenced in a class' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        1.times do
          foo = 1
          puts foo
          class SomeClass
            foo = 2
            ^^^ Useless assignment to variable - `foo`.
            bar = 3
            puts bar
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        1.times do
          foo = 1
          puts foo
          class SomeClass
            2
            bar = 3
            puts bar
          end
        end
      RUBY
    end
  end

  context 'when a variable is assigned and unreferenced in a class ' \
          'subclassing another class stored in local variable' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        1.times do
          foo = 1
          puts foo
          array_class = Array
          class SomeClass < array_class
            foo = 2
            ^^^ Useless assignment to variable - `foo`.
            bar = 3
            puts bar
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        1.times do
          foo = 1
          puts foo
          array_class = Array
          class SomeClass < array_class
            2
            bar = 3
            puts bar
          end
        end
      RUBY
    end
  end

  context 'when a variable is assigned and unreferenced in a singleton class' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        1.times do
          foo = 1
          puts foo
          instance = Object.new
          class << instance
            foo = 2
            ^^^ Useless assignment to variable - `foo`.
            bar = 3
            puts bar
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        1.times do
          foo = 1
          puts foo
          instance = Object.new
          class << instance
            2
            bar = 3
            puts bar
          end
        end
      RUBY
    end
  end

  context 'when a variable is assigned and unreferenced in a module' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        1.times do
          foo = 1
          puts foo
          module SomeModule
            foo = 2
            ^^^ Useless assignment to variable - `foo`.
            bar = 3
            puts bar
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        1.times do
          foo = 1
          puts foo
          module SomeModule
            2
            bar = 3
            puts bar
          end
        end
      RUBY
    end
  end

  context 'when a variable is assigned and referenced when defining a module' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        x = Object.new
        module x::Foo
        end
      RUBY
    end
  end

  context 'when a variable is assigned and unreferenced in top level' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        foo = 1
        ^^^ Useless assignment to variable - `foo`.
        bar = 2
        puts bar
      RUBY

      expect_correction(<<~RUBY)
        1
        bar = 2
        puts bar
      RUBY
    end
  end

  context 'when a variable is assigned with operator assignment in top level' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        foo ||= 1
        ^^^ Useless assignment to variable - `foo`. Use `||` instead of `||=`.
      RUBY

      expect_correction(<<~RUBY)
        foo || 1
      RUBY
    end
  end

  context 'when a variable is assigned multiple times but unreferenced' do
    it 'registers offenses for each assignment' do
      expect_offense(<<~RUBY)
        def some_method
          foo = 1
          ^^^ Useless assignment to variable - `foo`.
          bar = 2
          foo = 3
          ^^^ Useless assignment to variable - `foo`.
          puts bar
        end
      RUBY

      expect_correction(<<~RUBY)
        def some_method
          1
          bar = 2
          3
          puts bar
        end
      RUBY
    end
  end

  context 'when a referenced variable is reassigned but not re-referenced' do
    it 'registers an offense for the non-re-referenced assignment' do
      expect_offense(<<~RUBY)
        def some_method
          foo = 1
          puts foo
          foo = 3
          ^^^ Useless assignment to variable - `foo`.
        end
      RUBY

      expect_correction(<<~RUBY)
        def some_method
          foo = 1
          puts foo
          3
        end
      RUBY
    end
  end

  context 'when an unreferenced variable is reassigned and re-referenced' do
    it 'registers an offense for the unreferenced assignment' do
      expect_offense(<<~RUBY)
        def some_method
          foo = 1
          ^^^ Useless assignment to variable - `foo`.
          foo = 3
          puts foo
        end
      RUBY

      expect_correction(<<~RUBY)
        def some_method
          1
          foo = 3
          puts foo
        end
      RUBY
    end
  end

  context 'when an unreferenced variable is reassigned in a block' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def const_name(node)
          const_names = []
          const_node = node

          loop do
            namespace_node, name = *const_node
            const_names << name
            break unless namespace_node
            break if namespace_node.type == :cbase
            const_node = namespace_node
          end

          const_names.reverse.join('::')
        end
      RUBY
    end
  end

  context 'when a referenced variable is reassigned in a block' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method
          foo = 1
          puts foo
          1.times do
            foo = 2
          end
        end
      RUBY
    end
  end

  context 'when a block local variable is declared but not assigned' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        1.times do |i; foo|
        end
      RUBY
    end
  end

  context 'when a block local variable is assigned and unreferenced' do
    it 'registers offenses for the assignment' do
      expect_offense(<<~RUBY)
        1.times do |i; foo|
          foo = 2
          ^^^ Useless assignment to variable - `foo`.
        end
      RUBY

      expect_correction(<<~RUBY)
        1.times do |i; foo|
          2
        end
      RUBY
    end

    it 'registers offenses for self assignment in numblock', :ruby27 do
      expect_offense(<<~RUBY)
        do_something { foo += _1 }
                       ^^^ Useless assignment to variable - `foo`. Use `+` instead of `+=`.
      RUBY

      expect_correction(<<~RUBY)
        do_something { foo + _1 }
      RUBY
    end
  end

  context 'when a variable is assigned in loop body and unreferenced' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def some_method
          while true
            foo = 1
            ^^^ Useless assignment to variable - `foo`.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def some_method
          while true
            1
          end
        end
      RUBY
    end
  end

  context 'when a variable is reassigned at the end of loop body ' \
          'and would be referenced in next iteration' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method
          total = 0
          foo = 0

          while total < 100
            total += foo
            foo += 1
          end

          total
        end
      RUBY
    end
  end

  context 'when a variable is reassigned at the end of loop body ' \
          'and would be referenced in loop condition' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method
          total = 0
          foo = 0

          while foo < 100
            total += 1
            foo += 1
          end

          total
        end
      RUBY
    end
  end

  context 'when a setter is invoked with operator assignment in loop body' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method
          obj = {}

          while obj[:count] < 100
            obj[:count] += 1
          end
        end
      RUBY
    end
  end

  context "when a variable is reassigned in loop body but won't " \
          'be referenced either next iteration or loop condition' do
    it 'registers an offense' do
      pending 'Requires advanced logic that checks whether the return ' \
              'value of an operator assignment is used or not.'
      expect_offense(<<~RUBY)
        def some_method
          total = 0
          foo = 0

          while total < 100
            total += 1
            foo += 1
            ^^^ Useless assignment to variable - `foo`.
          end

          total
        end
      RUBY

      expect_correction(<<~RUBY)
        def some_method
          total = 0
          foo = 0

          while total < 100
            total += 1
            foo = 1
          end

          total
        end
      RUBY
    end
  end

  context 'when a referenced variable is reassigned ' \
          'but not re-referenced in a method defined in loop' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        while true
          def some_method
            foo = 1
            puts foo
            foo = 3
            ^^^ Useless assignment to variable - `foo`.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        while true
          def some_method
            foo = 1
            puts foo
            3
          end
        end
      RUBY
    end
  end

  context 'when a variable that has same name as outer scope variable ' \
          'is not referenced in a method defined in loop' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        foo = 1

        while foo < 100
          foo += 1
          def some_method
            foo = 1
            ^^^ Useless assignment to variable - `foo`.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        foo = 1

        while foo < 100
          foo += 1
          def some_method
            1
          end
        end
      RUBY
    end
  end

  context 'when a variable is assigned in single branch if and unreferenced' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def some_method(flag)
          if flag
            foo = 1
            ^^^ Useless assignment to variable - `foo`.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def some_method(flag)
          if flag
            1
          end
        end
      RUBY
    end
  end

  context 'when a unreferenced variable is reassigned in same branch ' \
          'and referenced after the branching' do
    it 'registers an offense for the unreferenced assignment' do
      expect_offense(<<~RUBY)
        def some_method(flag)
          if flag
            foo = 1
            ^^^ Useless assignment to variable - `foo`.
            foo = 2
          end

          foo
        end
      RUBY

      expect_correction(<<~RUBY)
        def some_method(flag)
          if flag
            1
            foo = 2
          end

          foo
        end
      RUBY
    end
  end

  context 'when a variable is reassigned in single branch if and referenced after the branching' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method(flag)
          foo = 1

          if flag
            foo = 2
          end

          foo
        end
      RUBY
    end
  end

  context 'when a variable is reassigned in a loop' do
    context 'while loop' do
      it 'accepts' do
        expect_no_offenses(<<~RUBY)
          def while(param)
            ret = 1

            while param != 10
              param += 2
              ret = param + 1
            end

            ret
          end
        RUBY
      end
    end

    context 'post while loop' do
      it 'accepts' do
        expect_no_offenses(<<~RUBY)
          def post_while(param)
            ret = 1

            begin
              param += 2
              ret = param + 1
            end while param < 40

            ret
          end
        RUBY
      end
    end

    context 'until loop' do
      it 'accepts' do
        expect_no_offenses(<<~RUBY)
          def until(param)
            ret = 1

            until param == 10
              param += 2
              ret = param + 1
            end

            ret
          end
        RUBY
      end
    end

    context 'post until loop' do
      it 'accepts' do
        expect_no_offenses(<<~RUBY)
          def post_until(param)
            ret = 1

            begin
              param += 2
              ret = param + 1
            end until param == 10

            ret
          end
        RUBY
      end
    end

    context 'for loop' do
      it 'accepts' do
        expect_no_offenses(<<~RUBY)
          def for(param)
            ret = 1

            for x in param...10
              param += x
              ret = param + 1
            end

            ret
          end
        RUBY
      end
    end
  end

  context 'when a variable is assigned in each branch of if and referenced after the branching' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method(flag)
          if flag
            foo = 2
          else
            foo = 3
          end

          foo
        end
      RUBY
    end
  end

  context 'when a variable is reassigned in single branch if and referenced in the branch' do
    it 'registers an offense for the unreferenced assignment' do
      expect_offense(<<~RUBY)
        def some_method(flag)
          foo = 1
          ^^^ Useless assignment to variable - `foo`.

          if flag
            foo = 2
            puts foo
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def some_method(flag)
          1

          if flag
            foo = 2
            puts foo
          end
        end
      RUBY
    end
  end

  context 'when a variable is assigned in each branch of if and referenced in the else branch' do
    it 'registers an offense for the assignment in the if branch' do
      expect_offense(<<~RUBY)
        def some_method(flag)
          if flag
            foo = 2
            ^^^ Useless assignment to variable - `foo`.
          else
            foo = 3
            puts foo
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def some_method(flag)
          if flag
            2
          else
            foo = 3
            puts foo
          end
        end
      RUBY
    end
  end

  context 'when a variable is reassigned and unreferenced in a if branch ' \
          'while the variable is referenced in the paired else branch' do
    it 'registers an offense for the reassignment in the if branch' do
      expect_offense(<<~RUBY)
        def some_method(flag)
          foo = 1

          if flag
            puts foo
            foo = 2
            ^^^ Useless assignment to variable - `foo`.
          else
            puts foo
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def some_method(flag)
          foo = 1

          if flag
            puts foo
            2
          else
            puts foo
          end
        end
      RUBY
    end
  end

  context "when there's an unreferenced assignment in top level if branch " \
          'while the variable is referenced in the paired else branch' do
    it 'registers an offense for the assignment in the if branch' do
      expect_offense(<<~RUBY)
        if flag
          foo = 1
          ^^^ Useless assignment to variable - `foo`.
        else
          puts foo
        end
      RUBY

      expect_correction(<<~RUBY)
        if flag
          1
        else
          puts foo
        end
      RUBY
    end
  end

  context "when there's an unreferenced reassignment in a if branch " \
          'while the variable is referenced in the paired elsif branch' do
    it 'registers an offense for the reassignment in the if branch' do
      expect_offense(<<~RUBY)
        def some_method(flag_a, flag_b)
          foo = 1

          if flag_a
            puts foo
            foo = 2
            ^^^ Useless assignment to variable - `foo`.
          elsif flag_b
            puts foo
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def some_method(flag_a, flag_b)
          foo = 1

          if flag_a
            puts foo
            2
          elsif flag_b
            puts foo
          end
        end
      RUBY
    end
  end

  context "when there's an unreferenced reassignment in a if branch " \
          'while the variable is referenced in a case branch ' \
          'in the paired else branch' do
    it 'registers an offense for the reassignment in the if branch' do
      expect_offense(<<~RUBY)
        def some_method(flag_a, flag_b)
          foo = 1

          if flag_a
            puts foo
            foo = 2
            ^^^ Useless assignment to variable - `foo`.
          else
            case
            when flag_b
              puts foo
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def some_method(flag_a, flag_b)
          foo = 1

          if flag_a
            puts foo
            2
          else
            case
            when flag_b
              puts foo
            end
          end
        end
      RUBY
    end
  end

  context 'when an assignment in a if branch is referenced in another if branch' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method(flag_a, flag_b)
          if flag_a
            foo = 1
          end

          if flag_b
            puts foo
          end
        end
      RUBY
    end
  end

  context 'when a variable is assigned in branch of modifier if ' \
          'that references the variable in its conditional clause' \
          'and referenced after the branching' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method(flag)
          foo = 1 unless foo
          puts foo
        end
      RUBY
    end
  end

  context 'when a variable is assigned in branch of modifier if ' \
          'that references the variable in its conditional clause' \
          'and unreferenced' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def some_method(flag)
          foo = 1 unless foo
          ^^^ Useless assignment to variable - `foo`.
        end
      RUBY

      expect_correction(<<~RUBY)
        def some_method(flag)
          1 unless foo
        end
      RUBY
    end
  end

  context 'when a variable is assigned on each side of && and referenced after the &&' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method
          (foo = do_something_returns_object_or_nil) && (foo = 1)
          foo
        end
      RUBY
    end
  end

  context 'when a unreferenced variable is reassigned ' \
          'on the left side of && and referenced after the &&' do
    it 'registers an offense for the unreferenced assignment' do
      expect_offense(<<~RUBY)
        def some_method
          foo = 1
          ^^^ Useless assignment to variable - `foo`.
          (foo = do_something_returns_object_or_nil) && do_something
          foo
        end
      RUBY

      expect_correction(<<~RUBY)
        def some_method
          1
          (foo = do_something_returns_object_or_nil) && do_something
          foo
        end
      RUBY
    end
  end

  context 'when a unreferenced variable is reassigned ' \
          'on the right side of && and referenced after the &&' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method
          foo = 1
          do_something_returns_object_or_nil && foo = 2
          foo
        end
      RUBY
    end
  end

  context 'when a variable is reassigned while referencing itself in rhs and referenced' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method
          foo = [1, 2]
          foo = foo.map { |i| i + 1 }
          puts foo
        end
      RUBY
    end
  end

  context 'when a variable is reassigned with binary operator assignment and referenced' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method
          foo = 1
          foo += 1
          foo
        end
      RUBY
    end
  end

  context 'when a variable is reassigned with logical operator assignment and referenced' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method
          foo = do_something_returns_object_or_nil
          foo ||= 1
          foo
        end
      RUBY
    end
  end

  context 'when a variable is reassigned with binary operator ' \
          'assignment while assigning to itself in rhs ' \
          'then referenced' do
    it 'registers an offense for the assignment in rhs' do
      expect_offense(<<~RUBY)
        def some_method
          foo = 1
          foo += foo = 2
                 ^^^ Useless assignment to variable - `foo`.
          foo
        end
      RUBY

      expect_correction(<<~RUBY)
        def some_method
          foo = 1
          foo += 2
          foo
        end
      RUBY
    end
  end

  context 'when a variable is assigned first with ||= and referenced' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method
          foo ||= 1
          foo
        end
      RUBY
    end
  end

  context 'when a variable is assigned with ||= at the last expression of the scope' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def some_method
          foo = do_something_returns_object_or_nil
          foo ||= 1
          ^^^ Useless assignment to variable - `foo`. Use `||` instead of `||=`.
        end
      RUBY

      expect_correction(<<~RUBY)
        def some_method
          foo = do_something_returns_object_or_nil
          foo || 1
        end
      RUBY
    end
  end

  context 'when a variable is assigned with ||= before the last expression of the scope' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def some_method
          foo = do_something_returns_object_or_nil
          foo ||= 1
          ^^^ Useless assignment to variable - `foo`.
          some_return_value
        end
      RUBY

      expect_correction(<<~RUBY)
        def some_method
          foo = do_something_returns_object_or_nil
          foo || 1
          some_return_value
        end
      RUBY
    end
  end

  context 'when a variable is assigned with multiple assignment and unreferenced' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def some_method
          foo, bar = do_something
               ^^^ Useless assignment to variable - `bar`. Use `_` or `_bar` as a variable name to indicate that it won't be used.
          puts foo
        end
      RUBY

      expect_correction(<<~RUBY)
        def some_method
          foo, _ = do_something
          puts foo
        end
      RUBY
    end
  end

  context 'when a variable is reassigned with multiple assignment ' \
          'while referencing itself in rhs and referenced' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method
          foo = 1
          foo, bar = do_something(foo)
          puts foo, bar
        end
      RUBY
    end
  end

  context 'when a variable is assigned in loop body and referenced in post while condition' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        begin
          a = (a || 0) + 1
          puts a
        end while a <= 2
      RUBY
    end
  end

  context 'when a variable is assigned in loop body and referenced in post until condition' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        begin
          a = (a || 0) + 1
          puts a
        end until a > 2
      RUBY
    end
  end

  context 'when a variable is assigned in main body of begin with rescue but unreferenced' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        begin
          do_something
          foo = true
          ^^^ Useless assignment to variable - `foo`.
        rescue
          do_anything
        end
      RUBY

      expect_correction(<<~RUBY)
        begin
          do_something
          true
        rescue
          do_anything
        end
      RUBY
    end
  end

  context 'when a variable is assigned in main body of begin, rescue ' \
          'and else then referenced after the begin' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        begin
          do_something
          foo = :in_begin
        rescue FirstError
          foo = :in_first_rescue
        rescue SecondError
          foo = :in_second_rescue
        else
          foo = :in_else
        end

        puts foo
      RUBY
    end
  end

  context 'when a variable is reassigned multiple times ' \
          'in main body of begin then referenced after the begin' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        begin
          status = :initial
          connect_sometimes_fails!
          status = :connected
          fetch_sometimes_fails!
          status = :fetched
        rescue
          do_something
        end

        puts status
      RUBY
    end
  end

  context 'when a variable is reassigned multiple times ' \
          'in main body of begin then referenced in rescue' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        begin
          status = :initial
          connect_sometimes_fails!
          status = :connected
          fetch_sometimes_fails!
          status = :fetched
        rescue
          puts status
        end
      RUBY
    end
  end

  context 'when a variable is reassigned multiple times ' \
          'in main body of begin then referenced in ensure' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        begin
          status = :initial
          connect_sometimes_fails!
          status = :connected
          fetch_sometimes_fails!
          status = :fetched
        ensure
          puts status
        end
      RUBY
    end
  end

  context 'when a variable is reassigned multiple times in rescue and referenced after the begin' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        foo = false

        begin
          do_something
        rescue
          foo = true
          ^^^ Useless assignment to variable - `foo`.
          foo = true
        end

        puts foo
      RUBY

      expect_correction(<<~RUBY)
        foo = false

        begin
          do_something
        rescue
          true
          foo = true
        end

        puts foo
      RUBY
    end
  end

  context 'when a variable is reassigned multiple times ' \
          'in rescue with ensure then referenced after the begin' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        foo = false

        begin
          do_something
        rescue
          foo = true
          ^^^ Useless assignment to variable - `foo`.
          foo = true
        ensure
          do_anything
        end

        puts foo
      RUBY

      expect_correction(<<~RUBY)
        foo = false

        begin
          do_something
        rescue
          true
          foo = true
        ensure
          do_anything
        end

        puts foo
      RUBY
    end
  end

  context 'when a variable is reassigned multiple times ' \
          'in ensure with rescue then referenced after the begin' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        begin
          do_something
        rescue
          do_anything
        ensure
          foo = true
          ^^^ Useless assignment to variable - `foo`.
          foo = true
        end

        puts foo
      RUBY

      expect_correction(<<~RUBY)
        begin
          do_something
        rescue
          do_anything
        ensure
          true
          foo = true
        end

        puts foo
      RUBY
    end
  end

  context 'when a variable is assigned at the end of rescue and would be referenced with retry' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        retried = false

        begin
          do_something
        rescue
          fail if retried
          retried = true
          retry
        end
      RUBY
    end
  end

  context 'when a variable is assigned with operator assignment ' \
          'in rescue and would be referenced with retry' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        retry_count = 0

        begin
          do_something
        rescue
          fail if (retry_count += 1) > 3
          retry
        end
      RUBY
    end
  end

  context 'when a variable is assigned ' \
          'in main body of begin, rescue and else ' \
          'and reassigned in ensure then referenced after the begin' do
    it 'registers offenses for each assignment before ensure' do
      expect_offense(<<~RUBY)
        begin
          do_something
          foo = :in_begin
          ^^^ Useless assignment to variable - `foo`.
        rescue FirstError
          foo = :in_first_rescue
          ^^^ Useless assignment to variable - `foo`.
        rescue SecondError
          foo = :in_second_rescue
          ^^^ Useless assignment to variable - `foo`.
        else
          foo = :in_else
          ^^^ Useless assignment to variable - `foo`.
        ensure
          foo = :in_ensure
        end

        puts foo
      RUBY

      expect_correction(<<~RUBY)
        begin
          do_something
          :in_begin
        rescue FirstError
          :in_first_rescue
        rescue SecondError
          :in_second_rescue
        else
          :in_else
        ensure
          foo = :in_ensure
        end

        puts foo
      RUBY
    end
  end

  context 'when a rescued error variable is wrongly tried to be referenced ' \
          'in another rescue body' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        begin
          do_something
        rescue FirstError => error
                             ^^^^^ Useless assignment to variable - `error`.
        rescue SecondError
          p error # => nil
        end
      RUBY

      expect_correction(<<~RUBY)
        begin
          do_something
        rescue FirstError
        rescue SecondError
          p error # => nil
        end
      RUBY
    end
  end

  context 'when a method argument is reassigned and zero arity super is called' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method(foo)
          foo = 1
          super
        end
      RUBY
    end
  end

  context 'when a local variable is unreferenced and zero arity super is called' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def some_method(bar)
          foo = 1
          ^^^ Useless assignment to variable - `foo`.
          super
        end
      RUBY

      expect_correction(<<~RUBY)
        def some_method(bar)
          1
          super
        end
      RUBY
    end
  end

  context 'when a method argument is reassigned but not passed to super' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def some_method(foo, bar)
          foo = 1
          ^^^ Useless assignment to variable - `foo`.
          super(bar)
        end
      RUBY

      expect_correction(<<~RUBY)
        def some_method(foo, bar)
          1
          super(bar)
        end
      RUBY
    end
  end

  context 'when a named capture is unreferenced in top level' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        /(?<foo>\w+)/ =~ 'FOO'
        ^^^^^^^^^^^^ Useless assignment to variable - `foo`.
      RUBY

      expect_correction(<<~RUBY)
        /(?:\w+)/ =~ 'FOO'
      RUBY
    end
  end

  context 'when a named capture is unreferenced in other than top level' do
    it 'registers an offense' do
      expect_offense(<<~'RUBY')
        def some_method
          /(?<foo>\w+)/ =~ 'FOO'
          ^^^^^^^^^^^^^ Useless assignment to variable - `foo`.
        end
      RUBY

      expect_correction(<<~'RUBY')
        def some_method
          /(?:\w+)/ =~ 'FOO'
        end
      RUBY
    end
  end

  context 'when a named capture is referenced' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method
          /(?<foo>\w+)(?<bar>\s+)/ =~ 'FOO'
          puts foo
          puts bar
        end
      RUBY
    end
  end

  context 'when a variable is referenced in rhs of named capture expression' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method
          foo = 'some string'
          /(?<foo>\w+)/ =~ foo
          puts foo
        end
      RUBY
    end
  end

  context 'when a variable is assigned in begin and referenced outside' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method
          begin
            foo = 1
          end
          puts foo
        end
      RUBY
    end
  end

  context 'when a variable is shadowed by a block argument and unreferenced' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def some_method
          foo = 1
          ^^^ Useless assignment to variable - `foo`.
          1.times do |foo|
            puts foo
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def some_method
          1
          1.times do |foo|
            puts foo
          end
        end
      RUBY
    end
  end

  context 'when a variable is not used and the name starts with _' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method
          _foo = 1
          bar = 2
          puts bar
        end
      RUBY
    end
  end

  context 'when a method argument is not used' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method(arg)
        end
      RUBY
    end
  end

  context 'when an optional method argument is not used' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method(arg = nil)
        end
      RUBY
    end
  end

  context 'when a block method argument is not used' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method(&block)
        end
      RUBY
    end
  end

  context 'when a splat method argument is not used' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method(*args)
        end
      RUBY
    end
  end

  context 'when a optional keyword method argument is not used' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method(name: value)
        end
      RUBY
    end
  end

  context 'when a keyword splat method argument is used' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method(name: value, **rest_keywords)
          p rest_keywords
        end
      RUBY
    end
  end

  context 'when a keyword splat method argument is not used' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method(name: value, **rest_keywords)
        end
      RUBY
    end
  end

  context 'when an anonymous keyword splat method argument is defined' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        def some_method(name: value, **)
        end
      RUBY
    end
  end

  context 'when a block argument is not used' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        1.times do |i|
        end
      RUBY
    end
  end

  context 'when there is only one AST node and it is unused variable' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        foo = 1
        ^^^ Useless assignment to variable - `foo`.
      RUBY

      expect_correction(<<~RUBY)
        1
      RUBY
    end
  end

  context 'when a variable is assigned while being passed to a method taking block' do
    context 'and the variable is used' do
      it 'accepts' do
        expect_no_offenses(<<~RUBY)
          some_method(foo = 1) do
          end
          puts foo
        RUBY
      end
    end

    context 'and the variable is not used' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          some_method(foo = 1) do
                      ^^^ Useless assignment to variable - `foo`.
          end
        RUBY

        expect_correction(<<~RUBY)
          some_method(1) do
          end
        RUBY
      end
    end
  end

  context 'when a variable is assigned and passed to a method followed by method taking block' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        pattern = '*.rb'
        Dir.glob(pattern).map do |path|
        end
      RUBY
    end
  end

  context 'using numbered block parameter', :ruby27 do
    it 'does not register an offense when the variable is used' do
      expect_no_offenses(<<~RUBY)
        var = 42

        do_something { _1 == var }
      RUBY
    end

    it 'does not register an offense when the variable is assigned and later used' do
      expect_no_offenses(<<~RUBY)
        var = nil

        do_something { var = _1 }

        something_else(var)
      RUBY
    end
  end

  # regression test, from problem in Locatable
  context 'when a variable is assigned in 2 identical if branches' do
    it "doesn't think 1 of the 2 assignments is useless" do
      expect_no_offenses(<<~RUBY)
        def foo
          if bar
            foo = 1
          else
            foo = 1
          end
          foo.bar.baz
        end
      RUBY
    end
  end

  describe 'similar name suggestion' do
    context "when there's a similar variable-like method invocation" do
      it 'suggests the method name' do
        expect_offense(<<~RUBY)
          def some_method
            enviromnent = {}
            ^^^^^^^^^^^ Useless assignment to variable - `enviromnent`. Did you mean `environment`?
            another_symbol
            puts environment
          end
        RUBY

        expect_correction(<<~RUBY)
          def some_method
            {}
            another_symbol
            puts environment
          end
        RUBY
      end
    end

    context "when there's a similar variable" do
      it 'suggests the variable name' do
        expect_offense(<<~RUBY)
          def some_method
            environment = nil
            another_symbol
            enviromnent = {}
            ^^^^^^^^^^^ Useless assignment to variable - `enviromnent`. Did you mean `environment`?
            puts environment
          end
        RUBY

        expect_correction(<<~RUBY)
          def some_method
            environment = nil
            another_symbol
            {}
            puts environment
          end
        RUBY
      end
    end

    context 'when there are only less similar names' do
      it 'does not suggest any name' do
        expect_offense(<<~RUBY)
          def some_method
            enviromnent = {}
            ^^^^^^^^^^^ Useless assignment to variable - `enviromnent`.
            another_symbol
            puts envelope
          end
        RUBY

        expect_correction(<<~RUBY)
          def some_method
            {}
            another_symbol
            puts envelope
          end
        RUBY
      end
    end

    context "when there's a similar method invocation with explicit receiver" do
      it 'does not suggest any name' do
        expect_offense(<<~RUBY)
          def some_method
            enviromnent = {}
            ^^^^^^^^^^^ Useless assignment to variable - `enviromnent`.
            another_symbol
            puts self.environment
          end
        RUBY

        expect_correction(<<~RUBY)
          def some_method
            {}
            another_symbol
            puts self.environment
          end
        RUBY
      end
    end

    context "when there's a similar method invocation with arguments" do
      it 'does not suggest any name' do
        expect_offense(<<~RUBY)
          def some_method
            enviromnent = {}
            ^^^^^^^^^^^ Useless assignment to variable - `enviromnent`.
            another_symbol
            puts environment(1)
          end
        RUBY

        expect_correction(<<~RUBY)
          def some_method
            {}
            another_symbol
            puts environment(1)
          end
        RUBY
      end
    end

    context "when there's a similar name but it's in inner scope" do
      it 'does not suggest any name' do
        expect_offense(<<~RUBY)
          class SomeClass
            enviromnent = {}
            ^^^^^^^^^^^ Useless assignment to variable - `enviromnent`.

            def some_method(environment)
              puts environment
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class SomeClass
            {}

            def some_method(environment)
              puts environment
            end
          end
        RUBY
      end
    end
  end

  context 'inside a `case-match` node', :ruby27 do
    it 'does not register an offense when the variable is used' do
      expect_no_offenses(<<~RUBY)
        case '0'
        in String
          res = 1
        else
          res = 2
        end

        do_something(res)
      RUBY
    end
  end
end
