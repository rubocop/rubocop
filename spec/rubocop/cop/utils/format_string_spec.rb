# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Utils::FormatString do
  def format_sequences(string)
    described_class.new(string).format_sequences
  end

  it 'finds the correct number of fields' do
    expect(format_sequences('').size)
      .to eq(0)
    expect(format_sequences('%s').size)
      .to eq(1)
    expect(format_sequences('%s %s').size)
      .to eq(2)
    expect(format_sequences('%s %s %%').size)
      .to eq(3)
    expect(format_sequences('%s %s %%').size)
      .to eq(3)
    expect(format_sequences('% d').size)
      .to eq(1)
    expect(format_sequences('%+d').size)
      .to eq(1)
    expect(format_sequences('%d').size)
      .to eq(1)
    expect(format_sequences('%+o').size)
      .to eq(1)
    expect(format_sequences('%#o').size)
      .to eq(1)
    expect(format_sequences('%.0e').size)
      .to eq(1)
    expect(format_sequences('%#.0e').size)
      .to eq(1)
    expect(format_sequences('% 020d').size)
      .to eq(1)
    expect(format_sequences('%20d').size)
      .to eq(1)
    expect(format_sequences('%+20d').size)
      .to eq(1)
    expect(format_sequences('%020d').size)
      .to eq(1)
    expect(format_sequences('%+020d').size)
      .to eq(1)
    expect(format_sequences('% 020d').size)
      .to eq(1)
    expect(format_sequences('%-20d').size)
      .to eq(1)
    expect(format_sequences('%-+20d').size)
      .to eq(1)
    expect(format_sequences('%- 20d').size)
      .to eq(1)
    expect(format_sequences('%020x').size)
      .to eq(1)
    expect(format_sequences('%#20.8x').size)
      .to eq(1)
    expect(format_sequences('%+g:% g:%-g').size)
      .to eq(3)
    expect(format_sequences('%+-d').size) # multiple flags
      .to eq(1)
  end

  describe '#named_interpolation?' do
    shared_examples 'named format sequence' do |format_string|
      it 'detects named format sequence' do
        expect(described_class.new(format_string).named_interpolation?)
          .to be_truthy
      end

      it 'does not detect escaped named format sequence' do
        escaped = format_string.gsub(/%/, '%%')

        expect(described_class.new(escaped).named_interpolation?)
          .to be_falsey
        expect(described_class.new('prefix:' + escaped).named_interpolation?)
          .to be_falsey
      end
    end

    it_behaves_like 'named format sequence', '%<greeting>2s'
    it_behaves_like 'named format sequence', '%2<greeting>s'
    it_behaves_like 'named format sequence', '%+0<num>8.2f'
    it_behaves_like 'named format sequence', '%+08<num>.2f'
  end
end
