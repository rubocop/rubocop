# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::DuplicateSetEnumerables, :config do
  context 'when there is duplicated symbols in set' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Set.new[:otherkey, :key, :key]
                                 ^^^^ Duplicate enumerables found in Set.
                           ^^^^ Duplicate enumerables found in Set.
      RUBY
    end
  end

  context 'when there is no duplicated symbols in set' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        Set.new[:otherkey, :key]
      RUBY
    end
  end

  context 'when there is duplicated strings in set' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Set.new['otherkey', 'key', 'key']
                                   ^^^^^ Duplicate enumerables found in Set.
                            ^^^^^ Duplicate enumerables found in Set.
      RUBY
    end
  end

  context 'when there is no duplicated strings in set' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        Set.new['otherkey', 'key']
      RUBY
    end
  end

  context 'when there is duplicated numbers in set' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Set.new[1, 2, 2]
                      ^ Duplicate enumerables found in Set.
                   ^ Duplicate enumerables found in Set.
      RUBY
    end
  end

  context 'when there is no duplicated numbers in set' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        Set.new[1, 2]
      RUBY
    end
  end

  context 'when there is duplicated boolean in set' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Set.new[true, false, false]
                             ^^^^^ Duplicate enumerables found in Set.
                      ^^^^^ Duplicate enumerables found in Set.
      RUBY
    end
  end

  context 'when there is no duplicated boolean in set' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        Set.new[true, false]
      RUBY
    end
  end
end
