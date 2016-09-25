# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::WhenThen do
  subject(:cop) { described_class.new }

  it 'registers an offense for when x;' do
    inspect_source(cop, ['case a',
                         'when b; c',
                         'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts when x then' do
    inspect_source(cop, ['case a',
                         'when b then c',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts ; separating statements in the body of when' do
    inspect_source(cop, ['case a',
                         'when b then c; d',
                         'end',
                         '',
                         'case e',
                         'when f',
                         '  g; h',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects "when x;" with "when x then"' do
    new_source = autocorrect_source(cop, ['case a',
                                          'when b; c',
                                          'end'])
    expect(new_source).to eq(['case a',
                              'when b then c',
                              'end'].join("\n"))
  end
end
