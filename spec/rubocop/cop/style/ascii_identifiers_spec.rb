# frozen_string_literal: true

describe RuboCop::Cop::Style::AsciiIdentifiers do
  subject(:cop) { described_class.new }

  it 'registers an offense for a variable name with non-ascii chars' do
    expect_offense(<<-RUBY.strip_indent)
      # encoding: utf-8
      älg = 1
      ^ Use only ascii symbols in identifiers.
    RUBY
  end

  it 'registers an offense for a variable name with mixed chars' do
    expect_offense(<<-RUBY.strip_indent)
      # encoding: utf-8
      foo∂∂bar = baz
         ^^ Use only ascii symbols in identifiers.
    RUBY
  end

  it 'accepts identifiers with only ascii chars' do
    expect_no_offenses('x.empty?')
  end

  it 'does not get confused by a byte order mark' do
    bom = "\xef\xbb\xbf"
    inspect_source(cop,
                   [bom + '# encoding: utf-8',
                    "puts 'foo'"])
    expect(cop.offenses).to be_empty
  end

  it 'does not get confused by an empty file' do
    expect_no_offenses('')
  end
end
