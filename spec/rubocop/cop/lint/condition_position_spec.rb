# frozen_string_literal: true

describe RuboCop::Cop::Lint::ConditionPosition do
  subject(:cop) { described_class.new }

  %w[if unless while until].each do |keyword|
    it 'registers an offense for condition on the next line' do
      inspect_source(cop,
                     [keyword,
                      'x == 10',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it 'accepts condition on the same line' do
      expect_no_offenses(<<-END.strip_indent)
        #{keyword} x == 10
         bala
        end
      END
    end

    it 'accepts condition on a different line for modifiers' do
      expect_no_offenses(<<-END.strip_indent)
        do_something #{keyword}
          something && something_else
      END
    end
  end

  it 'registers an offense for elsif condition on the next line' do
    inspect_source(cop, <<-END.strip_indent)
      if something
        test
      elsif
        something
        test
      end
    END
    expect(cop.offenses.size).to eq(1)
  end

  it 'handles ternary ops' do
    expect_no_offenses('x ? a : b')
  end
end
