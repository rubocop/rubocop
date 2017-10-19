# frozen_string_literal: true

describe RuboCop::Cop::Layout::MultilineMethodCallBraceLayout, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'EnforcedStyle' => 'symmetrical' } }

  it 'ignores implicit calls' do
    expect_no_offenses(<<-RUBY.strip_indent)
      foo 1,
      2
    RUBY
  end

  it 'ignores single-line calls' do
    expect_no_offenses('foo(1,2)')
  end

  it 'ignores calls without arguments' do
    expect_no_offenses('puts')
  end

  it 'ignores calls with an empty brace' do
    expect_no_offenses('puts()')
  end

  it 'ignores calls with a multiline empty brace ' do
    expect_no_offenses(<<-RUBY.strip_indent)
      puts(
      )
    RUBY
  end

  include_examples 'multiline literal brace layout' do
    let(:open) { 'foo(' }
    let(:close) { ')' }
  end

  include_examples 'multiline literal brace layout trailing comma' do
    let(:open) { 'foo(' }
    let(:close) { ')' }
  end

  context 'when EnforcedStyle is new_line' do
    let(:cop_config) { { 'EnforcedStyle' => 'new_line' } }

    it 'still ignores single-line calls' do
      expect_no_offenses('puts("Hello world!")')
    end

    it 'ignores single-line calls with multi-line receiver' do
      expect_no_offenses(<<-RUBY.strip_indent)
        [
        ].join(" ")
      RUBY
    end

    it 'ignores single-line calls with multi-line receiver with leading dot' do
      expect_no_offenses(<<-RUBY.strip_indent)
        [
        ]
        .join(" ")
      RUBY
    end
  end
end
