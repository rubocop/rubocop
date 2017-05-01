# frozen_string_literal: true

describe RuboCop::Cop::Style::AutoResourceCleanup do
  subject(:cop) { described_class.new }

  it 'registers an offense for File.open without block' do
    inspect_source(cop, 'File.open("filename")')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Use the block version of `File.open`.'])
  end

  it 'does not register an offense for File.open with block' do
    expect_no_offenses('File.open("file") { |f| something }')
  end

  it 'does not register an offense for File.open with block-pass' do
    expect_no_offenses('File.open("file", &:read)')
  end
end
