# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Rails::Output do
  subject(:cop) { described_class.new }

  it 'should record an offense for puts statements' do
    source = ['p "edmond dantes"',
              'puts "sinbad"',
              'print "abbe busoni"',
              'pp "monte cristo"']
    inspect_source(cop, source)
    expect(cop.offenses.size).to eq(4)
  end

  it 'should not record an offense for methods' do
    source = ['obj.print',
              'something.p',
              'nothing.pp']
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end

  it 'should not record an offense for comments' do
    source = ['# print "test"',
              '# p']
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end
end
