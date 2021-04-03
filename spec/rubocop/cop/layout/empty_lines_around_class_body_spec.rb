# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EmptyLinesAroundClassBody, :config do
  let(:extra_begin) { 'Extra empty line detected at class body beginning.' }
  let(:extra_end) { 'Extra empty line detected at class body end.' }
  let(:missing_begin) { 'Empty line missing at class body beginning.' }
  let(:missing_end) { 'Empty line missing at class body end.' }
  let(:missing_def) { 'Empty line missing before first def definition' }
  let(:missing_type) { 'Empty line missing before first class definition' }

  context 'when EnforcedStyle is no_empty_lines' do
    let(:cop_config) { { 'EnforcedStyle' => 'no_empty_lines' } }

    it 'registers an offense for class body starting with a blank' do
      expect_offense(<<~RUBY)
        class SomeClass

        ^{} #{extra_begin}
          do_something
        end
      RUBY

      expect_correction(<<~RUBY)
        class SomeClass
          do_something
        end
      RUBY
    end

    it 'registers an offense for class body ending with a blank' do
      expect_offense(<<~RUBY)
        class SomeClass
          do_something

        ^{} #{extra_end}
        end
      RUBY

      expect_correction(<<~RUBY)
        class SomeClass
          do_something
        end
      RUBY
    end

    it 'autocorrects singleton class body containing only a blank' do
      expect_offense(<<~RUBY)
        class << self

        ^{} #{extra_begin}
        end
      RUBY

      expect_correction(<<~RUBY)
        class << self
        end
      RUBY
    end

    it 'registers an offense for singleton class body ending with a blank' do
      expect_offense(<<~RUBY)
        class << self
          do_something

        ^{} #{extra_end}
        end
      RUBY

      expect_correction(<<~RUBY)
        class << self
          do_something
        end
      RUBY
    end
  end

  context 'when EnforcedStyle is empty_lines' do
    let(:cop_config) { { 'EnforcedStyle' => 'empty_lines' } }

    it 'does not register offenses' do
      expect_no_offenses(<<~RUBY)
        class Foo

          def do_something
          end

        end
      RUBY
    end

    it 'does not register offenses when specifying a superclass that breaks the line' do
      expect_no_offenses(<<~RUBY)
        class Foo <
              Bar

          def do_something
          end

        end
      RUBY
    end

    it 'registers an offense for class body not starting or ending with a blank' do
      expect_offense(<<~RUBY)
        class SomeClass
          do_something
        ^ #{missing_begin}
        end
        ^ #{missing_end}
      RUBY

      expect_correction(<<~RUBY)
        class SomeClass

          do_something

        end
      RUBY
    end

    it 'accepts classes with an empty body' do
      expect_no_offenses("class SomeClass\nend")
    end

    it 'registers an offense for singleton class body not starting or ending with a blank' do
      expect_offense(<<~RUBY)
        class << self
          do_something
        ^ #{missing_begin}
        end
        ^ #{missing_end}
      RUBY

      expect_correction(<<~RUBY)
        class << self

          do_something

        end
      RUBY
    end

    it 'accepts singleton classes with an empty body' do
      expect_no_offenses("class << self\nend")
    end
  end

  context 'when EnforcedStyle is empty_lines_except_namespace' do
    let(:cop_config) { { 'EnforcedStyle' => 'empty_lines_except_namespace' } }

    context 'when only child is class' do
      it 'requires no empty lines for namespace' do
        expect_no_offenses(<<~RUBY)
          class Parent < Base
            class Child

              do_something

            end
          end
        RUBY
      end

      it 'registers offense for namespace body starting with a blank' do
        expect_offense(<<~RUBY)
          class Parent

          ^{} #{extra_begin}
            class Child

              do_something

            end
          end
        RUBY
      end

      it 'registers offense for namespace body ending with a blank' do
        expect_offense(<<~RUBY)
          class Parent
            class Child

              do_something

            end

          ^{} #{extra_end}
          end
        RUBY
      end

      it 'registers offenses for namespaced class body not starting with a blank' do
        expect_offense(<<~RUBY)
          class Parent
            class Child
              do_something
          ^ #{missing_begin}

            end
          end
        RUBY
      end

      it 'registers offenses for namespaced class body not ending with a blank' do
        expect_offense(<<~RUBY)
          class Parent
            class Child

              do_something
            end
          ^ #{missing_end}
          end
        RUBY
      end

      it 'autocorrects beginning and end' do
        expect_offense(<<~RUBY)
          class Parent < Base

          ^{} #{extra_begin}
            class Child
              do_something
          ^ #{missing_begin}
            end
          ^ #{missing_end}

          ^{} #{extra_end}
          end
        RUBY

        expect_correction(<<~RUBY)
          class Parent < Base
            class Child

              do_something

            end
          end
        RUBY
      end
    end

    context 'when only child is module' do
      it 'requires no empty lines for namespace' do
        expect_no_offenses(<<~RUBY)
          class Parent
            module Child
              do_something
            end
          end
        RUBY
      end

      it 'registers offense for namespace body starting with a blank' do
        expect_offense(<<~RUBY)
          class Parent

          ^{} #{extra_begin}
            module Child
              do_something
            end
          end
        RUBY
      end

      it 'registers offense for namespace body ending with a blank' do
        expect_offense(<<~RUBY)
          class Parent
            module Child
              do_something
            end

          ^{} #{extra_end}
          end
        RUBY
      end
    end

    context 'when has multiple child classes' do
      it 'requires empty lines for namespace' do
        expect_no_offenses(<<~RUBY)
          class Parent

            class Mom

              do_something

            end
            class Dad

            end

          end
        RUBY
      end

      it 'registers offenses for namespace body starting and ending without a blank' do
        expect_offense(<<~RUBY)
          class Parent
            class Mom
          ^ #{missing_begin}
              do_something
          ^ #{missing_begin}
            end
          ^ #{missing_end}
            class Dad

            end
          end
          ^ #{missing_end}
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is beginning_only' do
    let(:cop_config) { { 'EnforcedStyle' => 'beginning_only' } }

    it 'ignores empty lines at the beginning of a class' do
      expect_no_offenses(<<~RUBY)
        class SomeClass

          do_something
        end
      RUBY
    end

    it 'registers an offense for an empty line at the end of a class' do
      expect_offense(<<~RUBY)
        class SomeClass

          do_something

        ^{} #{extra_end}
        end
      RUBY

      expect_correction(<<~RUBY)
        class SomeClass

          do_something
        end
      RUBY
    end
  end

  context 'when EnforcedStyle is ending_only' do
    let(:cop_config) { { 'EnforcedStyle' => 'ending_only' } }

    it 'ignores empty lines at the beginning of a class' do
      expect_no_offenses(<<~RUBY)
        class SomeClass
          do_something

        end
      RUBY
    end

    it 'registers an offense for an empty line at the end of a class' do
      expect_offense(<<~RUBY)
        class SomeClass

        ^{} #{extra_begin}
          do_something

        end
      RUBY

      expect_correction(<<~RUBY)
        class SomeClass
          do_something

        end
      RUBY
    end
  end

  include_examples 'empty_lines_around_class_or_module_body', 'class'
end
