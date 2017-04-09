# frozen_string_literal: true

describe RuboCop::Cop::Style::RescueEnsureAlignment do
  subject(:cop) { described_class.new }

  shared_examples 'common behavior' do |keyword|
    context 'bad alignment' do
      it 'registers an offense when used with begin' do
        inspect_source(cop, <<-END.strip_indent)
          begin
            something
              #{keyword}
              error
          end
        END
        expect(cop.messages).to eq(["`#{keyword}` at 3, 4 is not aligned with" \
                                    ' `end` at 5, 0.'])
      end

      it 'registers an offense when used with def' do
        inspect_source(cop, <<-END.strip_indent)
          def test
            something
              #{keyword}
              error
          end
        END
        expect(cop.messages).to eq(["`#{keyword}` at 3, 4 is not aligned with" \
                                    ' `end` at 5, 0.'])
      end

      it 'registers an offense when used with defs' do
        inspect_source(cop, <<-END.strip_indent)
          def Test.test
            something
              #{keyword}
              error
          end
        END
        expect(cop.messages).to eq(["`#{keyword}` at 3, 4 is not aligned with" \
                                    ' `end` at 5, 0.'])
      end

      it 'registers an offense when used with class' do
        inspect_source(cop, <<-END.strip_indent)
          class C
            something
              #{keyword}
              error
          end
        END
        expect(cop.messages).to eq(["`#{keyword}` at 3, 4 is not aligned with" \
                                    ' `end` at 5, 0.'])
      end

      it 'registers an offense when used with module' do
        inspect_source(cop, <<-END.strip_indent)
          module M
            something
              #{keyword}
              error
          end
        END
        expect(cop.messages).to eq(["`#{keyword}` at 3, 4 is not aligned with" \
                                    ' `end` at 5, 0.'])
      end

      it 'accepts rescue and ensure on the same line' do
        inspect_source(cop, 'begin; puts 1; rescue; ensure; puts 2; end')

        expect(cop.messages).to be_empty
      end

      it 'auto-corrects' do
        corrected = autocorrect_source(cop, <<-END.strip_indent)
          begin
            something
              #{keyword}
              error
          end
        END
        expect(corrected).to eq(<<-END.strip_indent)
          begin
            something
          #{keyword}
              error
          end
        END
      end
    end

    it 'accepts correct alignment' do
      inspect_source(cop, ['begin',
                           '  something',
                           keyword,
                           '    error',
                           'end'])
      expect(cop.messages).to be_empty
    end
  end

  context 'rescue' do
    it_behaves_like 'common behavior', 'rescue'

    it 'accepts the modifier form' do
      inspect_source(cop, 'test rescue nil')
      expect(cop.messages).to be_empty
    end
  end

  context 'ensure' do
    it_behaves_like 'common behavior', 'ensure'
  end

  describe 'excluded file' do
    let(:config) do
      RuboCop::Config.new('Style/RescueEnsureAlignment' =>
                          { 'Enabled' => true,
                            'Exclude' => ['**/**'] })
    end

    subject(:cop) { described_class.new(config) }

    it 'processes excluded files with issue' do
      inspect_source_file(cop, <<-END.strip_indent)
        begin
          foo
        rescue
          bar
        end
      END

      expect(cop.messages).to be_empty
    end
  end
end
