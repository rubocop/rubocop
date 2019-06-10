# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ProceduralConditionStatement, :config do
  subject(:cop) { described_class.new(config) }

  it 'registers an offense when using `case`' do
    expect_offense(<<~RUBY)
      case statement
      ^^^^ Avoid condition statement.
      when condition
        stuff
      else
        something
      end
    RUBY
  end

  context 'with default config' do
    it 'registers an offense when using `if`' do
      expect_offense(<<~RUBY)
        if condition
        ^^ Avoid condition statement.
          something
        end
      RUBY
    end

    it 'registers an offense when using modifier form' do
      expect_offense(<<~RUBY)
        variable = something if condition
                             ^^ Avoid condition statement.
      RUBY
    end

    it 'registers an offense when using guard clause' do
      expect_offense(<<~RUBY)
        def stuff
          return if condition
                 ^^ Avoid condition statement.
          something
        end
      RUBY
    end

    it 'registers an offense when using ternary operator' do
      expect_offense(<<~RUBY)
        condition ? stuff : something
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid condition statement.
      RUBY
    end
  end

  context 'with `AllowModifierForm` set' do
    let(:cop_config) do
      {
        'AllowModifierForm' => true
      }
    end

    it 'registers an offense when using `if`' do
      expect_offense(<<~RUBY)
        if condition
        ^^ Avoid condition statement.
          something
        end
      RUBY
    end

    it 'does not register an offense when using modifier form' do
      expect_no_offenses(<<~RUBY)
        variable = something if condition
      RUBY
    end

    it 'registers an offense when using guard clause' do
      expect_offense(<<~RUBY)
        def stuff
          return if condition
                 ^^ Avoid condition statement.
          something
        end
      RUBY
    end
  end

  context 'with `AllowGuardClause`' do
    let(:cop_config) do
      {
        'AllowGuardClause' => true
      }
    end

    it 'registers an offense when using `if`' do
      expect_offense(<<~RUBY)
        if condition
        ^^ Avoid condition statement.
          something
        end
      RUBY
    end

    it 'registers an offense when using modifier form' do
      expect_offense(<<~RUBY)
        variable = something if condition
                             ^^ Avoid condition statement.
      RUBY
    end

    it 'does not register an offense when using guard clause' do
      expect_no_offenses(<<~RUBY)
        def stuff
          return if condition
          something
        end
      RUBY
    end
  end

  context 'with `AllowTernaryOperator`' do
    let(:cop_config) do
      {
        'AllowTernaryOperator' => true
      }
    end

    it 'registers an offense when using `if`' do
      expect_offense(<<~RUBY)
        if condition
        ^^ Avoid condition statement.
          something
        end
      RUBY
    end

    it 'registers an offense when using modifier form' do
      expect_offense(<<~RUBY)
        variable = something if condition
                             ^^ Avoid condition statement.
      RUBY
    end

    it 'registers an offense when using guard clause' do
      expect_offense(<<~RUBY)
        def stuff
          return if condition
                 ^^ Avoid condition statement.
          something
        end
      RUBY
    end

    it 'does not register an offense when using ternary operator' do
      expect_no_offenses(<<~RUBY)
        condition ? stuff : something
      RUBY
    end
  end
end
