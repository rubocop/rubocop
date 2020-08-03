# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ClassAndModuleChildren, :config do
  context 'nested style' do
    let(:cop_config) { { 'EnforcedStyle' => 'nested' } }

    it 'registers an offense for not nested classes' do
      expect_offense(<<~RUBY)
        class FooClass::BarClass
              ^^^^^^^^^^^^^^^^^^ Use nested module/class definitions instead of compact style.
        end
      RUBY
      expect_correction(<<~RUBY)
        module FooClass
          class BarClass
          end
        end
      RUBY
    end

    it 'registers an offense for not nested classes with explicit superclass' do
      expect_offense(<<~RUBY)
        class FooClass::BarClass < Super
              ^^^^^^^^^^^^^^^^^^ Use nested module/class definitions instead of compact style.
        end
      RUBY
      expect_correction(<<~RUBY)
        module FooClass
          class BarClass < Super
          end
        end
      RUBY
    end

    it 'registers an offense for not nested modules' do
      expect_offense(<<~RUBY)
        module FooModule::BarModule
               ^^^^^^^^^^^^^^^^^^^^ Use nested module/class definitions instead of compact style.
        end
      RUBY
      expect_correction(<<~RUBY)
        module FooModule
          module BarModule
          end
        end
      RUBY
    end

    it 'accepts nested children' do
      expect_no_offenses(<<~RUBY)
        class FooClass
          class BarClass
          end
        end

        module FooModule
          module BarModule
          end
        end
      RUBY
    end

    it 'accepts :: in parent class on inheritance' do
      expect_no_offenses(<<~RUBY)
        class FooClass
          class BarClass
          end
        end

        class BazClass < FooClass::BarClass
        end
      RUBY
    end
  end

  context 'compact style' do
    let(:cop_config) { { 'EnforcedStyle' => 'compact' } }

    it 'registers a offense for classes with nested children' do
      expect_offense(<<~RUBY)
        class FooClass
              ^^^^^^^^ Use compact module/class definition instead of nested style.
          class BarClass
          end
        end
      RUBY
      expect_correction(<<~RUBY)
        class FooClass::BarClass
        end
      RUBY
    end

    it 'registers a offense for modules with nested children' do
      expect_offense(<<~RUBY)
        module FooModule
               ^^^^^^^^^ Use compact module/class definition instead of nested style.
          module BarModule
          end
        end
      RUBY
      expect_correction(<<~RUBY)
        module FooModule::BarModule
        end
      RUBY
    end

    it 'accepts compact style for classes/modules' do
      expect_no_offenses(<<~RUBY)
        class FooClass::BarClass
        end

        module FooClass::BarModule
        end
      RUBY
    end

    it 'accepts nesting for classes/modules with more than one child' do
      expect_no_offenses(<<~RUBY)
        class FooClass
          class BarClass
          end
          class BazClass
          end
        end

        module FooModule
          module BarModule
          end
          class BazModule
          end
        end
      RUBY
    end

    it 'accepts class/module with single method' do
      expect_no_offenses(<<~RUBY)
        class FooClass
          def bar_method
          end
        end
      RUBY
    end

    it 'accepts nesting for classes with an explicit superclass' do
      expect_no_offenses(<<~RUBY)
        class FooClass < Super
          class BarClass
          end
        end
      RUBY
    end
  end
end
