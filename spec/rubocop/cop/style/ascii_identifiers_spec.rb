# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::AsciiIdentifiers do
  subject(:cop) { described_class.new }

  it 'registers an offence for a variable name with non-ascii chars' do
    inspect_source(cop,
                   ['# encoding: utf-8',
                    'älg = 1'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['Use only ascii symbols in identifiers.'])
  end

  it 'accepts identifiers with only ascii chars' do
    inspect_source(cop,
                   ['x.empty?'])
    expect(cop.offences).to be_empty
  end

  it 'does not get confused by a byte order mark' do
    bom = "\xef\xbb\xbf"
    inspect_source(cop,
                   [bom + '# encoding: utf-8',
                    "puts 'foo'"])
    expect(cop.offences).to be_empty
  end

  it 'does not get confused by an empty file' do
    inspect_source(cop,
                   [''])
    expect(cop.offences).to be_empty
  end
end
