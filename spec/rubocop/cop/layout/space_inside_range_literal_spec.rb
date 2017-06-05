# frozen_string_literal: true

describe RuboCop::Cop::Layout::SpaceInsideRangeLiteral do
  subject(:cop) { described_class.new }

  it 'registers an offense for space inside .. literal' do
    inspect_source(cop, <<-RUBY.strip_indent)
      1 .. 2
      1.. 2
      1 ..2
    RUBY
    expect(cop.offenses.size).to eq(3)
    expect(cop.messages)
      .to eq(['Space inside range literal.'] * 3)
  end

  it 'accepts no space inside .. literal' do
    expect_no_offenses('1..2')
  end

  it 'registers an offense for space inside ... literal' do
    inspect_source(cop, <<-RUBY.strip_indent)
      1 ... 2
      1... 2
      1 ...2
    RUBY
    expect(cop.offenses.size).to eq(3)
    expect(cop.messages)
      .to eq(['Space inside range literal.'] * 3)
  end

  it 'accepts no space inside ... literal' do
    expect_no_offenses('1...2')
  end

  it 'accepts complex range literal with space in it' do
    expect_no_offenses('0...(line - 1)')
  end

  it 'accepts multiline range literal with no space in it' do
    expect_no_offenses(<<-RUBY.strip_indent)
      x = 0..
          10
    RUBY
  end

  it 'registers an offense in multiline range literal with space in it' do
    inspect_source(cop, <<-RUBY.strip_indent)
      x = 0 ..
          10
    RUBY
    expect(cop.offenses.size).to eq(1)
  end

  it 'autocorrects space around .. literal' do
    corrected = autocorrect_source(cop, ['1  .. 2'])
    expect(corrected).to eq '1..2'
  end

  it 'autocorrects space around ... literal' do
    corrected = autocorrect_source(cop, ['1  ... 2'])
    expect(corrected).to eq '1...2'
  end
end
