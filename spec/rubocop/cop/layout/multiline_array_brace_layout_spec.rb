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

  context 'when `Layout/SpaceInsideArrayLiteralBrackets` uses the `compact` style' do
    let(:cop_config) { { 'EnforcedStyle' => 'new_line' } }
    let(:other_cops) do
      {
        'Layout/SpaceInsideArrayLiteralBrackets' => {
          'Enabled' => true, 'EnforcedStyle' => 'compact'
        }
      }
    end

    it 'does not register an offense when the last element is an array literal' do
      expect_no_offenses(<<~RUBY)
        [[1, 2],
         [3, 4]]
      RUBY
    end

    it 'registers an offense when the last element is an index call' do
      expect_offense(<<~RUBY)
        [[1, 2],
         foo[3]]
               ^ The closing array brace must be on the line after the last array element.
      RUBY
    end

    it 'registers an offense when the last element is not an array literal' do
      expect_offense(<<~RUBY)
        [[1, 2],
         3]
          ^ The closing array brace must be on the line after the last array element.
      RUBY
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

  context 'when EnforcedStyle is same_line' do
    let(:cop_config) { { 'EnforcedStyle' => 'same_line' } }

    it 'registers an offense and corrects a nested array whose closing bracket follows a comment line' do
      expect_offense(<<~RUBY)
        foo = [
          [
            1,
            # comment
          ]
          ^ The closing array brace must be on the same line as the last array element.
        ]
        ^ The closing array brace must be on the same line as the last array element.
      RUBY

      expect_correction(<<~RUBY)
        foo = [
          [
            1,]]
            # comment
      RUBY
    end

    it 'registers an offense and corrects a closing bracket followed by an argument after a comment line' do
      expect_offense(<<~RUBY)
        foo([
          1,
          # comment
        ], bar)
        ^ The closing array brace must be on the same line as the last array element.
      RUBY

      expect_correction(<<~RUBY)
        foo([
          1,], bar)
          # comment
      RUBY
    end

    it 'registers an offense and corrects a nested array whose closing bracket is followed by an element after a comment line' do
      expect_offense(<<~RUBY)
        foo = [
          [
            1,
            # comment
          ], 2
          ^ The closing array brace must be on the same line as the last array element.
        ]
        ^ The closing array brace must be on the same line as the last array element.
      RUBY

      expect_correction(<<~RUBY)
        foo = [
          [
            1,], 2]
            # comment
      RUBY
    end
  end
end
