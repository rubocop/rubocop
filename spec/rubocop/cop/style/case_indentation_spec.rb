# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::CaseIndentation do
  subject(:cop) { described_class.new }

  it "registers an offence for a when clause that's deeper than case" do
    source = ['case a',
              '    when 0 then return',
              '        case b',
              '         when 1 then return',
              '        end',
              'end']
    inspect_source(cop, source)
    expect(cop.messages).to eq(
      ['Indent when as deep as case.'] * 2)
  end

  it "accepts a when clause that's equally indented with case" do
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
