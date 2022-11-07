# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::HashAsLastArrayItem, :config do
  context 'when EnforcedStyle is braces' do
    let(:cop_config) { { 'EnforcedStyle' => 'braces' } }

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

    it 'does not register an offense when the array is all hashes' do
      expect_no_offenses(<<~RUBY)
        [{ one: 1 }, { two: 2 }]
      RUBY
    end

    it 'does not register an offense when the hash is empty' do
      expect_no_offenses(<<~RUBY)
        [1, {}]
      RUBY
    end

    it 'does not register an offense when using double splat operator' do
      expect_no_offenses(<<~RUBY)
        [1, **options]
      RUBY
    end
  end

  context 'when EnforcedStyle is no_braces' do
    let(:cop_config) { { 'EnforcedStyle' => 'no_braces' } }

    it 'registers an offense and corrects when hash with braces' do
      expect_offense(<<~RUBY)
        [{ one: 1 }, { three: 3 }, 2, { three: 3 }]
                                      ^^^^^^^^^^^^ Omit the braces around the hash.
      RUBY

      expect_correction(<<~RUBY)
        [{ one: 1 }, { three: 3 }, 2,  three: 3 ]
      RUBY
    end

    it 'registers an offense and corrects when hash with braces and trailing comma' do
      expect_offense(<<~RUBY)
        [1, 2, { one: 1, two: 2, },]
               ^^^^^^^^^^^^^^^^^^^ Omit the braces around the hash.
      RUBY

      expect_correction(<<~RUBY)
        [1, 2,  one: 1, two: 2, ]
      RUBY
    end

    it 'registers an offense and corrects when hash with braces and trailing comma and new line' do
      expect_offense(<<~RUBY)
        [
          1,
          2,
          {
          ^ Omit the braces around the hash.
            one: 1,
            two: 2,
          },
        ]
      RUBY

      expect_correction(<<~RUBY)
        [
          1,
          2,
        #{'  '}
            one: 1,
            two: 2,
        #{'  '}
        ]
      RUBY
    end

    it 'does not register an offense when hash is not the last element' do
      expect_no_offenses(<<~RUBY)
        [
          1,
          2,
          {
            one: 1
          },
          two: 2
        ]
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

    it 'does not register an offense when the array is all hashes' do
      expect_no_offenses(<<~RUBY)
        [{ one: 1 }, { two: 2 }]
      RUBY
    end

    it 'does not register an offense when the hash is empty' do
      expect_no_offenses(<<~RUBY)
        [1, {}]
      RUBY
    end

    it 'does not register an offense when passing an implicit array to a setter' do
      expect_no_offenses(<<~RUBY)
        cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }
      RUBY
    end
  end
end
