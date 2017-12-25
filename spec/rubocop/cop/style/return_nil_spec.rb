# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ReturnNil do
  subject(:cop) { described_class.new(config) }

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
      expect_offense(<<-RUBY.strip_indent)
        return nil
        ^^^^^^^^^^ Use `return` instead of `return nil`.
      RUBY
    end

    it 'auto-corrects `return nil` into `return`' do
      expect(autocorrect_source('return nil')).to eq 'return'
    end

    it 'does not register an offense for return' do
      expect_no_offenses('return')
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
      expect_offense(<<-RUBY.strip_indent)
        return
        ^^^^^^ Use `return nil` instead of `return`.
      RUBY
    end

    it 'auto-corrects `return` into `return nil`' do
      expect(autocorrect_source('return')).to eq 'return nil'
    end

    it 'does not register an offense for return nil' do
      expect_no_offenses('return nil')
    end

    it 'does not register an offense for returning others' do
      expect_no_offenses('return 2')
    end
  end
end
