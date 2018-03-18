# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::ClosingParenthesisIndentation do
  subject(:cop) { described_class.new }

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

      it 'accepts empty ()' do
        expect_no_offenses('some_method()')
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

      it 'accepts empty ()' do
        expect_no_offenses('foo = some_method()')
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
end
