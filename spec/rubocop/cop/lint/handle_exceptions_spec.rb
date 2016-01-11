# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::HandleExceptions do
  subject(:cop) { described_class.new }

  it 'registers an offense for empty rescue block' do
    inspect_source(cop,
                   ['begin',
                    '  something',
                    'rescue',
                    '  #do nothing',
                    'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Do not suppress exceptions.'])
  end

  it 'does not register an offense for rescue with body' do
    inspect_source(cop,
                   ['begin',
                    '  something',
                    '  return',
                    'rescue',
                    '  file.close',
                    'end'])
    expect(cop.offenses).to be_empty
  end
end
