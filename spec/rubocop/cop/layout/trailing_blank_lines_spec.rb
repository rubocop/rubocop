# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::TrailingBlankLines, :config do
  subject(:cop) { described_class.new(config) }

  it 'accepts final newline' do
    expect_no_offenses("x = 0\n")
  end

  it 'accepts an empty file' do
    expect_no_offenses('')
  end

  it 'accepts final blank lines if they come after __END__' do
    expect_no_offenses(<<-RUBY.strip_indent)
        x = 0

        __END__

      RUBY
  end

  it 'accepts final blank lines if they come after __END__ in empty file' do
    expect_no_offenses(<<-RUBY.strip_indent)
        __END__


      RUBY
  end

  it 'registers an offense for multiple trailing blank lines' do
    inspect_source(['x = 0', '', '', '', ''])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['3 trailing blank lines detected.'])
  end

  it 'registers an offense for multiple blank lines in an empty file' do
    inspect_source(['', '', '', '', ''])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['3 trailing blank lines detected.'])
  end

  it 'registers an offense for no final newline after assignment' do
    inspect_source('x = 0')
    expect(cop.messages).to eq(['Final newline missing.'])
  end

  it 'registers an offense for no final newline after block comment' do
    inspect_source("puts 'testing rubocop when final new line is missing " \
                   "after block comments'\n\n=begin\nfirst line\nsecond " \
                   "line\nthird line\n=end")

    expect(cop.messages).to eq(['Final newline missing.'])
  end

  it 'auto-corrects unwanted blank lines' do
    new_source = autocorrect_source(['x = 0', '', '', '', ''])
    expect(new_source).to eq(['x = 0', ''].join("\n"))
  end

  it 'auto-corrects unwanted blank lines in an empty file' do
    new_source = autocorrect_source(['', '', '', '', ''])
    expect(new_source).to eq(['', ''].join("\n"))
  end

  it 'auto-corrects even if some lines have space' do
    new_source = autocorrect_source(['x = 0', '', '  ', '', ''])
    expect(new_source).to eq(['x = 0', ''].join("\n"))
  end
end
