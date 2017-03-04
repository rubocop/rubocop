# frozen_string_literal: true

describe RuboCop::Cop::Style::AsciiIdentifiers do
  subject(:cop) { described_class.new }

  it 'registers an offense for a variable name with non-ascii chars' do
    inspect_source(cop,
                   ['# encoding: utf-8',
                    'älg = 1'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['ä'])
    expect(cop.messages)
      .to eq(['Use only ascii symbols in identifiers.'])
  end

  it 'registers an offense for a variable name with mixed chars' do
    inspect_source(cop,
                   ['# encoding: utf-8',
                    'foo∂∂bar = baz'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['∂∂'])
    expect(cop.messages)
      .to eq(['Use only ascii symbols in identifiers.'])
  end

  it 'accepts identifiers with only ascii chars' do
    inspect_source(cop,
                   'x.empty?')
    expect(cop.offenses).to be_empty
  end

  it 'does not get confused by a byte order mark' do
    bom = "\xef\xbb\xbf"
    inspect_source(cop,
                   [bom + '# encoding: utf-8',
                    "puts 'foo'"])
    expect(cop.offenses).to be_empty
  end

  it 'does not get confused by an empty file' do
    inspect_source(cop,
                   '')
    expect(cop.offenses).to be_empty
  end
end
