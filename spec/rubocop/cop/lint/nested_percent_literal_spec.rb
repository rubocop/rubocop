# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::NestedPercentLiteral do
  subject(:cop) { described_class.new }

  it 'registers no offense for empty array' do
    expect_no_offenses('%i[]')
  end

  it 'registers no offense for array' do
    expect_no_offenses('%i[a b c d xyz]')
  end

  it 'registers no offense for percent modifier character in isolation' do
    expect_no_offenses('%i[% %i %I %q %Q %r %s %w %W %x]')
  end

  it 'registers no offense for nestings under percent' do
    expect_no_offenses('%[a b %[c d] xyz]')
    expect_no_offenses('%[a b %i[c d] xyz]')
  end

  it 'registers no offense for percents in the middle of literals' do
    expect_no_offenses('%w[1%+ 2]')
  end

  it 'registers offense for nested percent literals' do
    expect_offense(<<-RUBY.strip_indent)
      %i[a b %i[c d] xyz]
      ^^^^^^^^^^^^^^^^^^^ Within percent literals, nested percent literals do not function and may be unwanted in the result.
    RUBY
  end

  it 'registers offense for repeated nested percent literals' do
    expect_offense(<<-RUBY.strip_indent)
      %i[a b %i[c d] %i[xyz]]
      ^^^^^^^^^^^^^^^^^^^^^^^ Within percent literals, nested percent literals do not function and may be unwanted in the result.
    RUBY
  end

  it 'registers offense for multiply nested percent literals' do
    # TODO: This emits only one offense for the entire snippet, though it
    # would be more correct to emit two offenses. This is tricky to fix, as
    # the AST parses %i[b, %i[c, and d]] as separate tokens.
    expect_offense(<<-RUBY.strip_indent)
      %i[a %i[b %i[c d]] xyz]
      ^^^^^^^^^^^^^^^^^^^^^^^ Within percent literals, nested percent literals do not function and may be unwanted in the result.
    RUBY
  end

  context 'when handling invalid UTF8 byte sequence' do
    it 'registers no offense for array' do
      expect_no_offenses('%W[\xff]')
    end

    it 'registers offense for nested percent literal' do
      source = '%W[\xff %W[]]'
      inspect_source(source)

      expect(cop.messages).to eq(['Within percent literals, nested percent' \
                                  ' literals do not function and may be' \
                                  ' unwanted in the result.'])
      expect(cop.highlights).to eq([source])
    end
  end
end
