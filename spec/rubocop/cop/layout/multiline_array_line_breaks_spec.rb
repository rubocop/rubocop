# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::MultilineArrayLineBreaks, :config do
  context 'when on same line' do
    it 'does not add any offenses' do
      expect_no_offenses(<<~RUBY)
        [1,2,3]
      RUBY
    end
  end

  context 'when on same line, separate line from brackets' do
    it 'does not add any offenses' do
      expect_no_offenses(<<~RUBY)
        [
          1,2,3,
        ]
      RUBY
    end
  end

  context 'when two elements on same line' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        [1,
          2, 4]
             ^ Each item in a multi-line array must start on a separate line.
      RUBY

      expect_correction(<<~RUBY)
        [1,
          2,\s
        4]
      RUBY
    end
  end

  context 'when nested arrays' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        [1,
          [2, 3], 4]
                  ^ Each item in a multi-line array must start on a separate line.
      RUBY

      expect_correction(<<~RUBY)
        [1,
          [2, 3],\s
        4]
      RUBY
    end
  end

  context 'ignore last element' do
    let(:cop_config) { { 'AllowMultilineFinalElement' => true } }

    it 'ignores last value that is a multiline hash' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3, {
          a: 1
        }]
      RUBY
    end

    it 'registers and corrects values that are multiline hashes and not the last value' do
      expect_offense(<<~RUBY)
        [1, 2, 3, {
                  ^ Each item in a multi-line array must start on a separate line.
               ^ Each item in a multi-line array must start on a separate line.
            ^ Each item in a multi-line array must start on a separate line.
          a: 1
        }, 4]
      RUBY

      expect_correction(<<~RUBY)
        [1,#{trailing_whitespace}
        2,#{trailing_whitespace}
        3,#{trailing_whitespace}
        {
          a: 1
        },#{trailing_whitespace}
        4]
      RUBY
    end
  end
end
