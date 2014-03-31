# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::Tab do
  subject(:cop) { described_class.new }

  it 'registers an offense for a line indented with tab' do
    inspect_source(cop, ["\tx = 0"])
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts a line with tab in a string' do
    inspect_source(cop, ["(x = \"\t\")"])
    expect(cop.offenses).to be_empty
  end

  context 'auto-corrects unwanted tabs' do
    it 'single line' do
      new_source = autocorrect_source(cop, "\tx = 0")
      expect(new_source).to eq('  x = 0')
    end

    it 'multiple lines' do
      new_source = autocorrect_source(cop,
                                      ['if a',
                                       "  \t\tcase b",
                                       "  \t  when c then",
                                       "\t  \tend",
                                       'end'])
      expect_source =
%q(if a
      case b
      when c then
      end
end)
      expect(new_source).to eq(expect_source)
    end
  end
end
