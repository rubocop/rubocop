# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::OneClassPerFile, :config do
  context 'when multiple top-level definitions exist' do
    it 'registers an offense for two top-level classes' do
      expect_offense(<<~RUBY)
        class Foo
        end

        class Bar
        ^^^^^^^^^ Do not define multiple classes/modules at the top level in a single file.
        end
      RUBY
    end

    it 'registers an offense for two top-level modules' do
      expect_offense(<<~RUBY)
        module Foo
        end

        module Bar
        ^^^^^^^^^^ Do not define multiple classes/modules at the top level in a single file.
        end
      RUBY
    end

    it 'registers an offense for a class and a module at top level' do
      expect_offense(<<~RUBY)
        class Foo
        end

        module Bar
        ^^^^^^^^^^ Do not define multiple classes/modules at the top level in a single file.
        end
      RUBY
    end

    it 'registers an offense for a module and a class at top level' do
      expect_offense(<<~RUBY)
        module Foo
        end

        class Bar
        ^^^^^^^^^ Do not define multiple classes/modules at the top level in a single file.
        end
      RUBY
    end

    it 'registers offenses for three top-level classes' do
      expect_offense(<<~RUBY)
        class Foo
        end

        class Bar
        ^^^^^^^^^ Do not define multiple classes/modules at the top level in a single file.
        end

        class Baz
        ^^^^^^^^^ Do not define multiple classes/modules at the top level in a single file.
        end
      RUBY
    end

    it 'registers an offense for top-level classes with namespaced names' do
      expect_offense(<<~RUBY)
        class Foo::Baz
        end

        class Bar::Qux
        ^^^^^^^^^^^^^^ Do not define multiple classes/modules at the top level in a single file.
        end
      RUBY
    end

    it 'registers an offense for classes preceded by other statements' do
      expect_offense(<<~RUBY)
        require 'something'

        class Foo
        end

        class Bar
        ^^^^^^^^^ Do not define multiple classes/modules at the top level in a single file.
        end
      RUBY
    end

    it 'registers an offense for top-level classes with bodies' do
      expect_offense(<<~RUBY)
        class Foo
          def method_one
          end
        end

        class Bar
        ^^^^^^^^^ Do not define multiple classes/modules at the top level in a single file.
          def method_two
          end
        end
      RUBY
    end
  end

  context 'when only one top-level definition exists' do
    it 'does not register an offense for a single top-level class' do
      expect_no_offenses(<<~RUBY)
        class Foo
          def method_one
          end
        end
      RUBY
    end

    it 'does not register an offense for a single top-level module' do
      expect_no_offenses(<<~RUBY)
        module Foo
          def method_one
          end
        end
      RUBY
    end

    it 'does not register an offense for a single class with no body' do
      expect_no_offenses(<<~RUBY)
        class Foo
        end
      RUBY
    end
  end

  context 'when definitions are nested' do
    it 'does not register an offense for nested classes' do
      expect_no_offenses(<<~RUBY)
        class Foo
          class Bar
          end
        end
      RUBY
    end

    it 'does not register an offense for nested modules' do
      expect_no_offenses(<<~RUBY)
        module Foo
          module Bar
          end
        end
      RUBY
    end

    it 'does not register an offense for multiple classes inside a module' do
      expect_no_offenses(<<~RUBY)
        module Foo
          class Bar
          end

          class Baz
          end
        end
      RUBY
    end
  end

  context 'when file has no class or module definitions' do
    it 'does not register an offense for an empty file' do
      expect_no_offenses('')
    end

    it 'does not register an offense for a file with only method calls' do
      expect_no_offenses(<<~RUBY)
        require 'foo'
        require 'bar'
      RUBY
    end
  end

  context 'when a singleton class is at top level' do
    it 'does not register an offense for class << self alongside a class' do
      expect_no_offenses(<<~RUBY)
        class Foo
        end

        class << self
          def something
          end
        end
      RUBY
    end
  end

  context 'when AllowedClasses is configured' do
    let(:cop_config) { { 'AllowedClasses' => ['SpecificError'] } }

    it 'does not count allowed classes toward the limit' do
      expect_no_offenses(<<~RUBY)
        class Foo
        end

        class SpecificError
        end
      RUBY
    end

    it 'still registers an offense for non-allowed additional classes' do
      expect_offense(<<~RUBY)
        class Foo
        end

        class SpecificError
        end

        class Bar
        ^^^^^^^^^ Do not define multiple classes/modules at the top level in a single file.
        end
      RUBY
    end

    it 'does not count allowed modules toward the limit' do
      expect_no_offenses(<<~RUBY)
        class Foo
        end

        module SpecificError
        end
      RUBY
    end
  end

  context 'when AllowedClasses contains multiple entries' do
    let(:cop_config) { { 'AllowedClasses' => %w[ErrorA ErrorB] } }

    it 'does not count any allowed classes toward the limit' do
      expect_no_offenses(<<~RUBY)
        class Foo
        end

        class ErrorA
        end

        class ErrorB
        end
      RUBY
    end
  end
end
