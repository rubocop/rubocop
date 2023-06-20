# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ReturnNilInPredicateMethodDefinition, :config do
  context 'when defining predicate method' do
    it 'registers an offense when using `return`' do
      expect_offense(<<~RUBY)
        def foo?
          return if condition
          ^^^^^^ Use `return false` instead of `return` in the predicate method.

          bar?
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo?
          return false if condition

          bar?
        end
      RUBY
    end

    it 'registers an offense when using `return nil`' do
      expect_offense(<<~RUBY)
        def foo?
          return nil if condition
          ^^^^^^^^^^ Use `return false` instead of `return nil` in the predicate method.

          bar?
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo?
          return false if condition

          bar?
        end
      RUBY
    end

    it 'does not register an offense when using `return false`' do
      expect_no_offenses(<<~RUBY)
        def foo?
          return false if condition

          bar?
        end
      RUBY
    end

    it 'does not register an offense when using `return true`' do
      expect_no_offenses(<<~RUBY)
        def foo?
          return true if condition

          bar?
        end
      RUBY
    end

    it 'does not register an offense when using `return value`' do
      expect_no_offenses(<<~RUBY)
        def foo?
          return value if condition

          bar?
        end
      RUBY
    end

    it 'does not register an offense when not using `return`' do
      expect_no_offenses(<<~RUBY)
        def foo?
          do_something
        end
      RUBY
    end

    it 'does not register an offense when empty body`' do
      expect_no_offenses(<<~RUBY)
        def foo?
        end
      RUBY
    end
  end

  context 'when defining predicate class method' do
    it 'registers an offense when using `return`' do
      expect_offense(<<~RUBY)
        def self.foo?
          return if condition
          ^^^^^^ Use `return false` instead of `return` in the predicate method.

          bar?
        end
      RUBY

      expect_correction(<<~RUBY)
        def self.foo?
          return false if condition

          bar?
        end
      RUBY
    end

    it 'registers an offense when using `return nil`' do
      expect_offense(<<~RUBY)
        def self.foo?
          return nil if condition
          ^^^^^^^^^^ Use `return false` instead of `return nil` in the predicate method.

          bar?
        end
      RUBY

      expect_correction(<<~RUBY)
        def self.foo?
          return false if condition

          bar?
        end
      RUBY
    end

    it 'does not register an offense when using `return false`' do
      expect_no_offenses(<<~RUBY)
        def self.foo?
          return false if condition

          bar?
        end
      RUBY
    end
  end

  context 'when not defining predicate method' do
    it 'does not register an offense when using `return`' do
      expect_no_offenses(<<~RUBY)
        def foo
          return if condition

          bar?
        end
      RUBY
    end
  end

  context "when `AllowedMethod: ['foo?']`" do
    let(:cop_config) { { 'AllowedMethods' => ['foo?'] } }

    context 'when defining predicate method' do
      it 'does not register an offense when using `return`' do
        expect_no_offenses(<<~RUBY)
          def foo?
            return if condition

            bar?
          end
        RUBY
      end

      it 'does not register an offense when using `return nil`' do
        expect_no_offenses(<<~RUBY)
          def foo?
            return nil if condition

            bar?
          end
        RUBY
      end
    end

    context 'when defining predicate class method' do
      it 'does not register an offense when using `return`' do
        expect_no_offenses(<<~RUBY)
          def self.foo?
            return if condition

            bar?
          end
        RUBY
      end

      it 'does not register an offense when using `return nil`' do
        expect_no_offenses(<<~RUBY)
          def self.foo?
            return nil if condition

            bar?
          end
        RUBY
      end
    end
  end

  context 'when `AllowedPattern: [/foo/]`' do
    let(:cop_config) { { 'AllowedPatterns' => [/foo/] } }

    context 'when defining predicate method' do
      it 'does not register an offense when using `return`' do
        expect_no_offenses(<<~RUBY)
          def foo?
            return if condition

            bar?
          end
        RUBY
      end

      it 'does not register an offense when using `return nil`' do
        expect_no_offenses(<<~RUBY)
          def foo?
            return nil if condition

            bar?
          end
        RUBY
      end
    end

    context 'when defining predicate class method' do
      it 'does not register an offense when using `return`' do
        expect_no_offenses(<<~RUBY)
          def self.foo?
            return if condition

            bar?
          end
        RUBY
      end

      it 'does not register an offense when using `return nil`' do
        expect_no_offenses(<<~RUBY)
          def self.foo?
            return nil if condition

            bar?
          end
        RUBY
      end
    end
  end
end
