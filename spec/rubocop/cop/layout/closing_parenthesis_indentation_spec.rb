# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::ClosingParenthesisIndentation, :config do
  context 'for method calls' do
    context 'with line break before 1st parameter' do
      it 'registers an offense for misaligned )' do
        expect_offense(<<~RUBY)
          some_method(
            a
            )
            ^ Indent `)` to column 0 (not 2)
        RUBY

        expect_correction(<<~RUBY)
          some_method(
            a
          )
        RUBY
      end

      it 'accepts a correctly aligned )' do
        expect_no_offenses(<<~RUBY)
          some_method(
            a
          )
        RUBY
      end
    end

    context 'with no line break before 1st parameter' do
      it 'registers an offense for misaligned )' do
        expect_offense(<<~RUBY)
          some_method(a
          )
          ^ Align `)` with `(`.
        RUBY

        expect_correction(<<~RUBY)
          some_method(a
                     )
        RUBY
      end

      it 'accepts a correctly aligned )' do
        expect_no_offenses(<<~RUBY)
          some_method(a
                     )
        RUBY
      end

      it 'does not register an offense when using keyword arguments' do
        expect_no_offenses(<<~RUBY)
          some_method(x: 1,
            y: 2,
            z: 3
          )
        RUBY
      end

      it 'does not register an offense when using keyword splat arguments' do
        expect_no_offenses(<<~RUBY)
          some_method(x,
            **options
          )
        RUBY
      end

      it 'accepts a correctly indented )' do
        expect_no_offenses(<<~RUBY)
          some_method(a,
            x: 1,
            y: 2
          )
          b =
            some_method(a,
                       )
        RUBY
      end

      it 'accepts a correctly indented ) inside a block' do
        expect_no_offenses(<<~RUBY)
          block_adds_extra_indentation do
            some_method(a,
              x: 1,
              y: 2
            )
            b =
              some_method(a,
                         )
          end
        RUBY
      end

      it 'registers an offense and corrects misindented ) when ) is aligned with the params' do
        expect_offense(<<~RUBY)
          some_method(a,
            x: 1,
            y: 2
                      )
                      ^ Indent `)` to column 0 (not 12)
          b =
            some_method(a,
                        )
                        ^ Align `)` with `(`.
        RUBY

        expect_correction(<<~RUBY)
          some_method(a,
            x: 1,
            y: 2
          )
          b =
            some_method(a,
                       )
        RUBY
      end
    end

    context 'without arguments' do
      it 'accepts empty ()' do
        expect_no_offenses('some_method()')
      end

      it 'can handle indentation up against the left edge' do
        expect_no_offenses(<<~RUBY)
          some_method(
          )
        RUBY
      end

      it 'accepts a correctly aligned ) against (' do
        expect_no_offenses(<<~RUBY)
          some_method(
                     )
        RUBY
      end
    end

    context 'with first multiline arg on new line' do
      it 'accepts ) on the same level as ( with args on same line' do
        expect_no_offenses(<<~RUBY)
          where(
            "multiline
             condition", second_arg
          )
        RUBY
      end

      it 'accepts ) on the same level as ( with second arg on new line' do
        expect_no_offenses(<<~RUBY)
          where(
            "multiline
             condition",
            second_arg
          )
        RUBY
      end
    end
  end

  context 'for method assignments with indented parameters' do
    context 'with line break before 1st parameter' do
      it 'registers an offense for misaligned )' do
        expect_offense(<<~RUBY)
          foo = some_method(
                             a
            )
            ^ Align `)` with `(`.
        RUBY

        expect_correction(<<~RUBY)
          foo = some_method(
                             a
                           )
        RUBY
      end

      it 'accepts a correctly aligned )' do
        expect_no_offenses(<<~RUBY)
          foo = some_method(
                             a
                           )
        RUBY
      end
    end

    context 'with no line break before 1st parameter' do
      it 'registers an offense for misaligned )' do
        expect_offense(<<~RUBY)
          foo = some_method(a
          )
          ^ Align `)` with `(`.
          some_method(a,
                      x: 1,
                      y: 2
                      )
                      ^ Align `)` with `(`.
        RUBY

        expect_correction(<<~RUBY)
          foo = some_method(a
                           )
          some_method(a,
                      x: 1,
                      y: 2
                     )
        RUBY
      end

      it 'can handle inner method calls' do
        expect_no_offenses(<<~RUBY)
          expect(response).to contain_exactly(
                                { a: 1, b: 'x' },
                                { a: 2, b: 'y' }
                              )
        RUBY
      end

      it 'can handle individual arguments that are broken over lines' do
        expect_no_offenses(<<~RUBY)
          corrector.insert_before(
            range,
            "\n" + ' ' * (node.loc.keyword.column +
                          indent_steps * configured_width)
          )
        RUBY
      end

      it 'can handle indentation up against the left edge' do
        expect_no_offenses(<<~RUBY)
          foo(
          a: b
          )
        RUBY
      end

      it 'can handle hash arguments that are not broken over lines' do
        expect_no_offenses(<<~RUBY)
          corrector.insert_before(
                                   range,
                                   arg_1: 'foo', arg_2: 'bar'
                                 )
        RUBY
      end

      it 'accepts a correctly aligned )' do
        expect_no_offenses(<<~RUBY)
          foo = some_method(a
                           )
        RUBY
      end

      it 'accepts a correctly indented )' do
        expect_no_offenses(<<~RUBY)
          foo = some_method(a,
                            x: 1,
                            y: 2
                           )
          b =
            some_method(a,
                       )
        RUBY
      end
    end

    context 'without arguments' do
      it 'accepts empty ()' do
        expect_no_offenses('foo = some_method()')
      end

      it 'accepts a correctly aligned ) against (' do
        expect_no_offenses(<<~RUBY)
          foo = some_method(
                           )
        RUBY
      end

      it 'can handle indentation up against the left edge' do
        expect_no_offenses(<<~RUBY)
          foo = some_method(
          )
        RUBY
      end

      it 'can handle indentation up against the method' do
        expect_no_offenses(<<~RUBY)
          foo = some_method(
                )
        RUBY
      end

      it 'registers an offense for misaligned )' do
        expect_offense(<<~RUBY)
          foo = some_method(
            )
            ^ Indent `)` to column 0 (not 2)
        RUBY

        expect_correction(<<~RUBY)
          foo = some_method(
          )
        RUBY
      end
    end
  end

  context 'for method chains' do
    it 'can handle multiple chains with differing breaks' do
      expect_no_offenses(<<~RUBY)
        good = foo.methA(:arg1, :arg2, options: :hash)
                 .methB(
                   :arg1,
                   :arg2,
                 )
                 .methC

        good = foo.methA(
                   :arg1,
                   :arg2,
                   options: :hash,
                 )
                 .methB(
                   :arg1,
                   :arg2,
                 )
                 .methC
      RUBY
    end

    it 'registers an offense and corrects method chains' do
      expect_offense(<<~RUBY)
        good = foo.methA(:arg1, :arg2, options: :hash)
                 .methB(
                   :arg1,
                   :arg2,
             )
             ^ Indent `)` to column 9 (not 5)
                 .methC

        good = foo.methA(
                   :arg1,
                   :arg2,
                   options: :hash,
            )
            ^ Indent `)` to column 9 (not 4)
                 .methB(
                   :arg1,
                   :arg2,
               )
               ^ Indent `)` to column 9 (not 7)
                 .methC
      RUBY

      expect_correction(<<~RUBY)
        good = foo.methA(:arg1, :arg2, options: :hash)
                 .methB(
                   :arg1,
                   :arg2,
                 )
                 .methC

        good = foo.methA(
                   :arg1,
                   :arg2,
                   options: :hash,
                 )
                 .methB(
                   :arg1,
                   :arg2,
                 )
                 .methC
      RUBY
    end

    context 'when using safe navigation operator' do
      it 'registers an offense and corrects misaligned )' do
        expect_offense(<<~RUBY)
          receiver&.some_method(
            a
            )
            ^ Indent `)` to column 0 (not 2)
        RUBY

        expect_correction(<<~RUBY)
          receiver&.some_method(
            a
          )
        RUBY
      end
    end
  end

  context 'for method definitions' do
    context 'with line break before 1st parameter' do
      it 'registers an offense for misaligned )' do
        expect_offense(<<~RUBY)
          def some_method(
            a
            )
            ^ Indent `)` to column 0 (not 2)
          end
        RUBY

        expect_correction(<<~RUBY)
          def some_method(
            a
          )
          end
        RUBY
      end

      it 'accepts a correctly aligned )' do
        expect_no_offenses(<<~RUBY)
          def some_method(
            a
          )
          end
        RUBY
      end
    end

    context 'with no line break before 1st parameter' do
      it 'registers an offense for misaligned )' do
        expect_offense(<<~RUBY)
          def some_method(a
          )
          ^ Align `)` with `(`.
          end
        RUBY

        expect_correction(<<~RUBY)
          def some_method(a
                         )
          end
        RUBY
      end

      it 'accepts a correctly aligned )' do
        expect_no_offenses(<<~RUBY)
          def some_method(a
                         )
          end
        RUBY
      end

      it 'accepts empty ()' do
        expect_no_offenses(<<~RUBY)
          def some_method()
          end
        RUBY
      end
    end
  end

  context 'for grouped expressions' do
    context 'with line break before 1st operand' do
      it 'registers an offense for misaligned )' do
        expect_offense(<<~RUBY)
          w = x * (
            y + z
            )
            ^ Indent `)` to column 0 (not 2)
        RUBY

        expect_correction(<<~RUBY)
          w = x * (
            y + z
          )
        RUBY
      end

      it 'accepts a correctly aligned )' do
        expect_no_offenses(<<~RUBY)
          w = x * (
            y + z
          )
        RUBY
      end
    end

    context 'with no line break before 1st operand' do
      it 'registers an offense for misaligned )' do
        expect_offense(<<~RUBY)
          w = x * (y + z
          )
          ^ Align `)` with `(`.
        RUBY

        expect_correction(<<~RUBY)
          w = x * (y + z
                  )
        RUBY
      end

      it 'accepts a correctly aligned )' do
        expect_no_offenses(<<~RUBY)
          w = x * (y + z
                  )
        RUBY
      end

      it 'accepts ) that does not begin its line' do
        expect_no_offenses(<<~RUBY)
          w = x * (y + z +
                  a)
        RUBY
      end
    end
  end

  it 'accepts begin nodes that are not grouped expressions' do
    expect_no_offenses(<<~RUBY)
      def a
        x
        y
      end
    RUBY
  end
end
