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
        inspect_source(cop, <<-END.strip_indent)
          some_method(
            a
            )
        END
        expect(cop.messages)
          .to eq(['Indent `)` the same as the start of the line where `(` is.'])
        expect(cop.highlights).to eq([')'])
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
        inspect_source(cop, <<-END.strip_indent)
          some_method(
            a
          )
        END
        expect(cop.offenses).to be_empty
      end
    end

    context 'with no line break before 1st parameter' do
      it 'registers an offense for misaligned )' do
        inspect_source(cop, <<-END.strip_indent)
          some_method(a
          )
        END
        expect(cop.messages).to eq(['Align `)` with `(`.'])
        expect(cop.highlights).to eq([')'])
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
        inspect_source(cop, <<-END.strip_indent)
          some_method(a
                     )
        END
        expect(cop.offenses).to be_empty
      end

      it 'accepts empty ()' do
        inspect_source(cop, 'some_method()')
        expect(cop.offenses).to be_empty
      end

      context 'with fixed indentation of parameters' do
        let(:align_parameters_config) { 'with_fixed_indentation' }

        it 'accepts a correctly indented )' do
          inspect_source(cop, <<-END.strip_indent)
            some_method(a,
              x: 1,
              y: 2
            )
            b =
              some_method(a,
              )
          END
          expect(cop.offenses).to be_empty
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
        inspect_source(cop, <<-END.strip_indent)
          def some_method(
            a
            )
          end
        END
        expect(cop.messages)
          .to eq(['Indent `)` the same as the start of the line where `(` is.'])
        expect(cop.highlights).to eq([')'])
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
        inspect_source(cop, <<-END.strip_indent)
          def some_method(
            a
          )
          end
        END
        expect(cop.offenses).to be_empty
      end
    end

    context 'with no line break before 1st parameter' do
      it 'registers an offense for misaligned )' do
        inspect_source(cop, <<-END.strip_indent)
          def some_method(a
          )
          end
        END
        expect(cop.messages).to eq(['Align `)` with `(`.'])
        expect(cop.highlights).to eq([')'])
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
        inspect_source(cop, <<-END.strip_indent)
          def some_method(a
                         )
          end
        END
        expect(cop.offenses).to be_empty
      end

      it 'accepts empty ()' do
        inspect_source(cop, <<-END.strip_indent)
          def some_method()
          end
        END
        expect(cop.offenses).to be_empty
      end
    end
  end

  context 'for grouped expressions' do
    context 'with line break before 1st operand' do
      it 'registers an offense for misaligned )' do
        inspect_source(cop, <<-END.strip_indent)
          w = x * (
            y + z
            )
        END
        expect(cop.messages)
          .to eq(['Indent `)` the same as the start of the line where `(` is.'])
        expect(cop.highlights).to eq([')'])
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
        inspect_source(cop, <<-END.strip_indent)
          w = x * (
            y + z
          )
        END
        expect(cop.offenses).to be_empty
      end
    end

    context 'with no line break before 1st operand' do
      it 'registers an offense for misaligned )' do
        inspect_source(cop, <<-END.strip_indent)
          w = x * (y + z
          )
        END
        expect(cop.messages).to eq(['Align `)` with `(`.'])
        expect(cop.highlights).to eq([')'])
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
        inspect_source(cop, <<-END.strip_indent)
          w = x * (y + z
                  )
        END
        expect(cop.offenses).to be_empty
      end

      it 'accepts ) that does not begin its line' do
        inspect_source(cop, <<-END.strip_indent)
          w = x * (y + z +
                  a)
        END
        expect(cop.offenses).to be_empty
      end
    end
  end

  it 'accepts begin nodes that are not grouped expressions' do
    inspect_source(cop, <<-END.strip_indent)
      def a
        x
        y
      end
    END
    expect(cop.offenses).to be_empty
  end
end
