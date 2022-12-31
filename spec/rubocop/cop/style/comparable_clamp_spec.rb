# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ComparableClamp, :config do
  context 'target ruby version >= 2.4', :ruby24 do
    it 'registers and corrects an offense when using `if x < low` / `elsif high < x` / `else`' do
      expect_offense(<<~RUBY)
        if x < low
        ^^^^^^^^^^ Use `x.clamp(low, high)` instead of `if/elsif/else`.
          low
        elsif high < x
          high
        else
          x
        end
      RUBY

      expect_correction(<<~RUBY)
        x.clamp(low, high)
      RUBY
    end

    it 'registers and corrects an offense when using `if low > x` / `elsif high < x` / `else`' do
      expect_offense(<<~RUBY)
        if low > x
        ^^^^^^^^^^ Use `x.clamp(low, high)` instead of `if/elsif/else`.
          low
        elsif high < x
          high
        else
          x
        end
      RUBY

      expect_correction(<<~RUBY)
        x.clamp(low, high)
      RUBY
    end

    it 'registers and corrects an offense when using `if x < low` / `elsif x > high` / `else`' do
      expect_offense(<<~RUBY)
        if x < low
        ^^^^^^^^^^ Use `x.clamp(low, high)` instead of `if/elsif/else`.
          low
        elsif x > high
          high
        else
          x
        end
      RUBY

      expect_correction(<<~RUBY)
        x.clamp(low, high)
      RUBY
    end

    it 'registers and corrects an offense when using `if low > x` / `elsif x > high` / `else`' do
      expect_offense(<<~RUBY)
        if low > x
        ^^^^^^^^^^ Use `x.clamp(low, high)` instead of `if/elsif/else`.
          low
        elsif x > high
          high
        else
          x
        end
      RUBY

      expect_correction(<<~RUBY)
        x.clamp(low, high)
      RUBY
    end

    it 'registers and corrects an offense when using `if high < x` / `elsif x < low` / `else`' do
      expect_offense(<<~RUBY)
        if high < x
        ^^^^^^^^^^^ Use `x.clamp(low, high)` instead of `if/elsif/else`.
          high
        elsif x < low
          low
        else
          x
        end
      RUBY

      expect_correction(<<~RUBY)
        x.clamp(low, high)
      RUBY
    end

    it 'registers and corrects an offense when using `if x > high` / `elsif x < low` / `else`' do
      expect_offense(<<~RUBY)
        if x > high
        ^^^^^^^^^^^ Use `x.clamp(low, high)` instead of `if/elsif/else`.
          high
        elsif x < low
          low
        else
          x
        end
      RUBY

      expect_correction(<<~RUBY)
        x.clamp(low, high)
      RUBY
    end

    it 'registers and corrects an offense when using `if high < x` / `elsif low > x` / `else`' do
      expect_offense(<<~RUBY)
        if high < x
        ^^^^^^^^^^^ Use `x.clamp(low, high)` instead of `if/elsif/else`.
          high
        elsif low > x
          low
        else
          x
        end
      RUBY

      expect_correction(<<~RUBY)
        x.clamp(low, high)
      RUBY
    end

    it 'registers and corrects an offense when using `if x > high` / `elsif low > x` / `else`' do
      expect_offense(<<~RUBY)
        if x > high
        ^^^^^^^^^^^ Use `x.clamp(low, high)` instead of `if/elsif/else`.
          high
        elsif low > x
          low
        else
          x
        end
      RUBY

      expect_correction(<<~RUBY)
        x.clamp(low, high)
      RUBY
    end

    it 'registers and corrects an offense when using `elsif x > high` / `elsif low > x` / `else`' do
      expect_offense(<<~RUBY)
        if condition
          do_something
        elsif x > high
        ^^^^^^^^^^^^^^ Use `x.clamp(low, high)` instead of `if/elsif/else`.
          high
        elsif low > x
          low
        else
          x
        end
      RUBY

      expect_correction(<<~RUBY)
        if condition
          do_something
        else
          x.clamp(low, high)
        end
      RUBY
    end

    it 'does not register and corrects an offense when using `if x < low` / `elsif high < x` / `else` and all return values are the same' do
      expect_no_offenses(<<~RUBY)
        if x < low
          x
        elsif high < x
          x
        else
          x
        end
      RUBY
    end

    it 'registers an offense when using `[[x, low].max, high].min`' do
      expect_offense(<<~RUBY)
        [[x, low].max, high].min
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `Comparable#clamp` instead.
      RUBY

      expect_no_corrections
    end

    it 'registers an offense when using `[[low, x].max, high].min`' do
      expect_offense(<<~RUBY)
        [[low, x].max, high].min
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `Comparable#clamp` instead.
      RUBY

      expect_no_corrections
    end

    it 'registers an offense when using `[high, [x, low].max].min`' do
      expect_offense(<<~RUBY)
        [high, [x, low].max].min
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `Comparable#clamp` instead.
      RUBY

      expect_no_corrections
    end

    it 'registers an offense when using `[high, [low, x].max].min`' do
      expect_offense(<<~RUBY)
        [high, [low, x].max].min
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `Comparable#clamp` instead.
      RUBY

      expect_no_corrections
    end

    it 'registers an offense when using `[[x, high].min, low].max`' do
      expect_offense(<<~RUBY)
        [[x, high].min, low].max
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `Comparable#clamp` instead.
      RUBY

      expect_no_corrections
    end

    it 'registers an offense when using `[[high, x].min, low].max`' do
      expect_offense(<<~RUBY)
        [[high, x].min, low].max
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `Comparable#clamp` instead.
      RUBY

      expect_no_corrections
    end

    it 'registers and corrects an offense when using `[[low, high].min].max`' do
      expect_offense(<<~RUBY)
        [low, [x, high].min].max
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `Comparable#clamp` instead.
      RUBY

      expect_no_corrections
    end

    it 'registers and corrects an offense when using `[low, [high, x].min].max`' do
      expect_offense(<<~RUBY)
        [low, [high, x].min].max
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `Comparable#clamp` instead.
      RUBY

      expect_no_corrections
    end
  end

  context 'target ruby version <= 2.3', :ruby23 do
    it 'does not register an offense when using `[[x, low].max, high].min`' do
      expect_no_offenses(<<~RUBY)
        [[x, low].max, high].min
      RUBY
    end

    it 'does not register an offense when using `[[low, x].max, high].min`' do
      expect_no_offenses(<<~RUBY)
        [[low, x].max, high].min
      RUBY
    end

    it 'does not register an offense when using `[high, [x, low].max].min`' do
      expect_no_offenses(<<~RUBY)
        [high, [x, low].max].min
      RUBY
    end

    it 'does not register an offense when using `[high, [low, x].max].min`' do
      expect_no_offenses(<<~RUBY)
        [high, [low, x].max].min
      RUBY
    end
  end

  it 'does not register an offense when using `[low, high].min`' do
    expect_no_offenses(<<~RUBY)
      [low, high].min
    RUBY
  end
end
