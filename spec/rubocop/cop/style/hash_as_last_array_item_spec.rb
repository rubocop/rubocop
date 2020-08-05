# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::HashAsLastArrayItem, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is braces' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'braces' }
    end

    it 'registers an offense and corrects when hash without braces' do
      expect_offense(<<~RUBY)
        [1, 2, one: 1, two: 2]
               ^^^^^^^^^^^^^^ Wrap hash in `{` and `}`.
      RUBY

      expect_correction(<<~RUBY)
        [1, 2, {one: 1, two: 2}]
      RUBY
    end

    it 'does not register an offense when hash with braces' do
      expect_no_offenses(<<~RUBY)
        [1, 2, { one: 1, two: 2 }]
      RUBY
    end

    it 'does not register an offense when hash is not inside array' do
      expect_no_offenses(<<~RUBY)
        foo(one: 1, two: 2)
      RUBY
    end
  end

  context 'when EnforcedStyle is no_braces' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'no_braces' }
    end

    it 'registers an offense and corrects when hash with braces' do
      expect_offense(<<~RUBY)
        [{ one: 1 }, 2, { three: 3 }]
                        ^^^^^^^^^^^^ Omit the braces around the hash.
      RUBY

      expect_correction(<<~RUBY)
        [{ one: 1 }, 2,  three: 3 ]
      RUBY
    end

    it 'does not register an offense when hash without braces' do
      expect_no_offenses(<<~RUBY)
        [1, 2, one: 1, two: 2]
      RUBY
    end

    it 'does not register an offense when hash is not inside array' do
      expect_no_offenses(<<~RUBY)
        foo({ one: 1, two: 2 })
      RUBY
    end
  end
end
