# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::OrAssignment, :config do
  context 'when using var = var ? var : something' do
    it 'registers an offense with normal variables' do
      expect_offense(<<~RUBY)
        foo = foo ? foo : 'default'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
      RUBY

      expect_correction(<<~RUBY)
        foo ||= 'default'
      RUBY
    end

    it 'registers an offense with instance variables' do
      expect_offense(<<~RUBY)
        @foo = @foo ? @foo : 'default'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
      RUBY

      expect_correction(<<~RUBY)
        @foo ||= 'default'
      RUBY
    end

    it 'registers an offense with class variables' do
      expect_offense(<<~RUBY)
        @@foo = @@foo ? @@foo : 'default'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
      RUBY

      expect_correction(<<~RUBY)
        @@foo ||= 'default'
      RUBY
    end

    it 'registers an offense with global variables' do
      expect_offense(<<~RUBY)
        $foo = $foo ? $foo : 'default'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
      RUBY

      expect_correction(<<~RUBY)
        $foo ||= 'default'
      RUBY
    end

    it 'does not register an offense if any of the variables are different' do
      expect_no_offenses('foo = bar ? foo : 3')
      expect_no_offenses('foo = foo ? bar : 3')
    end
  end

  context 'when using var = if var; var; else; something; end' do
    it 'registers an offense with normal variables' do
      expect_offense(<<~RUBY)
        foo = if foo
        ^^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
                foo
              else
                'default'
              end
      RUBY

      expect_correction(<<~RUBY)
        foo ||= 'default'
      RUBY
    end

    it 'registers an offense with instance variables' do
      expect_offense(<<~RUBY)
        @foo = if @foo
        ^^^^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
                 @foo
               else
                 'default'
               end
      RUBY

      expect_correction(<<~RUBY)
        @foo ||= 'default'
      RUBY
    end

    it 'registers an offense with class variables' do
      expect_offense(<<~RUBY)
        @@foo = if @@foo
        ^^^^^^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
                  @@foo
                else
                  'default'
                end
      RUBY

      expect_correction(<<~RUBY)
        @@foo ||= 'default'
      RUBY
    end

    it 'registers an offense with global variables' do
      expect_offense(<<~RUBY)
        $foo = if $foo
        ^^^^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
                 $foo
               else
                 'default'
               end
      RUBY

      expect_correction(<<~RUBY)
        $foo ||= 'default'
      RUBY
    end

    it 'does not register an offense if any of the variables are different' do
      expect_no_offenses(<<~RUBY)
        foo = if foo
                bar
              else
                3
              end
      RUBY
      expect_no_offenses(<<~RUBY)
        foo = if bar
                foo
              else
                3
              end
      RUBY
    end
  end

  context 'when using var = something unless var' do
    it 'registers an offense for normal variables' do
      expect_offense(<<~RUBY)
        foo = 'default' unless foo
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
      RUBY

      expect_correction(<<~RUBY)
        foo ||= 'default'
      RUBY
    end

    it 'registers an offense for instance variables' do
      expect_offense(<<~RUBY)
        @foo = 'default' unless @foo
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
      RUBY

      expect_correction(<<~RUBY)
        @foo ||= 'default'
      RUBY
    end

    it 'registers an offense for class variables' do
      expect_offense(<<~RUBY)
        @@foo = 'default' unless @@foo
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
      RUBY

      expect_correction(<<~RUBY)
        @@foo ||= 'default'
      RUBY
    end

    it 'registers an offense for global variables' do
      expect_offense(<<~RUBY)
        $foo = 'default' unless $foo
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
      RUBY

      expect_correction(<<~RUBY)
        $foo ||= 'default'
      RUBY
    end

    it 'does not register an offense if any of the variables are different' do
      expect_no_offenses('foo = 3 unless bar')
      expect_no_offenses(<<~RUBY)
        unless foo
          bar = 3
        end
      RUBY
    end
  end

  context 'when using unless var; var = something; end' do
    it 'registers an offense for normal variables' do
      expect_offense(<<~RUBY)
        foo = nil
        unless foo
        ^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
          foo = 'default'
        end
      RUBY

      expect_correction(<<~RUBY)
        foo = nil
        foo ||= 'default'
      RUBY
    end

    it 'registers an offense for instance variables' do
      expect_offense(<<~RUBY)
        @foo = nil
        unless @foo
        ^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
          @foo = 'default'
        end
      RUBY

      expect_correction(<<~RUBY)
        @foo = nil
        @foo ||= 'default'
      RUBY
    end

    it 'registers an offense for class variables' do
      expect_offense(<<~RUBY)
        @@foo = nil
        unless @@foo
        ^^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
          @@foo = 'default'
        end
      RUBY

      expect_correction(<<~RUBY)
        @@foo = nil
        @@foo ||= 'default'
      RUBY
    end

    it 'registers an offense for global variables' do
      expect_offense(<<~RUBY)
        $foo = nil
        unless $foo
        ^^^^^^^^^^^ Use the double pipe equals operator `||=` instead.
          $foo = 'default'
        end
      RUBY

      expect_correction(<<~RUBY)
        $foo = nil
        $foo ||= 'default'
      RUBY
    end

    it 'does not register an offense if any of the variables are different' do
      expect_no_offenses(<<~RUBY)
        unless foo
          bar = 3
        end
      RUBY
    end
  end

  context 'when `then` branch body is empty' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        foo = nil
        if foo
        ^^^^^^ Use the double pipe equals operator `||=` instead.
        else
          foo = 2
        end
      RUBY

      expect_correction(<<~RUBY)
        foo = nil
        foo ||= 2
      RUBY
    end
  end

  context 'when using `elsif` statement' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        foo = if foo
                foo
              elsif
                bar
              else
                'default'
              end
      RUBY
    end
  end
end
