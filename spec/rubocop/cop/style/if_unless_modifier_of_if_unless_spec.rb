# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::IfUnlessModifierOfIfUnless do
  include StatementModifierHelper

  subject(:cop) { described_class.new }

  it 'provides a good error message' do
    expect_offense(<<~RUBY)
      condition ? then_part : else_part unless external_condition
                                        ^^^^^^ Avoid modifier `unless` after another conditional.
    RUBY
  end

  context 'ternary with modifier' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        condition ? then_part : else_part unless external_condition
                                          ^^^^^^ Avoid modifier `unless` after another conditional.
      RUBY
    end
  end

  context 'conditional with modifier' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        unless condition
          then_part
        end if external_condition
            ^^ Avoid modifier `if` after another conditional.
      RUBY
    end
  end

  context 'conditional with modifier in body' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        if condition
          then_part if maybe?
        end
      RUBY
    end
  end

  context 'nested conditionals' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        if external_condition
          if condition
            then_part
          end
        end
      RUBY
    end
  end
end
