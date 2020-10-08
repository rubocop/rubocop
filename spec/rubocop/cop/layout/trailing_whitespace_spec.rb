# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::TrailingWhitespace, :config do
  let(:cop_config) { { 'AllowInHeredoc' => false } }

  it 'registers an offense for a line ending with space' do
    expect_offense(
      ['x = 0 ',
       '     ^ Trailing whitespace detected.']
    )
  end

  it 'registers an offense for a blank line with space' do
    expect_offense(
      ['  ',
       "^^ Trailing whitespace detected.\n"]
    )
  end

  it 'registers an offense for a line ending with tab' do
    expect_offense(
      ["x = 0\t",
       '     ^ Trailing whitespace detected.']
    )
  end

  it 'registers an offense for trailing whitespace in a heredoc string' do
    expect_offense(
      [
        'x = <<RUBY',
        '  Hi   ',
        '    ^^^ Trailing whitespace detected.',
        'RUBY'
      ]
    )
  end

  it 'registers offenses before __END__ but not after' do
    expect_offense(
      [
        "x = 0\t",
        '     ^ Trailing whitespace detected.',
        ' ',
        '^ Trailing whitespace detected.',
        '__END__',
        "x = 0\t"
      ]
    )
    # expect(offenses.map(&:line)).to eq([1, 2])
  end

  it 'is not fooled by __END__ within a documentation comment' do
    expect_offense(
      ["x = 0\t",
       '     ^ Trailing whitespace detected.',
       '=begin',
       '__END__',
       '=end',
       "x = 0\t",
       '     ^ Trailing whitespace detected.']
    )
  end

  it 'is not fooled by heredoc containing __END__' do
    expect_offense(
      ['x1 = <<RUBY ',
       '           ^ Trailing whitespace detected.',
       '__END__',
       "x2 = 0\t",
       '      ^ Trailing whitespace detected.',
       'RUBY',
       "x3 = 0\t",
       '      ^ Trailing whitespace detected.']
    )
  end

  it 'is not fooled by heredoc containing __END__ within a doc comment' do
    expect_offense(
      ['x1 = <<RUBY ',
       '           ^ Trailing whitespace detected.',
       '=begin  ',
       '      ^^ Trailing whitespace detected.',
       '__END__',
       '=end',
       "x2 = 0\t",
       '      ^ Trailing whitespace detected.',
       'RUBY',
       "x3 = 0\t",
       '      ^ Trailing whitespace detected.']
    )
  end

  it 'accepts a line without trailing whitespace' do
    expect_no_offenses('x = 0')
  end

  it 'auto-corrects unwanted space' do
    expect_offense(['x = 0 ',
                    '     ^ Trailing whitespace detected.',
                    "x = 0\t",
                    '     ^ Trailing whitespace detected.'])

    expect_correction(['x = 0',
                       'x = 0'])
  end

  context 'when `AllowInHeredoc` is set to true' do
    let(:cop_config) { { 'AllowInHeredoc' => true } }

    it 'accepts trailing whitespace in a heredoc string' do
      expect_no_offenses(['x = <<RUBY',
                          '  Hi   ',
                          'RUBY'])
    end

    it 'registers an offense for trailing whitespace at the heredoc begin' do
      expect_offense(['x = <<RUBY ',
                      '          ^ Trailing whitespace detected.',
                      '  Hi   ',
                      'RUBY'])
    end
  end
end
