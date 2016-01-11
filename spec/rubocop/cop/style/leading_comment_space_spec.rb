# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::LeadingCommentSpace do
  subject(:cop) { described_class.new }

  it 'registers an offense for comment without leading space' do
    inspect_source(cop, '#missing space')
    expect(cop.offenses.size).to eq(1)
  end

  it 'does not register an offense for # followed by no text' do
    inspect_source(cop, '#')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for more than one space' do
    inspect_source(cop, '#   heavily indented')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for more than one #' do
    inspect_source(cop, '###### heavily indented')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for only #s' do
    inspect_source(cop, '######')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for #! on first line' do
    inspect_source(cop,
                   ['#!/usr/bin/ruby',
                    'test'])
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for #! after the first line' do
    inspect_source(cop, ['test',
                         '#!/usr/bin/ruby'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts rdoc syntax' do
    inspect_source(cop,
                   ['#++',
                    '#--',
                    '#:nodoc:'])

    expect(cop.offenses).to be_empty
  end

  it 'accepts sprockets directives' do
    inspect_source(cop, '#= require_tree .')
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects missing space' do
    new_source = autocorrect_source(cop, '#comment')
    expect(new_source).to eq('# comment')
  end

  it 'accepts =begin/=end comments' do
    inspect_source(cop, ['=begin',
                         '#blahblah',
                         '=end'])
    expect(cop.offenses).to be_empty
  end
end
