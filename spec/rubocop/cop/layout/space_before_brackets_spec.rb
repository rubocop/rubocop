# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceBeforeBrackets, :config do
  subject(:cop) { described_class.new(config) }

  context 'when referencing' do
    it 'registers an offense and corrects when using space between receiver and left brackets' do
      expect_offense(<<~RUBY)
        collection [index_or_key]
                  ^ Remove the space before the opening brackets.
      RUBY

      expect_correction(<<~RUBY)
        collection[index_or_key]
      RUBY
    end

    it 'does not register an offense when not using space between receiver and left brackets' do
      expect_no_offenses(<<~RUBY)
        collection[index_or_key]
      RUBY
    end

    it 'does not register an offense when array literal argument is enclosed in parentheses' do
      expect_no_offenses(<<~RUBY)
        collection([index_or_key])
      RUBY
    end

    it 'does not register an offense when it is used as a method argument' do
      expect_no_offenses(<<~RUBY)
        expect(offenses).to eq []
      RUBY
    end

    it 'does not register an offense when using multiple arguments' do
      expect_no_offenses(<<~RUBY)
        do_something [foo], bar
      RUBY
    end

    it 'does not register an offense when without receiver' do
      expect_no_offenses(<<~RUBY)
        [index_or_key]
      RUBY
    end
  end

  context 'when assigning' do
    it 'registers an offense and corrects when using space between receiver and left brackets' do
      expect_offense(<<~RUBY)
        @correction [index_or_key] = :value
                   ^ Remove the space before the opening brackets.
      RUBY

      expect_correction(<<~RUBY)
        @correction[index_or_key] = :value
      RUBY
    end

    it 'does not register an offense when not using space between receiver and left brackets' do
      expect_no_offenses(<<~RUBY)
        @correction[index_or_key] = :value
      RUBY
    end
  end

  it 'does not register an offense when assigning an array' do
    expect_no_offenses(<<~RUBY)
      task.options = ['--no-output']
    RUBY
  end
end
