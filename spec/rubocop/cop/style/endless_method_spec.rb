# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EndlessMethod, :config do
  context 'Ruby >= 3.0', :ruby30 do
    context 'EnforcedStyle: disallow' do
      let(:cop_config) { { 'EnforcedStyle' => 'disallow' } }

      it 'registers an offense for an endless method' do
        expect_offense(<<~RUBY)
          def my_method() = x
          ^^^^^^^^^^^^^^^^^^^ Avoid endless method definitions.
        RUBY

        expect_correction(<<~RUBY)
          def my_method
            x
          end
        RUBY
      end

      it 'registers an offense for an endless method with arguments' do
        expect_offense(<<~RUBY)
          def my_method(a, b) = x
          ^^^^^^^^^^^^^^^^^^^^^^^ Avoid endless method definitions.
        RUBY

        expect_correction(<<~RUBY)
          def my_method(a, b)
            x
          end
        RUBY
      end
    end

    context 'EnforcedStyle: allow_single_line' do
      let(:cop_config) { { 'EnforcedStyle' => 'allow_single_line' } }

      it 'does not register an offense for an endless method' do
        expect_no_offenses(<<~RUBY)
          def my_method() = x
        RUBY
      end

      it 'does not register an offense for an endless method with arguments' do
        expect_no_offenses(<<~RUBY)
          def my_method(a, b) = x
        RUBY
      end

      it 'registers an offense and corrects for a multiline endless method' do
        expect_offense(<<~RUBY)
          def my_method() = x.foo
          ^^^^^^^^^^^^^^^^^^^^^^^ Avoid endless method definitions with multiple lines.
                             .bar
                             .baz
        RUBY

        expect_correction(<<~RUBY)
          def my_method
            x.foo
                             .bar
                             .baz
          end
        RUBY
      end

      it 'registers an offense and corrects for a multiline endless method with begin' do
        expect_offense(<<~RUBY)
          def my_method() = begin
          ^^^^^^^^^^^^^^^^^^^^^^^ Avoid endless method definitions with multiple lines.
            foo && bar
          end
        RUBY

        expect_correction(<<~RUBY)
          def my_method
            begin
            foo && bar
          end
          end
        RUBY
      end

      it 'registers an offense and corrects for a multiline endless method with arguments' do
        expect_offense(<<~RUBY)
          def my_method(a, b) = x.foo
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid endless method definitions with multiple lines.
                                 .bar
                                 .baz
        RUBY

        expect_correction(<<~RUBY)
          def my_method(a, b)
            x.foo
                                 .bar
                                 .baz
          end
        RUBY
      end
    end

    context 'EnforcedStyle: allow_always' do
      let(:cop_config) { { 'EnforcedStyle' => 'allow_always' } }

      it 'does not register an offense for an endless method' do
        expect_no_offenses(<<~RUBY)
          def my_method() = x
        RUBY
      end

      it 'does not register an offense for an endless method with arguments' do
        expect_no_offenses(<<~RUBY)
          def my_method(a, b) = x
        RUBY
      end

      it 'does not register an offense for a multiline endless method' do
        expect_no_offenses(<<~RUBY)
          def my_method() = x.foo
                             .bar
                             .baz
        RUBY
      end

      it 'does not register an offense for a multiline endless method with begin' do
        expect_no_offenses(<<~RUBY)
          def my_method() = begin
            foo && bar
          end
        RUBY
      end

      it 'does not register an offense for a multiline endless method with arguments' do
        expect_no_offenses(<<~RUBY)
          def my_method(a, b) = x.foo
                                 .bar
                                 .baz
        RUBY
      end
    end
  end
end
