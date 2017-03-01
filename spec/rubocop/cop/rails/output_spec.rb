# frozen_string_literal: true

describe RuboCop::Cop::Rails::Output do
  subject(:cop) { described_class.new }

  it 'records an offense for methods without a receiver' do
    source = ['p "edmond dantes"',
              'puts "sinbad"',
              'print "abbe busoni"',
              'pp "monte cristo"']
    inspect_source(cop, source)
    expect(cop.offenses.size).to eq(4)
  end

  it 'does not record an offense for methods with a receiver' do
    source = ['obj.print',
              'something.p',
              'nothing.pp']
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end

  it 'does not record an offense for methods without arguments' do
    source = %w(print pp puts)
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end

  it 'does not record an offense for comments' do
    source = ['# print "test"',
              '# p']
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end
end
