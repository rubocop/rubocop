# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::RequireParentheses do
  subject(:cop) { described_class.new }

  it 'registers an offense for missing parentheses around expression with ' \
     '&& operator' do
    inspect_source(cop, ["if day.is? 'monday' && month == :jan",
                         '  foo',
                         'end'])
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
    inspect_source(cop, ["if day_is? 'tuesday' + rest",
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts method calls without parentheses followed by keyword and/or' do
    inspect_source(cop, ["if day.is? 'tuesday' and month == :jan",
                         'end',
                         "if day.is? 'tuesday' or month == :jan",
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts method calls that are all operations' do
    inspect_source(cop, ['if current_level == max + 1',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts condition that is not a call' do
    inspect_source(cop, ['if @debug',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts parentheses around expression with boolean operator' do
    inspect_source(cop, ["if day.is?('tuesday' && true == true)",
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts method call with parentheses in ternary' do
    inspect_source(cop, "wd.include?('tuesday' && true == true) ? a : b")
    expect(cop.offenses).to be_empty
  end

  it 'accepts missing parentheses when method is not a predicate' do
    inspect_source(cop, "weekdays.foo 'tuesday' && true == true")
    expect(cop.offenses).to be_empty
  end

  it 'accepts calls to methods that are setters' do
    inspect_source(cop, 's.version = @version || ">= 1.8.5"')
    expect(cop.offenses).to be_empty
  end

  it 'accepts calls to methods that are operators' do
    inspect_source(cop, 'a[b || c]')
    expect(cop.offenses).to be_empty
  end
end
