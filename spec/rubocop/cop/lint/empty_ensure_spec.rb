# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::EmptyEnsure do
  subject(:cop) { described_class.new }

  it 'registers an offense for empty ensure' do
    inspect_source(cop,
                   ['begin',
                    '  something',
                    'ensure',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'does not register an offense for non-empty ensure' do
    inspect_source(cop,
                   ['begin',
                    '  something',
                    '  return',
                    'ensure',
                    '  file.close',
                    'end'])
    expect(cop.offenses).to be_empty
  end
end
