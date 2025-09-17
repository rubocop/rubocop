# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Utils::FormatString do
  def format_sequences(string)
    RuboCop::Cop::Utils::FormatString.new(string).format_sequences
  end

  it 'finds the correct number of fields' do # rubocop:disable RSpec/MultipleExpectations
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
    expect(format_sequences('%*s').size).to eq(1)
    expect(format_sequences('%-*s').size).to eq(1)
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

  describe described_class::FormatSequence do
    subject(:sequence) { format_sequences(format_string).first }

    describe '#variable_width?' do
      context 'when no width is given' do
        let(:format_string) { '%s' }

        it { is_expected.not_to be_variable_width }
      end

      context 'when a fixed width is given' do
        let(:format_string) { '%2s' }

        it { is_expected.not_to be_variable_width }
      end

      context 'when a negative fixed width is given' do
        let(:format_string) { '%-2s' }

        it { is_expected.not_to be_variable_width }
      end

      context 'when a variable width is given' do
        let(:format_string) { '%*s' }

        it { is_expected.to be_variable_width }
      end

      context 'when a negative variable width is given' do
        let(:format_string) { '%-*s' }

        it { is_expected.to be_variable_width }
      end

      context 'when a variable width with an explicit argument number is given' do
        let(:format_string) { '%*2$s' }

        it { is_expected.to be_variable_width }
      end
    end

    describe '#variable_width_argument_number' do
      subject { sequence.variable_width_argument_number }

      context 'when no width is given' do
        let(:format_string) { '%s' }

        it { is_expected.to be_nil }
      end

      context 'when a fixed width is given' do
        let(:format_string) { '%2s' }

        it { is_expected.to be_nil }
      end

      context 'when a negative fixed width is given' do
        let(:format_string) { '%-2s' }

        it { is_expected.to be_nil }
      end

      context 'when a variable width is given' do
        let(:format_string) { '%*s' }

        it { is_expected.to eq(1) }
      end

      context 'when a negative variable width is given' do
        let(:format_string) { '%-*s' }

        it { is_expected.to eq(1) }
      end

      context 'when a variable width with an explicit argument number is given' do
        let(:format_string) { '%*2$s' }

        it { is_expected.to eq(2) }
      end
    end
  end
end
