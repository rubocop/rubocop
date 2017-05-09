# frozen_string_literal: true

describe RuboCop::Cop::Rails::RelativeDateConstant do
  subject(:cop) { described_class.new }

  it 'registers an offense for ActiveSupport::Duration.since' do
    expect_offense(<<-RUBY.strip_indent)
      class SomeClass
        EXPIRED_AT = 1.week.since
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Do not assign since to constants as it will be evaluated only once.
      end
    RUBY
  end

  it 'accepts a method with arguments' do
    expect_no_offenses(<<-END.strip_indent)
      class SomeClass
        EXPIRED_AT = 1.week.since(base)
      end
    END
  end

  it 'accepts a lambda' do
    expect_no_offenses(<<-END.strip_indent)
      class SomeClass
        EXPIRED_AT = -> { 1.year.ago }
      end
    END
  end

  it 'accepts a proc' do
    expect_no_offenses(<<-END.strip_indent)
      class SomeClass
        EXPIRED_AT = Proc.new { 1.year.ago }
      end
    END
  end

  it 'registers an offense for relative date in ||=' do
    expect_offense(<<-RUBY.strip_indent)
      class SomeClass
        EXPIRED_AT ||= 1.week.since
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not assign since to constants as it will be evaluated only once.
      end
    RUBY
  end

  it 'registers an offense for relative date in multiple assignment' do
    expect_offense(<<-RUBY.strip_indent)
      class SomeClass
        START, A, x = 2.weeks.ago, 1.week.since, 5
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not assign ago to constants as it will be evaluated only once.
      end
    RUBY
  end

  it 'registers an offense for exclusive end range' do
    expect_offense(<<-RUBY.strip_indent)
      class SomeClass
        TRIAL_PERIOD = DateTime.current..1.day.since
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not assign since to constants as it will be evaluated only once.
      end
    RUBY
  end

  it 'registers an offense for inclusive end range' do
    expect_offense(<<-RUBY.strip_indent)
      class SomeClass
        TRIAL_PERIOD = DateTime.current...1.day.since
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not assign since to constants as it will be evaluated only once.
      end
    RUBY
  end

  it 'autocorrects' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      class SomeClass
        EXPIRED_AT = 1.week.since
      end
    END
    expect(new_source).to eq(<<-END.strip_indent)
      class SomeClass
        def self.expired_at
          1.week.since
        end
      end
    END
  end
end
