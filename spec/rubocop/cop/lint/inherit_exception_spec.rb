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
    end
  end
end
