# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::InheritException, :config do
  context 'when class inherits from `Exception`' do
    context 'with enforced style set to `runtime_error`' do
      let(:cop_config) { { 'EnforcedStyle' => 'runtime_error' } }

      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          class C < Exception; end
                    ^^^^^^^^^ Inherit from `RuntimeError` instead of `Exception`.
        RUBY

        expect_correction(<<~RUBY)
          class C < RuntimeError; end
        RUBY
      end

      context 'when creating a subclass using Class.new' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            Class.new(Exception)
                      ^^^^^^^^^ Inherit from `RuntimeError` instead of `Exception`.
          RUBY

          expect_correction(<<~RUBY)
            Class.new(RuntimeError)
          RUBY
        end
      end

      context 'when inheriting `Exception`' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            module Foo
              class C < Exception; end # This `Exception` is the same as `::Exception`.
                        ^^^^^^^^^ Inherit from `RuntimeError` instead of `Exception`.
              class Exception < RuntimeError; end
            end
          RUBY

          expect_correction(<<~RUBY)
            module Foo
              class C < RuntimeError; end # This `Exception` is the same as `::Exception`.
              class Exception < RuntimeError; end
            end
          RUBY
        end
      end

      context 'when inheriting `Exception` and has non-constant siblings' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            module Foo
              include Bar

              class C < Exception; end # This `Exception` is the same as `::Exception`.
                        ^^^^^^^^^ Inherit from `RuntimeError` instead of `Exception`.
              class Exception < RuntimeError; end
            end
          RUBY

          expect_correction(<<~RUBY)
            module Foo
              include Bar

              class C < RuntimeError; end # This `Exception` is the same as `::Exception`.
              class Exception < RuntimeError; end
            end
          RUBY
        end
      end

      context 'when inheriting `::Exception`' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            module Foo
              class Exception < RuntimeError; end
              class C < ::Exception; end
                        ^^^^^^^^^^^ Inherit from `RuntimeError` instead of `Exception`.
            end
          RUBY

          expect_correction(<<~RUBY)
            module Foo
              class Exception < RuntimeError; end
              class C < RuntimeError; end
            end
          RUBY
        end
      end

      context 'when inheriting a standard lib exception class that is not a subclass of `StandardError`' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            class C < Interrupt; end
          RUBY
        end
      end

      context 'when inheriting `Exception` with omitted namespace' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            module Foo
              class Exception < RuntimeError; end # This `Exception` is the same as `Foo::Exception`.
              class C < Exception; end
            end
          RUBY
        end
      end
    end

    context 'with enforced style set to `standard_error`' do
      let(:cop_config) { { 'EnforcedStyle' => 'standard_error' } }

      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          class C < Exception; end
                    ^^^^^^^^^ Inherit from `StandardError` instead of `Exception`.
        RUBY

        expect_correction(<<~RUBY)
          class C < StandardError; end
        RUBY
      end

      context 'when creating a subclass using Class.new' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            Class.new(Exception)
                      ^^^^^^^^^ Inherit from `StandardError` instead of `Exception`.
          RUBY

          expect_correction(<<~RUBY)
            Class.new(StandardError)
          RUBY
        end
      end

      context 'when inheriting `Exception`' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            module Foo
              class C < Exception; end # This `Exception` is the same as `::Exception`.
                        ^^^^^^^^^ Inherit from `StandardError` instead of `Exception`.
              class Exception < RuntimeError; end
            end
          RUBY

          expect_correction(<<~RUBY)
            module Foo
              class C < StandardError; end # This `Exception` is the same as `::Exception`.
              class Exception < RuntimeError; end
            end
          RUBY
        end
      end

      context 'when inheriting `::Exception`' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            module Foo
              class Exception < RuntimeError; end
              class C < ::Exception; end
                        ^^^^^^^^^^^ Inherit from `StandardError` instead of `Exception`.
            end
          RUBY

          expect_correction(<<~RUBY)
            module Foo
              class Exception < RuntimeError; end
              class C < StandardError; end
            end
          RUBY
        end
      end

      context 'when inheriting a standard lib exception class that is not a subclass of `StandardError`' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            class C < Interrupt; end
          RUBY
        end
      end

      context 'when inheriting `Exception` with omitted namespace' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            module Foo
              class Exception < StandardError; end # This `Exception` is the same as `Foo::Exception`.
              class C < Exception; end
            end
          RUBY
        end
      end
    end
  end

  context 'with a project index', :project_index do
    let(:cop_config) { { 'EnforcedStyle' => 'standard_error' } }

    def index_with_current(source, sources = {})
      build_index(sources.merge('file:///current.rb' => source))
    end

    it 'registers an offense without autocorrection when the parent inherits `Exception` in another file' do
      source = <<~RUBY
        class MyError < BaseError
        end
      RUBY
      cop.project_index = index_with_current(
        source, 'file:///base.rb' => "class BaseError < Exception\nend\n"
      )

      expect_offense(<<~RUBY, 'current.rb')
        class MyError < BaseError
                        ^^^^^^^^^ Inherit from `StandardError` instead of `Exception` (inherited via `BaseError`).
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense when `Exception` is inherited two hops away' do
      source = <<~RUBY
        class MyError < MidError
        end
      RUBY
      cop.project_index = index_with_current(
        source,
        'file:///mid.rb' => "class MidError < BaseError\nend\n",
        'file:///base.rb' => "class BaseError < Exception\nend\n"
      )

      expect_offense(<<~RUBY, 'current.rb')
        class MyError < MidError
                        ^^^^^^^^ Inherit from `StandardError` instead of `Exception` (inherited via `BaseError`).
        end
      RUBY
    end

    it 'does not register an offense when the parent inherits `StandardError` in another file' do
      source = <<~RUBY
        class MyError < BaseError
        end
      RUBY
      cop.project_index = index_with_current(
        source, 'file:///base.rb' => "class BaseError < StandardError\nend\n"
      )

      expect_no_offenses(source, 'current.rb')
    end

    it 'does not register an offense when the parent inherits an unresolvable class' do
      source = <<~RUBY
        class MyError < BaseError
        end
      RUBY
      cop.project_index = index_with_current(
        source, 'file:///base.rb' => "class BaseError < SomeGemError\nend\n"
      )

      expect_no_offenses(source, 'current.rb')
    end

    it 'does not register an offense when the parent is not in the index' do
      source = <<~RUBY
        class MyError < SomeGemError
        end
      RUBY
      cop.project_index = index_with_current(source)

      expect_no_offenses(source, 'current.rb')
    end
  end
end
