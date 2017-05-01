# frozen_string_literal: true

describe RuboCop::Cop::Style::EvenOdd do
  subject(:cop) { described_class.new }

  it 'registers an offense for x % 2 == 0' do
    inspect_source(cop, 'x % 2 == 0')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Replace with `Integer#even?`.'])
  end

  it 'registers an offense for x % 2 != 0' do
    inspect_source(cop, 'x % 2 != 0')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Replace with `Integer#odd?`.'])
  end

  it 'registers an offense for (x % 2) == 0' do
    inspect_source(cop, '(x % 2) == 0')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Replace with `Integer#even?`.'])
  end

  it 'registers an offense for (x % 2) != 0' do
    inspect_source(cop, '(x % 2) != 0')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Replace with `Integer#odd?`.'])
  end

  it 'registers an offense for x % 2 == 1' do
    inspect_source(cop, 'x % 2 == 1')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Replace with `Integer#odd?`.'])
  end

  it 'registers an offense for x % 2 != 1' do
    inspect_source(cop, 'x % 2 != 1')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Replace with `Integer#even?`.'])
  end

  it 'registers an offense for (x % 2) == 1' do
    inspect_source(cop, '(x % 2) == 1')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Replace with `Integer#odd?`.'])
  end

  it 'registers an offense for (x % 2) != 1' do
    inspect_source(cop, '(x % 2) != 1')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Replace with `Integer#even?`.'])
  end

  it 'registers an offense for (x.y % 2) != 1' do
    inspect_source(cop, '(x.y % 2) != 1')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Replace with `Integer#even?`.'])
  end

  it 'registers an offense for (x(y) % 2) != 1' do
    inspect_source(cop, '(x(y) % 2) != 1')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Replace with `Integer#even?`.'])
  end

  it 'accepts x % 3 == 0' do
    expect_no_offenses('x % 3 == 0')
  end

  it 'accepts x % 3 != 0' do
    expect_no_offenses('x % 3 != 0')
  end

  it 'converts x % 2 == 0 to #even?' do
    corrected = autocorrect_source(cop, 'x % 2 == 0')
    expect(corrected).to eq('x.even?')
  end

  it 'converts x % 2 != 0 to #odd?' do
    corrected = autocorrect_source(cop, 'x % 2 != 0')
    expect(corrected).to eq('x.odd?')
  end

  it 'converts (x % 2) == 0 to #even?' do
    corrected = autocorrect_source(cop, '(x % 2) == 0')
    expect(corrected).to eq('x.even?')
  end

  it 'converts (x % 2) != 0 to #odd?' do
    corrected = autocorrect_source(cop, '(x % 2) != 0')
    expect(corrected).to eq('x.odd?')
  end

  it 'converts x % 2 == 1 to odd?' do
    corrected = autocorrect_source(cop, 'x % 2 == 1')
    expect(corrected).to eq('x.odd?')
  end

  it 'converts x % 2 != 1 to even?' do
    corrected = autocorrect_source(cop, 'x % 2 != 1')
    expect(corrected).to eq('x.even?')
  end

  it 'converts (x % 2) == 1 to odd?' do
    corrected = autocorrect_source(cop, '(x % 2) == 1')
    expect(corrected).to eq('x.odd?')
  end

  it 'converts (y % 2) != 1 to even?' do
    corrected = autocorrect_source(cop, '(y % 2) != 1')
    expect(corrected).to eq('y.even?')
  end

  it 'converts (x.y % 2) != 1 to even?' do
    corrected = autocorrect_source(cop, '(x.y % 2) != 1')
    expect(corrected).to eq('x.y.even?')
  end

  it 'converts (x(y) % 2) != 1 to even?' do
    corrected = autocorrect_source(cop, '(x(y) % 2) != 1')
    expect(corrected).to eq('x(y).even?')
  end

  it 'converts (x._(y) % 2) != 1 to even?' do
    corrected = autocorrect_source(cop, '(x._(y) % 2) != 1')
    expect(corrected).to eq('x._(y).even?')
  end

  it 'converts (x._(y)) % 2 != 1 to even?' do
    corrected = autocorrect_source(cop, '(x._(y)) % 2 != 1')
    expect(corrected).to eq('(x._(y)).even?')
  end

  it 'converts x._(y) % 2 != 1 to even?' do
    corrected = autocorrect_source(cop, 'x._(y) % 2 != 1')
    expect(corrected).to eq('x._(y).even?')
  end

  it 'converts 1 % 2 != 1 to even?' do
    corrected = autocorrect_source(cop, '1 % 2 != 1')
    expect(corrected).to eq('1.even?')
  end

  it 'converts complex examples' do
    corrected = autocorrect_source(cop, <<-END.strip_indent)
      if (y % 2) != 1
        method == :== ? :even : :odd
      elsif x % 2 == 1
        method == :== ? :odd : :even
      end
    END
    expect(corrected).to eq(<<-END.strip_indent)
      if y.even?
        method == :== ? :even : :odd
      elsif x.odd?
        method == :== ? :odd : :even
      end
    END
  end
end
