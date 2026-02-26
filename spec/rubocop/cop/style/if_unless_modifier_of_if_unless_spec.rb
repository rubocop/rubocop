# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::IfUnlessModifierOfIfUnless, :config do
  it 'provides a good error message' do
    expect_offense(<<~RUBY)
      condition ? then_part : else_part unless external_condition
                                        ^^^^^^ Avoid modifier `unless` after another conditional.
    RUBY

    expect_correction(<<~RUBY)
      unless external_condition
      condition ? then_part : else_part
      end
    RUBY
  end

  context 'ternary with modifier' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        condition ? then_part : else_part unless external_condition
                                          ^^^^^^ Avoid modifier `unless` after another conditional.
      RUBY

      expect_correction(<<~RUBY)
        unless external_condition
        condition ? then_part : else_part
        end
      RUBY
    end
  end

  context 'conditional with modifier' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        unless condition
          then_part
        end if external_condition
            ^^ Avoid modifier `if` after another conditional.
      RUBY

      expect_correction(<<~RUBY)
        if external_condition
        unless condition
          then_part
        end
        end
      RUBY
    end
  end

  context '`unless` / `else` with modifier' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        unless condition
          then_part
        else
          else_part
        end if external_condition
            ^^ Avoid modifier `if` after another conditional.
      RUBY

      expect_correction(<<~RUBY)
        if external_condition
        unless condition
          then_part
        else
          else_part
        end
        end
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
