# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::IfWithSemicolon do
  subject(:cop) { described_class.new }

  it 'registers an offence for one line if/;/end' do
    inspect_source(cop, ['if cond; run else dont end'])
    expect(cop.messages).to eq(
      ['Never use if x; Use the ternary operator instead.'])
  end

  it 'can handle modifier conditionals' do
    inspect_source(cop, ['class Hash',
                         'end if RUBY_VERSION < "1.8.7"'])
    expect(cop.messages).to be_empty
  end
end
