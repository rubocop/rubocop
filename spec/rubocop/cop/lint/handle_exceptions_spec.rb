# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Lint::HandleExceptions do
  subject(:cop) { described_class.new }

  it 'registers an offence for empty rescue block' do
    inspect_source(cop,
                   ['begin',
                    '  something',
                    'rescue',
                    '  #do nothing',
                    'end'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['Do not suppress exceptions.'])
  end

  it 'does not register an offence for rescue with body' do
    inspect_source(cop,
                   ['begin',
                    '  something',
                    '  return',
                    'rescue',
                    '  file.close',
                    'end'])
    expect(cop.offences).to be_empty
  end
end
