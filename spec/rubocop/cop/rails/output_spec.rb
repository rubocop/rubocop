# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Rails::Output do
  subject(:cop) { described_class.new }

  it 'should record an offence for puts statements' do
    source = ['p "edmond dantes"',
              'puts "sinbad"',
              'print "abbe busoni"',
              'pp "monte cristo"']
    inspect_source(cop, source)
    expect(cop.offences.size).to eq(4)
  end

  it 'should not record an offence for methods' do
    source = ['obj.print',
              'something.p',
              'nothing.pp']
    inspect_source(cop, source)
    expect(cop.offences).to be_empty
  end

  it 'should not record an offence for comments' do
    source = ['# print "test"',
              '# p']
    inspect_source(cop, source)
    expect(cop.offences).to be_empty
  end
end
