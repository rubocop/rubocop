# frozen_string_literal: true

describe RuboCop::Cop::Layout::TrailingWhitespace do
  subject(:cop) { described_class.new }

  it 'registers an offense for a line ending with space' do
    inspect_source(cop, 'x = 0 ')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for a blank line with space' do
    inspect_source(cop, '  ')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for a line ending with tab' do
    inspect_source(cop, "x = 0\t")
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for trailing whitespace in a heredoc string' do
    inspect_source(cop, ['x = <<END',
                         '  Hi   ',
                         'END'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers offenses before __END__ but not after' do
    inspect_source(cop, ["x = 0\t",
                         ' ',
                         '__END__',
                         "x = 0\t"])
    expect(cop.offenses.map(&:line)).to eq([1, 2])
  end

  it 'is not fooled by __END__ within a documentation comment' do
    inspect_source(cop, ["x = 0\t",
                         '=begin',
                         '__END__',
                         '=end',
                         "x = 0\t"])
    expect(cop.offenses.map(&:line)).to eq([1, 5])
  end

  it 'is not fooled by heredoc containing __END__' do
    inspect_source(cop, ['x1 = <<END ',
                         '__END__',
                         "x2 = 0\t",
                         'END',
                         "x3 = 0\t"])
    expect(cop.offenses.map(&:line)).to eq([1, 3, 5])
  end

  it 'is not fooled by heredoc containing __END__ within a doc comment' do
    inspect_source(cop, ['x1 = <<END ',
                         '=begin  ',
                         '__END__',
                         '=end',
                         "x2 = 0\t",
                         'END',
                         "x3 = 0\t"])
    expect(cop.offenses.map(&:line)).to eq([1, 2, 5, 7])
  end

  it 'accepts a line without trailing whitespace' do
    expect_no_offenses('x = 0')
  end

  it 'auto-corrects unwanted space' do
    new_source = autocorrect_source(cop, ['x = 0 ',
                                          "x = 0\t"])
    expect(new_source).to eq(['x = 0',
                              'x = 0'].join("\n"))
  end
end
