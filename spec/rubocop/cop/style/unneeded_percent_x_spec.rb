# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::UnneededPercentX do
  subject(:cop) { described_class.new }

  it 'registers an offense for a %x string without backquotes' do
    inspect_source(cop, '%x(ls)')
    expect(cop.messages)
      .to eq(['Do not use `%x` unless the command string contains ' \
              'backquotes.'])
  end

  it 'accepts a %x string with backquotes' do
    inspect_source(cop, '%x(echo `ls`)')
    expect(cop.offenses).to be_empty
  end

  it 'accepts a `` string without inner backquotes' do
    inspect_source(cop, '`ls`')
    expect(cop.offenses).to be_empty
  end

  it 'accepts a `` string with inner backquotes' do
    inspect_source(cop, '`echo \`ls\``')
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects' do
    new_source = autocorrect_source(cop, '%x(ls)')
    expect(new_source).to eq('`ls`')
  end
end
