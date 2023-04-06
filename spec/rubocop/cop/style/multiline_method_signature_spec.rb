# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MultilineMethodSignature, :config do
  context 'when arguments span a single line' do
    context 'when defining an instance method' do
      it 'registers an offense and corrects when closing paren is on the following line' do
        expect_offense(<<~RUBY)
          def foo(bar
          ^^^^^^^^^^^ Avoid multi-line method signatures.
              )
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo(bar)
          end
        RUBY
      end

      it 'registers an offense and corrects when line break after opening parenthesis' do
        expect_offense(<<~RUBY)
          class Foo
            def foo(
            ^^^^^^^^ Avoid multi-line method signatures.
              arg
          )
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class Foo
            def foo(arg)
            end
          end
        RUBY
      end

      it 'registers an offense and corrects when closing paren is on the following line' \
         'and line break after `def` keyword' do
        expect_offense(<<~RUBY)
          def
          ^^^ Avoid multi-line method signatures.
          foo(bar
              )
          end
        RUBY

        expect_correction(<<~RUBY)
          def
          foo(bar)
          end
        RUBY
      end

      context 'when method signature is on a single line' do
        it 'does not register an offense for parameterized method' do
          expect_no_offenses(<<~RUBY)
            def foo(bar, baz)
            end
          RUBY
        end

        it 'does not register an offense for unparameterized method' do
          expect_no_offenses(<<~RUBY)
            def foo
            end
          RUBY
        end
      end

      it 'does not register an offense when line break after `def` keyword' do
        expect_no_offenses(<<~RUBY)
          def
          method_name arg; end
        RUBY
      end
    end

    context 'when defining an class method' do
      context 'when arguments span a single line' do
        it 'registers an offense and corrects when closing paren is on the following line' do
          expect_offense(<<~RUBY)
            def self.foo(bar
            ^^^^^^^^^^^^^^^^ Avoid multi-line method signatures.
                )
            end
          RUBY

          expect_correction(<<~RUBY)
            def self.foo(bar)
            end
          RUBY
        end
      end

      context 'when method signature is on a single line' do
        it 'does not register an offense for parameterized method' do
          expect_no_offenses(<<~RUBY)
            def self.foo(bar, baz)
            end
          RUBY
        end

        it 'does not register an offense for unparameterized method' do
          expect_no_offenses(<<~RUBY)
            def self.foo
            end
          RUBY
        end
      end
    end
  end

  context 'when arguments span multiple lines' do
    context 'when defining an instance method' do
      it 'registers an offense and corrects when `end` is on the following line' do
        expect_offense(<<~RUBY)
          def foo(bar,
          ^^^^^^^^^^^^ Avoid multi-line method signatures.
                  baz)
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo(bar, baz)
          end
        RUBY
      end

      it 'registers an offense and corrects when `end` is on the same line with last argument' do
        expect_offense(<<~RUBY)
          def foo(bar,
          ^^^^^^^^^^^^ Avoid multi-line method signatures.
                  baz); end
        RUBY

        expect_correction(<<~RUBY)
          def foo(bar, baz); end
        RUBY
      end

      it 'registers an offense and corrects when `end` is on the same line with only closing parentheses' do
        expect_offense(<<~RUBY)
          def foo(bar,
          ^^^^^^^^^^^^ Avoid multi-line method signatures.
                  baz
                 ); end
        RUBY

        expect_correction(<<~RUBY)
          def foo(bar, baz); end
        RUBY
      end
    end

    context 'when defining an class method' do
      it 'registers an offense and corrects when `end` is on the following line' do
        expect_offense(<<~RUBY)
          def self.foo(bar,
          ^^^^^^^^^^^^^^^^^ Avoid multi-line method signatures.
                  baz)
          end
        RUBY

        expect_correction(<<~RUBY)
          def self.foo(bar, baz)
          end
        RUBY
      end

      it 'registers an offense and corrects when `end` is on the same line' do
        expect_offense(<<~RUBY)
          def self.foo(bar,
          ^^^^^^^^^^^^^^^^^ Avoid multi-line method signatures.
                  baz); end
        RUBY

        expect_correction(<<~RUBY)
          def self.foo(bar, baz); end
        RUBY
      end

      it 'registers an offense and corrects when `end` is on the same line with only closing parentheses' do
        expect_offense(<<~RUBY)
          def self.foo(bar,
          ^^^^^^^^^^^^^^^^^ Avoid multi-line method signatures.
                  baz
              ); end
        RUBY

        expect_correction(<<~RUBY)
          def self.foo(bar, baz); end
        RUBY
      end
    end

    context 'when correction would exceed maximum line length' do
      let(:other_cops) { { 'Layout/LineLength' => { 'Max' => 5 } } }

      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          def foo(bar,
                  baz)
          end
        RUBY
      end
    end

    context 'when correction would not exceed maximum line length' do
      let(:other_cops) { { 'Layout/LineLength' => { 'Max' => 25 } } }

      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          def foo(bar,
          ^^^^^^^^^^^^ Avoid multi-line method signatures.
                  baz)
            qux.qux
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo(bar, baz)
            qux.qux
          end
        RUBY
      end
    end
  end
end
