# frozen_string_literal: true

describe RuboCop::Cop::Layout::MultilineHashBraceLayout, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'EnforcedStyle' => 'symmetrical' } }

  it 'ignores implicit hashes' do
    expect_no_offenses(<<-END.strip_indent)
      foo(a: 1,
      b: 2)
    END
  end

  it 'ignores single-line hashes' do
    expect_no_offenses('{a: 1, b: 2}')
  end

  it 'ignores empty hashes' do
    expect_no_offenses('{}')
  end

  include_examples 'multiline literal brace layout' do
    let(:open) { '{' }
    let(:close) { '}' }
    let(:a) { 'a: 1' }
    let(:b) { 'b: 2' }
    let(:multi_prefix) { 'b: ' }
    let(:multi) { ['[', '1', ']'] }
  end

  include_examples 'multiline literal brace layout trailing comma' do
    let(:open) { '{' }
    let(:close) { '}' }
    let(:a) { 'a: 1' }
    let(:b) { 'b: 2' }
  end
end
