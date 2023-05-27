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
end
