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
end
