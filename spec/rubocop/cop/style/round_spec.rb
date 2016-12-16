# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::Round do
  subject(:cop) { described_class.new }

  context 'with round' do
    it 'registers an offense with 0' do
      inspect_source(cop, '6.75.round(0)')
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense without args' do
      inspect_source(cop, '6.75.round')
      expect(cop.offenses.size).to eq(1)
    end

    it 'does not register an offense with other args' do
      inspect_source(cop, '6.75.round(2)')
      expect(cop.offenses).to be_empty
    end
  end

  context 'with ceil' do
    after(:each) { expect(cop.offenses).to be_empty }

    it 'does not register an offense' do
      inspect_source(cop, '6.75.ceil')
    end
  end

  context 'with floor' do
    after(:each) { expect(cop.offenses).to be_empty }

    it 'does not register an offense' do
      inspect_source(cop, '6.75.floor')
    end
  end
end
