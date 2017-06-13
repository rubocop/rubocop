# frozen_string_literal: true

describe RuboCop::Cop::Layout::BlockEndNewline do
  subject(:cop) { described_class.new }

  it 'does not register an offense for a one-liner' do
    expect_no_offenses('test do foo end')
  end

  it 'does not register an offense for multiline blocks with newlines before '\
     'the end' do
    inspect_source(<<-RUBY.strip_indent)
      test do
        foo
      end
    RUBY
    expect(cop.messages).to be_empty
  end

  it 'registers an offense when multiline block end is not on its own line' do
    expect_offense(<<-RUBY.strip_indent)
      test do
        foo end
            ^^^ Expression at 2, 7 should be on its own line.
    RUBY
  end

  it 'registers an offense when multiline block } is not on its own line' do
    expect_offense(<<-RUBY.strip_indent)
      test {
        foo }
            ^ Expression at 2, 7 should be on its own line.
    RUBY
  end

  it 'autocorrects a do/end block where the end is not on its own line' do
    src = <<-RUBY.strip_indent
      test do
        foo end
    RUBY

    new_source = autocorrect_source(cop, src)

    expect(new_source).to eq(['test do',
                              '  foo ',
                              'end',
                              ''].join("\n"))
  end

  it 'autocorrects a {} block where the } is not on its own line' do
    src = <<-RUBY.strip_indent
      test {
        foo }
    RUBY

    new_source = autocorrect_source(cop, src)

    expect(new_source).to eq(['test {',
                              '  foo ',
                              '}',
                              ''].join("\n"))
  end
end
