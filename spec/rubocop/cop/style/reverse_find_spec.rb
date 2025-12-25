# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ReverseFind, :config do
  context 'when Ruby >= 4.0', :ruby40 do
    it 'registers an offense when using `reverse.find` with block' do
      expect_offense(<<~RUBY)
        array.reverse.find { |item| item.even? }
              ^^^^^^^^^^^^ Use `rfind` instead.
      RUBY

      expect_correction(<<~RUBY)
        array.rfind { |item| item.even? }
      RUBY
    end

    it 'registers an offense when using `reverse&.find` with block' do
      expect_offense(<<~RUBY)
        array&.reverse&.find { |item| item.even? }
               ^^^^^^^^^^^^^ Use `rfind` instead.
      RUBY

      expect_correction(<<~RUBY)
        array&.rfind { |item| item.even? }
      RUBY
    end

    it 'registers an offense when using `reverse.find` with numbered block' do
      expect_offense(<<~RUBY)
        array.reverse.find { _1.even? }
              ^^^^^^^^^^^^ Use `rfind` instead.
      RUBY

      expect_correction(<<~RUBY)
        array.rfind { _1.even? }
      RUBY
    end

    it 'registers an offense when using `reverse.find` with `it` block' do
      expect_offense(<<~RUBY)
        array.reverse.find { it.even? }
              ^^^^^^^^^^^^ Use `rfind` instead.
      RUBY

      expect_correction(<<~RUBY)
        array.rfind { it.even? }
      RUBY
    end

    it 'registers an offense when using `reverse.detect` with block' do
      expect_offense(<<~RUBY)
        array.reverse.detect { |item| item.even? }
              ^^^^^^^^^^^^^^ Use `rfind` instead.
      RUBY

      expect_correction(<<~RUBY)
        array.rfind { |item| item.even? }
      RUBY
    end

    it 'registers an offense when using `reverse_each.find` with block' do
      expect_offense(<<~RUBY)
        array.reverse_each.find { |item| item.even? }
              ^^^^^^^^^^^^^^^^^ Use `rfind` instead.
      RUBY

      expect_correction(<<~RUBY)
        array.rfind { |item| item.even? }
      RUBY
    end

    it 'registers an offense when using `reverse_each.detect` with block' do
      expect_offense(<<~RUBY)
        array.reverse_each.detect { |item| item.even? }
              ^^^^^^^^^^^^^^^^^^^ Use `rfind` instead.
      RUBY

      expect_correction(<<~RUBY)
        array.rfind { |item| item.even? }
      RUBY
    end

    it 'registers an offense when using `reverse.find` with symbol proc' do
      expect_offense(<<~RUBY)
        array.reverse.find(&:even?)
              ^^^^^^^^^^^^ Use `rfind` instead.
      RUBY

      expect_correction(<<~RUBY)
        array.rfind(&:even?)
      RUBY
    end

    it 'registers an offense when using `reverse.detect` with symbol proc' do
      expect_offense(<<~RUBY)
        array.reverse.detect(&:even?)
              ^^^^^^^^^^^^^^ Use `rfind` instead.
      RUBY

      expect_correction(<<~RUBY)
        array.rfind(&:even?)
      RUBY
    end

    it 'does not register an offense when using `rfind`' do
      expect_no_offenses(<<~RUBY)
        array.rfind { |item| item.even? }
      RUBY
    end
  end

  context 'when Ruby <= 3.4', :ruby34 do
    it 'does not register an offense when using `reverse.find` with block' do
      expect_no_offenses(<<~RUBY)
        array.reverse.find { |item| item.even? }
      RUBY
    end

    it 'does not register an offense when using `reverse.detect` with block' do
      expect_no_offenses(<<~RUBY)
        array.reverse.detect { |item| item.even? }
      RUBY
    end

    it 'does not register an offense when using `reverse.find` with symbol proc' do
      expect_no_offenses(<<~RUBY)
        array.reverse.find(&:even?)
      RUBY
    end

    it 'does not register an offense when using `reverse.detect` with symbol proc' do
      expect_no_offenses(<<~RUBY)
        array.reverse.detect(&:even?)
      RUBY
    end
  end
end
