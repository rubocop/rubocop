# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EmptyMethod, :config do
  context 'when configured with compact style' do
    let(:cop_config) { { 'EnforcedStyle' => 'compact' } }

    context 'with an empty instance method definition' do
      it 'registers an offense for empty method' do
        expect_offense(<<~RUBY)
          def foo
          ^^^^^^^ Put empty method definitions on a single line.
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo; end
        RUBY
      end

      it 'registers an offense for method with arguments' do
        expect_offense(<<~RUBY)
          def foo(bar, baz)
          ^^^^^^^^^^^^^^^^^ Put empty method definitions on a single line.
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo(bar, baz); end
        RUBY
      end

      it 'registers an offense for method with arguments without parens' do
        expect_offense(<<~RUBY)
          def foo bar, baz
          ^^^^^^^^^^^^^^^^ Put empty method definitions on a single line.
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo bar, baz; end
        RUBY
      end

      it 'registers an offense for method with blank line' do
        expect_offense(<<~RUBY)
          def foo
          ^^^^^^^ Put empty method definitions on a single line.

          end
        RUBY

        expect_correction(<<~RUBY)
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
        expect_offense(<<~RUBY)
          def self.foo
          ^^^^^^^^^^^^ Put empty method definitions on a single line.
          end
        RUBY

        expect_correction(<<~RUBY)
          def self.foo; end
        RUBY
      end

      it 'registers an offense for empty method with arguments' do
        expect_offense(<<~RUBY)
          def self.foo(bar, baz)
          ^^^^^^^^^^^^^^^^^^^^^^ Put empty method definitions on a single line.
          end
        RUBY

        expect_correction(<<~RUBY)
          def self.foo(bar, baz); end
        RUBY
      end

      it 'registers an offense for method with blank line' do
        expect_offense(<<~RUBY)
          def self.foo
          ^^^^^^^^^^^^ Put empty method definitions on a single line.

          end
        RUBY

        expect_correction(<<~RUBY)
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

    context 'relation with Layout/LineLength' do
      let(:other_cops) do
        {
          'Layout/LineLength' => {
            'Enabled' => line_length_enabled,
            'Max' => 20
          }
        }
      end
      let(:line_length_enabled) { true }

      context 'when that cop is disabled' do
        let(:line_length_enabled) { false }

        it 'corrects to long lines' do
          expect_offense(<<~RUBY)
            def foo(abc: '10000', def: '20000', ghi: '30000')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Put empty method definitions on a single line.
            end
          RUBY

          expect_correction(<<~RUBY)
            def foo(abc: '10000', def: '20000', ghi: '30000'); end
          RUBY
        end
      end

      context 'when the correction would exceed the configured maximum' do
        it 'reports an offense but does not correct' do
          expect_offense(<<~RUBY)
            def foo(abc: '10000', def: '20000', ghi: '30000')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Put empty method definitions on a single line.
            end
          RUBY

          expect_no_corrections
        end
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
        expect_offense(<<~RUBY)
          def foo; end
          ^^^^^^^^^^^^ Put the `end` of empty method definitions on the next line.
        RUBY

        expect_correction(<<~RUBY)
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
        expect_offense(<<~RUBY)
          def self.foo; end
          ^^^^^^^^^^^^^^^^^ Put the `end` of empty method definitions on the next line.
        RUBY

        expect_correction(<<~RUBY)
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

    context 'relation with Layout/LineLength' do
      let(:other_cops) do
        {
          'Layout/LineLength' => {
            'Enabled' => true,
            'Max' => 20
          }
        }
      end

      it 'still corrects even if the method is longer than the configured Max' do
        expect_offense(<<~RUBY)
          def foo(abc: '10000', def: '20000', ghi: '30000'); end
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Put the `end` of empty method definitions on the next line.
        RUBY

        expect_correction(<<~RUBY)
          def foo(abc: '10000', def: '20000', ghi: '30000')
          end
        RUBY
      end
    end
  end
end
