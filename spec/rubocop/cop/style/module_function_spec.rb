# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ModuleFunction, :config do
  context 'when enforced style is `module_function`' do
    let(:cop_config) { { 'EnforcedStyle' => 'module_function' } }

    it 'registers an offense for `extend self` in a module' do
      expect_offense(<<~RUBY)
        module Test
          extend self
          ^^^^^^^^^^^ Use `module_function` instead of `extend self`.
          def test; end
        end
      RUBY

      expect_correction(<<~RUBY)
        module Test
          module_function
          def test; end
        end
      RUBY
    end

    it 'accepts for `extend self` in a module with private methods' do
      expect_no_offenses(<<~RUBY)
        module Test
          extend self
          def test; end
          private
          def test_private;end
        end
      RUBY
    end

    it 'accepts for `extend self` in a module with declarative private' do
      expect_no_offenses(<<~RUBY)
        module Test
          extend self
          def test; end
          private :test
        end
      RUBY
    end

    it 'accepts `extend self` in a class' do
      expect_no_offenses(<<~RUBY)
        class Test
          extend self
        end
      RUBY
    end
  end

  context 'when enforced style is `extend_self`' do
    let(:cop_config) { { 'EnforcedStyle' => 'extend_self' } }

    it 'registers an offense for `module_function` without an argument' do
      expect_offense(<<~RUBY)
        module Test
          module_function
          ^^^^^^^^^^^^^^^ Use `extend self` instead of `module_function`.
          def test; end
        end
      RUBY

      expect_correction(<<~RUBY)
        module Test
          extend self
          def test; end
        end
      RUBY
    end

    it 'accepts module_function with an argument' do
      expect_no_offenses(<<~RUBY)
        module Test
          def test; end
          module_function :test
        end
      RUBY
    end
  end

  context 'when enforced style is `forbidden`' do
    let(:cop_config) { { 'EnforcedStyle' => 'forbidden' } }

    context 'registers an offense for `extend self`' do
      it 'in a module' do
        expect_offense(<<~RUBY)
          module Test
            extend self
            ^^^^^^^^^^^ Do not use `module_function` or `extend self`.
            def test; end
          end
        RUBY

        expect_no_corrections
      end

      it 'in a module with private methods' do
        expect_offense(<<~RUBY)
          module Test
            extend self
            ^^^^^^^^^^^ Do not use `module_function` or `extend self`.
            def test; end
            private
            def test_private;end
          end
        RUBY

        expect_no_corrections
      end

      it 'in a module with declarative private' do
        expect_offense(<<~RUBY)
          module Test
            extend self
            ^^^^^^^^^^^ Do not use `module_function` or `extend self`.
            def test; end
            private :test
          end
        RUBY

        expect_no_corrections
      end
    end

    it 'accepts `extend self` in a class' do
      expect_no_offenses(<<~RUBY)
        class Test
          extend self
        end
      RUBY
    end

    it 'registers an offense for `module_function` without an argument' do
      expect_offense(<<~RUBY)
        module Test
          module_function
          ^^^^^^^^^^^^^^^ Do not use `module_function` or `extend self`.
          def test; end
        end
      RUBY

      expect_no_corrections
    end
  end
end
