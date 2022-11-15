# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantConstantBase, :config do
  context 'with prefixed constant in class' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        class Foo
          ::Bar
        end
      RUBY
    end
  end

  context 'with prefixed constant in module' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        module Foo
          ::Bar
        end
      RUBY
    end
  end

  context 'with prefixed constant in neither class nor module' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        ::Bar
        ^^ Avoid redundant `::` prefix on constant.
      RUBY

      expect_correction(<<~RUBY)
        Bar
      RUBY
    end
  end

  context 'with prefixed nested constant in neither class nor module' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        ::Bar::Baz
        ^^ Avoid redundant `::` prefix on constant.
      RUBY

      expect_correction(<<~RUBY)
        Bar::Baz
      RUBY
    end
  end

  context 'with prefixed constant in sclass' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        class << self
          ::Bar
          ^^ Avoid redundant `::` prefix on constant.
        end
      RUBY

      expect_correction(<<~RUBY)
        class << self
          Bar
        end
      RUBY
    end
  end

  context 'with prefixed constant as super class' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        class Foo < ::Bar
                    ^^ Avoid redundant `::` prefix on constant.
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo < Bar
        end
      RUBY
    end
  end
end
