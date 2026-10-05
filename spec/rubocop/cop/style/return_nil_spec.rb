# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ReturnNil, :config do
  context 'when enforced style is `return`' do
    let(:config) do
      RuboCop::Config.new(
        'Style/ReturnNil' => {
          'EnforcedStyle' => 'return',
          'SupportedStyles' => %w[return return_nil]
        }
      )
    end

    it 'registers an offense for return nil' do
      expect_offense(<<~RUBY)
        return nil
        ^^^^^^^^^^ Use `return` instead of `return nil`.
      RUBY

      expect_correction(<<~RUBY)
        return
      RUBY
    end

    it 'does not register an offense for returning others' do
      expect_no_offenses('return 2')
    end

    it 'does not register an offense for return nil from iterators' do
      expect_no_offenses(<<~RUBY)
        loop do
          return if x
        end
      RUBY
    end
  end

  context 'when enforced style is `return_nil`' do
    let(:config) do
      RuboCop::Config.new(
        'Style/ReturnNil' => {
          'EnforcedStyle' => 'return_nil',
          'SupportedStyles' => %w[return return_nil]
        }
      )
    end

    it 'registers an offense and adds parentheses for return as an operand of `||`' do
      expect_offense(<<~RUBY)
        def foo
          bar || return
                 ^^^^^^ Use `return nil` instead of `return`.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo
          bar || (return nil)
        end
      RUBY
    end

    it 'registers an offense and adds parentheses for return in a ternary operator' do
      expect_offense(<<~RUBY)
        def foo
          x = bar ? return : baz
                    ^^^^^^ Use `return nil` instead of `return`.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo
          x = bar ? (return nil) : baz
        end
      RUBY
    end

    it 'registers an offense without adding parentheses for return as an operand of `or`' do
      expect_offense(<<~RUBY)
        def foo
          bar or return
                 ^^^^^^ Use `return nil` instead of `return`.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo
          bar or return nil
        end
      RUBY
    end

    it 'registers an offense for return' do
      expect_offense(<<~RUBY)
        return
        ^^^^^^ Use `return nil` instead of `return`.
      RUBY

      expect_correction(<<~RUBY)
        return nil
      RUBY
    end

    it 'does not register an offense for returning others' do
      expect_no_offenses('return 2')
    end
  end
end
