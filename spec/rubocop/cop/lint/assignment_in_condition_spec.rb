# frozen_string_literal: true

describe RuboCop::Cop::Lint::AssignmentInCondition, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'AllowSafeAssignment' => true } }

  it 'registers an offense for lvar assignment in condition' do
    expect_offense(<<-RUBY.strip_indent)
      if test = 10
              ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
      end
    RUBY
  end

  it 'registers an offense for lvar assignment in while condition' do
    expect_offense(<<-RUBY.strip_indent)
      while test = 10
                 ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
      end
    RUBY
  end

  it 'registers an offense for lvar assignment in until condition' do
    expect_offense(<<-RUBY.strip_indent)
      until test = 10
                 ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
      end
    RUBY
  end

  it 'registers an offense for ivar assignment in condition' do
    expect_offense(<<-RUBY.strip_indent)
      if @test = 10
               ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
      end
    RUBY
  end

  it 'registers an offense for clvar assignment in condition' do
    expect_offense(<<-RUBY.strip_indent)
      if @@test = 10
                ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
      end
    RUBY
  end

  it 'registers an offense for gvar assignment in condition' do
    expect_offense(<<-RUBY.strip_indent)
      if $test = 10
               ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
      end
    RUBY
  end

  it 'registers an offense for constant assignment in condition' do
    expect_offense(<<-RUBY.strip_indent)
      if TEST = 10
              ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
      end
    RUBY
  end

  it 'registers an offense for collection element assignment in condition' do
    expect_offense(<<-RUBY.strip_indent)
      if a[3] = 10
              ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
      end
    RUBY
  end

  it 'accepts == in condition' do
    expect_no_offenses(<<-RUBY.strip_indent)
      if test == 10
      end
    RUBY
  end

  it 'registers an offense for assignment after == in condition' do
    expect_offense(<<-RUBY.strip_indent)
      if test == 10 || foobar = 1
                              ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
      end
    RUBY
  end

  it 'accepts = in a block that is called in a condition' do
    expect_no_offenses('return 1 if any_errors? { o = inspect(file) }')
  end

  it 'accepts = in a block followed by method call' do
    expect_no_offenses('return 1 if any_errors? { o = file }.present?')
  end

  it 'accepts ||= in condition' do
    expect_no_offenses('raise StandardError unless foo ||= bar')
  end

  it 'registers an offense for assignment after ||= in condition' do
    expect_offense(<<-RUBY.strip_indent)
      raise StandardError unless (foo ||= bar) || a = b
                                                    ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
    RUBY
  end

  it 'registers an offense for assignment methods' do
    expect_offense(<<-RUBY.strip_indent)
      if test.method = 10
                     ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
      end
    RUBY
  end

  it 'does not blow up for empty if condition' do
    expect_no_offenses(<<-RUBY.strip_indent)
      if ()
      end
    RUBY
  end

  it 'does not blow up for empty unless condition' do
    expect_no_offenses(<<-RUBY.strip_indent)
      unless ()
      end
    RUBY
  end

  context 'safe assignment is allowed' do
    it 'accepts = in condition surrounded with braces' do
      expect_no_offenses(<<-RUBY.strip_indent)
        if (test = 10)
        end
      RUBY
    end

    it 'accepts []= in condition surrounded with braces' do
      expect_no_offenses(<<-RUBY.strip_indent)
        if (test[0] = 10)
        end
      RUBY
    end
  end

  context 'safe assignment is not allowed' do
    let(:cop_config) { { 'AllowSafeAssignment' => false } }

    it 'does not accept = in condition surrounded with braces' do
      expect_offense(<<-RUBY.strip_indent)
        if (test = 10)
                 ^ Use `==` if you meant to do a comparison or move the assignment up out of the condition.
        end
      RUBY
    end

    it 'does not accept []= in condition surrounded with braces' do
      expect_offense(<<-RUBY.strip_indent)
        if (test[0] = 10)
                    ^ Use `==` if you meant to do a comparison or move the assignment up out of the condition.
        end
      RUBY
    end
  end
end
