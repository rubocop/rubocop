# frozen_string_literal: true

describe RuboCop::Cop::Lint::ConditionPosition do
  subject(:cop) { described_class.new }

  %w[if unless while until].each do |keyword|
    it 'registers an offense for condition on the next line' do
      expect_offense(<<-RUBY.strip_indent)
        #{keyword}
        x == 10
        ^^^^^^^ Place the condition on the same line as `#{keyword}`.
        end
      RUBY
    end

    it 'accepts condition on the same line' do
      expect_no_offenses(<<-RUBY.strip_indent)
        #{keyword} x == 10
         bala
        end
      RUBY
    end

    it 'accepts condition on a different line for modifiers' do
      expect_no_offenses(<<-RUBY.strip_indent)
        do_something #{keyword}
          something && something_else
      RUBY
    end
  end

  it 'registers an offense for elsif condition on the next line' do
    expect_offense(<<-RUBY.strip_indent)
      if something
        test
      elsif
        something
        ^^^^^^^^^ Place the condition on the same line as `elsif`.
        test
      end
    RUBY
  end

  it 'handles ternary ops' do
    expect_no_offenses('x ? a : b')
  end
end
