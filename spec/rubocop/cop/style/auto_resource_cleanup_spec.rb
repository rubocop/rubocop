# frozen_string_literal: true

describe RuboCop::Cop::Style::AutoResourceCleanup do
  subject(:cop) { described_class.new }

  it 'registers an offense for File.open without block' do
    inspect_source(cop, 'File.open("filename")')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Use the block version of `File.open`.'])
  end

  it 'does not register an offense for File.open with block' do
    inspect_source(cop, 'File.open("file") { |f| something }')

    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for File.open with block-pass' do
    inspect_source(cop, 'File.open("file", &:read)')

    expect(cop.offenses).to be_empty
  end
end
