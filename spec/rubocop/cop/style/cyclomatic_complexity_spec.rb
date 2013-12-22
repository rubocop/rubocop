# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::CyclomaticComplexity, :config do
  subject(:cop) { described_class.new(config) }

  context 'when Max is 1' do
    let(:cop_config) { { 'Max' => 1 } }

    it 'accepts a method with no decision points' do
      inspect_source(cop, ['def method_name',
                           '  call_foo',
                           'end'])
      expect(cop.offences).to be_empty
    end

    it 'accepts complex code outside of methods' do
      inspect_source(cop,
                     ['def method_name',
                      '  call_foo',
                      'end',
                      '',
                      'if first_condition then',
                      '  call_foo if second_condition && third_condition',
                      '  call_bar if fourth_condition || fifth_condition',
                      'end'])
      expect(cop.offences).to be_empty
    end

    it 'registers an offence for an if modifier' do
      inspect_source(cop, ['def self.method_name',
                           '  call_foo if some_condition',
                           'end'])
      expect(cop.messages)
        .to eq(['Cyclomatic complexity for method_name is too high. [2/1]'])
      expect(cop.highlights).to eq(['def'])
      expect(cop.config_to_allow_offences).to eq('Max' => 2)
    end

    it 'registers an offence for an unless modifier' do
      inspect_source(cop, ['def method_name',
                           '  call_foo unless some_condition',
                           'end'])
      expect(cop.messages)
        .to eq(['Cyclomatic complexity for method_name is too high. [2/1]'])
    end

    it 'registers an offence for an elsif block' do
      inspect_source(cop, ['def method_name',
                           '  if first_condition then',
                           '    call_foo',
                           '  elsif second_condition then',
                           '    call_bar',
                           '  else',
                           '    call_bam',
                           '  end',
                           'end'])
      expect(cop.messages)
        .to eq(['Cyclomatic complexity for method_name is too high. [3/1]'])
    end

    it 'registers an offence for a ternary operator' do
      inspect_source(cop, ['def method_name',
                           '  value = some_condition ? 1 : 2',
                           'end'])
      expect(cop.messages)
        .to eq(['Cyclomatic complexity for method_name is too high. [2/1]'])
    end

    it 'registers an offence for a while block' do
      inspect_source(cop, ['def method_name',
                           '  while some_condition do',
                           '    call_foo',
                           '  end',
                           'end'])
      expect(cop.messages)
        .to eq(['Cyclomatic complexity for method_name is too high. [2/1]'])
    end

    it 'registers an offence for an until block' do
      inspect_source(cop, ['def method_name',
                           '  until some_condition do',
                           '    call_foo',
                           '  end',
                           'end'])
      expect(cop.messages)
        .to eq(['Cyclomatic complexity for method_name is too high. [2/1]'])
    end

    it 'registers an offence for a for block' do
      inspect_source(cop, ['def method_name',
                           '  for i in 1..2 do',
                           '    call_method',
                           '  end',
                           'end'])
      expect(cop.messages)
        .to eq(['Cyclomatic complexity for method_name is too high. [2/1]'])
    end

    it 'registers an offence for a rescue block' do
      inspect_source(cop, ['def method_name',
                           '  begin',
                           '    call_foo',
                           '  rescue Exception',
                           '    call_bar',
                           '  end',
                           'end'])
      expect(cop.messages)
        .to eq(['Cyclomatic complexity for method_name is too high. [2/1]'])
    end

    it 'registers an offence for a case/when block' do
      inspect_source(cop, ['def method_name',
                           '  case value',
                           '  when 1',
                           '    call_foo',
                           '  when 2',
                           '    call_bar',
                           '  end',
                           'end'])
      expect(cop.messages)
        .to eq(['Cyclomatic complexity for method_name is too high. [3/1]'])
    end

    it 'registers an offence for &&' do
      inspect_source(cop, ['def method_name',
                           '  call_foo && call_bar',
                           'end'])
      expect(cop.messages)
        .to eq(['Cyclomatic complexity for method_name is too high. [2/1]'])
    end

    it 'registers an offence for and' do
      inspect_source(cop, ['def method_name',
                           '  call_foo and call_bar',
                           'end'])
      expect(cop.messages)
        .to eq(['Cyclomatic complexity for method_name is too high. [2/1]'])
    end

    it 'registers an offence for ||' do
      inspect_source(cop, ['def method_name',
                           '  call_foo || call_bar',
                           'end'])
      expect(cop.messages)
        .to eq(['Cyclomatic complexity for method_name is too high. [2/1]'])
    end

    it 'registers an offence for or' do
      inspect_source(cop, ['def method_name',
                           '  call_foo or call_bar',
                           'end'])
      expect(cop.messages)
        .to eq(['Cyclomatic complexity for method_name is too high. [2/1]'])
    end

    it 'deals with nested if blocks containing && and ||' do
      inspect_source(cop,
                     ['def method_name',
                      '  if first_condition then',
                      '    call_foo if second_condition && third_condition',
                      '    call_bar if fourth_condition || fifth_condition',
                      '  end',
                      'end'])
      expect(cop.messages)
        .to eq(['Cyclomatic complexity for method_name is too high. [6/1]'])
    end

    it 'counts only a single method' do
      inspect_source(cop, ['def method_name_1',
                           '  call_foo if some_condition',
                           'end',
                           '',
                           'def method_name_2',
                           '  call_foo if some_condition',
                           'end'])
      expect(cop.messages)
        .to eq(['Cyclomatic complexity for method_name_1 is too high. [2/1]',
                'Cyclomatic complexity for method_name_2 is too high. [2/1]'])
    end
  end

  context 'when Max is 2' do
    let(:cop_config) { { 'Max' => 2 } }

    it 'counts stupid nested if and else blocks' do
      inspect_source(cop, ['def method_name',
                           '  if first_condition then',
                           '    call_foo',
                           '  else',
                           '    if second_condition then',
                           '      call_bar',
                           '    else',
                           '      call_bam if third_condition',
                           '    end',
                           '    call_baz if fourth_condition',
                           '  end',
                           'end'])
      expect(cop.messages)
        .to eq(['Cyclomatic complexity for method_name is too high. [5/2]'])
    end
  end
end
