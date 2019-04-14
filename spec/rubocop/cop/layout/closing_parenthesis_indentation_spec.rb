# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::ClosingParenthesisIndentation do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new('Layout/ClosingParenthesisIndentation' => cop_config)
  end
  let(:cop_config) do
    {} # default config
  end

  context 'for method calls' do
    context 'with line break before 1st parameter' do
      it 'registers an offense for misaligned )' do
        expect_offense(<<-RUBY.strip_indent)
          some_method(
            a
            )
            ^ Indent `)` to column 0 (not 2)
        RUBY
      end

      it 'autocorrects misaligned )' do
        corrected = autocorrect_source(<<-RUBY.strip_indent)
          some_method(
            a
            )
        RUBY
        expect(corrected).to eq <<-RUBY.strip_indent
          some_method(
            a
          )
        RUBY
      end

      it 'accepts a correctly aligned )' do
        expect_no_offenses(<<-RUBY.strip_indent)
          some_method(
            a
          )
        RUBY
      end
    end

    context 'with no line break before 1st parameter' do
      it 'registers an offense for misaligned )' do
        expect_offense(<<-RUBY.strip_indent)
          some_method(a
          )
          ^ Align `)` with `(`.
        RUBY
      end

      it 'autocorrects misaligned )' do
        corrected = autocorrect_source(<<-RUBY.strip_indent)
          some_method(a
          )
        RUBY
        expect(corrected).to eq <<-RUBY.strip_indent
          some_method(a
                     )
        RUBY
      end

      it 'accepts a correctly aligned )' do
        expect_no_offenses(<<-RUBY.strip_indent)
          some_method(a
                     )
        RUBY
      end

      it 'accepts a correctly indented )' do
        expect_no_offenses(<<-RUBY.strip_indent)
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
        expect_no_offenses(<<-RUBY.strip_indent)
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

      it 'autocorrects misindented )' do
        corrected = autocorrect_source(<<-RUBY.strip_indent)
          some_method(a,
            x: 1,
            y: 2
                      )
          b =
            some_method(a,
                        )
        RUBY
        expect(corrected).to eq <<-RUBY.strip_indent
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
        expect_no_offenses(<<-RUBY.strip_indent)
          some_method(
          )
        RUBY
      end

      it 'accepts a correctly aligned ) against (' do
        expect_no_offenses(<<-RUBY.strip_indent)
          some_method(
                     )
        RUBY
      end
    end

    context 'with first multiline arg on new line' do
      it 'accepts ) on the same level as ( with args on same line' do
        expect_no_offenses(<<-RUBY.strip_indent)
          where(
            "multiline
             condition", second_arg
          )
        RUBY
      end

      it 'accepts ) on the same level as ( with second arg on new line' do
        expect_no_offenses(<<-RUBY.strip_indent)
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
        expect_offense(<<-RUBY.strip_indent)
          foo = some_method(
                             a
            )
            ^ Align `)` with `(`.
        RUBY
      end

      it 'autocorrects misaligned )' do
        corrected = autocorrect_source(<<-RUBY.strip_indent)
          foo = some_method(
                             a
            )
        RUBY
        expect(corrected).to eq <<-RUBY.strip_indent
          foo = some_method(
                             a
                           )
        RUBY
      end

      it 'accepts a correctly aligned )' do
        expect_no_offenses(<<-RUBY.strip_indent)
          foo = some_method(
                             a
                           )
        RUBY
      end
    end

    context 'with no line break before 1st parameter' do
      it 'registers an offense for misaligned )' do
        expect_offense(<<-RUBY.strip_indent)
          foo = some_method(a
          )
          ^ Align `)` with `(`.
        RUBY
      end

      it 'can handle inner method calls' do
        expect_no_offenses(<<-RUBY.strip_indent)
          expect(response).to contain_exactly(
                                { a: 1, b: 'x' },
                                { a: 2, b: 'y' }
                              )
        RUBY
      end

      it 'can handle individual arguments that are broken over lines' do
        expect_no_offenses(<<-RUBY.strip_indent)
          corrector.insert_before(
            range,
            "\n" + ' ' * (node.loc.keyword.column +
                          indent_steps * configured_width)
          )
        RUBY
      end

      it 'can handle indentation up against the left edge' do
        expect_no_offenses(<<-RUBY.strip_indent)
          foo(
          a: b
          )
        RUBY
      end

      it 'can handle hash arguments that are not broken over lines' do
        expect_no_offenses(<<-RUBY.strip_indent)
          corrector.insert_before(
                                   range,
                                   arg_1: 'foo', arg_2: 'bar'
                                 )
        RUBY
      end

      it 'autocorrects misaligned )' do
        corrected = autocorrect_source(<<-RUBY.strip_indent)
          foo = some_method(a
          )
        RUBY
        expect(corrected).to eq <<-RUBY.strip_indent
          foo = some_method(a
                           )
        RUBY
      end

      it 'accepts a correctly aligned )' do
        expect_no_offenses(<<-RUBY.strip_indent)
          foo = some_method(a
                           )
        RUBY
      end
      it 'accepts a correctly indented )' do
        expect_no_offenses(<<-RUBY.strip_indent)
          foo = some_method(a,
                            x: 1,
                            y: 2
                           )
          b =
            some_method(a,
                       )
        RUBY
      end

      it 'autocorrects misindented )' do
        corrected = autocorrect_source(<<-RUBY.strip_indent)
          some_method(a,
                      x: 1,
                      y: 2
                      )
          b =
            some_method(a,
                        )
        RUBY
        expect(corrected).to eq <<-RUBY.strip_indent
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
        expect_no_offenses('foo = some_method()')
      end

      it 'accepts a correctly aligned ) against (' do
        expect_no_offenses(<<-RUBY.strip_indent)
          foo = some_method(
                           )
        RUBY
      end

      it 'can handle indentation up against the left edge' do
        expect_no_offenses(<<-RUBY.strip_indent)
          foo = some_method(
          )
        RUBY
      end

      it 'can handle indentation up against the method' do
        expect_no_offenses(<<-RUBY.strip_indent)
          foo = some_method(
                )
        RUBY
      end

      it 'registers an offense for misaligned )' do
        expect_offense(<<-RUBY.strip_indent)
          foo = some_method(
            )
            ^ Indent `)` to column 0 (not 2)
        RUBY

        expect_correction(<<-RUBY.strip_indent)
          foo = some_method(
          )
        RUBY
      end
    end
  end

  context 'for method chains' do
    it 'can handle multiple chains with differing breaks' do
      expect_no_offenses(<<-RUBY.strip_indent)
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

    it 'can autocorrect method chains' do
      corrected = autocorrect_source(<<-RUBY.strip_indent)
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

      expect(corrected).to eq <<-RUBY.strip_indent
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

    context 'when using safe navigation operator', :ruby23 do
      it 'registers an offense for misaligned )' do
        expect_offense(<<-RUBY.strip_indent)
          receiver&.some_method(
            a
            )
            ^ Indent `)` to column 0 (not 2)
        RUBY
      end
    end
  end

  context 'for method definitions' do
    context 'with line break before 1st parameter' do
      it 'registers an offense for misaligned )' do
        expect_offense(<<-RUBY.strip_indent)
          def some_method(
            a
            )
            ^ Indent `)` to column 0 (not 2)
          end
        RUBY
      end

      it 'autocorrects misaligned )' do
        corrected = autocorrect_source(<<-RUBY.strip_indent)
          def some_method(
            a
            )
          end
        RUBY
        expect(corrected).to eq <<-RUBY.strip_indent
          def some_method(
            a
          )
          end
        RUBY
      end

      it 'accepts a correctly aligned )' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def some_method(
            a
          )
          end
        RUBY
      end
    end

    context 'with no line break before 1st parameter' do
      it 'registers an offense for misaligned )' do
        expect_offense(<<-RUBY.strip_indent)
          def some_method(a
          )
          ^ Align `)` with `(`.
          end
        RUBY
      end

      it 'autocorrects misaligned )' do
        corrected = autocorrect_source(<<-RUBY.strip_indent)
          def some_method(a
          )
          end
        RUBY
        expect(corrected).to eq <<-RUBY.strip_indent
          def some_method(a
                         )
          end
        RUBY
      end

      it 'accepts a correctly aligned )' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def some_method(a
                         )
          end
        RUBY
      end

      it 'accepts empty ()' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def some_method()
          end
        RUBY
      end
    end
  end

  context 'for grouped expressions' do
    context 'with line break before 1st operand' do
      it 'registers an offense for misaligned )' do
        expect_offense(<<-RUBY.strip_indent)
          w = x * (
            y + z
            )
            ^ Indent `)` to column 0 (not 2)
        RUBY
      end

      it 'autocorrects misaligned )' do
        corrected = autocorrect_source(<<-RUBY.strip_indent)
          w = x * (
            y + z
            )
        RUBY
        expect(corrected).to eq <<-RUBY.strip_indent
          w = x * (
            y + z
          )
        RUBY
      end

      it 'accepts a correctly aligned )' do
        expect_no_offenses(<<-RUBY.strip_indent)
          w = x * (
            y + z
          )
        RUBY
      end
    end

    context 'with no line break before 1st operand' do
      it 'registers an offense for misaligned )' do
        expect_offense(<<-RUBY.strip_indent)
          w = x * (y + z
          )
          ^ Align `)` with `(`.
        RUBY
      end

      it 'autocorrects misaligned )' do
        corrected = autocorrect_source(<<-RUBY.strip_indent)
          w = x * (y + z
            )
        RUBY
        expect(corrected).to eq <<-RUBY.strip_indent
          w = x * (y + z
                  )
        RUBY
      end

      it 'accepts a correctly aligned )' do
        expect_no_offenses(<<-RUBY.strip_indent)
          w = x * (y + z
                  )
        RUBY
      end

      it 'accepts ) that does not begin its line' do
        expect_no_offenses(<<-RUBY.strip_indent)
          w = x * (y + z +
                  a)
        RUBY
      end
    end
  end

  it 'accepts begin nodes that are not grouped expressions' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def a
        x
        y
      end
    RUBY
  end

  context 'beginning_of_first_line mode' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'beginning_of_first_line' }
    end

    context 'method calls' do
      context 'strangely aligned method params' do
        it 'does not add any offenses' do
          expect_no_offenses(
            <<-RUBY
              expect(foo.find_by(
                 bar: 1,
                    bat: 2,
              )).to eq(nil)
            RUBY
          )
        end
      end

      context 'when one line' do
        it 'does not add any offenses' do
          expect_no_offenses(
            <<-RUBY
              taz("abc", "def")
            RUBY
          )
        end
      end

      context 'when no args' do
        it 'does not add any offenses' do
          expect_no_offenses(
            <<-RUBY
              taz()
            RUBY
          )
        end
      end

      context 'when no parens' do
        it 'does not add any offenses' do
          expect_no_offenses(
            <<-RUBY
              taz "abc",
               "def"
            RUBY
          )
        end
      end

      context 'when paren is on ending line' do
        it 'does not add any offenses' do
          expect_no_offenses(
            <<-RUBY
              taz("abc",
               "def")
            RUBY
          )
        end
      end

      context 'when paren on ending line and first arg is on new line' do
        it 'does not add any offenses' do
          expect_no_offenses(
            <<-RUBY
              taz(
               "abc",
               "123",
               "345",
               "def",  )
            RUBY
          )
        end
      end

      context 'when no args' do
        it 'does not add any offenses' do
          expect_no_offenses(
            <<-RUBY
              foo.to eq 1
            RUBY
          )
        end
      end

      context 'when multiple calls on separate lines' do
        it 'does not add any offenses' do
          expect_no_offenses(
            <<-RUBY
              allow(obj).to(
                receive(:message).and_throw(:this_symbol)
              )
            RUBY
          )
        end
      end

      context 'when method and object are on different lines' do
        it 'does not add any offenses' do
          expect_no_offenses(
            <<-RUBY
              foo(:bar)
                .bar(:baz)
            RUBY
          )
        end
      end

      context 'when method and object on different lines with nested calls' do
        it 'does not add any offenses' do
          expect_no_offenses(
            <<-RUBY
              allow(obj)
                .to(receive(:message))
            RUBY
          )
        end
      end

      context 'when hash args with braces' do
        it 'does not add any offenses' do
          expect_no_offenses(
            <<-RUBY
              taz({
                    a: "abc",
                    b: "def",
              })
            RUBY
          )
        end
      end

      context 'when hash args without braces' do
        it 'does not add any offenses' do
          expect_no_offenses(
            <<-RUBY
              taz(
                    a: "abc",
                    b: "def",
              )
            RUBY
          )
        end
      end

      context 'when do block' do
        it 'does not add any offenses' do
          expect_no_offenses(
            <<-RUBY
              context 'when do block' do
                it 'something' do
                  foo.bar(2)
                end
              end
            RUBY
          )
        end
      end

      context 'when eq on other line' do
        it 'does not add any offenses' do
          expect_no_offenses(
            <<-RUBY
              expect(new_source).to eq(
                something
              )
            RUBY
          )
        end
      end

      context 'when paren isnt indented enough' do
        it 'adds an offense' do
          expect_offense(
            <<-RUBY
                taz(
                  "abc",
                  "foo",
              )
              ^ Indent `)` to align with the beginning of the first line containing the expression.
            RUBY
          )
        end

        it 'autocorrects the offense' do
          new_source = autocorrect_source(
            <<-RUBY
                taz(
                  "abc",
                  "foo",
              )
            RUBY
          )

          expect(new_source).to eq(
            <<-RUBY
              \s\staz(
              \s\s  "abc",
              \s\s  "foo",
              \s\s)
            RUBY
          )
        end
      end

      context 'when paren is indented too much' do
        it 'adds an offense' do
          expect_offense(
            <<-RUBY
              taz(
                  "abc",
                  "foo",
                    )
                    ^ Indent `)` to align with the beginning of the first line containing the expression.
            RUBY
          )
        end

        it 'autocorrects the offense' do
          new_source = autocorrect_source(
            <<-RUBY
              taz(
                  "abc",
                  "foo",
                    )
            RUBY
          )

          expect(new_source).to eq(
            <<-RUBY
              taz(
                  "abc",
                  "foo",
              )
            RUBY
          )
        end
      end

      context 'when paren is indented too much and all params on same line' do
        it 'adds an offense' do
          expect_offense(
            <<-RUBY
              taz("abc", "foo",
                    )
                    ^ Indent `)` to align with the beginning of the first line containing the expression.
            RUBY
          )
        end

        it 'autocorrects the offense' do
          new_source = autocorrect_source(
            <<-RUBY
              taz("abc", "foo",
                    )
            RUBY
          )

          expect(new_source).to eq(
            <<-RUBY
              taz("abc", "foo",
              )
            RUBY
          )
        end
      end

      context 'when paren is indented not enough and params aligned' do
        it 'adds an offense' do
          expect_offense(
            <<-RUBY
              taz("abc",
                  "foo",
                    )
                    ^ Indent `)` to align with the beginning of the first line containing the expression.
            RUBY
          )
        end

        it 'autocorrects the offense' do
          new_source = autocorrect_source(
            <<-RUBY
              taz("abc",
                  "foo",
                    )
            RUBY
          )

          expect(new_source).to eq(
            <<-RUBY
              taz("abc",
                  "foo",
              )
            RUBY
          )
        end
      end
    end

    context 'paren expressions' do
      context 'when eq on other line' do
        it 'does not add any offenses' do
          expect_no_offenses(
            <<-RUBY
              foo = (
                something
              )
            RUBY
          )
        end
      end

      context 'when paren isnt indented enough' do
        it 'adds an offense' do
          expect_offense(
            <<-RUBY
              foo = (
                something
            )
            ^ Indent `)` to align with the beginning of the first line containing the expression.
            RUBY
          )
        end

        it 'autocorrects the offense' do
          new_source = autocorrect_source(
            <<-RUBY
              foo = (
                something
            )
            RUBY
          )

          expect(new_source).to eq(
            <<-RUBY
              foo = (
                something
              )
            RUBY
          )
        end
      end
    end

    context 'method definitions' do
      context 'when eq on other line' do
        it 'does not add any offenses' do
          expect_no_offenses(
            <<-RUBY
              def foo(
                something
              )
                something_else
              end
            RUBY
          )
        end
      end

      context 'when paren isnt indented enough' do
        it 'adds an offense' do
          expect_offense(
            <<-RUBY
              def foo(
                something
            )
            ^ Indent `)` to align with the beginning of the first line containing the expression.
                something_else
              end
            RUBY
          )
        end

        it 'autocorrects the offense' do
          new_source = autocorrect_source(
            <<-RUBY
              def foo(
                something
            )
                something_else
              end
            RUBY
          )

          expect(new_source).to eq(
            <<-RUBY
              def foo(
                something
              )
                something_else
              end
            RUBY
          )
        end
      end
    end
  end
end
