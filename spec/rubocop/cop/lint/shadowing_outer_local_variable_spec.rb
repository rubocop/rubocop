# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ShadowingOuterLocalVariable, :config do
  context 'when a block argument has same name as an outer scope variable' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def some_method
          foo = 1
          puts foo
          1.times do |foo|
                      ^^^ Shadowing outer local variable - `foo`.
          end
        end
      RUBY
    end
  end

  context 'when a splat block argument has same name as an outer scope variable' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def some_method
          foo = 1
          puts foo
          1.times do |*foo|
                      ^^^^ Shadowing outer local variable - `foo`.
          end
        end
      RUBY
    end
  end

  context 'when a block block argument has same name as an outer scope variable' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def some_method
          foo = 1
          puts foo
          proc_taking_block = proc do |&foo|
                                       ^^^^ Shadowing outer local variable - `foo`.
          end
          proc_taking_block.call do
          end
        end
      RUBY
    end
  end

  context 'when a block local variable has same name as an outer scope variable' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def some_method
          foo = 1
          puts foo
          1.times do |i; foo|
                         ^^^ Shadowing outer local variable - `foo`.
            puts foo
          end
        end
      RUBY
    end
  end

  context 'when a block local variable has same name as an outer `until` scope variable' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        until foo
          var = do_something
        end

        if bar
          array.each do |var|
                         ^^^ Shadowing outer local variable - `var`.
          end
        end
      RUBY
    end
  end

  context 'when a block local variable has same name as an outer `while` scope variable' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        while foo
          var = do_something
        end

        if bar
          array.each do |var|
                         ^^^ Shadowing outer local variable - `var`.
          end
        end
      RUBY
    end
  end

  context 'when a block local variable has same name as an outer scope variable' \
          'with same branches of same `if` condition node not in the method definition' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        if condition?
          foo = 1
          puts foo
          bar.each do |foo|
                       ^^^ Shadowing outer local variable - `foo`.
          end
        else
          bar.each do |foo|
          end
        end
      RUBY
    end
  end

  context 'when a block local variable has same name as an outer scope variable' \
          'with same branches of same `if` condition node' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def some_method
          if condition?
            foo = 1
            puts foo
            bar.each do |foo|
                         ^^^ Shadowing outer local variable - `foo`.
            end
          else
            bar.each do |foo|
            end
          end
        end
      RUBY
    end
  end

  context 'when a block local variable has same name as an outer scope variable' \
          'with same branches of same nested `if` condition node' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def some_method
          if condition?
            foo = 1
            puts foo
            if other_condition?
              bar.each do |foo|
                           ^^^ Shadowing outer local variable - `foo`.
              end
            end
          elsif other_condition?
            bar.each do |foo|
            end
          else
            bar.each do |foo|
            end
          end
        end
      RUBY
    end
  end

  context 'when a block local variable has same name as an outer scope variable' \
          'with same branches of same `unless` condition node' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def some_method
          unless condition?
            foo = 1
            puts foo
            bar.each do |foo|
                         ^^^ Shadowing outer local variable - `foo`.
            end
          else
            bar.each do |foo|
            end
          end
        end
      RUBY
    end
  end

  context 'when a block local variable has same name as an outer scope variable' \
          'with same branches of same `case` condition node' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def some_method
          case condition
          when foo then
            foo = 1
            puts foo
            bar.each do |foo|
                         ^^^ Shadowing outer local variable - `foo`.
            end
          when bar then
            bar.each do |foo|
            end
          else
            bar.each do |foo|
            end
          end
        end
      RUBY
    end
  end

  context 'when a block local variable has same name as an outer scope variable' \
          'with different branches of same `if` condition node' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def some_method
          if condition?
            foo = 1
          elsif other_condition?
            bar.each do |foo|
            end
          else
            bar.each do |foo|
            end
          end
        end
      RUBY
    end
  end

  context 'when a block local variable has same name as an outer scope variable' \
          'with different branches of same `unless` condition node' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def some_method
          unless condition?
            foo = 1
          else
            bar.each do |foo|
            end
          end
        end
      RUBY
    end
  end

  context 'when a block local variable has same name as an outer scope variable' \
          'with different branches of same `case` condition node' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def some_method
          case condition
          when foo then
            foo = 1
          else
            bar.each do |foo|
            end
          end
        end
      RUBY
    end
  end

  context 'when a block argument has different name with outer scope variables' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def some_method
          foo = 1
          puts foo
          1.times do |bar|
          end
        end
      RUBY
    end
  end

  context 'when an outer scope variable is reassigned in a block' do
    it 'does not register an offense' do
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

  context 'when an outer scope variable is referenced in a block' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def some_method
          foo = 1
          puts foo
          1.times do
            puts foo
          end
        end
      RUBY
    end
  end

  context 'when the same variable name as a block variable is used in return value assignment of `if`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def some_method
          foo = if condition
                  bar { |foo| baz(foo) }
                end
        end
      RUBY
    end
  end

  context 'when multiple block arguments have same name "_"' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def some_method
          1.times do |_, foo, _|
          end
        end
      RUBY
    end
  end

  context 'when multiple block arguments have a same name starts with "_"' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def some_method
          1.times do |_foo, bar, _foo|
          end
        end
      RUBY
    end
  end

  context 'when a block argument has same name "_" as outer scope variable "_"' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def some_method
          _ = 1
          puts _
          1.times do |_|
          end
        end
      RUBY
    end
  end

  context 'when a block argument has a same name starts with "_" as an outer scope variable' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def some_method
          _foo = 1
          puts _foo
          1.times do |_foo|
          end
        end
      RUBY
    end
  end

  context 'when a method argument has same name as an outer scope variable' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class SomeClass
          foo = 1
          puts foo
          def some_method(foo)
          end
        end
      RUBY
    end
  end

  context 'when a block parameter has same name as a prior block body variable' do
    context 'when assigning a block parameter' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          def x(array)
            array.each { |foo|
              bar = foo
            }.each { |bar|
            }
          end
        RUBY
      end
    end

    context 'when assigning a numbered block parameter', :ruby27 do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          def x(array)
            array.each {
              bar = _1
            }.each { |bar|
            }
          end
        RUBY
      end
    end
  end

  context 'with Ractor.new' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def foo(*args)
          Ractor.new(*args) do |*args|
          end
        end
      RUBY
    end
  end
end
