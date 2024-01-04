# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::TextUtil do
  describe 'pluralize' do
    it 'does not change 0 to no' do
      pluralized_text = described_class.pluralize(0, 'file')

      expect(pluralized_text).to eq('0 files')
    end

    it 'changes 0 to no when configured' do
      pluralized_text = described_class.pluralize(0, 'file', no_for_zero: true)

      expect(pluralized_text).to eq('no files')
    end

    it 'does not pluralize 1' do
      pluralized_text = described_class.pluralize(1, 'file')

      expect(pluralized_text).to eq('1 file')
    end

    it 'pluralizes quantities greater than 1' do
      pluralized_text = described_class.pluralize(3, 'file')

      expect(pluralized_text).to eq('3 files')
    end

    it 'pluralizes fractions' do
      pluralized_text = described_class.pluralize(0.5, 'file')

      expect(pluralized_text).to eq('0.5 files')
    end

    it 'pluralizes -1' do
      pluralized_text = described_class.pluralize(-1, 'file')

      expect(pluralized_text).to eq('-1 files')
    end

    it 'pluralizes negative quantities less than -1' do
      pluralized_text = described_class.pluralize(-2, 'file')

      expect(pluralized_text).to eq('-2 files')
    end
  end
end
