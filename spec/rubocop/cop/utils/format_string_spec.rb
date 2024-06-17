# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Utils::FormatString do
  def format_sequences(string)
    described_class.new(string).format_sequences
  end

  it 'finds the correct number of fields' do
    expect(format_sequences('').size).to eq(0)
    expect(format_sequences('%s').size).to eq(1)
    expect(format_sequences('%s %s').size).to eq(2)
    expect(format_sequences('%s %s %%').size).to eq(3)
    expect(format_sequences('%s %s %%').size).to eq(3)
    expect(format_sequences('% d').size).to eq(1)
    expect(format_sequences('%+d').size).to eq(1)
    expect(format_sequences('%d').size).to eq(1)
    expect(format_sequences('%+o').size).to eq(1)
    expect(format_sequences('%#o').size).to eq(1)
    expect(format_sequences('%.0e').size).to eq(1)
    expect(format_sequences('%#.0e').size).to eq(1)
    expect(format_sequences('% 020d').size).to eq(1)
    expect(format_sequences('%20d').size).to eq(1)
    expect(format_sequences('%+20d').size).to eq(1)
    expect(format_sequences('%020d').size).to eq(1)
    expect(format_sequences('%+020d').size).to eq(1)
    expect(format_sequences('% 020d').size).to eq(1)
    expect(format_sequences('%-20d').size).to eq(1)
    expect(format_sequences('%-+20d').size).to eq(1)
    expect(format_sequences('%- 20d').size).to eq(1)
    expect(format_sequences('%020x').size).to eq(1)
    expect(format_sequences('%#20.8x').size).to eq(1)
    expect(format_sequences('%+g:% g:%-g').size).to eq(3)
    expect(format_sequences('%+-d').size) # multiple flags
      .to eq(1)
  end

  describe '#named_interpolation?' do
    shared_examples 'named format sequence' do |format_string|
      it 'detects named format sequence' do
        expect(described_class.new(format_string)).to be_named_interpolation
      end

      it 'does not detect escaped named format sequence' do
        escaped = format_string.gsub('%', '%%')

        expect(described_class.new(escaped)).not_to be_named_interpolation
        expect(described_class.new("prefix:#{escaped}")).not_to be_named_interpolation
      end
    end

    it_behaves_like 'named format sequence', '%<greeting>2s'
    it_behaves_like 'named format sequence', '%2<greeting>s'
    it_behaves_like 'named format sequence', '%+0<num>8.2f'
    it_behaves_like 'named format sequence', '%+08<num>.2f'
  end

  describe '#valid?' do
    it 'returns true when there are only unnumbered formats' do
      fs = described_class.new('%s %d')
      expect(fs).to be_valid
    end

    it 'returns true when there are only numbered formats' do
      fs = described_class.new('%1$s %2$d')
      expect(fs).to be_valid
    end

    it 'returns true when there are only named formats' do
      fs = described_class.new('%{foo}s')
      expect(fs).to be_valid
    end

    it 'returns true when there are only named with escaped `%` formats' do
      fs = described_class.new('%%%{foo}d')
      expect(fs).to be_valid
    end

    it 'returns false when there are unnumbered and numbered formats' do
      fs = described_class.new('%s %1$d')
      expect(fs).not_to be_valid
    end

    it 'returns false when there are unnumbered and named formats' do
      fs = described_class.new('%s %{foo}d')
      expect(fs).not_to be_valid
    end

    it 'returns false when there are numbered and named formats' do
      fs = described_class.new('%1$s %{foo}d')
      expect(fs).not_to be_valid
    end
  end
end
