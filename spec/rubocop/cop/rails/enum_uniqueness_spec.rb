# frozen_string_literal: true

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
        expect_offense(<<-RUBY.strip_indent)
          enum status: [:active, :archived, :active, :active]
                                                     ^^^^^^^ Duplicate value `:active` found in `status` enum declaration.
                                            ^^^^^^^ Duplicate value `:active` found in `status` enum declaration.
        RUBY
      end
    end

    context 'with no duplicated enum values' do
      it 'does not register an offense for unique enum values' do
        expect_no_offenses('enum status: [:active, :archived]')
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
        expect_offense(<<-RUBY.strip_indent)
          enum status: { active: 0, pending: 0, archived: 0 }
                                                          ^ Duplicate value `0` found in `status` enum declaration.
                                             ^ Duplicate value `0` found in `status` enum declaration.
        RUBY
      end
    end

    context 'with no duplicated enum values' do
      it 'does not register an offense' do
        expect_no_offenses('enum status: { active: 0, pending: 1 }')
      end
    end
  end

  context 'when receiving a variable' do
    it 'does not register an offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
        var = { status: { active: 0, archived: 1 } }
        enum var
      RUBY
    end
  end

  context 'when receiving a hash without literal values' do
    context 'when value is a variable' do
      it 'does not register an offense' do
        expect_no_offenses('enum status: statuses')
      end
    end

    context 'when value is a method chain' do
      it 'does not register an offense' do
        expect_no_offenses('enum status: User.statuses.keys')
      end
    end

    context 'when value is a constant' do
      it 'does not register an offense' do
        expect_no_offenses('enum status: STATUSES')
      end
    end
  end
end
