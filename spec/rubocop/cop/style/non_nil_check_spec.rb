# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::NonNilCheck do
  subject(:cop) { described_class.new }

  it 'registers an offense for != nil' do
    inspect_source(cop, 'x != nil')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['!='])
  end

  it 'registers an offense for !x.nil?' do
    inspect_source(cop, '!x.nil?')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['!x.nil?'])
  end

  it 'registers an offense for not x.nil?' do
    inspect_source(cop, 'not x.nil?')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['not x.nil?'])
  end

  it 'does not register an offense if only expression in predicate' do
    inspect_source(cop, ['def signed_in?',
                         '  !current_user.nil?',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense if only expression in class predicate' do
    inspect_source(cop, ['def Test.signed_in?',
                         '  !current_user.nil?',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense if last expression in predicate' do
    inspect_source(cop, ['def signed_in?',
                         '  something',
                         '  !current_user.nil?',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense if last expression in class predicate' do
    inspect_source(cop, ['def Test.signed_in?',
                         '  something',
                         '  !current_user.nil?',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'autocorrects by removing != nil' do
    corrected = autocorrect_source(cop, 'x != nil')
    expect(corrected).to eq 'x'
  end

  it 'autocorrects by removing non-nil (!x.nil?) check' do
    corrected = autocorrect_source(cop, '!x.nil?')
    expect(corrected).to eq 'x'
  end

  it 'does not blow up when autocorrecting implicit receiver' do
    corrected = autocorrect_source(cop, '!nil?')
    expect(corrected).to eq 'self'
  end
end
