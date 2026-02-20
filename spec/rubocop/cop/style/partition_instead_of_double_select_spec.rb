# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::PartitionInsteadOfDoubleSelect, :config do
  context 'when using select and reject with same receiver and block' do
    it 'registers an offense and corrects select followed by reject' do
      expect_offense(<<~RUBY)
        positives = arr.select { |x| x > 0 }
        negatives = arr.reject { |x| x > 0 }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `partition` instead of consecutive `select` and `reject` calls.
      RUBY

      expect_correction(<<~RUBY)
        positives, negatives = arr.partition { |x| x > 0 }
      RUBY
    end

    it 'registers an offense and corrects reject followed by select' do
      expect_offense(<<~RUBY)
        negatives = arr.reject { |x| x > 0 }
        positives = arr.select { |x| x > 0 }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `partition` instead of consecutive `reject` and `select` calls.
      RUBY

      expect_correction(<<~RUBY)
        positives, negatives = arr.partition { |x| x > 0 }
      RUBY
    end

    it 'registers an offense and corrects filter followed by reject' do
      expect_offense(<<~RUBY)
        positives = arr.filter { |x| x > 0 }
        negatives = arr.reject { |x| x > 0 }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `partition` instead of consecutive `filter` and `reject` calls.
      RUBY

      expect_correction(<<~RUBY)
        positives, negatives = arr.partition { |x| x > 0 }
      RUBY
    end

    it 'registers an offense and corrects find_all followed by reject' do
      expect_offense(<<~RUBY)
        positives = arr.find_all { |x| x > 0 }
        negatives = arr.reject { |x| x > 0 }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `partition` instead of consecutive `find_all` and `reject` calls.
      RUBY

      expect_correction(<<~RUBY)
        positives, negatives = arr.partition { |x| x > 0 }
      RUBY
    end

    it 'registers an offense and corrects with do...end blocks' do
      expect_offense(<<~RUBY)
        positives = arr.select do |x|
          x > 0
        end
        negatives = arr.reject do |x|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `partition` instead of consecutive `select` and `reject` calls.
          x > 0
        end
      RUBY

      expect_correction(<<~RUBY)
        positives, negatives = arr.partition do |x|
          x > 0
        end
      RUBY
    end

    it 'registers an offense and corrects with numbered block parameters' do
      expect_offense(<<~RUBY)
        positives = arr.select { _1 > 0 }
        negatives = arr.reject { _1 > 0 }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `partition` instead of consecutive `select` and `reject` calls.
      RUBY

      expect_correction(<<~RUBY)
        positives, negatives = arr.partition { _1 > 0 }
      RUBY
    end

    it 'registers an offense and corrects with `it` block parameter', :ruby34 do
      expect_offense(<<~RUBY)
        positives = arr.select { it > 0 }
        negatives = arr.reject { it > 0 }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `partition` instead of consecutive `select` and `reject` calls.
      RUBY

      expect_correction(<<~RUBY)
        positives, negatives = arr.partition { it > 0 }
      RUBY
    end

    it 'registers an offense and corrects with a method chain receiver' do
      expect_offense(<<~RUBY)
        positives = foo.bar.select { |x| x > 0 }
        negatives = foo.bar.reject { |x| x > 0 }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `partition` instead of consecutive `select` and `reject` calls.
      RUBY

      expect_correction(<<~RUBY)
        positives, negatives = foo.bar.partition { |x| x > 0 }
      RUBY
    end

    it 'registers an offense and corrects with safe navigation' do
      expect_offense(<<~RUBY)
        positives = arr&.select { |x| x > 0 }
        negatives = arr&.reject { |x| x > 0 }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `partition` instead of consecutive `select` and `reject` calls.
      RUBY

      expect_correction(<<~RUBY)
        positives, negatives = arr&.partition { |x| x > 0 }
      RUBY
    end

    it 'registers an offense but does not correct bare blocks without assignment' do
      expect_offense(<<~RUBY)
        arr.select { |x| x > 0 }
        arr.reject { |x| x > 0 }
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `partition` instead of consecutive `select` and `reject` calls.
      RUBY

      expect_no_corrections
    end

    it 'registers an offense but does not correct instance variable assignments' do
      expect_offense(<<~RUBY)
        @positives = arr.select { |x| x > 0 }
        @negatives = arr.reject { |x| x > 0 }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `partition` instead of consecutive `select` and `reject` calls.
      RUBY

      expect_no_corrections
    end

    it 'registers an offense but does not correct mixed assignment types' do
      expect_offense(<<~RUBY)
        positives = arr.select { |x| x > 0 }
        @negatives = arr.reject { |x| x > 0 }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `partition` instead of consecutive `select` and `reject` calls.
      RUBY

      expect_no_corrections
    end

    it 'preserves surrounding code when correcting' do
      expect_offense(<<~RUBY)
        before_code
        positives = arr.select { |x| x > 0 }
        negatives = arr.reject { |x| x > 0 }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `partition` instead of consecutive `select` and `reject` calls.
        after_code
      RUBY

      expect_correction(<<~RUBY)
        before_code
        positives, negatives = arr.partition { |x| x > 0 }
        after_code
      RUBY
    end
  end

  context 'when using select and reject with block_pass (&:sym) form' do
    it 'registers an offense and corrects select followed by reject' do
      expect_offense(<<~RUBY)
        positives = arr.select(&:positive?)
        negatives = arr.reject(&:positive?)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `partition` instead of consecutive `select` and `reject` calls.
      RUBY

      expect_correction(<<~RUBY)
        positives, negatives = arr.partition(&:positive?)
      RUBY
    end

    it 'registers an offense and corrects reject followed by select' do
      expect_offense(<<~RUBY)
        negatives = arr.reject(&:positive?)
        positives = arr.select(&:positive?)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `partition` instead of consecutive `reject` and `select` calls.
      RUBY

      expect_correction(<<~RUBY)
        positives, negatives = arr.partition(&:positive?)
      RUBY
    end

    it 'registers an offense and corrects filter with block_pass followed by reject' do
      expect_offense(<<~RUBY)
        positives = arr.filter(&:positive?)
        negatives = arr.reject(&:positive?)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `partition` instead of consecutive `filter` and `reject` calls.
      RUBY

      expect_correction(<<~RUBY)
        positives, negatives = arr.partition(&:positive?)
      RUBY
    end

    it 'registers an offense and corrects with safe navigation' do
      expect_offense(<<~RUBY)
        positives = arr&.select(&:positive?)
        negatives = arr&.reject(&:positive?)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `partition` instead of consecutive `select` and `reject` calls.
      RUBY

      expect_correction(<<~RUBY)
        positives, negatives = arr&.partition(&:positive?)
      RUBY
    end

    it 'registers an offense but does not correct bare calls without assignment' do
      expect_offense(<<~RUBY)
        arr.select(&:positive?)
        arr.reject(&:positive?)
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `partition` instead of consecutive `select` and `reject` calls.
      RUBY

      expect_no_corrections
    end

    it 'does not register an offense when block_pass arguments differ' do
      expect_no_offenses(<<~RUBY)
        positives = arr.select(&:positive?)
        negatives = arr.reject(&:negative?)
      RUBY
    end

    it 'does not register an offense when receivers differ' do
      expect_no_offenses(<<~RUBY)
        positives = arr1.select(&:positive?)
        negatives = arr2.reject(&:positive?)
      RUBY
    end

    it 'registers an offense and corrects block_pass select with block reject' do
      expect_offense(<<~RUBY)
        positives = arr.select(&:positive?)
        negatives = arr.reject { |x| x.positive? }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `partition` instead of consecutive `select` and `reject` calls.
      RUBY

      expect_correction(<<~RUBY)
        positives, negatives = arr.partition(&:positive?)
      RUBY
    end

    it 'registers an offense and corrects block select with block_pass reject' do
      expect_offense(<<~RUBY)
        positives = arr.select { |x| x.positive? }
        negatives = arr.reject(&:positive?)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `partition` instead of consecutive `select` and `reject` calls.
      RUBY

      expect_correction(<<~RUBY)
        positives, negatives = arr.partition { |x| x.positive? }
      RUBY
    end

    it 'does not register an offense for non-equivalent mixed forms' do
      expect_no_offenses(<<~RUBY)
        positives = arr.select(&:positive?)
        negatives = arr.reject { |x| x.negative? }
      RUBY
    end
  end

  context 'when using same method with negated predicate' do
    it 'registers an offense and corrects two select calls with negation' do
      expect_offense(<<~RUBY)
        a = arr.select { |x| x.positive? }
        b = arr.select { |x| !x.positive? }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `partition` instead of consecutive `select` and `select` calls.
      RUBY

      expect_correction(<<~RUBY)
        a, b = arr.partition { |x| x.positive? }
      RUBY
    end

    it 'registers an offense and corrects reversed select calls with negation' do
      expect_offense(<<~RUBY)
        b = arr.select { |x| !x.positive? }
        a = arr.select { |x| x.positive? }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `partition` instead of consecutive `select` and `select` calls.
      RUBY

      expect_correction(<<~RUBY)
        a, b = arr.partition { |x| x.positive? }
      RUBY
    end

    it 'registers an offense and corrects two reject calls with negation' do
      expect_offense(<<~RUBY)
        a = arr.reject { |x| x.positive? }
        b = arr.reject { |x| !x.positive? }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `partition` instead of consecutive `reject` and `reject` calls.
      RUBY

      expect_correction(<<~RUBY)
        b, a = arr.partition { |x| x.positive? }
      RUBY
    end

    it 'registers an offense and corrects with numbered block parameters' do
      expect_offense(<<~RUBY)
        a = arr.select { _1.positive? }
        b = arr.select { !_1.positive? }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `partition` instead of consecutive `select` and `select` calls.
      RUBY

      expect_correction(<<~RUBY)
        a, b = arr.partition { _1.positive? }
      RUBY
    end

    it 'registers an offense but does not correct bare calls' do
      expect_offense(<<~RUBY)
        arr.select { |x| x.positive? }
        arr.select { |x| !x.positive? }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `partition` instead of consecutive `select` and `select` calls.
      RUBY

      expect_no_corrections
    end

    it 'does not register an offense when negation is on a different expression' do
      expect_no_offenses(<<~RUBY)
        a = arr.select { |x| x.positive? }
        b = arr.select { |x| !x.negative? }
      RUBY
    end

    it 'does not register an offense for two select calls with same body' do
      expect_no_offenses(<<~RUBY)
        a = arr.select { |x| x > 0 }
        b = arr.select { |x| x > 0 }
      RUBY
    end

    it 'does not register an offense for two reject calls with same body' do
      expect_no_offenses(<<~RUBY)
        a = arr.reject { |x| x > 0 }
        b = arr.reject { |x| x > 0 }
      RUBY
    end
  end

  context 'when blocks differ' do
    it 'does not register an offense when block bodies differ' do
      expect_no_offenses(<<~RUBY)
        positives = arr.select { |x| x > 0 }
        negatives = arr.reject { |x| x < 0 }
      RUBY
    end

    it 'does not register an offense when block argument names differ' do
      expect_no_offenses(<<~RUBY)
        positives = arr.select { |x| x > 0 }
        negatives = arr.reject { |y| y > 0 }
      RUBY
    end

    it 'does not register an offense when block types differ' do
      expect_no_offenses(<<~RUBY)
        positives = arr.select { |x| x > 0 }
        negatives = arr.reject { _1 > 0 }
      RUBY
    end
  end

  context 'when receivers differ' do
    it 'does not register an offense when receivers differ' do
      expect_no_offenses(<<~RUBY)
        positives = arr1.select { |x| x > 0 }
        negatives = arr2.reject { |x| x > 0 }
      RUBY
    end
  end

  context 'when calls are not consecutive' do
    it 'does not register an offense when calls are separated by other code' do
      expect_no_offenses(<<~RUBY)
        positives = arr.select { |x| x > 0 }
        do_something
        negatives = arr.reject { |x| x > 0 }
      RUBY
    end
  end

  context 'when inside conditional branches' do
    it 'does not register an offense when in separate branches' do
      expect_no_offenses(<<~RUBY)
        if condition
          arr.select { |x| x > 0 }
        else
          arr.reject { |x| x > 0 }
        end
      RUBY
    end
  end
end
