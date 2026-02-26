# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NegatedIf do
  subject(:cop) do
    config = RuboCop::Config.new(
      'Style/NegatedIf' => {
        'SupportedStyles' => %w[both prefix postfix],
        'EnforcedStyle' => 'both'
      }
    )
    described_class.new(config)
  end

  describe 'with “both” style' do
    it 'registers an offense for if with exclamation point condition' do
      expect_offense(<<~RUBY)
        if !a_condition
        ^^^^^^^^^^^^^^^ Favor `unless` over `if` for negative conditions.
          some_method
        end
        some_method if !a_condition
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor `unless` over `if` for negative conditions.
      RUBY

      expect_correction(<<~RUBY)
        unless a_condition
          some_method
        end
        some_method unless a_condition
      RUBY
    end

    it 'registers an offense for if with "not" condition' do
      expect_offense(<<~RUBY)
        if not a_condition
        ^^^^^^^^^^^^^^^^^^ Favor `unless` over `if` for negative conditions.
          some_method
        end
        some_method if not a_condition
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor `unless` over `if` for negative conditions.
      RUBY

      expect_correction(<<~RUBY)
        unless a_condition
          some_method
        end
        some_method unless a_condition
      RUBY
    end

    it 'accepts an if/else with negative condition' do
      expect_no_offenses(<<~RUBY)
        if !a_condition
          some_method
        else
          something_else
        end
        if not a_condition
          some_method
        elsif other_condition
          something_else
        end
      RUBY
    end

    it 'accepts an if where only part of the condition is negated' do
      expect_no_offenses(<<~RUBY)
        if !condition && another_condition
          some_method
        end
        if not condition or another_condition
          some_method
        end
        some_method if not condition or another_condition
      RUBY
    end

    it 'accepts an if where the condition is doubly negated' do
      expect_no_offenses(<<~RUBY)
        if !!condition
          some_method
        end
        some_method if !!condition
      RUBY
    end

    it 'is not confused by negated elsif' do
      expect_no_offenses(<<~RUBY)
        if test.is_a?(String)
          3
        elsif test.is_a?(Array)
          2
        elsif !test.nil?
          1
        end
      RUBY
    end

    it 'autocorrects by replacing parenthesized if not with unless' do
      expect_offense(<<~RUBY)
        something if (!x.even?)
        ^^^^^^^^^^^^^^^^^^^^^^^ Favor `unless` over `if` for negative conditions.
      RUBY

      expect_correction(<<~RUBY)
        something unless (x.even?)
      RUBY
    end
  end

  describe 'with “prefix” style' do
    subject(:cop) do
      config = RuboCop::Config.new(
        'Style/NegatedIf' => {
          'SupportedStyles' => %w[both prefix postfix],
          'EnforcedStyle' => 'prefix'
        }
      )

      described_class.new(config)
    end

    it 'registers an offense for prefix' do
      expect_offense(<<~RUBY)
        if !foo
        ^^^^^^^ Favor `unless` over `if` for negative conditions.
        end
      RUBY

      expect_correction(<<~RUBY)
        unless foo
        end
      RUBY
    end

    it 'does not register an offense for postfix' do
      expect_no_offenses('foo if !bar')
    end
  end

  describe 'with “postfix” style' do
    subject(:cop) do
      config = RuboCop::Config.new(
        'Style/NegatedIf' => {
          'SupportedStyles' => %w[both prefix postfix],
          'EnforcedStyle' => 'postfix'
        }
      )

      described_class.new(config)
    end

    it 'registers an offense for postfix' do
      expect_offense(<<~RUBY)
        foo if !bar
        ^^^^^^^^^^^ Favor `unless` over `if` for negative conditions.
      RUBY

      expect_correction(<<~RUBY)
        foo unless bar
      RUBY
    end

    it 'does not register an offense for prefix' do
      expect_no_offenses(<<~RUBY)
        if !foo
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
