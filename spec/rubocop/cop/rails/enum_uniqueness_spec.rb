# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Rails::EnumUniqueness, :config do
  subject(:cop) { described_class.new }

  context 'when array syntax is used' do
    it 'does not register an offense' do
      inspect_source(cop, 'enum status: [ :active, :archived ]')

      expect(cop.messages).to be_empty
    end

    it 'does not register an offense given additional enum configuration' do
      inspect_source(cop, 'enum status: [:active, :archived], _suffix: true')

      expect(cop.messages).to be_empty
    end
  end

  context 'when hash syntax is used' do
    it 'registers an offense for duplicate enum values' do
      inspect_source(cop, 'enum status: { active: 4, archived: 4 }')

      msg = 'Duplicate value `4` found in `status` enum declaration.'
      expect(cop.messages).to eq([msg])
    end

    it 'registers an offense when given enum configuration' do
      src = 'enum test_status: { x: 7, y: 7 }, _prefix: :test'
      inspect_source(cop, src)

      msg = 'Duplicate value `7` found in `test_status` enum declaration.'
      expect(cop.messages).to eq([msg])
    end

    it 'does not register an offense for unique enum values' do
      inspect_source(cop, 'enum status: { active: 0, archived: 1 }')

      expect(cop.messages).to be_empty
    end
  end
end
