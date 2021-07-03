# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceAroundSingletonClassOperator, :config do
  context 'when EnforcedStyle is space' do
    let(:cop_config) { { 'EnforcedStyle' => 'space' } }

    it 'registers an offense for no space to the left`' do
      expect_offense(<<~RUBY)
        class<< self
             ^^^ Use a single space around the singleton class operator.
        end
      RUBY
    end

    it 'registers an offense for no space to the right`' do
      expect_offense(<<~RUBY)
        class <<Other
             ^^^ Use a single space around the singleton class operator.
        end
      RUBY
    end

    it 'registers an offense for no space at all`' do
      expect_offense(<<~RUBY)
        class<<self
             ^^ Use a single space around the singleton class operator.
        end
      RUBY
    end

    it 'does not register an offense for << surrounded by single spaces' do
      expect_no_offenses(<<~RUBY)
        class << self
        end
      RUBY
    end
  end

  context 'when EnforcedStyle is no_space' do
    let(:cop_config) { { 'EnforcedStyle' => 'no_space' } }

    it 'registers an offense for space to the left`' do
      expect_offense(<<~RUBY)
        class <<self
             ^^^ Use no space around the singleton class operator.
        end
      RUBY
    end

    it 'registers an offense for space to the right`' do
      expect_offense(<<~RUBY)
        class<< self
             ^^^ Use no space around the singleton class operator.
        end
      RUBY
    end

    it 'does not register an offense for << surrounded by no space' do
      expect_no_offenses(<<~RUBY)
        class<<self
        end
      RUBY
    end
  end
end
