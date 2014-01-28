# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::CaseIndentation do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    merged = Rubocop::ConfigLoader
      .default_configuration['CaseIndentation'].merge(cop_config)
    Rubocop::Config.new('CaseIndentation' => merged)
  end

  context 'with IndentWhenRelativeTo: case' do
    context 'with IndentOneStep: false' do
      let(:cop_config) do
        { 'IndentWhenRelativeTo' => 'case', 'IndentOneStep' => false }
      end

      context 'regarding assignment where the right hand side is a case' do
        it 'accepts a correcty indented assignment' do
          source = ['output = case variable',
                    "         when 'value1'",
                    "           'output1'",
                    '         else',
                    "           'output2'",
                    '         end']
          inspect_source(cop, source)
          expect(cop.offences).to be_empty
        end

        it 'registers on offence for an assignment indented as end' do
          source = ['output = case variable',
                    "when 'value1'",
                    "  'output1'",
                    'else',
                    "  'output2'",
                    'end']
          inspect_source(cop, source)
          expect(cop.messages).to eq(['Indent when as deep as case.'])
          expect(cop.config_to_allow_offences).to eq('IndentWhenRelativeTo' =>
                                                     'end')
        end

        it 'registers on offence for an assignment indented some other way' do
          source = ['output = case variable',
                    "  when 'value1'",
                    "    'output1'",
                    '  else',
                    "    'output2'",
                    'end']
          inspect_source(cop, source)
          expect(cop.messages).to eq(['Indent when as deep as case.'])
          expect(cop.config_to_allow_offences).to eq('Enabled' => false)
        end

        it 'registers on offence for correct + opposite' do
          source = ['output = case variable',
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
          inspect_source(cop, source)
          expect(cop.messages).to eq(['Indent when as deep as case.'])
          expect(cop.config_to_allow_offences).to eq('Enabled' => false)
        end
      end

      it "registers an offence for a when clause that's deeper than case" do
        source = ['case a',
                  '    when 0 then return',
                  '    else',
                  '        case b',
                  '         when 1 then return',
                  '        end',
                  'end']
        inspect_source(cop, source)
        expect(cop.messages).to eq(['Indent when as deep as case.'] * 2)
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
        expect(cop.offences).to be_empty
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
        { 'IndentWhenRelativeTo' => 'case', 'IndentOneStep' => true }
      end

      context 'regarding assignment where the right hand side is a case' do
        it 'accepts a correcty indented assignment' do
          source = ['output = case variable',
                    "           when 'value1'",
                    "             'output1'",
                    '           else',
                    "             'output2'",
                    '         end']
          inspect_source(cop, source)
          expect(cop.offences).to be_empty
        end

        it 'registers on offence for an assignment indented some other way' do
          source = ['output = case variable',
                    "         when 'value1'",
                    "           'output1'",
                    '         else',
                    "           'output2'",
                    '         end']
          inspect_source(cop, source)
          expect(cop.messages).to eq(['Indent when one step more than case.'])
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
        expect(cop.offences).to be_empty
      end

      it "registers an offence for  a when clause that's equally indented " \
        'with case' do
        source = ['y = case a',
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
        inspect_source(cop, source)
        expect(cop.messages)
          .to eq(['Indent when one step more than case.'] * 5)
      end
    end
  end

  context 'with IndentWhenRelativeTo: end' do
    context 'with IndentOneStep: false' do
      let(:cop_config) do
        { 'IndentWhenRelativeTo' => 'end', 'IndentOneStep' => false }
      end

      context 'regarding assignment where the right hand side is a case' do
        it 'accepts a correcty indented assignment' do
          source = ['output = case variable',
                    "when 'value1'",
                    "  'output1'",
                    'else',
                    "  'output2'",
                    'end']
          inspect_source(cop, source)
          expect(cop.offences).to be_empty
        end

        it 'registers on offence for an assignment indented some other way' do
          source = ['output = case variable',
                    "  when 'value1'",
                    "    'output1'",
                    '  else',
                    "    'output2'",
                    'end']
          inspect_source(cop, source)
          expect(cop.messages).to eq(['Indent when as deep as end.'])
        end
      end
    end

    context 'with IndentOneStep: true' do
      let(:cop_config) do
        { 'IndentWhenRelativeTo' => 'end', 'IndentOneStep' => true }
      end

      context 'regarding assignment where the right hand side is a case' do
        it 'accepts a correcty indented assignment' do
          source = ['output = case variable',
                    "  when 'value1'",
                    "    'output1'",
                    '  else',
                    "    'output2'",
                    'end']
          inspect_source(cop, source)
          expect(cop.offences).to be_empty
        end

        it 'registers on offence for an assignment indented as case' do
          source = ['output = case variable',
                    "         when 'value1'",
                    "           'output1'",
                    '         else',
                    "           'output2'",
                    '         end']
          inspect_source(cop, source)
          expect(cop.messages).to eq(['Indent when one step more than end.'])
          expect(cop.config_to_allow_offences).to eq('IndentWhenRelativeTo' =>
                                                     'case')
        end

        it 'registers on offence for an assignment indented some other way' do
          source = ['output = case variable',
                    "       when 'value1'",
                    "         'output1'",
                    '       else',
                    "         'output2'",
                    '       end']
          inspect_source(cop, source)
          expect(cop.messages).to eq(['Indent when one step more than end.'])
          expect(cop.config_to_allow_offences).to eq('Enabled' => false)
        end
      end
    end
  end
end
