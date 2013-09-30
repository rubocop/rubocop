# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::AndOr do
  subject(:cop) { described_class.new }

  it 'registers an offence for OR' do
    inspect_source(cop,
                   ['test if a or b'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages).to eq(['Use || instead of or.'])
  end

  it 'registers an offence for AND' do
    inspect_source(cop,
                   ['test if a and b'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages).to eq(['Use && instead of and.'])
  end

  it 'accepts ||' do
    inspect_source(cop,
                   ['test if a || b'])
    expect(cop.offences).to be_empty
  end

  it 'accepts &&' do
    inspect_source(cop,
                   ['test if a && b'])
    expect(cop.offences).to be_empty
  end

  it 'auto-corrects "and" with &&' do
    new_source = autocorrect_source(cop, 'true and false')
    expect(new_source).to eq('true && false')
  end

  it 'auto-corrects "or" with ||' do
    new_source = autocorrect_source(cop, ['x = 12345',
                                          'true or false'])
    expect(new_source).to eq(['x = 12345',
                              'true || false'].join("\n"))
  end

  it 'leaves *or* as is if auto-correction changes the meaning' do
    src = "teststring.include? 'a' or teststring.include? 'b'"
    new_source = autocorrect_source(cop, src)
    expect(new_source).to eq(src)
  end

  it 'leaves *and* as is if auto-correction changes the meaning' do
    src = 'x = a + b and return x'
    new_source = autocorrect_source(cop, src)
    expect(new_source).to eq(src)
  end
end
