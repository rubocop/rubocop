# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::TextUtil do
  describe 'pluralize' do
    it 'will not change 0 to no' do
      pluralized_text = described_class.pluralize(0, 'file')

      expect(pluralized_text).to eq('0 files')
    end

    it 'will change 0 to no when configured' do
      pluralized_text = described_class.pluralize(0, 'file', no_for_zero: true)

      expect(pluralized_text).to eq('no files')
    end

    it 'will not pluralize 1' do
      pluralized_text = described_class.pluralize(1, 'file')

      expect(pluralized_text).to eq('1 file')
    end

    it 'will pluralize quantities greater than 1' do
      pluralized_text = described_class.pluralize(3, 'file')

      expect(pluralized_text).to eq('3 files')
    end

    it 'will pluralize fractions' do
      pluralized_text = described_class.pluralize(0.5, 'file')

      expect(pluralized_text).to eq('0.5 files')
    end

    it 'will pluralize -1' do
      pluralized_text = described_class.pluralize(-1, 'file')

      expect(pluralized_text).to eq('-1 files')
    end

    it 'will pluralize negative quantities less than -1' do
      pluralized_text = described_class.pluralize(-2, 'file')

      expect(pluralized_text).to eq('-2 files')
    end
  end
end
