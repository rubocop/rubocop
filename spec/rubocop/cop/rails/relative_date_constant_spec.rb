# frozen_string_literal: true

describe RuboCop::Cop::Rails::RelativeDateConstant do
  subject(:cop) { described_class.new }

  it 'registers an offense for ActiveSupport::Duration.since' do
    inspect_source(cop, <<-END.strip_indent)
      class SomeClass
        EXPIRED_AT = 1.week.since
      end
    END
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts a method with arguments' do
    inspect_source(cop, <<-END.strip_indent)
      class SomeClass
        EXPIRED_AT = 1.week.since(base)
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'accepts a lambda' do
    inspect_source(cop, <<-END.strip_indent)
      class SomeClass
        EXPIRED_AT = -> { 1.year.ago }
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'accepts a proc' do
    inspect_source(cop, <<-END.strip_indent)
      class SomeClass
        EXPIRED_AT = Proc.new { 1.year.ago }
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for relative date in ||=' do
    inspect_source(cop, <<-END.strip_indent)
      class SomeClass
        EXPIRED_AT ||= 1.week.since
      end
    END
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for exclusive end range' do
    inspect_source(cop, <<-END.strip_indent)
      class SomeClass
        TRIAL_PERIOD = DateTime.current..1.day.since
      end
    END
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for inclusive end range' do
    inspect_source(cop, <<-END.strip_indent)
      class SomeClass
        TRIAL_PERIOD = DateTime.current...1.day.since
      end
    END
    expect(cop.offenses.size).to eq(1)
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
