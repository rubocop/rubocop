# frozen_string_literal: true

describe RuboCop::Cop::Lint::RequireParentheses do
  subject(:cop) { described_class.new }

  it 'registers an offense for missing parentheses around expression with ' \
     '&& operator' do
    inspect_source(cop, <<-END.strip_indent)
      if day.is? 'monday' && month == :jan
        foo
      end
    END
    expect(cop.highlights).to eq(["day.is? 'monday' && month == :jan"])
    expect(cop.messages)
      .to eq(['Use parentheses in the method call to avoid confusion about ' \
              'precedence.'])
  end

  it 'registers an offense for missing parentheses around expression with ' \
     '|| operator' do
    inspect_source(cop, "day_is? 'tuesday' || true")
    expect(cop.highlights).to eq(["day_is? 'tuesday' || true"])
  end

  it 'registers an offense for missing parentheses around expression in ' \
     'ternary' do
    inspect_source(cop, "wd.include? 'tuesday' && true == true ? a : b")
    expect(cop.highlights).to eq(["wd.include? 'tuesday' && true == true"])
  end

  it 'accepts missing parentheses around expression with + operator' do
    inspect_source(cop, <<-END.strip_indent)
      if day_is? 'tuesday' + rest
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'accepts method calls without parentheses followed by keyword and/or' do
    inspect_source(cop, <<-END.strip_indent)
      if day.is? 'tuesday' and month == :jan
      end
      if day.is? 'tuesday' or month == :jan
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'accepts method calls that are all operations' do
    inspect_source(cop, <<-END.strip_indent)
      if current_level == max + 1
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'accepts condition that is not a call' do
    inspect_source(cop, <<-END.strip_indent)
      if @debug
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'accepts parentheses around expression with boolean operator' do
    inspect_source(cop, <<-END.strip_indent)
      if day.is?('tuesday' && true == true)
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'accepts method call with parentheses in ternary' do
    expect_no_offenses("wd.include?('tuesday' && true == true) ? a : b")
  end

  it 'accepts missing parentheses when method is not a predicate' do
    expect_no_offenses("weekdays.foo 'tuesday' && true == true")
  end

  it 'accepts calls to methods that are setters' do
    expect_no_offenses('s.version = @version || ">= 1.8.5"')
  end

  it 'accepts calls to methods that are operators' do
    expect_no_offenses('a[b || c]')
  end
end
