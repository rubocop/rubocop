# frozen_string_literal: true

describe RuboCop::Cop::Lint::DuplicateCaseCondition do
  subject(:cop) { described_class.new }

  it 'registers an offense for repeated case conditionals' do
    inspect_source(cop, <<-END.strip_indent)
      case x
      when false
        first_method
      when true
        second_method
      when false
        third_method
      end
    END
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for subsequent repeated case conditionals' do
    inspect_source(cop, <<-END.strip_indent)
      case x
      when false
        first_method
      when false
        second_method
      end
    END
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers multiple offenses for multiple repeated case conditionals' do
    inspect_source(cop, <<-END.strip_indent)
      case x
      when false
        first_method
      when true
        second_method
      when false
        third_method
      when true
        fourth_method
      end
    END
    expect(cop.offenses.size).to eq(2)
  end

  it 'registers multiple offenses for repeated multi-value condtionals' do
    inspect_source(cop, <<-END.strip_indent)
      case x
      when a, b
        first_method
      when b, a
        second_method
      end
    END
    expect(cop.offenses.size).to eq(2)
  end

  it 'registers an offense for repeated logical operator when expressions' do
    inspect_source(cop, <<-END.strip_indent)
      case x
      when a && b
        first_method
      when a && b
        second_method
      end
    END
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts trivial case expressions' do
    inspect_source(cop, <<-END.strip_indent)
      case x
      when false
        first_method
      end
    END
    expect(cop.messages).to be_empty
  end

  it 'accepts non-redundant case expressions' do
    inspect_source(cop, <<-END.strip_indent)
      case x
      when false
        first_method
      when true
        second_method
      end
    END
    expect(cop.messages).to be_empty
  end

  it 'accepts non-redundant case expressions with an else expression' do
    inspect_source(cop, <<-END.strip_indent)
      case x
      when false
        method_name
      when true
        second_method
      else
        third_method
      end
    END
    expect(cop.messages).to be_empty
  end

  it 'accepts similar but not equivalent && expressions' do
    inspect_source(cop, <<-END.strip_indent)
      case x
      when something && another && other
        first_method
      when something && another
        second_method
      end
    END
    expect(cop.messages).to be_empty
  end
end
