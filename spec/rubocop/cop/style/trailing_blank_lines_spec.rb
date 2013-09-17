# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::TrailingBlankLines, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { {} } # use default which is 0

  it 'accepts final newline' do
    inspect_source(cop, ['x = 0', ''])
    expect(cop.offences).to be_empty
  end

  it 'registers an offence for multiple trailing blank lines' do
    inspect_source(cop, ['x = 0', '', '', '', ''])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages).to eq([<<-EOS.strip])
        3 trailing blank lines detected. Max allowed is 0.
        EOS
  end

  context 'when configured to a max of 3 blank lines' do
    let(:cop_config) { { "Max" => 3 } }

    it "does not register an offence on 3 trailing blank lines" do
      inspect_source(cop, ['x = 0', '', '', '', ''])
      expect(cop.offences.size).to eq(0)
      expect(cop.messages).to eq([])
    end

    it 'registers an offence for 4 trailing blank lines' do
      inspect_source(cop, ['x = 0', '', '', '', '', ''])
      expect(cop.offences.size).to eq(1)
      expect(cop.messages).to eq([<<-EOS.strip])
          4 trailing blank lines detected. Max allowed is 3.
          EOS
    end
  end
end
