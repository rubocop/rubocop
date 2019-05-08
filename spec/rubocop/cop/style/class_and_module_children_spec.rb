# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ClassAndModuleChildren, :config do
  subject(:cop) { described_class.new(config) }

  context 'nested style' do
    let(:cop_config) { { 'EnforcedStyle' => 'nested' } }

    it 'registers an offense for not nested classes' do
      expect_offense(<<~RUBY)
        class FooClass::BarClass
              ^^^^^^^^^^^^^^^^^^ Use nested module/class definitions instead of compact style.
        end
      RUBY
    end

    it 'registers an offense for not nested classes with explicit superclass' do
      expect_offense(<<~RUBY)
        class FooClass::BarClass < Super
              ^^^^^^^^^^^^^^^^^^ Use nested module/class definitions instead of compact style.
        end
      RUBY
    end

    it 'registers an offense for not nested modules' do
      expect_offense(<<~RUBY)
        module FooModule::BarModule
               ^^^^^^^^^^^^^^^^^^^^ Use nested module/class definitions instead of compact style.
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
    end

    it 'registers a offense for modules with nested children' do
      expect_offense(<<~RUBY)
        module FooModule
               ^^^^^^^^^ Use compact module/class definition instead of nested style.
          module BarModule
          end
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

  context 'autocorrect' do
    let(:cop_config) do
      { 'AutoCorrect' => 'true', 'EnforcedStyle' => enforced_style }
    end

    context 'nested style' do
      let(:enforced_style) { 'nested' }

      it 'corrects a not nested class' do
        source = <<~RUBY
          class FooClass::BarClass
          end
        RUBY
        new_source = autocorrect_source(source)
        expect(new_source).to eq(<<~RUBY)
          module FooClass
            class BarClass
            end
          end
        RUBY
      end

      it 'corrects a not nested class with explicit superclass' do
        source = <<~RUBY
          class FooClass::BarClass < Super
          end
        RUBY
        new_source = autocorrect_source(source)
        expect(new_source).to eq(<<~RUBY)
          module FooClass
            class BarClass < Super
            end
          end
        RUBY
      end

      it 'corrects a not nested module' do
        source = <<~RUBY
          module FooClass::BarClass
          end
        RUBY
        new_source = autocorrect_source(source)
        expect(new_source).to eq(<<~RUBY)
          module FooClass
            module BarClass
            end
          end
        RUBY
      end

      it 'does not correct nested children' do
        source = <<~RUBY
          class FooClass
            class BarClass
            end
          end

          module FooModule
            module BarModule
            end
          end
        RUBY
        new_source = autocorrect_source(source)
        expect(new_source).to eq(source)
      end

      it 'does not correct :: in parent class on inheritance' do
        source = <<~RUBY
          class FooClass
            class BarClass
            end
          end

          class BazClass < FooClass::BarClass
          end
        RUBY
        new_source = autocorrect_source(source)
        expect(new_source).to eq(source)
      end
    end

    context 'compact style' do
      let(:enforced_style) { 'compact' }

      it 'corrects nested children' do
        source = <<~RUBY
          class FooClass
            class BarClass
            end
          end
        RUBY
        new_source = autocorrect_source(source)
        expect(new_source).to eq(<<~RUBY)
          class FooClass::BarClass
          end
        RUBY
      end

      it 'corrects modules with nested children' do
        source = <<~RUBY
          module FooModule
            module BarModule
            end
          end
        RUBY
        new_source = autocorrect_source(source)
        expect(new_source).to eq(<<~RUBY)
          module FooModule::BarModule
          end
        RUBY
      end

      it 'does not correct compact style for classes/modules' do
        source = <<~RUBY
          class FooClass::BarClass
          end

          module FooClass::BarModule
          end
        RUBY
        new_source = autocorrect_source(source)
        expect(new_source).to eq(source)
      end

      it 'does not correct nested classes/modules with more than one child' do
        source = <<~RUBY
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
        new_source = autocorrect_source(source)
        expect(new_source).to eq(source)
      end

      it 'does not correct class/module with single method' do
        source = <<~RUBY
          class FooClass
            def bar_method
            end
          end
        RUBY
        new_source = autocorrect_source(source)
        expect(new_source).to eq(source)
      end

      it 'does not correct nesting for classes with an explicit superclass' do
        source = <<~RUBY
          class FooClass < Super
            class BarClass
            end
          end
        RUBY
        new_source = autocorrect_source(source)
        expect(new_source).to eq(source)
      end
    end
  end
end
