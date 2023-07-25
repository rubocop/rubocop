# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ReturnNilInPredicateMethodDefinition, :config do
  context 'when defining predicate method' do
    it 'registers an offense when using `return`' do
      expect_offense(<<~RUBY)
        def foo?
          return if condition
          ^^^^^^ Return `false` instead of `nil` in predicate methods.

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
          ^^^^^^^^^^ Return `false` instead of `nil` in predicate methods.

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

    it 'registers an offense when using `nil` at the end of the predicate method definition and using guard condition' do
      expect_offense(<<~RUBY)
        def foo?
          return true if condition

          nil
          ^^^ Return `false` instead of `nil` in predicate methods.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo?
          return true if condition

          false
        end
      RUBY
    end

    it 'registers an offense when using `nil` at the end of the predicate method definition' do
      expect_offense(<<~RUBY)
        def foo?
          nil
          ^^^ Return `false` instead of `nil` in predicate methods.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo?
          false
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

    it 'does not register an offense when using `nil` at the middle of method definition' do
      expect_no_offenses(<<~RUBY)
        def foo?
          do_something

          nil

          do_something
        end
      RUBY
    end

    it 'does not register an offense when the last safe navigation method argument in method definition is `nil`' do
      expect_no_offenses(<<~RUBY)
        def foo?
          bar&.baz(nil)
        end
      RUBY
    end

    it 'does not register an offense when the last method argument in method definition is `nil`' do
      expect_no_offenses(<<~RUBY)
        def foo?
          bar.baz(nil)
        end
      RUBY
    end

    it 'does not register an offense when assigning `nil` to a variable in predicate method definition' do
      expect_no_offenses(<<~RUBY)
        def foo?
          bar = nil
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

    it 'does not register an offense when not using `return`' do
      expect_no_offenses(<<~RUBY)
        def foo?
          do_something
        end
      RUBY
    end

    it 'does not register an offense when empty body' do
      expect_no_offenses(<<~RUBY)
        def foo?
        end
      RUBY
    end

    it 'does not register an offense when empty body with `rescue`' do
      expect_no_offenses(<<~RUBY)
        def foo?
          return false unless condition
        rescue
        end
      RUBY
    end
  end

  context 'when defining predicate class method' do
    it 'registers an offense when using `return`' do
      expect_offense(<<~RUBY)
        def self.foo?
          return if condition
          ^^^^^^ Return `false` instead of `nil` in predicate methods.

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
          ^^^^^^^^^^ Return `false` instead of `nil` in predicate methods.

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
