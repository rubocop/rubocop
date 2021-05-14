# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::ConditionPosition, :config do
  %w[if unless while until].each do |keyword|
    it 'registers an offense and corrects for condition on the next line' do
      expect_offense(<<~RUBY)
        #{keyword}
        x == 10
        ^^^^^^^ Place the condition on the same line as `#{keyword}`.
        end
      RUBY

      expect_correction(<<~RUBY)
        #{keyword} x == 10
        end
      RUBY
    end

    it 'accepts condition on the same line' do
      expect_no_offenses(<<~RUBY)
        #{keyword} x == 10
         bala
        end
      RUBY
    end

    it 'accepts condition on a different line for modifiers' do
      expect_no_offenses(<<~RUBY)
        do_something #{keyword}
          something && something_else
      RUBY
    end
  end

  it 'registers an offense and corrects for elsif condition on the next line' do
    expect_offense(<<~RUBY)
      if something
        test
      elsif
        something
        ^^^^^^^^^ Place the condition on the same line as `elsif`.
        test
      end
    RUBY

    expect_correction(<<~RUBY)
      if something
        test
      elsif something
        test
      end
    RUBY
  end

  it 'accepts ternary ops' do
    expect_no_offenses('x ? a : b')
  end
end
