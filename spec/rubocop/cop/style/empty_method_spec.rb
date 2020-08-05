# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EmptyMethod, :config do
  context 'when configured with compact style' do
    let(:cop_config) { { 'EnforcedStyle' => 'compact' } }

    context 'with an empty instance method definition' do
      it 'registers an offense for empty method' do
        expect_offense(<<~'RUBY')
          def foo
          ^^^^^^^ Put empty method definitions on a single line.
          end
        RUBY
        expect_correction(<<~'RUBY')
          def foo; end
        RUBY
      end

      it 'registers an offense for method with arguments' do
        expect_offense(<<~'RUBY')
          def foo(bar, baz)
          ^^^^^^^^^^^^^^^^^ Put empty method definitions on a single line.
          end
        RUBY
        expect_correction(<<~'RUBY')
          def foo(bar, baz); end
        RUBY
      end

      it 'registers an offense for method with arguments without parens' do
        expect_offense(<<~'RUBY')
          def foo bar, baz
          ^^^^^^^^^^^^^^^^ Put empty method definitions on a single line.
          end
        RUBY
        expect_correction(<<~'RUBY')
          def foo bar, baz; end
        RUBY
      end

      it 'registers an offense for method with blank line' do
        expect_offense(<<~'RUBY')
          def foo
          ^^^^^^^ Put empty method definitions on a single line.

          end
        RUBY
        expect_correction(<<~'RUBY')
          def foo; end
        RUBY
      end

      it 'registers an offense for method with closing paren on following line' do
        expect_offense(<<~RUBY)
          def foo(arg
          ^^^^^^^^^^^ Put empty method definitions on a single line.
          ); end
        RUBY
        expect_correction(<<~RUBY)
          def foo(arg); end
        RUBY
      end

      it 'allows single line method' do
        expect_no_offenses('def foo; end')
      end
    end

    context 'with a non-empty instance method definition' do
      it 'allows multi line method' do
        expect_no_offenses(<<~RUBY)
          def foo
            bar
          end
        RUBY
      end

      it 'allows single line method' do
        expect_no_offenses('def foo; bar; end')
      end

      it 'allows multi line method with comment' do
        expect_no_offenses(<<~RUBY)
          def foo
            # bar
          end
        RUBY
      end
    end

    context 'with an empty class method definition' do
      it 'registers an offense for empty method' do
        expect_offense(<<~'RUBY')
          def self.foo
          ^^^^^^^^^^^^ Put empty method definitions on a single line.
          end
        RUBY
        expect_correction(<<~'RUBY')
          def self.foo; end
        RUBY
      end

      it 'registers an offense for empty method with arguments' do
        expect_offense(<<~'RUBY')
          def self.foo(bar, baz)
          ^^^^^^^^^^^^^^^^^^^^^^ Put empty method definitions on a single line.
          end
        RUBY
        expect_correction(<<~'RUBY')
          def self.foo(bar, baz); end
        RUBY
      end

      it 'registers an offense for method with blank line' do
        expect_offense(<<~'RUBY')
          def self.foo
          ^^^^^^^^^^^^ Put empty method definitions on a single line.

          end
        RUBY
        expect_correction(<<~'RUBY')
          def self.foo; end
        RUBY
      end

      it 'allows single line method' do
        expect_no_offenses('def self.foo; end')
      end
    end

    context 'with a non-empty class method definition' do
      it 'allows multi line method' do
        expect_no_offenses(<<~RUBY)
          def self.foo
            bar
          end
        RUBY
      end

      it 'allows single line method' do
        expect_no_offenses('def self.foo; bar; end')
      end

      it 'allows multi line method with comment' do
        expect_no_offenses(<<~RUBY)
          def self.foo
            # bar
          end
        RUBY
      end
    end
  end

  context 'when configured with expanded style' do
    let(:cop_config) { { 'EnforcedStyle' => 'expanded' } }

    context 'with an empty instance method definition' do
      it 'allows multi line method' do
        expect_no_offenses(<<~RUBY)
          def foo
          end
        RUBY
      end

      it 'allows multi line method with blank line' do
        expect_no_offenses(<<~RUBY)
          def foo

          end
        RUBY
      end

      it 'registers an offense for single line method' do
        expect_offense(<<~'RUBY')
          def foo; end
          ^^^^^^^^^^^^ Put the `end` of empty method definitions on the next line.
        RUBY
        expect_correction(<<~'RUBY')
          def foo
          end
        RUBY
      end
    end

    context 'with a non-empty instance method definition' do
      it 'allows multi line method' do
        expect_no_offenses(<<~RUBY)
          def foo
            bar
          end
        RUBY
      end

      it 'allows single line method' do
        expect_no_offenses('def foo; bar; end')
      end

      it 'allows multi line method with a comment' do
        expect_no_offenses(<<~RUBY)
          def foo
            # bar
          end
        RUBY
      end
    end

    context 'with an empty class method definition' do
      it 'allows empty multi line method' do
        expect_no_offenses(<<~RUBY)
          def self.foo
          end
        RUBY
      end

      it 'allows multi line method with a blank line' do
        expect_no_offenses(<<~RUBY)
          def self.foo

          end
        RUBY
      end

      it 'registers an offense for single line method' do
        expect_offense(<<~'RUBY')
          def self.foo; end
          ^^^^^^^^^^^^^^^^^ Put the `end` of empty method definitions on the next line.
        RUBY
        expect_correction(<<~'RUBY')
          def self.foo
          end
        RUBY
      end
    end

    context 'with a non-empty class method definition' do
      it 'allows multi line method' do
        expect_no_offenses(<<~RUBY)
          def self.foo
            bar
          end
        RUBY
      end

      it 'allows single line method' do
        expect_no_offenses('def self.foo; bar; end')
      end

      it 'allows multi line method with comment' do
        expect_no_offenses(<<~RUBY)
          def self.foo
            # bar
          end
        RUBY
      end
    end

    context 'when method is nested in class scope' do
      it 'registers an offense for single line method' do
        expect_offense(<<~RUBY)
          class Foo
            def bar; end
            ^^^^^^^^^^^^ Put the `end` of empty method definitions on the next line.
          end
        RUBY
        expect_correction(<<~RUBY)
          class Foo
            def bar
            end
          end
        RUBY
      end
    end
  end
end
