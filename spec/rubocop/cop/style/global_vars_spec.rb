# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::GlobalVars, :config do
  cop_config = {
    'AllowedVariables' => ['$allowed']
  }

  subject(:cop) { described_class.new(config) }
  let(:cop_config) { cop_config }

  it 'registers an offence for $custom' do
    inspect_source(cop, ['puts $custom'])
    expect(cop.offences.size).to eq(1)
  end

  it 'allows user whitelisted variables' do
    inspect_source(cop, ['puts $allowed'])
    expect(cop.offences).to be_empty
  end

  described_class::BUILT_IN_VARS.each do |var|
    it "does not register an offence for built-in variable #{var}" do
      inspect_source(cop, ["puts #{var}"])
      expect(cop.offences).to be_empty
    end
  end

  it 'does not register an offence for backrefs like $1' do
    inspect_source(cop, ['puts $1'])
    expect(cop.offences).to be_empty
  end
end
