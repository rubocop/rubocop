# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::DuplicateCaseCondition do
  subject(:cop) { described_class.new }

  it 'registers an offense for repeated case conditionals' do
    expect_offense(<<-RUBY.strip_indent)
      case x
      when false
        first_method
      when true
        second_method
      when false
           ^^^^^ Duplicate `when` condition detected.
        third_method
      end
    RUBY
  end

  it 'registers an offense for subsequent repeated case conditionals' do
    expect_offense(<<-RUBY.strip_indent)
      case x
      when false
        first_method
      when false
           ^^^^^ Duplicate `when` condition detected.
        second_method
      end
    RUBY
  end

  it 'registers multiple offenses for multiple repeated case conditionals' do
    expect_offense(<<-RUBY.strip_indent)
      case x
      when false
        first_method
      when true
        second_method
      when false
           ^^^^^ Duplicate `when` condition detected.
        third_method
      when true
           ^^^^ Duplicate `when` condition detected.
        fourth_method
      end
    RUBY
  end

  it 'registers multiple offenses for repeated multi-value condtionals' do
    expect_offense(<<-RUBY.strip_indent)
      case x
      when a, b
        first_method
      when b, a
              ^ Duplicate `when` condition detected.
           ^ Duplicate `when` condition detected.
        second_method
      end
    RUBY
  end

  it 'registers an offense for repeated logical operator when expressions' do
    expect_offense(<<-RUBY.strip_indent)
      case x
      when a && b
        first_method
      when a && b
           ^^^^^^ Duplicate `when` condition detected.
        second_method
      end
    RUBY
  end

  it 'accepts trivial case expressions' do
    expect_no_offenses(<<-RUBY.strip_indent)
      case x
      when false
        first_method
      end
    RUBY
  end

  it 'accepts non-redundant case expressions' do
    expect_no_offenses(<<-RUBY.strip_indent)
      case x
      when false
        first_method
      when true
        second_method
      end
    RUBY
  end

  it 'accepts non-redundant case expressions with an else expression' do
    expect_no_offenses(<<-RUBY.strip_indent)
      case x
      when false
        method_name
      when true
        second_method
      else
        third_method
      end
    RUBY
  end

  it 'accepts similar but not equivalent && expressions' do
    expect_no_offenses(<<-RUBY.strip_indent)
      case x
      when something && another && other
        first_method
      when something && another
        second_method
      end
    RUBY
  end
end
