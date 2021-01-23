# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::DuplicateRegexpCharacterClassElement do
  subject(:cop) { described_class.new }

  context 'with a repeated character class element' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        foo = /[xyx]/
                  ^ Duplicate element inside regexp character class
      RUBY

      expect_correction(<<~RUBY)
        foo = /[xy]/
      RUBY
    end
  end

  context 'with a repeated character class element with quantifier' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        foo = /[xyx]+/
                  ^ Duplicate element inside regexp character class
      RUBY

      expect_correction(<<~RUBY)
        foo = /[xy]+/
      RUBY
    end
  end

  context 'with no repeated character class elements' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        foo = /[xyz]/
      RUBY
    end
  end

  context 'with repeated elements in different character classes' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        foo = /[xyz][xyz]/
      RUBY
    end
  end

  context 'with a repeated character class element and %r{} literal' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        foo = %r{[xyx]}
                    ^ Duplicate element inside regexp character class
      RUBY

      expect_correction(<<~RUBY)
        foo = %r{[xy]}
      RUBY
    end
  end

  context 'with a repeated character class element inside a group' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        foo = /([xyx])/
                   ^ Duplicate element inside regexp character class
      RUBY

      expect_correction(<<~RUBY)
        foo = /([xy])/
      RUBY
    end
  end

  context 'with a repeated character posix character class inside a group' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        foo = /([[:alnum:]y[:alnum:]])/
                           ^^^^^^^^^ Duplicate element inside regexp character class
      RUBY

      expect_correction(<<~RUBY)
        foo = /([[:alnum:]y])/
      RUBY
    end
  end

  context 'with a repeated character class element with interpolation' do
    it 'registers an offense and corrects' do
      expect_offense(<<~'RUBY')
        foo = /([a#{foo}a#{bar}a])/
                        ^ Duplicate element inside regexp character class
                               ^ Duplicate element inside regexp character class
      RUBY

      expect_correction(<<~'RUBY')
        foo = /([a#{foo}#{bar}])/
      RUBY
    end
  end

  context 'with a repeated range element' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        foo = /[0-9x0-9]/
                    ^^^ Duplicate element inside regexp character class
      RUBY

      expect_correction(<<~RUBY)
        foo = /[0-9x]/
      RUBY
    end
  end

  context 'with a repeated intersection character class' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        foo = /[ab&&ab]/
      RUBY
    end
  end

  context 'with a range that covers a repeated element character class' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        foo = /[a-cb]/
      RUBY
    end
  end

  context 'with multiple regexps with the same interpolation' do
    it 'does not register an offense' do
      expect_no_offenses(<<~'RUBY')
        a_field.gsub!(/[#{bad_chars}]/, '')
        some_other_field.gsub!(/[#{bad_chars}]/, '')
      RUBY
    end
  end
end
