# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::OneLineConditional do
  subject(:cop) { described_class.new }

  it 'registers an offence for one line if/then/end' do
    inspect_source(cop, ['if cond then run else dont end'])
    expect(cop.messages).to eq(['Favor the ternary operator (?:)' \
                                ' over if/then/else/end constructs.'])
  end
end
