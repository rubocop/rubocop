# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UselessTimes, :config do
  it 'registers an offense and corrects with 0.times' do
    expect_offense(<<~RUBY)
      0.times { something }
      ^^^^^^^^^^^^^^^^^^^^^ Useless call to `0.times` detected.
    RUBY

    expect_correction('')
  end

  it 'registers an offense and corrects with 0.times with block arg' do
    expect_offense(<<~RUBY)
      0.times { |i| something(i) }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Useless call to `0.times` detected.
    RUBY

    expect_correction('')
  end

  it 'registers an offense and corrects with negative times' do
    expect_offense(<<~RUBY)
      -1.times { something }
      ^^^^^^^^^^^^^^^^^^^^^^ Useless call to `-1.times` detected.
    RUBY

    expect_correction('')
  end

  it 'registers an offense and corrects with negative times with block arg' do
    expect_offense(<<~RUBY)
      -1.times { |i| something(i) }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Useless call to `-1.times` detected.
    RUBY

    expect_correction('')
  end

  it 'registers an offense and corrects with 1.times' do
    expect_offense(<<~RUBY)
      1.times { something }
      ^^^^^^^^^^^^^^^^^^^^^ Useless call to `1.times` detected.
    RUBY

    expect_correction(<<~RUBY)
      something
    RUBY
  end

  it 'registers an offense and corrects with 1.times with block arg' do
    expect_offense(<<~RUBY)
      1.times { |i| something(i) }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Useless call to `1.times` detected.
    RUBY

    expect_correction(<<~RUBY)
      something(0)
    RUBY
  end

  it 'registers an offense and corrects with 1.times with method chain' do
    expect_offense(<<~RUBY)
      1.times.reverse_each do
      ^^^^^^^ Useless call to `1.times` detected.
        foo
      end
    RUBY

    expect_no_corrections
  end

  it 'registers an offense and corrects when 1.times with empty block argument' do
    expect_offense(<<~RUBY)
      def foo
        1.times do
        ^^^^^^^^^^ Useless call to `1.times` detected.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
      end
    RUBY
  end

  it 'registers an offense and corrects when there is a blank line in the method definition' do
    expect_offense(<<~RUBY)
      def foo
        1.times do
        ^^^^^^^^^^ Useless call to `1.times` detected.
          bar

          baz
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        bar

        baz
      end
    RUBY
  end

  it 'does not register an offense for an integer > 1' do
    expect_no_offenses(<<~RUBY)
      2.times { |i| puts i }
    RUBY
  end

  context 'short-form method' do
    it 'registers an offense and corrects with 0.times' do
      expect_offense(<<~RUBY)
        0.times(&:something)
        ^^^^^^^^^^^^^^^^^^^^ Useless call to `0.times` detected.
      RUBY

      expect_correction('')
    end

    it 'registers an offense and corrects with negative times' do
      expect_offense(<<~RUBY)
        -1.times(&:something)
        ^^^^^^^^^^^^^^^^^^^^^ Useless call to `-1.times` detected.
      RUBY

      expect_correction('')
    end

    it 'registers an offense and corrects with 1.times' do
      expect_offense(<<~RUBY)
        1.times(&:something)
        ^^^^^^^^^^^^^^^^^^^^ Useless call to `1.times` detected.
      RUBY

      expect_correction(<<~RUBY)
        something
      RUBY
    end

    it 'does not register an offense for an integer > 1' do
      expect_no_offenses(<<~RUBY)
        2.times(&:something)
      RUBY
    end

    it 'does not adjust surrounding space' do
      expect_offense(<<~RUBY)
        precondition
        0.times(&:something)
        ^^^^^^^^^^^^^^^^^^^^ Useless call to `0.times` detected.
        postcondition
      RUBY

      expect_correction(<<~RUBY)
        precondition
        postcondition
      RUBY
    end
  end

  context 'multiline block' do
    it 'correctly handles a multiline block with 1.times' do
      expect_offense(<<~RUBY)
        1.times do |i|
        ^^^^^^^^^^^^^^ Useless call to `1.times` detected.
          do_something(i)
          do_something_else(i)
        end
      RUBY

      expect_correction(<<~RUBY)
        do_something(0)
        do_something_else(0)
      RUBY
    end

    it 'does not try to correct a block if the block arg is changed' do
      expect_offense(<<~RUBY)
        1.times do |i|
        ^^^^^^^^^^^^^^ Useless call to `1.times` detected.
          do_something(i)
          i += 1
          do_something_else(i)
        end
      RUBY

      expect_no_corrections
    end

    it 'does not try to correct a block if the block arg is changed in parallel assignment' do
      expect_offense(<<~RUBY)
        1.times do |i|
        ^^^^^^^^^^^^^^ Useless call to `1.times` detected.
          do_something(i)
          i, j = i * 2, i * 3
          do_something_else(i)
        end
      RUBY

      expect_no_corrections
    end

    it 'corrects a block that changes another lvar' do
      expect_offense(<<~RUBY)
        1.times do |i|
        ^^^^^^^^^^^^^^ Useless call to `1.times` detected.
          do_something(i)
          j = 1
          do_something_else(j)
        end
      RUBY

      expect_correction(<<~RUBY)
        do_something(0)
        j = 1
        do_something_else(j)
      RUBY
    end
  end

  context 'within indentation' do
    it 'corrects properly when removing single line' do
      expect_offense(<<~RUBY)
        def my_method
          0.times { do_something }
          ^^^^^^^^^^^^^^^^^^^^^^^^ Useless call to `0.times` detected.
        end
      RUBY

      expect_correction(<<~RUBY)
        def my_method
        end
      RUBY
    end

    it 'corrects properly when removing multiline' do
      expect_offense(<<~RUBY)
        def my_method
          0.times do
          ^^^^^^^^^^ Useless call to `0.times` detected.
            do_something
            do_something_else
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def my_method
        end
      RUBY
    end

    it 'corrects properly when replacing' do
      expect_offense(<<~RUBY)
        def my_method
          1.times do
          ^^^^^^^^^^ Useless call to `1.times` detected.
            do_something
            do_something_else
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def my_method
          do_something
          do_something_else
        end
      RUBY
    end

    context 'inline `Integer#times` calls' do
      it 'does not try to correct `0.times`' do
        expect_offense(<<~RUBY)
          foo(0.times { do_something })
              ^^^^^^^^^^^^^^^^^^^^^^^^ Useless call to `0.times` detected.
        RUBY

        expect_no_corrections
      end

      it 'does not try to correct `1.times`' do
        expect_offense(<<~RUBY)
          foo(1.times { do_something })
              ^^^^^^^^^^^^^^^^^^^^^^^^ Useless call to `1.times` detected.
        RUBY

        expect_no_corrections
      end
    end
  end
end
