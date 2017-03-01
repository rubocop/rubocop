# frozen_string_literal: true

describe RuboCop::Cop::Style::VariableInterpolation do
  subject(:cop) { described_class.new }

  it 'registers an offense for interpolated global variables in string' do
    inspect_source(cop,
                   'puts "this is a #$test"')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['$test'])
    expect(cop.messages)
      .to eq(['Replace interpolated variable `$test`' \
              ' with expression `#{$test}`.'])
  end

  it 'registers an offense for interpolated global variables in regexp' do
    inspect_source(cop,
                   'puts /this is a #$test/')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['$test'])
    expect(cop.messages)
      .to eq(['Replace interpolated variable `$test`' \
              ' with expression `#{$test}`.'])
  end

  it 'registers an offense for interpolated global variables in backticks' do
    inspect_source(cop,
                   'puts `this is a #$test`')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['$test'])
    expect(cop.messages)
      .to eq(['Replace interpolated variable `$test`' \
              ' with expression `#{$test}`.'])
  end

  it 'registers an offense for interpolated regexp nth back references' do
    inspect_source(cop,
                   'puts "this is a #$1"')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['$1'])
    expect(cop.messages)
      .to eq(['Replace interpolated variable `$1` with expression `#{$1}`.'])
  end

  it 'registers an offense for interpolated regexp back references' do
    inspect_source(cop,
                   'puts "this is a #$+"')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['$+'])
    expect(cop.messages)
      .to eq(['Replace interpolated variable `$+` with expression `#{$+}`.'])
  end

  it 'registers an offense for interpolated instance variables' do
    inspect_source(cop,
                   'puts "this is a #@test"')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['@test'])
    expect(cop.messages)
      .to eq(['Replace interpolated variable `@test`' \
              ' with expression `#{@test}`.'])
  end

  it 'registers an offense for interpolated class variables' do
    inspect_source(cop,
                   'puts "this is a #@@t"')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['@@t'])
    expect(cop.messages)
      .to eq(['Replace interpolated variable `@@t` with expression `#{@@t}`.'])
  end

  it 'does not register an offense for variables in expressions' do
    inspect_source(cop,
                   'puts "this is a #{@test} #{@@t} #{$t} #{$1} #{$+}"')
    expect(cop.offenses).to be_empty
  end

  it 'autocorrects by adding the missing {}' do
    corrected = autocorrect_source(cop, ['"some #@var"'])
    expect(corrected).to eq '"some #{@var}"'
  end
end
