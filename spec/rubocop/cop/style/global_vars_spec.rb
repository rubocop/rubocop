# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::GlobalVars, :config do
  cop_config = {
    'AllowedVariables' => ['$allowed']
  }

  subject(:cop) { described_class.new(config) }
  let(:cop_config) { cop_config }

  it 'registers an offense for $custom' do
    inspect_source(cop, 'puts $custom')
    expect(cop.offenses.size).to eq(1)
  end

  it 'allows user whitelisted variables' do
    inspect_source(cop, 'puts $allowed')
    expect(cop.offenses).to be_empty
  end

  described_class::BUILT_IN_VARS.each do |var|
    it "does not register an offense for built-in variable #{var}" do
      inspect_source(cop, "puts #{var}")
      expect(cop.offenses).to be_empty
    end
  end

  it 'does not register an offense for backrefs like $1' do
    inspect_source(cop, 'puts $1')
    expect(cop.offenses).to be_empty
  end
end
