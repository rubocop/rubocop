# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::MultilineHashBraceLayout, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'EnforcedStyle' => 'symmetrical' } }

  it 'ignores implicit hashes' do
    expect_no_offenses(<<-RUBY.strip_indent)
      foo(a: 1,
      b: 2)
    RUBY
  end

  it 'ignores single-line hashes' do
    expect_no_offenses('{a: 1, b: 2}')
  end

  it 'ignores empty hashes' do
    expect_no_offenses('{}')
  end

  it_behaves_like 'multiline literal brace layout' do
    let(:open) { '{' }
    let(:close) { '}' }
    let(:a) { 'a: 1' }
    let(:b) { 'b: 2' }
    let(:multi_prefix) { 'b: ' }
    let(:multi) do
      <<-RUBY.strip_indent.chomp
        [
        1
        ]
      RUBY
    end
  end

  it_behaves_like 'multiline literal brace layout method argument' do
    let(:open) { '{' }
    let(:close) { '}' }
    let(:a) { 'a: 1' }
    let(:b) { 'b: 2' }
  end

  it_behaves_like 'multiline literal brace layout trailing comma' do
    let(:open) { '{' }
    let(:close) { '}' }
    let(:a) { 'a: 1' }
    let(:b) { 'b: 2' }
  end
end
