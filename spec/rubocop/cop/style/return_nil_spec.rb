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
      expect_no_offenses(<<-RUBY)
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
