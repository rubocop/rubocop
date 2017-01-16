# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Rails::EnumUniqueness, :config do
  subject(:cop) { described_class.new }

  context 'when array syntax is used' do
    context 'with a single duplicated enum value' do
      it 'registers an offense' do
        inspect_source(cop, 'enum status: [:active, :archived, :active]')

        msg = 'Duplicate value `:active` found in `status` enum declaration.'
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages).to eq([msg])
      end
    end

    context 'with several duplicated enum values' do
      it 'registers two offenses' do
        inspect_source(cop,
                       'enum status: [:active, :archived, :active, :active]')

        expect(cop.offenses.size).to eq(2)
      end
    end

    context 'with no duplicated enum values' do
      it 'does not register an offense for unique enum values' do
        inspect_source(cop, 'enum status: [:active, :archived]')

        expect(cop.offenses).to be_empty
      end
    end
  end

  context 'when hash syntax is used' do
    context 'with a single duplicated enum value' do
      it 'registers an offense' do
        inspect_source(cop, 'enum status: { active: 0, archived: 0 }')

        msg = 'Duplicate value `0` found in `status` enum declaration.'
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages).to eq([msg])
      end
    end

    context 'with several duplicated enum values' do
      it 'registers two offenses' do
        inspect_source(cop,
                       'enum status: { active: 0, pending: 0, archived: 0 }')

        expect(cop.offenses.size).to eq(2)
      end
    end

    context 'with no duplicated enum values' do
      it 'does not register an offense' do
        inspect_source(cop, 'enum status: { active: 0, pending: 1 }')

        expect(cop.offenses).to be_empty
      end
    end
  end

  context 'when receiving a variable' do
    it 'does not register an offense' do
      inspect_source(cop, ['var = { status: { active: 0, archived: 1 } }',
                           'enum var'])

      expect(cop.offenses).to be_empty
    end
  end

  context 'when receiving a hash without literal values' do
    context 'when value is a variable' do
      it 'does not register an offense' do
        inspect_source(cop, 'enum status: statuses')

        expect(cop.offenses).to be_empty
      end
    end

    context 'when value is a method chain' do
      it 'does not register an offense' do
        inspect_source(cop, 'enum status: User.statuses.keys')

        expect(cop.offenses).to be_empty
      end
    end

    context 'when value is a constant' do
      it 'does not register an offense' do
        inspect_source(cop, 'enum status: STATUSES')

        expect(cop.offenses).to be_empty
      end
    end
  end
end
