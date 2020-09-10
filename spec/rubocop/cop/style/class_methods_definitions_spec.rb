# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ClassMethodsDefinitions, :config do
  context 'when EnforcedStyle is def_self' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'def_self' }
    end

    it 'registers an offense and corrects when defining class methods with `class << self`' do
      expect_offense(<<~RUBY)
        class A
          class << self
            attr_reader :two

            def three
            ^^^^^^^^^ Use `def self.three` to define class method.
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class A
         #{trailing_whitespace}
            def self.three
            end

          class << self
            attr_reader :two
          end
        end
      RUBY
    end

    it 'correctly handles methods with annotation comments' do
      expect_offense(<<~RUBY)
        class A
          class << self
            attr_reader :one

            # Multiline
            # comment.
            def two
            ^^^^^^^ Use `def self.two` to define class method.
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class A
         #{trailing_whitespace}
            # Multiline
            # comment.
            def self.two
            end

          class << self
            attr_reader :one
          end
        end
      RUBY
    end

    it 'does not register an offense when `class << self` contains non public methods' do
      expect_no_offenses(<<~RUBY)
        class A
          class << self
            def one
            end

            private

            def one
            end
          end
        end
      RUBY
    end

    it 'does not register an offense when defining class methods with `def self.method`' do
      expect_no_offenses(<<~RUBY)
        class A
          def self.one
          end
        end
      RUBY
    end

    it 'does not register an offense when defining singleton methods using `self << object`' do
      expect_no_offenses(<<~RUBY)
        class A
          class << not_self
            def one
            end
          end
        end
      RUBY
    end
  end

  context 'when EnforcedStyle is self_class' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'self_class' }
    end

    it 'registers an offense when defining class methods with `def self.method`' do
      expect_offense(<<~RUBY)
        class A
          def self.one
          ^^^^^^^^^^^^ Use `class << self` to define class method.
          end
        end
      RUBY
    end

    it 'does not register an offense when defining class methods with `class << self`' do
      expect_no_offenses(<<~RUBY)
        class A
          class << self
            def one
            end
          end
        end
      RUBY
    end
  end
end
