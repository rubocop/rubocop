# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NegatedUnless do
  subject(:cop) do
    config = RuboCop::Config.new(
      'Style/NegatedUnless' => {
        'SupportedStyles' => %w[both prefix postfix],
        'EnforcedStyle' => 'both'
      }
    )
    described_class.new(config)
  end

  describe 'with “both” style' do
    it 'registers an offense for unless with exclamation point condition' do
      expect_offense(<<~RUBY)
        unless !a_condition
        ^^^^^^^^^^^^^^^^^^^ Favor `if` over `unless` for negative conditions.
          some_method
        end
        some_method unless !a_condition
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor `if` over `unless` for negative conditions.
      RUBY

      expect_correction(<<~RUBY)
        if a_condition
          some_method
        end
        some_method if a_condition
      RUBY
    end

    it 'registers an offense for unless with "not" condition' do
      expect_offense(<<~RUBY)
        unless not a_condition
        ^^^^^^^^^^^^^^^^^^^^^^ Favor `if` over `unless` for negative conditions.
          some_method
        end
        some_method unless not a_condition
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor `if` over `unless` for negative conditions.
      RUBY

      expect_correction(<<~RUBY)
        if a_condition
          some_method
        end
        some_method if a_condition
      RUBY
    end

    it 'accepts an unless/else with negative condition' do
      expect_no_offenses(<<~RUBY)
        unless !a_condition
          some_method
        else
          something_else
        end
      RUBY
    end

    it 'accepts an unless where only part of the condition is negated' do
      expect_no_offenses(<<~RUBY)
        unless !condition && another_condition
          some_method
        end
        unless not condition or another_condition
          some_method
        end
        some_method unless not condition or another_condition
      RUBY
    end

    it 'accepts an unless where the condition is doubly negated' do
      expect_no_offenses(<<~RUBY)
        unless !!condition
          some_method
        end
        some_method unless !!condition
      RUBY
    end

    it 'autocorrects by replacing parenthesized unless not with if' do
      expect_offense(<<~RUBY)
        something unless (!x.even?)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor `if` over `unless` for negative conditions.
      RUBY

      expect_correction(<<~RUBY)
        something if (x.even?)
      RUBY
    end
  end

  describe 'with “prefix” style' do
    subject(:cop) do
      config = RuboCop::Config.new(
        'Style/NegatedUnless' => {
          'SupportedStyles' => %w[both prefix postfix],
          'EnforcedStyle' => 'prefix'
        }
      )

      described_class.new(config)
    end

    it 'registers an offense for prefix' do
      expect_offense(<<~RUBY)
        unless !foo
        ^^^^^^^^^^^ Favor `if` over `unless` for negative conditions.
        end
      RUBY

      expect_correction(<<~RUBY)
        if foo
        end
      RUBY
    end

    it 'does not register an offense for postfix' do
      expect_no_offenses('foo unless !bar')
    end
  end

  describe 'with “postfix” style' do
    subject(:cop) do
      config = RuboCop::Config.new(
        'Style/NegatedUnless' => {
          'SupportedStyles' => %w[both prefix postfix],
          'EnforcedStyle' => 'postfix'
        }
      )

      described_class.new(config)
    end

    it 'registers an offense for postfix' do
      expect_offense(<<~RUBY)
        foo unless !bar
        ^^^^^^^^^^^^^^^ Favor `if` over `unless` for negative conditions.
      RUBY

      expect_correction(<<~RUBY)
        foo if bar
      RUBY
    end

    it 'does not register an offense for prefix' do
      expect_no_offenses(<<~RUBY)
        unless !foo
        end
      RUBY
    end
  end

  it 'does not blow up for ternary ops' do
    expect_no_offenses('a ? b : c')
  end

  it 'does not blow up on a negated ternary operator' do
    expect_no_offenses('!foo.empty? ? :bar : :baz')
  end

  it 'does not blow up for empty if condition' do
    expect_no_offenses(<<~RUBY)
      if ()
      end
    RUBY
  end

  it 'does not blow up for empty unless condition' do
    expect_no_offenses(<<~RUBY)
      unless ()
      end
    RUBY
  end
end
