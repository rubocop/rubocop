# frozen_string_literal: true

describe RuboCop::Cop::Layout::MultilineArrayBraceLayout, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'EnforcedStyle' => 'symmetrical' } }

  it 'ignores implicit arrays' do
    inspect_source(cop, <<-END.strip_indent)
      foo = a,
      b
    END

    expect(cop.offenses).to be_empty
  end

  it 'ignores single-line arrays' do
    expect_no_offenses('[a, b, c]')
  end

  it 'ignores empty arrays' do
    expect_no_offenses('[]')
  end

  include_examples 'multiline literal brace layout' do
    let(:open) { '[' }
    let(:close) { ']' }
  end

  include_examples 'multiline literal brace layout trailing comma' do
    let(:open) { '[' }
    let(:close) { ']' }
  end
end
