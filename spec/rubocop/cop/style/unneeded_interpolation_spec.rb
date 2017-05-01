# frozen_string_literal: true

describe RuboCop::Cop::Style::UnneededInterpolation do
  subject(:cop) { described_class.new }

  it 'registers an offense for "#{1 + 1}"' do
    inspect_source(cop, '"#{1 + 1}"')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['"#{1 + 1}"'])
  end

  it 'registers an offense for "%|#{1 + 1}|"' do
    inspect_source(cop, '%|#{1 + 1}|')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['%|#{1 + 1}|'])
  end

  it 'registers an offense for "%Q(#{1 + 1})"' do
    inspect_source(cop, '%Q(#{1 + 1})')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['%Q(#{1 + 1})'])
  end

  it 'registers an offense for "#{1 + 1; 2 + 2}"' do
    inspect_source(cop, '"#{1 + 1; 2 + 2}"')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['"#{1 + 1; 2 + 2}"'])
  end

  it 'registers an offense for "#{@var}"' do
    inspect_source(cop, '"#{@var}"')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['"#{@var}"'])
  end

  it 'registers an offense for "#@var"' do
    inspect_source(cop, '"#@var"')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['"#@var"'])
  end

  it 'registers an offense for "#{@@var}"' do
    inspect_source(cop, '"#{@@var}"')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['"#{@@var}"'])
  end

  it 'registers an offense for "#@@var"' do
    inspect_source(cop, '"#@@var"')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['"#@@var"'])
  end

  it 'registers an offense for "#{$var}"' do
    inspect_source(cop, '"#{$var}"')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['"#{$var}"'])
  end

  it 'registers an offense for "#$var"' do
    inspect_source(cop, '"#$var"')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['"#$var"'])
  end

  it 'registers an offense for "#{$1}"' do
    inspect_source(cop, '"#{$1}"')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['"#{$1}"'])
  end

  it 'registers an offense for "#$1"' do
    inspect_source(cop, '"#$1"')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['"#$1"'])
  end

  it 'registers an offense for "#{$+}"' do
    inspect_source(cop, '"#{$+}"')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['"#{$+}"'])
  end

  it 'registers an offense for "#$+"' do
    inspect_source(cop, '"#$+"')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['"#$+"'])
  end

  it 'registers an offense for "#{var}"' do
    inspect_source(cop, 'var = 1; "#{var}"')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['"#{var}"'])
  end

  it 'registers an offense for ["#{@var}"]' do
    inspect_source(cop, '["#{@var}", \'foo\']')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['"#{@var}"'])
  end

  it 'accepts strings with characters before the interpolation' do
    expect_no_offenses('"this is #{@sparta}"')
  end

  it 'accepts strings with characters after the interpolation' do
    expect_no_offenses('"#{@sparta} this is"')
  end

  it 'accepts strings implicitly concatenated with a later string' do
    expect_no_offenses(%q("#{sparta}" ' this is'))
  end

  it 'accepts strings implicitly concatenated with an earlier string' do
    expect_no_offenses(%q('this is ' "#{sparta}"))
  end

  it 'accepts strings that are part of a %W()' do
    expect_no_offenses('%W(#{@var} foo)')
  end

  it 'autocorrects "#{1 + 1; 2 + 2}"' do
    corrected = autocorrect_source(cop, ['"#{1 + 1; 2 + 2}"'])
    expect(corrected).to eq '(1 + 1; 2 + 2).to_s'
  end

  it 'autocorrects "#@var"' do
    corrected = autocorrect_source(cop, ['"#@var"'])
    expect(corrected).to eq '@var.to_s'
  end

  it 'autocorrects "#{var}"' do
    corrected = autocorrect_source(cop, ['var = 1; "#{var}"'])
    expect(corrected).to eq 'var = 1; var.to_s'
  end

  it 'autocorrects "#{@var}"' do
    corrected = autocorrect_source(cop, ['"#{@var}"'])
    expect(corrected).to eq '@var.to_s'
  end
end
