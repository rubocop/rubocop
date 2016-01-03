# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::SpaceBeforeComment do
  subject(:cop) { described_class.new }

  it 'registers an offense for missing space before an EOL comment' do
    inspect_source(cop, 'a += 1# increment')
    expect(cop.highlights).to eq(['# increment'])
  end

  it 'accepts an EOL comment with a preceding space' do
    inspect_source(cop, 'a += 1 # increment')
    expect(cop.offenses).to be_empty
  end

  it 'accepts a comment that begins a line' do
    inspect_source(cop, '# comment')
    expect(cop.offenses).to be_empty
  end

  it 'accepts a doc comment' do
    inspect_source(cop, ['=begin',
                         'Doc comment',
                         '=end'])
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects missing space' do
    new_source = autocorrect_source(cop, 'a += 1# increment')
    expect(new_source).to eq('a += 1 # increment')
  end
end
