# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Rails::Output, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'Ignore' => ['^.*\.rake$'] } }

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

  it 'should ignore certain files' do
    source = ['print 1']
    processed_source = parse_source(source)
    allow(processed_source.buffer)
      .to receive(:name).and_return('/var/lib/test.rake')
    _investigate(cop, processed_source)
    expect(cop.offences).to be_empty
  end
end
