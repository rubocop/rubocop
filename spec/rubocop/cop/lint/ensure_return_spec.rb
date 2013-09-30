# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Lint::EnsureReturn do
  subject(:cop) { described_class.new }

  it 'registers an offence for return in ensure' do
    inspect_source(cop,
                   ['begin',
                    '  something',
                    'ensure',
                    '  file.close',
                    '  return',
                    'end'])
    expect(cop.offences.size).to eq(1)
  end

  it 'does not register an offence for return outside ensure' do
    inspect_source(cop,
                   ['begin',
                    '  something',
                    '  return',
                    'ensure',
                    '  file.close',
                    'end'])
    expect(cop.offences).to be_empty
  end

  it 'does not check when ensure block has no body' do
    expect do
      inspect_source(cop,
                     ['begin',
                      '  something',
                      'ensure',
                      'end'])
    end.to_not raise_exception
  end
end
