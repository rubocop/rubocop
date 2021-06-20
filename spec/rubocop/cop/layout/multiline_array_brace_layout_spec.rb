# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::MultilineArrayBraceLayout, :config do
  let(:cop_config) { { 'EnforcedStyle' => 'symmetrical' } }

  it 'ignores implicit arrays' do
    expect_no_offenses(<<~RUBY)
      foo = a,
      b
    RUBY
  end

  it 'ignores single-line arrays' do
    expect_no_offenses('[a, b, c]')
  end

  it 'ignores empty arrays' do
    expect_no_offenses('[]')
  end

  it_behaves_like 'multiline literal brace layout' do
    let(:open) { '[' }
    let(:close) { ']' }
  end

  it_behaves_like 'multiline literal brace layout method argument' do
    let(:open) { '[' }
    let(:close) { ']' }
    let(:a) { 'a: 1' }
    let(:b) { 'b: 2' }
  end

  it_behaves_like 'multiline literal brace layout trailing comma' do
    let(:open) { '[' }
    let(:close) { ']' }

    let(:same_line_message) do
      'The closing array brace must be on the same line as the last array ' \
        'element when the opening [...]'
    end
    let(:always_same_line_message) do
      'The closing array brace must be on the same line as the last array ' \
        'element.'
    end
  end

  context 'when comment present before closing brace' do
    it 'corrects closing brace without crashing' do
      expect_offense(<<~RUBY)
        {
          key1: [a, # comment 1
                b # comment 2
          ],
          ^ The closing array brace must be on the same line as the last array element when the opening brace is on the same line as the first array element.
          key2: 'foo'
        }
      RUBY

      expect_correction(<<~RUBY)
        {
          key1: [a, # comment 1
                b], # comment 2
          key2: 'foo'
        }
      RUBY
    end
  end
end
