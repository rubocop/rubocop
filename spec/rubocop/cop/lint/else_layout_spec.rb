# frozen_string_literal: true

describe RuboCop::Cop::Lint::ElseLayout do
  subject(:cop) { described_class.new }

  it 'registers an offense for expr on same line as else' do
    inspect_source(cop, <<-END.strip_indent)
      if something
        test
      else ala
        something
        test
      end
    END
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts proper else' do
    expect_no_offenses(<<-END.strip_indent)
      if something
        test
      else
        something
        test
      end
    END
  end

  it 'accepts single-expr else regardless of layout' do
    expect_no_offenses(<<-END.strip_indent)
      if something
        test
      else bala
      end
    END
  end

  it 'can handle elsifs' do
    inspect_source(cop, <<-END.strip_indent)
      if something
        test
      elsif something
        bala
      else ala
        something
        test
      end
    END
    expect(cop.offenses.size).to eq(1)
  end

  it 'handles ternary ops' do
    expect_no_offenses('x ? a : b')
  end

  it 'handles modifier forms' do
    expect_no_offenses('x if something')
  end
end
