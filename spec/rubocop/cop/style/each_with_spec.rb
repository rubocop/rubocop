# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EachWith, :config do
  context 'with each_with_index' do
    it 'registers an offense and corrects `each_with_index` to `each.with_index`' do
      expect_offense(<<~RUBY)
        array.each_with_index { |v, i| do_something(v, i) }
              ^^^^^^^^^^^^^^^ Use `each.with_index` instead of `each_with_index`.
      RUBY

      expect_correction(<<~RUBY)
        array.each.with_index { |v, i| do_something(v, i) }
      RUBY
    end

    it 'registers an offense and corrects `each_with_index(1)` to `each.with_index(1)`' do
      expect_offense(<<~RUBY)
        array.each_with_index(1) { |v, i| do_something(v, i) }
              ^^^^^^^^^^^^^^^^^^ Use `each.with_index` instead of `each_with_index`.
      RUBY

      expect_correction(<<~RUBY)
        array.each.with_index(1) { |v, i| do_something(v, i) }
      RUBY
    end

    it 'registers an offense and corrects `each_with_index` with safe navigation' do
      expect_offense(<<~RUBY)
        array&.each_with_index { |v, i| do_something(v, i) }
               ^^^^^^^^^^^^^^^ Use `each.with_index` instead of `each_with_index`.
      RUBY

      expect_correction(<<~RUBY)
        array&.each.with_index { |v, i| do_something(v, i) }
      RUBY
    end

    it 'registers an offense when using `each_with_index` without a block' do
      expect_offense(<<~RUBY)
        array.each_with_index
              ^^^^^^^^^^^^^^^ Use `each.with_index` instead of `each_with_index`.
      RUBY

      expect_correction(<<~RUBY)
        array.each.with_index
      RUBY
    end

    it 'does not register an offense when using `each.with_index`' do
      expect_no_offenses(<<~RUBY)
        array.each.with_index { |v, i| do_something(v, i) }
      RUBY
    end

    it 'does not register an offense when using `each` without `with_index`' do
      expect_no_offenses(<<~RUBY)
        array.each { |v| do_something(v) }
      RUBY
    end

    it 'does not register an offense when receiver is not an array' do
      expect_no_offenses(<<~RUBY)
        hash.each_key { |k| do_something(k) }
      RUBY
    end
  end

  context 'with each_with_object' do
    it 'registers an offense and corrects `each_with_object([])` to `each.with_object([])`' do
      expect_offense(<<~RUBY)
        array.each_with_object([]) { |v, o| do_something(v, o) }
              ^^^^^^^^^^^^^^^^^^^^ Use `each.with_object` instead of `each_with_object`.
      RUBY

      expect_correction(<<~RUBY)
        array.each.with_object([]) { |v, o| do_something(v, o) }
      RUBY
    end

    it 'registers an offense and corrects `each_with_object({})` to `each.with_object({})`' do
      expect_offense(<<~RUBY)
        array.each_with_object({}) { |v, o| do_something(v, o) }
              ^^^^^^^^^^^^^^^^^^^^ Use `each.with_object` instead of `each_with_object`.
      RUBY

      expect_correction(<<~RUBY)
        array.each.with_object({}) { |v, o| do_something(v, o) }
      RUBY
    end

    it 'registers an offense and corrects `each_with_object([])` with safe navigation' do
      expect_offense(<<~RUBY)
        array&.each_with_object([]) { |v, o| do_something(v, o) }
               ^^^^^^^^^^^^^^^^^^^^ Use `each.with_object` instead of `each_with_object`.
      RUBY

      expect_correction(<<~RUBY)
        array&.each.with_object([]) { |v, o| do_something(v, o) }
      RUBY
    end

    it 'registers an offense when using `each_with_object([])` without a block' do
      expect_offense(<<~RUBY)
        array.each_with_object([])
              ^^^^^^^^^^^^^^^^^^^^ Use `each.with_object` instead of `each_with_object`.
      RUBY

      expect_correction(<<~RUBY)
        array.each.with_object([])
      RUBY
    end

    it 'does not register an offense when using `each.with_object`' do
      expect_no_offenses(<<~RUBY)
        array.each.with_object([]) { |v, o| do_something(v, o) }
      RUBY
    end

    it 'does not register an offense when using `each` without `with_object`' do
      expect_no_offenses(<<~RUBY)
        array.each { |v| do_something(v) }
      RUBY
    end

    it 'does not register an offense when receiver is not an array' do
      expect_no_offenses(<<~RUBY)
        hash.each_key { |k| do_something(k) }
      RUBY
    end
  end
end
