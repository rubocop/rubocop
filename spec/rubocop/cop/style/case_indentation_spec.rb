# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::CaseIndentation do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    merged = RuboCop::ConfigLoader
             .default_configuration['Style/CaseIndentation'].merge(cop_config)
    RuboCop::Config.new('Style/CaseIndentation' => merged,
                        'Style/IndentationWidth' => { 'Width' => 2 })
  end

  context 'with EnforcedStyle: case' do
    context 'with IndentOneStep: false' do
      let(:cop_config) do
        { 'EnforcedStyle' => 'case', 'IndentOneStep' => false }
      end

      context 'regarding assignment where the right hand side is a case' do
        let(:correct_source) do
          ['output = case variable',
           "         when 'value1'",
           "  'output1'",
           'else',
           "  'output2'",
           'end']
        end

        let(:source) do
          ['output = case variable',
           "         when 'value1'",
           "           'output1'",
           '         else',
           "           'output2'",
           '         end']
        end

        it 'accepts a correctly indented assignment' do
          inspect_source(cop, source)
          expect(cop.offenses).to be_empty
        end

        context 'an assignment indented as end' do
          let(:source) do
            ['output = case variable',
             "when 'value1'",
             "  'output1'",
             'else',
             "  'output2'",
             'end']
          end

          it 'registers an offense' do
            inspect_source(cop, source)
            expect(cop.messages).to eq(['Indent `when` as deep as `case`.'])
            expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' =>
                                                       'end')
          end

          it 'does auto-correction' do
            corrected = autocorrect_source(cop, source)
            expect(corrected).to eq correct_source.join("\n")
          end
        end

        context 'an assignment indented some other way' do
          let(:source) do
            ['output = case variable',
             "  when 'value1'",
             "    'output1'",
             '  else',
             "    'output2'",
             'end']
          end

          let(:correct_source) do
            ['output = case variable',
             "         when 'value1'",
             "    'output1'",
             '  else',
             "    'output2'",
             'end']
          end

          it 'registers an offense' do
            inspect_source(cop, source)
            expect(cop.messages).to eq(['Indent `when` as deep as `case`.'])
            expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
          end

          it 'does auto-correction' do
            corrected = autocorrect_source(cop, source)
            expect(corrected).to eq correct_source.join("\n")
          end
        end

        context 'correct + opposite' do
          let(:source) do
            ['output = case variable',
             "         when 'value1'",
             "           'output1'",
             '         else',
             "           'output2'",
             '         end',
             'output = case variable',
             "when 'value1'",
             "  'output1'",
             'else',
             "  'output2'",
             'end']
          end

          let(:correct_source) do
            ['output = case variable',
             "         when 'value1'",
             "           'output1'",
             '         else',
             "           'output2'",
             '         end',
             'output = case variable',
             "         when 'value1'",
             "  'output1'",
             'else',
             "  'output2'",
             'end']
          end

          it 'registers an offense' do
            inspect_source(cop, source)
            expect(cop.messages).to eq(['Indent `when` as deep as `case`.'])
            expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
          end

          it 'does auto-correction' do
            corrected = autocorrect_source(cop, source)
            expect(corrected).to eq(correct_source.join("\n"))
          end
        end
      end

      context "a when clause that's deeper than case" do
        let(:source) do
          ['case a',
           '    when 0 then return',
           '    else',
           '        case b',
           '         when 1 then return',
           '        end',
           'end']
        end

        it 'registers an offense' do
          inspect_source(cop, source)
          expect(cop.messages).to eq(['Indent `when` as deep as `case`.'] * 2)
        end

        it 'does auto-correction' do
          corrected = autocorrect_source(cop, source)
          expect(corrected).to eq(['case a',
                                   'when 0 then return',
                                   '    else',
                                   '        case b',
                                   '        when 1 then return',
                                   '        end',
                                   'end'].join("\n"))
        end
      end

      it "accepts a when clause that's equally indented with case" do
        source = ['y = case a',
                  '    when 0 then break',
                  '    when 0 then return',
                  '    else',
                  '      z = case b',
                  '          when 1 then return',
                  '          when 1 then break',
                  '          end',
                  '    end',
                  'case c',
                  'when 2 then encoding',
                  'end',
                  '']
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end

      it "doesn't get confused by strings with case in them" do
        source = ['a = "case"',
                  'case x',
                  'when 0',
                  'end',
                  '']
        inspect_source(cop, source)
        expect(cop.messages).to be_empty
      end

      it "doesn't get confused by symbols named case or when" do
        source = ['KEYWORDS = { :case => true, :when => true }',
                  'case type',
                  'when 0',
                  '  ParameterNode',
                  'when 1',
                  '  MethodCallNode',
                  'end',
                  '']
        inspect_source(cop, source)
        expect(cop.messages).to be_empty
      end

      it 'accepts correctly indented whens in complex combinations' do
        source = ['each {',
                  '  case state',
                  '  when 0',
                  '    case name',
                  '    when :a',
                  '    end',
                  '  when 1',
                  '    loop {',
                  '      case name',
                  '      when :b',
                  '      end',
                  '    }',
                  '  end',
                  '}',
                  'case s',
                  'when Array',
                  'end',
                  '']
        inspect_source(cop, source)
        expect(cop.messages).to be_empty
      end
    end

    context 'with IndentOneStep: true' do
      let(:cop_config) do
        { 'EnforcedStyle' => 'case', 'IndentOneStep' => true }
      end

      let(:correct_source) do
        ['output = case variable',
         "           when 'value1'",
         "             'output1'",
         '           else',
         "             'output2'",
         '         end']
      end

      context 'regarding assignment where the right hand side is a case' do
        it 'accepts a correctly indented assignment' do
          inspect_source(cop, correct_source)
          expect(cop.offenses).to be_empty
        end

        context 'an assignment indented some other way' do
          let(:source) do
            ['output = case variable',
             "         when 'value1'",
             "           'output1'",
             '         else',
             "           'output2'",
             '         end']
          end

          let(:correct_source) do
            ['output = case variable',
             "           when 'value1'",
             "           'output1'",
             '         else',
             "           'output2'",
             '         end']
          end

          it 'registers an offense' do
            inspect_source(cop, source)
            expect(cop.messages)
              .to eq(['Indent `when` one step more than `case`.'])
          end

          it 'does auto-correction' do
            corrected = autocorrect_source(cop, source)
            expect(corrected).to eq correct_source.join("\n")
          end
        end
      end

      it "accepts a when clause that's 2 spaces deeper than case" do
        source = ['case a',
                  '  when 0 then return',
                  '  else',
                  '        case b',
                  '          when 1 then return',
                  '        end',
                  'end']
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end

      context "a when clause that's equally indented with case" do
        let(:source) do
          ['y = case a',
           '    when 0 then break',
           '    when 0 then return',
           '      z = case b',
           '          when 1 then return',
           '          when 1 then break',
           '          end',
           '    end',
           'case c',
           'when 2 then encoding',
           'end',
           '']
        end

        it 'registers an offense' do
          inspect_source(cop, source)
          expect(cop.messages)
            .to eq(['Indent `when` one step more than `case`.'] * 5)
        end

        it 'does auto-correction' do
          corrected = autocorrect_source(cop, source)
          expect(corrected).to eq(['y = case a',
                                   '      when 0 then break',
                                   '      when 0 then return',
                                   '      z = case b',
                                   '            when 1 then return',
                                   '            when 1 then break',
                                   '          end',
                                   '    end',
                                   'case c',
                                   '  when 2 then encoding',
                                   'end',
                                   ''].join("\n"))
        end
      end

      context 'when indentation width is overridden for this cop only' do
        let(:cop_config) do
          {
            'EnforcedStyle' => 'case',
            'IndentOneStep' => true,
            'IndentationWidth' => 5
          }
        end

        let(:source) do
          ['output = case variable',
           "              when 'value1'",
           "             'output1'",
           '              else',
           "             'output2'",
           '         end']
        end

        it 'respects cop-specific IndentationWidth' do
          inspect_source(cop, source)
          expect(cop.offenses).to be_empty
        end
      end
    end
  end

  context 'with EnforcedStyle: end' do
    context 'with IndentOneStep: false' do
      let(:cop_config) do
        { 'EnforcedStyle' => 'end', 'IndentOneStep' => false }
      end

      let(:correct_source) do
        ['output = case variable',
         "when 'value1'",
         "  'output1'",
         'else',
         "  'output2'",
         'end']
      end

      context 'regarding assignment where the right hand side is a case' do
        it 'accepts a correctly indented assignment' do
          inspect_source(cop, correct_source)
          expect(cop.offenses).to be_empty
        end

        context 'an assignment indented some other way' do
          let(:source) do
            ['output = case variable',
             "  when 'value1'",
             "    'output1'",
             '  else',
             "    'output2'",
             'end']
          end

          let(:correct_source) do
            ['output = case variable',
             "when 'value1'",
             "    'output1'",
             '  else',
             "    'output2'",
             'end']
          end

          it 'registers an offense' do
            inspect_source(cop, source)
            expect(cop.messages).to eq(['Indent `when` as deep as `end`.'])
          end

          it 'does auto-correction' do
            corrected = autocorrect_source(cop, source)
            expect(corrected).to eq correct_source.join("\n")
          end
        end
      end
    end

    context 'with IndentOneStep: true' do
      let(:cop_config) do
        { 'EnforcedStyle' => 'end', 'IndentOneStep' => true }
      end

      let(:correct_source) do
        ['output = case variable',
         "  when 'value1'",
         "    'output1'",
         '  else',
         "    'output2'",
         'end']
      end

      context 'regarding assignment where the right hand side is a case' do
        it 'accepts a correctly indented assignment' do
          inspect_source(cop, correct_source)
          expect(cop.offenses).to be_empty
        end

        context 'an assignment indented as case' do
          let(:source) do
            ['output = case variable',
             "         when 'value1'",
             "           'output1'",
             '         else',
             "           'output2'",
             '         end']
          end

          let(:correct_source) do
            ['output = case variable',
             "           when 'value1'",
             "           'output1'",
             '         else',
             "           'output2'",
             '         end']
          end

          it 'registers an offense' do
            inspect_source(cop, source)
            expect(cop.messages)
              .to eq(['Indent `when` one step more than `end`.'])
            expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' =>
                                                       'case')
          end

          it 'does auto-correction' do
            corrected = autocorrect_source(cop, source)
            expect(corrected).to eq correct_source.join("\n")
          end
        end

        context 'an assignment indented some other way' do
          let(:source) do
            ['output = case variable',
             "       when 'value1'",
             "         'output1'",
             '       else',
             "         'output2'",
             '       end']
          end

          let(:correct_source) do
            ['output = case variable',
             "         when 'value1'",
             "         'output1'",
             '       else',
             "         'output2'",
             '       end']
          end

          it 'registers an offense' do
            inspect_source(cop, source)
            expect(cop.messages)
              .to eq(['Indent `when` one step more than `end`.'])
            expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
          end

          it 'does auto-correction' do
            corrected = autocorrect_source(cop, source)
            expect(corrected).to eq correct_source.join("\n")
          end
        end
      end
    end
  end

  context 'when case is preceded by something else than whitespace' do
    let(:cop_config) { {} }
    let(:source) do
      ['case test when something',
       'end']
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end

    it "doesn't auto-correct" do
      expect(autocorrect_source(cop, source))
        .to eq(source.join("\n"))
      expect(cop.offenses.map(&:corrected?)).to eq [false]
    end
  end
end
