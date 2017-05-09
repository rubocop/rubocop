# frozen_string_literal: true

describe RuboCop::Cop::Lint::AssignmentInCondition, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'AllowSafeAssignment' => true } }

  it 'registers an offense for lvar assignment in condition' do
    expect_offense(<<-RUBY.strip_indent)
      if test = 10
              ^ Assignment in condition - you probably meant to use `==`.
      end
    RUBY
  end

  it 'registers an offense for lvar assignment in while condition' do
    expect_offense(<<-RUBY.strip_indent)
      while test = 10
                 ^ Assignment in condition - you probably meant to use `==`.
      end
    RUBY
  end

  it 'registers an offense for lvar assignment in until condition' do
    expect_offense(<<-RUBY.strip_indent)
      until test = 10
                 ^ Assignment in condition - you probably meant to use `==`.
      end
    RUBY
  end

  it 'registers an offense for ivar assignment in condition' do
    expect_offense(<<-RUBY.strip_indent)
      if @test = 10
               ^ Assignment in condition - you probably meant to use `==`.
      end
    RUBY
  end

  it 'registers an offense for clvar assignment in condition' do
    expect_offense(<<-RUBY.strip_indent)
      if @@test = 10
                ^ Assignment in condition - you probably meant to use `==`.
      end
    RUBY
  end

  it 'registers an offense for gvar assignment in condition' do
    expect_offense(<<-RUBY.strip_indent)
      if $test = 10
               ^ Assignment in condition - you probably meant to use `==`.
      end
    RUBY
  end

  it 'registers an offense for constant assignment in condition' do
    expect_offense(<<-RUBY.strip_indent)
      if TEST = 10
              ^ Assignment in condition - you probably meant to use `==`.
      end
    RUBY
  end

  it 'registers an offense for collection element assignment in condition' do
    expect_offense(<<-RUBY.strip_indent)
      if a[3] = 10
              ^ Assignment in condition - you probably meant to use `==`.
      end
    RUBY
  end

  it 'accepts == in condition' do
    expect_no_offenses(<<-END.strip_indent)
      if test == 10
      end
    END
  end

  it 'registers an offense for assignment after == in condition' do
    expect_offense(<<-RUBY.strip_indent)
      if test == 10 || foobar = 1
                              ^ Assignment in condition - you probably meant to use `==`.
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
                                                    ^ Assignment in condition - you probably meant to use `==`.
    RUBY
  end

  it 'registers an offense for assignment methods' do
    expect_offense(<<-RUBY.strip_indent)
      if test.method = 10
                     ^ Assignment in condition - you probably meant to use `==`.
      end
    RUBY
  end

  it 'does not blow up for empty if condition' do
    expect_no_offenses(<<-END.strip_indent)
      if ()
      end
    END
  end

  it 'does not blow up for empty unless condition' do
    expect_no_offenses(<<-END.strip_indent)
      unless ()
      end
    END
  end

  context 'safe assignment is allowed' do
    it 'accepts = in condition surrounded with braces' do
      expect_no_offenses(<<-END.strip_indent)
        if (test = 10)
        end
      END
    end

    it 'accepts []= in condition surrounded with braces' do
      expect_no_offenses(<<-END.strip_indent)
        if (test[0] = 10)
        end
      END
    end
  end

  context 'safe assignment is not allowed' do
    let(:cop_config) { { 'AllowSafeAssignment' => false } }

    it 'does not accept = in condition surrounded with braces' do
      expect_offense(<<-RUBY.strip_indent)
        if (test = 10)
                 ^ Assignment in condition - you probably meant to use `==`.
        end
      RUBY
    end

    it 'does not accept []= in condition surrounded with braces' do
      expect_offense(<<-RUBY.strip_indent)
        if (test[0] = 10)
                    ^ Assignment in condition - you probably meant to use `==`.
        end
      RUBY
    end
  end
end
