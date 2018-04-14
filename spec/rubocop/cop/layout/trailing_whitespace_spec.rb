# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::TrailingWhitespace, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'AllowInHeredoc' => false } }

  it 'registers an offense for a line ending with space' do
    inspect_source('x = 0 ')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for a blank line with space' do
    inspect_source('  ')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for a line ending with tab' do
    inspect_source("x = 0\t")
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for trailing whitespace in a heredoc string' do
    inspect_source(['x = <<RUBY',
                    '  Hi   ',
                    'RUBY'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers offenses before __END__ but not after' do
    inspect_source(["x = 0\t",
                    ' ',
                    '__END__',
                    "x = 0\t"])
    expect(cop.offenses.map(&:line)).to eq([1, 2])
  end

  it 'is not fooled by __END__ within a documentation comment' do
    inspect_source(["x = 0\t",
                    '=begin',
                    '__END__',
                    '=end',
                    "x = 0\t"])
    expect(cop.offenses.map(&:line)).to eq([1, 5])
  end

  it 'is not fooled by heredoc containing __END__' do
    inspect_source(['x1 = <<RUBY ',
                    '__END__',
                    "x2 = 0\t",
                    'RUBY',
                    "x3 = 0\t"])
    expect(cop.offenses.map(&:line)).to eq([1, 3, 5])
  end

  it 'is not fooled by heredoc containing __END__ within a doc comment' do
    inspect_source(['x1 = <<RUBY ',
                    '=begin  ',
                    '__END__',
                    '=end',
                    "x2 = 0\t",
                    'RUBY',
                    "x3 = 0\t"])
    expect(cop.offenses.map(&:line)).to eq([1, 2, 5, 7])
  end

  it 'accepts a line without trailing whitespace' do
    expect_no_offenses('x = 0')
  end

  it 'auto-corrects unwanted space' do
    new_source = autocorrect_source(['x = 0 ',
                                     "x = 0\t"])
    expect(new_source).to eq(['x = 0',
                              'x = 0'].join("\n"))
  end

  context 'when `AllowInHeredoc` is set to true' do
    let(:cop_config) { { 'AllowInHeredoc' => true } }

    it 'accepts trailing whitespace in a heredoc string' do
      inspect_source(['x = <<RUBY',
                      '  Hi   ',
                      'RUBY'])
      expect(cop.offenses.size).to eq(0)
    end

    it 'registers an offence for trailing whitespace at the heredoc begin' do
      inspect_source(['x = <<RUBY ',
                      '  Hi   ',
                      'RUBY'])
      expect(cop.offenses.size).to eq(1)
    end
  end
end
