# frozen_string_literal: true

describe RuboCop::Cop::Rails::Date, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is "strict"' do
    let(:cop_config) { { 'EnforcedStyle' => 'strict' } }

    %w[today current yesterday tomorrow].each do |day|
      it "registers an offense for Date.#{day}" do
        inspect_source(cop, "Date.#{day}")
        expect(cop.offenses.size).to eq(1)
      end

      it "registers an offense for ::Date.#{day}" do
        inspect_source(cop, "::Date.#{day}")
        expect(cop.offenses.size).to eq(1)
      end

      it "accepts Some::Date.#{day}" do
        inspect_source(cop, "Some::Date.#{day}")
        expect(cop.offenses).to be_empty
      end
    end

    %w[to_time to_time_in_current_zone].each do |method|
      it "registers an offense for ##{method}" do
        inspect_source(cop, "date.#{method}")
        expect(cop.offenses.size).to eq(1)
      end

      it "accepts variable named #{method}" do
        inspect_source(cop, "#{method} = 1")
        expect(cop.offenses).to be_empty
      end

      it "accepts variable #{method} as range end" do
        inspect_source(cop, "from_time..#{method}")
        expect(cop.offenses).to be_empty
      end
    end

    context 'when a zone is provided' do
      it 'does not register an offense' do
        expect_no_offenses('date.to_time(:utc)')
      end
    end

    context 'when a string literal with timezone' do
      it 'does not register an offense' do
        expect_no_offenses('"2016-07-12 14:36:31 +0100".to_time(:utc)')
      end
    end

    context 'when a string literal without timezone' do
      it 'registers an offense' do
        inspect_source(cop, '"2016-07-12 14:36:31".to_time(:utc)')
        expect(cop.offenses.size).to eq(1)
      end
    end

    it 'does not blow up in the presence of a single constant to inspect' do
      expect_no_offenses('A')
    end

    RuboCop::Cop::Rails::TimeZone::ACCEPTED_METHODS.each do |a_method|
      it "registers an offense for val.to_time.#{a_method}" do
        inspect_source(cop, "val.to_time.#{a_method}")
        expect(cop.offenses.size).to eq(1)
      end
    end
  end

  context 'when EnforcedStyle is "flexible"' do
    let(:cop_config) { { 'EnforcedStyle' => 'flexible' } }

    %w[current yesterday tomorrow].each do |day|
      it "accepts Date.#{day}" do
        inspect_source(cop, "Date.#{day}")
        expect(cop.offenses).to be_empty
      end
    end

    it 'registers an offense for Date.today' do
      inspect_source(cop, 'Date.today')
      expect(cop.offenses.size).to eq(1)
    end

    RuboCop::Cop::Rails::TimeZone::ACCEPTED_METHODS.each do |a_method|
      it "accepts val.to_time.#{a_method}" do
        inspect_source(cop, "val.to_time.#{a_method}")
        expect(cop.offenses).to be_empty
      end
    end

    it 'accepts #to_time_in_current_zone' do
      expect_no_offenses('date.to_time_in_current_zone')
    end
  end
end
