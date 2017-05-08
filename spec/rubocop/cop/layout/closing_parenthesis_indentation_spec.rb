# frozen_string_literal: true

describe RuboCop::Cop::Layout::ClosingParenthesisIndentation do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    RuboCop::Config.new('Layout/AlignParameters' => {
                          'EnforcedStyle' => align_parameters_config
                        })
  end
  let(:align_parameters_config) { 'with_first_parameter' }

  context 'for method calls' do
    context 'with line break before 1st parameter' do
      it 'registers an offense for misaligned )' do
        expect_offense(<<-RUBY.strip_indent)
          some_method(
            a
            )
            ^ Indent `)` the same as the start of the line where `(` is.
        RUBY
      end

      it 'autocorrects misaligned )' do
        corrected = autocorrect_source(cop, <<-END.strip_indent)
          some_method(
            a
            )
        END
        expect(corrected).to eq <<-END.strip_indent
          some_method(
            a
          )
        END
      end

      it 'accepts a correctly aligned )' do
        expect_no_offenses(<<-END.strip_indent)
          some_method(
            a
          )
        END
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
        corrected = autocorrect_source(cop, <<-END.strip_indent)
          some_method(a
          )
        END
        expect(corrected).to eq <<-END.strip_indent
          some_method(a
                     )
        END
      end

      it 'accepts a correctly aligned )' do
        expect_no_offenses(<<-END.strip_indent)
          some_method(a
                     )
        END
      end

      it 'accepts empty ()' do
        expect_no_offenses('some_method()')
      end

      context 'with fixed indentation of parameters' do
        let(:align_parameters_config) { 'with_fixed_indentation' }

        it 'accepts a correctly indented )' do
          expect_no_offenses(<<-END.strip_indent)
            some_method(a,
              x: 1,
              y: 2
            )
            b =
              some_method(a,
              )
          END
        end

        it 'autocorrects misindented )' do
          corrected = autocorrect_source(cop, <<-END.strip_indent)
            some_method(a,
              x: 1,
              y: 2
                       )
            b =
              some_method(a,
                         )
          END
          expect(corrected).to eq <<-END.strip_indent
            some_method(a,
              x: 1,
              y: 2
            )
            b =
              some_method(a,
              )
          END
        end
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
            ^ Indent `)` the same as the start of the line where `(` is.
          end
        RUBY
      end

      it 'autocorrects misaligned )' do
        corrected = autocorrect_source(cop, <<-END.strip_indent)
          def some_method(
            a
            )
          end
        END
        expect(corrected).to eq <<-END.strip_indent
          def some_method(
            a
          )
          end
        END
      end

      it 'accepts a correctly aligned )' do
        expect_no_offenses(<<-END.strip_indent)
          def some_method(
            a
          )
          end
        END
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
        corrected = autocorrect_source(cop, <<-END.strip_indent)
          def some_method(a
          )
          end
        END
        expect(corrected).to eq <<-END.strip_indent
          def some_method(a
                         )
          end
        END
      end

      it 'accepts a correctly aligned )' do
        expect_no_offenses(<<-END.strip_indent)
          def some_method(a
                         )
          end
        END
      end

      it 'accepts empty ()' do
        expect_no_offenses(<<-END.strip_indent)
          def some_method()
          end
        END
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
            ^ Indent `)` the same as the start of the line where `(` is.
        RUBY
      end

      it 'autocorrects misaligned )' do
        corrected = autocorrect_source(cop, <<-END.strip_indent)
          w = x * (
            y + z
            )
        END
        expect(corrected).to eq <<-END.strip_indent
          w = x * (
            y + z
          )
        END
      end

      it 'accepts a correctly aligned )' do
        expect_no_offenses(<<-END.strip_indent)
          w = x * (
            y + z
          )
        END
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
        corrected = autocorrect_source(cop, <<-END.strip_indent)
          w = x * (y + z
            )
        END
        expect(corrected).to eq <<-END.strip_indent
          w = x * (y + z
                  )
        END
      end

      it 'accepts a correctly aligned )' do
        expect_no_offenses(<<-END.strip_indent)
          w = x * (y + z
                  )
        END
      end

      it 'accepts ) that does not begin its line' do
        expect_no_offenses(<<-END.strip_indent)
          w = x * (y + z +
                  a)
        END
      end
    end
  end

  it 'accepts begin nodes that are not grouped expressions' do
    expect_no_offenses(<<-END.strip_indent)
      def a
        x
        y
      end
    END
  end
end
