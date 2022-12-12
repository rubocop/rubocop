# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantConstantBase, :config do
  let(:other_cops) { { 'Lint/ConstantResolution' => { 'Enabled' => false } } }

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
        ^^ Remove redundant `::`.
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
        ^^ Remove redundant `::`.
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
          ^^ Remove redundant `::`.
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
                    ^^ Remove redundant `::`.
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo < Bar
        end
      RUBY
    end
  end

  context 'with prefixed constant and prefixed super class' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        class Foo < ::Bar
                    ^^ Remove redundant `::`.
          ::A
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo < Bar
          ::A
        end
      RUBY
    end
  end

  context 'when `Lint/ConstantResolution` is disabling' do
    let(:other_cops) { { 'Lint/ConstantResolution' => { 'Enabled' => true } } }

    context 'with prefixed constant in neither class nor module' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          ::Bar
        RUBY
      end
    end
  end
end
