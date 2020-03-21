# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::MultilineArrayLineBreaks do
  subject(:cop) { described_class.new }

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
end
