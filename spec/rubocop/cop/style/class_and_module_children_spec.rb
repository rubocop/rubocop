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

    it 'registers an offense for not nested classes when namespace is defined as a class' do
      expect_offense(<<~RUBY)
        class FooClass
        end

        class FooClass::BarClass
              ^^^^^^^^^^^^^^^^^^ Use nested module/class definitions instead of compact style.
        end
      RUBY

      expect_correction(<<~RUBY)
        class FooClass
        end

        class FooClass
          class BarClass
          end
        end
      RUBY
    end

    it 'registers an offense for not nested classes when namespace is defined as a module' do
      expect_offense(<<~RUBY)
        module FooClass
        end

        class FooClass::BarClass
              ^^^^^^^^^^^^^^^^^^ Use nested module/class definitions instead of compact style.
        end
      RUBY

      expect_correction(<<~RUBY)
        module FooClass
        end

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

    it 'registers an offense for partially nested classes' do
      expect_offense(<<~RUBY)
        class Foo::Bar
              ^^^^^^^^ Use nested module/class definitions instead of compact style.
          class Baz
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        module Foo
          class Bar
          class Baz
          end
          end
        end
      RUBY
    end

    it 'registers an offense for partially nested modules' do
      expect_offense(<<~RUBY)
        module Foo::Bar
               ^^^^^^^^ Use nested module/class definitions instead of compact style.
          module Baz
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        module Foo
          module Bar
          module Baz
          end
          end
        end
      RUBY
    end

    it 'preserves comments' do
      expect_offense(<<~RUBY)
        # top comment
        class Foo::Bar # describe Foo::Bar
              ^^^^^^^^ Use nested module/class definitions instead of compact style.
        end
      RUBY

      expect_correction(<<~RUBY)
        # top comment
        module Foo
          class Bar # describe Foo::Bar
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

    it 'accepts cbase class name' do
      expect_no_offenses(<<~RUBY)
        class ::Foo
        end
      RUBY
    end

    it 'accepts cbase module name' do
      expect_no_offenses(<<~RUBY)
        module ::Foo
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

    it 'accepts compact style when inside another module' do
      expect_no_offenses(<<~RUBY)
        module Z
          module X::Y
          end
        end
      RUBY
    end

    it 'accepts compact style when inside another class' do
      expect_no_offenses(<<~RUBY)
        class Z
          module X::Y
          end
        end
      RUBY
    end
  end

  context 'compact style' do
    let(:cop_config) { { 'EnforcedStyle' => 'compact' } }

    it 'registers an offense for classes with nested children' do
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

    it 'registers an offense for modules with nested children' do
      expect_offense(<<~RUBY)
        module FooModule
               ^^^^^^^^^ Use compact module/class definition instead of nested style.
          module BarModule
            def method_example
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        module FooModule::BarModule
          def method_example
          end
        end
      RUBY
    end

    it 'correctly indents heavily nested children' do
      expect_offense(<<~RUBY)
        module FooModule
               ^^^^^^^^^ Use compact module/class definition instead of nested style.
          module BarModule
            module BazModule
              module QuxModule
                CONST = 1

                def method_example
                end
              end
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        module FooModule::BarModule::BazModule::QuxModule
          CONST = 1

          def method_example
          end
        end
      RUBY
    end

    it 'registers an offense for classes with partially nested children' do
      expect_offense(<<~RUBY)
        class Foo::Bar
              ^^^^^^^^ Use compact module/class definition instead of nested style.
          class Baz
          end
        end

        class Foo
              ^^^ Use compact module/class definition instead of nested style.
          class Bar::Baz
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo::Bar::Baz
        end

        class Foo::Bar::Baz
        end
      RUBY
    end

    it 'registers an offense for deeply nested children' do
      expect_offense(<<~RUBY)
        class Foo
              ^^^ Use compact module/class definition instead of nested style.
          class Bar
            class Baz
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo::Bar::Baz
        end
      RUBY
    end

    it 'registers an offense for modules with partially nested children' do
      expect_offense(<<~RUBY)
        module Foo::Bar
               ^^^^^^^^ Use compact module/class definition instead of nested style.
          module Baz
          end
        end

        module Foo
               ^^^ Use compact module/class definition instead of nested style.
          module Bar::Baz
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        module Foo::Bar::Baz
        end

        module Foo::Bar::Baz
        end
      RUBY
    end

    it 'preserves comments between classes' do
      expect_offense(<<~RUBY)
        # describe Foo
        # more Foo
        class Foo
              ^^^ Use compact module/class definition instead of nested style.
          # describe Bar
          # more Bar
          class Bar
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        # describe Foo
        # more Foo
        # describe Bar
        # more Bar
        class Foo::Bar
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

    it 'registers an offense for tab-intended nested children' do
      expect_offense(<<~RUBY)
        module A
               ^ Use compact module/class definition instead of nested style.
        \tmodule B
        \t\tmodule C
        \t\t\tbody
        \t\tend
        \tend
        end
      RUBY

      expect_correction(<<~RUBY)
        module A::B::C
        \t\t\tbody
        end
      RUBY
    end

    context 'with unindented nested nodes' do
      it 'registers an offense and autocorrects unindented class' do
        expect_offense(<<~RUBY)
          module M
                 ^ Use compact module/class definition instead of nested style.
          class C
          end
          end
        RUBY

        expect_correction(<<~RUBY)
          class M::C
          end
        RUBY
      end

      it 'registers an offense and autocorrects unindented class and method' do
        expect_offense(<<~RUBY)
          module M
                 ^ Use compact module/class definition instead of nested style.
          class C
          def foo; 1; end
          end
          end
        RUBY

        expect_correction(<<~RUBY)
          class M::C
          def foo; 1; end
          end
        RUBY
      end

      it 'registers an offense and autocorrects unindented method' do
        expect_offense(<<~RUBY)
          module M
                 ^ Use compact module/class definition instead of nested style.
            class C
            def foo; 1; end
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class M::C
            def foo; 1; end
          end
        RUBY
      end

      context 'with tab-intended nested nodes' do
        it 'registers an offense and autocorrects when 3rd-level module has unintended body' do
          expect_offense(<<~RUBY)
            module A
                   ^ Use compact module/class definition instead of nested style.
            \tmodule B
            \t\tmodule C
            \t\tbody
            \t\tend
            \tend
            end
          RUBY

          expect_correction(<<~RUBY)
            module A::B::C
            \t\tbody
            end
          RUBY
        end

        it 'registers an offense and autocorrects when all nested modules have the same indentation' do
          expect_offense(<<~RUBY)
            module A
                   ^ Use compact module/class definition instead of nested style.
            \tmodule B
            \tmodule C
            \tbody
            \tend
            \tend
            end
          RUBY

          expect_correction(<<~RUBY)
            module A::B::C
            \tbody
            end
          RUBY
        end

        it 'registers an offense and autocorrects when all nested modules have the same indentation and nested body is intended' do
          expect_offense(<<~RUBY)
            module A
                   ^ Use compact module/class definition instead of nested style.
            \tmodule B
            \tmodule C
            \t\tbody
            \tend
            \tend
            end
          RUBY

          expect_correction(<<~RUBY)
            module A::B::C
            \t\tbody
            end
          RUBY
        end
      end
    end

    context 'with one-liner class definition' do
      it 'registers an offense for classes with nested one-liner children' do
        expect_offense(<<~RUBY)
          class FooClass
                ^^^^^^^^ Use compact module/class definition instead of nested style.
            class BarClass; end
          end
        RUBY

        expect_correction(<<~RUBY)
          class FooClass::BarClass
          end
        RUBY
      end

      it 'registers an offense when one-liner class definition is 3 levels deep' do
        expect_offense(<<~RUBY)
          class A < B
            class C
                  ^ Use compact module/class definition instead of nested style.
              class D; end
            end

            class E
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class A < B
            class C::D
            end

            class E
            end
          end
        RUBY
      end

      it 'registers an offense when one-liner class definition is 4 levels deep' do
        expect_offense(<<~RUBY)
          class A < B
            class F
              class C
                    ^ Use compact module/class definition instead of nested style.
                class D; end
              end

              class E
              end
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class A < B
            class F
              class C::D
              end

              class E
              end
            end
          end
        RUBY
      end

      it 'registers an offense when one-liner class definition has multiple whitespaces before the `end` token' do
        expect_offense(<<~RUBY)
          class A < B
            class C
                  ^ Use compact module/class definition instead of nested style.
              class D;    end
            end

            class E
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class A < B
            class C::D
            end

            class E
            end
          end
        RUBY
      end
    end
  end

  context 'when EnforcedStyleForClasses is set' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'nested', 'EnforcedStyleForClasses' => enforced_style_for_classes }
    end

    context 'EnforcedStyleForClasses: nil' do
      let(:enforced_style_for_classes) { nil }

      it 'uses the set `EnforcedStyle` for classes' do
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
    end

    context 'EnforcedStyleForClasses: compact' do
      let(:enforced_style_for_classes) { 'compact' }

      it 'registers an offense for classes with nested children' do
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
    end
  end

  context 'when EnforcedStyleForModules is set' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'nested', 'EnforcedStyleForModules' => enforced_style_for_modules }
    end

    context 'EnforcedStyleForModules: nil' do
      let(:enforced_style_for_modules) { nil }

      it 'uses the set `EnforcedStyle` for modules' do
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
    end

    context 'EnforcedStyleForModules: compact' do
      let(:enforced_style_for_modules) { 'compact' }

      it 'registers an offense for modules with nested children' do
        expect_offense(<<~RUBY)
          module FooModule
                 ^^^^^^^^^ Use compact module/class definition instead of nested style.
            module BarModule
              def method_example
              end
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          module FooModule::BarModule
            def method_example
            end
          end
        RUBY
      end
    end
  end
end
