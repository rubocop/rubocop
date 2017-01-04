# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::EnsureReturn do
  subject(:cop) { described_class.new }

  it 'registers an offense for return in ensure' do
    inspect_source(cop,
                   ['begin',
                    '  something',
                    'ensure',
                    '  file.close',
                    '  return',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'does not register an offense for return outside ensure' do
    inspect_source(cop,
                   ['begin',
                    '  something',
                    '  return',
                    'ensure',
                    '  file.close',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'does not check when ensure block has no body' do
    expect do
      inspect_source(cop,
                     ['begin',
                      '  something',
                      'ensure',
                      'end'])
    end.not_to raise_exception
  end
end
