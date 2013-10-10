# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::LeadingCommentSpace do
  subject(:cop) { described_class.new }

  it 'registers an offence for comment without leading space' do
    inspect_source(cop,
                   ['#missing space'])
    expect(cop.offences.size).to eq(1)
  end

  it 'does not register an offence for # followed by no text' do
    inspect_source(cop,
                   ['#'])
    expect(cop.offences).to be_empty
  end

  it 'does not register an offence for more than one space' do
    inspect_source(cop,
                   ['#   heavily indented'])
    expect(cop.offences).to be_empty
  end

  it 'does not register an offence for more than one #' do
    inspect_source(cop,
                   ['###### heavily indented'])
    expect(cop.offences).to be_empty
  end

  it 'does not register an offence for only #s' do
    inspect_source(cop,
                   ['######'])
    expect(cop.offences).to be_empty
  end

  it 'does not register an offence for #! on first line' do
    inspect_source(cop,
                   ['#!/usr/bin/ruby',
                    'test'])
    expect(cop.offences).to be_empty
  end

  it 'registers an offence for #! after the first line' do
    inspect_source(cop,
                   ['test', '#!/usr/bin/ruby'])
    expect(cop.offences.size).to eq(1)
  end

  it 'accepts rdoc syntax' do
    inspect_source(cop,
                   ['#++',
                    '#--',
                    '#:nodoc:'])

    expect(cop.offences).to be_empty
  end

  it 'auto-corrects missing space' do
    new_source = autocorrect_source(cop, '#comment')
    expect(new_source).to eq('# comment')
  end
end
