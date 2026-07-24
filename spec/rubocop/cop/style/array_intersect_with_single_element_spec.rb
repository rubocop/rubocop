# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ArrayIntersectWithSingleElement, :config do
  context 'with `include?(element)`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        array.include?(element)
      RUBY
    end
  end

  context 'with `intersect?([element])`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        array.intersect?([element])
              ^^^^^^^^^^^^^^^^^^^^^ Use `include?(element)` instead of `intersect?([element])`.
      RUBY

      expect_correction(<<~RUBY)
        array.include?(element)
      RUBY
    end
  end

  context 'with `intersect?(%i[element])`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        array.intersect?(%i[element])
              ^^^^^^^^^^^^^^^^^^^^^^^ Use `include?(element)` instead of `intersect?([element])`.
      RUBY

      expect_correction(<<~RUBY)
        array.include?(:element)
      RUBY
    end
  end

  context 'with `intersection([element]).any?`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        array.intersection([element]).any?
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `include?(element)` instead of `intersection([element]).any?`.
      RUBY

      expect_correction(<<~RUBY)
        array.include?(element)
      RUBY
    end
  end

  context 'when intersection without any' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        array.intersection([element])
      RUBY
    end
  end

  context 'with safe navigation' do
    it 'does not register an offense for `&.intersect?([element])`' do
      expect_no_offenses(<<~RUBY)
        array&.intersect?([element])
      RUBY
    end

    it 'does not register an offense for `&.intersection([element])&.any?`' do
      expect_no_offenses(<<~RUBY)
        array&.intersection([element])&.any?
      RUBY
    end
  end

  context 'with a splat element' do
    it 'does not register an offense (a splat is not a single element)' do
      expect_no_offenses(<<~RUBY)
        array.intersect?([*foo])
        array.intersection([*foo]).any?
      RUBY
    end
  end
end
