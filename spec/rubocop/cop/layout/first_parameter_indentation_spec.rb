# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::FirstParameterIndentation, :config do
  let(:config) do
    supported_styles = { 'SupportedStyles' => %w[consistent align_parentheses] }
    RuboCop::Config.new('Layout/FirstParameterIndentation' =>
                        cop_config.merge(supported_styles).merge(
                          'IndentationWidth' => cop_indent
                        ),
                        'Layout/IndentationWidth' => { 'Width' => 2 })
  end
  let(:cop_indent) { nil } # use indent from Layout/IndentationWidth

  context 'consistent style' do
    let(:cop_config) { { 'EnforcedStyle' => 'consistent' } }

    context 'no paren method defs' do
      it 'ignores' do
        expect_no_offenses(<<~RUBY)
          def abc foo, bar, baz
            foo
          end
        RUBY
      end

      it 'ignores with hash args' do
        expect_no_offenses(<<~RUBY)
          def abc foo: 1, bar: 3, baz: 3
            foo
          end
        RUBY
      end
    end

    context 'single line method defs' do
      it 'ignores' do
        expect_no_offenses(<<~RUBY)
          def abc(foo, bar, baz)
            foo
          end
        RUBY
      end

      it 'ignores with hash args' do
        expect_no_offenses(<<~RUBY)
          def abc(foo: 1, bar: 3, baz: 3)
            foo
          end
        RUBY
      end
    end

    context 'valid indentation on multi-line defs' do
      it 'accepts correctly indented first element' do
        expect_no_offenses(<<~RUBY)
          def abc(
            foo,
            bar,
            baz
          )
            foo
          end
        RUBY
      end

      it 'accepts correctly indented first element hash' do
        expect_no_offenses(<<~RUBY)
          def abc(
            foo: 1,
            bar: 3,
            baz: 3
          )
            foo
          end
        RUBY
      end
    end

    context 'valid indentation on static multi-line defs' do
      it 'accepts correctly indented first element' do
        expect_no_offenses(<<~RUBY)
          def self.abc(
            foo,
            bar,
            baz
          )
            foo
          end
        RUBY
      end

      it 'accepts correctly indented first element hash' do
        expect_no_offenses(<<~RUBY)
          def self.abc(
            foo: 1,
            bar: 3,
            baz: 3
          )
            foo
          end
        RUBY
      end
    end

    context 'invalid indentation on multi-line defs' do
      context 'normal arguments' do
        it 'registers an offense and corrects incorrectly indented first element' do
          expect_offense(<<~RUBY)
            def abc(
                        foo,
                        ^^^ Use 2 spaces for indentation in method args, relative to the start of the line where the left parenthesis is.
                        bar,
                        baz
            )
              foo
            end
          RUBY

          expect_correction(<<~RUBY)
            def abc(
              foo,
                        bar,
                        baz
            )
              foo
            end
          RUBY
        end
      end

      context 'hash arguments' do
        it 'registers an offense and corrects incorrectly indented first element' do
          expect_offense(<<~RUBY)
            def abc(
                      foo: 1,
                      ^^^^^^ Use 2 spaces for indentation in method args, relative to the start of the line where the left parenthesis is.
                      bar: 3,
                      baz: 3
            )
              foo
            end
          RUBY

          expect_correction(<<~RUBY)
            def abc(
              foo: 1,
                      bar: 3,
                      baz: 3
            )
              foo
            end
          RUBY
        end
      end

      context 'hash arguments static method def' do
        it 'registers an offense and corrects incorrectly indented first element' do
          expect_offense(<<~RUBY)
            def self.abc(
                      foo: 1,
                      ^^^^^^ Use 2 spaces for indentation in method args, relative to the start of the line where the left parenthesis is.
                      bar: 3,
                      baz: 3
            )
              foo
            end
          RUBY

          expect_correction(<<~RUBY)
            def self.abc(
              foo: 1,
                      bar: 3,
                      baz: 3
            )
              foo
            end
          RUBY
        end
      end
    end
  end

  context 'align_parentheses style' do
    let(:cop_config) { { 'EnforcedStyle' => 'align_parentheses' } }

    context 'no paren method defs' do
      it 'ignores' do
        expect_no_offenses(<<~RUBY)
          def abc foo, bar, baz
            foo
          end
        RUBY
      end

      it 'ignores with hash args' do
        expect_no_offenses(<<~RUBY)
          def abc foo: 1, bar: 3, baz: 3
            foo
          end
        RUBY
      end
    end

    context 'single line method defs' do
      it 'ignores' do
        expect_no_offenses(<<~RUBY)
          def abc(foo, bar, baz)
            foo
          end
        RUBY
      end

      it 'ignores with hash args' do
        expect_no_offenses(<<~RUBY)
          def abc(foo: 1, bar: 3, baz: 3)
            foo
          end
        RUBY
      end
    end

    context 'valid indentation on multi-line defs' do
      it 'accepts correctly indented first element' do
        expect_no_offenses(<<~RUBY)
          def abc(
                   foo,
                   bar,
                   baz
                 )
            foo
          end
        RUBY
      end

      it 'accepts correctly indented first element hash' do
        expect_no_offenses(<<~RUBY)
          def abc(
                   foo: 1,
                   bar: 3,
                   baz: 3
                 )
            foo
          end
        RUBY
      end
    end

    context 'invalid indentation on multi-line defs' do
      context 'normal arguments' do
        it 'registers an offense and corrects incorrectly indented first element' do
          expect_offense(<<~RUBY)
            def abc(
                        foo,
                        ^^^ Use 2 spaces for indentation in method args, relative to the position of the opening parenthesis.
                        bar,
                        baz
            )
              foo
            end
          RUBY

          expect_correction(<<~RUBY)
            def abc(
                     foo,
                        bar,
                        baz
            )
              foo
            end
          RUBY
        end
      end

      context 'hash arguments' do
        it 'registers an offense and corrects incorrectly indented first element' do
          expect_offense(<<~RUBY)
            def abc(
                      foo: 1,
                      ^^^^^^ Use 2 spaces for indentation in method args, relative to the position of the opening parenthesis.
                      bar: 3,
                      baz: 3
            )
              foo
            end
          RUBY

          expect_correction(<<~RUBY)
            def abc(
                     foo: 1,
                      bar: 3,
                      baz: 3
            )
              foo
            end
          RUBY
        end
      end

      context 'hash arguments static def' do
        it 'registers an offense and corrects incorrectly indented first element' do
          expect_offense(<<~RUBY)
            def self.abc(
                      foo: 1,
                      ^^^^^^ Use 2 spaces for indentation in method args, relative to the position of the opening parenthesis.
                      bar: 3,
                      baz: 3
            )
              foo
            end
          RUBY

          expect_correction(<<~RUBY)
            def self.abc(
                          foo: 1,
                      bar: 3,
                      baz: 3
            )
              foo
            end
          RUBY
        end
      end
    end
  end
end
