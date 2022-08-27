# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MapCompactWithConditionalBlock, :config do
  context 'With multiline block' do
    it 'registers an offense and corrects to `select` with `if` condition' do
      expect_offense(<<~RUBY)
        foo.map do |item|
            ^^^^^^^^^^^^^ Replace `map { ... }.compact` with `select`.
          if item.bar?
            item
          else
            next
          end
        end.compact
      RUBY

      expect_correction <<~RUBY
        foo.select { |item| item.bar? }
      RUBY
    end

    it 'registers an offense and corrects to `select` with multi-line `if` condition' do
      expect_offense(<<~RUBY)
        foo.map do |item|
            ^^^^^^^^^^^^^ Replace `map { ... }.compact` with `select`.
          if item.bar? &&
            bar.baz
            item
          else
            next
          end
        end.compact
      RUBY

      expect_correction <<~RUBY
        foo.select { |item| item.bar? &&
            bar.baz }
      RUBY
    end

    it 'registers an offense and corrects to `select` if `next value` in if_branch and `nil` in else_branch' do
      expect_offense(<<~RUBY)
        foo.map do |item|
            ^^^^^^^^^^^^^ Replace `map { ... }.compact` with `select`.
          if item.bar?
            next item
          else
            nil
          end
        end.compact
      RUBY

      expect_correction <<~RUBY
        foo.select { |item| item.bar? }
      RUBY
    end

    it 'registers an offense and corrects to `reject` with `if` condition' do
      expect_offense(<<~RUBY)
        foo.map do |item|
            ^^^^^^^^^^^^^ Replace `map { ... }.compact` with `reject`.
          if item.bar?
            next
          else
            item
          end
        end.compact
      RUBY

      expect_correction <<~RUBY
        foo.reject { |item| item.bar? }
      RUBY
    end

    it 'registers an offense and corrects to `reject` if `next value` in else_branch and `nil` in if_branch' do
      expect_offense(<<~RUBY)
        foo.map do |item|
            ^^^^^^^^^^^^^ Replace `map { ... }.compact` with `reject`.
          if item.bar?
            nil
          else
            next item
          end
        end.compact
      RUBY

      expect_correction <<~RUBY
        foo.reject { |item| item.bar? }
      RUBY
    end

    it 'registers an offense and corrects to `select` with ternary expression' do
      expect_offense(<<~RUBY)
        foo.map do |item|
            ^^^^^^^^^^^^^ Replace `map { ... }.compact` with `select`.
          item.bar? ? item : next
        end.compact
      RUBY

      expect_correction <<~RUBY
        foo.select { |item| item.bar? }
      RUBY
    end

    it 'registers an offense and corrects to `reject` with ternary expression' do
      expect_offense(<<~RUBY)
        foo.map do |item|
            ^^^^^^^^^^^^^ Replace `map { ... }.compact` with `reject`.
          item.bar? ? next : item
        end.compact
      RUBY

      expect_correction <<~RUBY
        foo.reject { |item| item.bar? }
      RUBY
    end

    it 'registers an offense and corrects to `select` with modifier form of `if` condition' do
      expect_offense(<<~RUBY)
        foo.map do |item|
            ^^^^^^^^^^^^^ Replace `map { ... }.compact` with `select`.
          item if item.bar?
        end.compact
      RUBY

      expect_correction <<~RUBY
        foo.select { |item| item.bar? }
      RUBY
    end

    it 'registers an offense and corrects to `reject` with modifier form of `unless` condition' do
      expect_offense(<<~RUBY)
        foo.map do |item|
            ^^^^^^^^^^^^^ Replace `map { ... }.compact` with `reject`.
          item unless item.bar?
        end.compact
      RUBY

      expect_correction <<~RUBY
        foo.reject { |item| item.bar? }
      RUBY
    end

    it 'registers an offense and corrects to `select` with guard clause of `if`' do
      expect_offense(<<~RUBY)
        foo.map do |item|
            ^^^^^^^^^^^^^ Replace `map { ... }.compact` with `select`.
          next if item.bar?

          item
        end.compact
      RUBY

      expect_correction <<~RUBY
        foo.select { |item| item.bar? }
      RUBY
    end

    it 'registers an offense and corrects to `reject` with guard clause of `unless`' do
      expect_offense(<<~RUBY)
        foo.map do |item|
            ^^^^^^^^^^^^^ Replace `map { ... }.compact` with `reject`.
          next unless item.bar?

          item
        end.compact
      RUBY

      expect_correction <<~RUBY
        foo.reject { |item| item.bar? }
      RUBY
    end

    it 'registers an offense and corrects to `select` with guard clause of `if` and `next` has a value' do
      expect_offense(<<~RUBY)
        foo.map do |item|
            ^^^^^^^^^^^^^ Replace `map { ... }.compact` with `select`.
          next item if item.bar?
        end.compact
      RUBY

      expect_correction <<~RUBY
        foo.select { |item| item.bar? }
      RUBY
    end

    it 'registers an offense and corrects to `reject` with guard clause of `unless` and `next` has a value' do
      expect_offense(<<~RUBY)
        foo.map do |item|
            ^^^^^^^^^^^^^ Replace `map { ... }.compact` with `reject`.
          next item unless item.bar?
        end.compact
      RUBY

      expect_correction <<~RUBY
        foo.reject { |item| item.bar? }
      RUBY
    end

    it 'registers an offense and corrects to `select` with guard clause of `if` and `next` has a value and return nil' do
      expect_offense(<<~RUBY)
        foo.map do |item|
            ^^^^^^^^^^^^^ Replace `map { ... }.compact` with `select`.
          next item if item.bar?

          nil
        end.compact
      RUBY

      expect_correction <<~RUBY
        foo.select { |item| item.bar? }
      RUBY
    end

    it 'registers an offense and corrects to `reject` with guard clause of `unless` and `next` has a value and return nil' do
      expect_offense(<<~RUBY)
        foo.map do |item|
            ^^^^^^^^^^^^^ Replace `map { ... }.compact` with `reject`.
          next item unless item.bar?

          nil
        end.compact
      RUBY

      expect_correction <<~RUBY
        foo.reject { |item| item.bar? }
      RUBY
    end

    it 'registers an offense and corrects to `select` with guard clause of `if` and next explicitly nil' do
      expect_offense(<<~RUBY)
        foo.map do |item|
            ^^^^^^^^^^^^^ Replace `map { ... }.compact` with `select`.
          next nil if item.bar?

          item
        end.compact
      RUBY

      expect_correction <<~RUBY
        foo.select { |item| item.bar? }
      RUBY
    end

    it 'registers an offense and corrects to `reject` with guard clause of `unless` and `next` explicitly nil' do
      expect_offense(<<~RUBY)
        foo.map do |item|
            ^^^^^^^^^^^^^ Replace `map { ... }.compact` with `reject`.
          next nil unless item.bar?

          item
        end.compact
      RUBY

      expect_correction <<~RUBY
        foo.reject { |item| item.bar? }
      RUBY
    end

    it 'registers an offense and corrects to `select` if condition has not else branch' do
      expect_offense(<<~RUBY)
        foo.map do |item|
            ^^^^^^^^^^^^^ Replace `map { ... }.compact` with `select`.
          if item.bar?
            item
          end
        end.compact
      RUBY

      expect_correction <<~RUBY
        foo.select { |item| item.bar? }
      RUBY
    end

    it 'registers an offense and corrects to `reject` with `unless` condition' do
      expect_offense(<<~RUBY)
        foo.map do |item|
            ^^^^^^^^^^^^^ Replace `map { ... }.compact` with `reject`.
          unless item.bar?
            item
          end
        end.compact
      RUBY

      expect_correction <<~RUBY
        foo.reject { |item| item.bar? }
      RUBY
    end

    it 'does not register offenses if `compact` is not chained to `map`' do
      expect_no_offenses(<<~RUBY)
        foo.map do |item|
          if item.bar?
            item
          else
            next
          end
        end
      RUBY
    end

    it 'does not register offenses if return value is not same as block argument' do
      expect_no_offenses(<<~RUBY)
        foo.map do |item|
          if item.bar?
            1
          else
            2
          end
        end.compact
      RUBY
    end

    it 'does not register offenses if condition has elsif branch' do
      expect_no_offenses(<<~RUBY)
        foo.map do |item|
          if item.bar?
            item
          elsif
            baz
          else
            next
          end
        end.compact
      RUBY
    end

    it 'does not register offenses if there are multiple guard clauses' do
      expect_no_offenses(<<~RUBY)
        next unless item.bar?
        next unless item.baz?

        item
      RUBY
    end
  end

  context 'With single line block' do
    it 'registers an offense and corrects to `select` with ternary expression' do
      expect_offense(<<~RUBY)
        foo.map { |item| item.bar? ? item : next }.compact
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Replace `map { ... }.compact` with `select`.
      RUBY

      expect_correction <<~RUBY
        foo.select { |item| item.bar? }
      RUBY
    end

    it 'registers an offense and corrects to `reject` with ternary expression' do
      expect_offense(<<~RUBY)
        foo.map { |item| item.bar? ? next : item }.compact
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Replace `map { ... }.compact` with `reject`.
      RUBY

      expect_correction <<~RUBY
        foo.reject { |item| item.bar? }
      RUBY
    end

    it 'registers an offense and corrects to `select` with modifier form of `if` condition' do
      expect_offense(<<~RUBY)
        foo.map { |item| item if item.bar? }.compact
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Replace `map { ... }.compact` with `select`.
      RUBY

      expect_correction <<~RUBY
        foo.select { |item| item.bar? }
      RUBY
    end

    it 'registers an offense and corrects to `reject` with modifier form of `unless` condition' do
      expect_offense(<<~RUBY)
        foo.map { |item| item unless item.bar? }.compact
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Replace `map { ... }.compact` with `reject`.
      RUBY

      expect_correction <<~RUBY
        foo.reject { |item| item.bar? }
      RUBY
    end

    it 'does not register offenses if `compact` is not chained to `map`' do
      expect_no_offenses(<<~RUBY)
        foo.map { |item| item if item.bar }
      RUBY
    end
  end
end
