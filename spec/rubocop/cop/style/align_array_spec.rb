# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::AlignArray do
  subject(:cop) { described_class.new }

  it 'registers an offence for misaligned array elements' do
    inspect_source(cop, ['array = [',
                         '  a,',
                         '   b,',
                         '  c,',
                         '   d',
                         ']'])
    expect(cop.messages).to eq(['Align the elements of an array ' \
                                'literal if they span more than ' +
                                'one line.'] * 2)
    expect(cop.highlights).to eq(%w(b d))
  end

  it 'accepts aligned array keys' do
    inspect_source(cop, ['array = [',
                         '  a,',
                         '  b,',
                         '  c,',
                         '  d',
                         ']'])
    expect(cop.offences).to be_empty
  end

  it 'accepts single line array' do
    inspect_source(cop, 'array = [ a, b ]')
    expect(cop.offences).to be_empty
  end

  it 'accepts several elements per line' do
    inspect_source(cop, ['array = [ a, b,',
                         '          c, d ]'])
    expect(cop.offences).to be_empty
  end

  it 'auto-corrects alignment' do
    new_source = autocorrect_source(cop, ['array = [',
                                          '  a,',
                                          '   b,',
                                          '  c,',
                                          ' d',
                                          ']'])
    expect(new_source).to eq(['array = [',
                              '  a,',
                              '  b,',
                              '  c,',
                              '  d',
                              ']'].join("\n"))
  end

  it 'auto-corrects array within array' do
    original_source = ['[:l1,',
                       '  [:l2,',
                       '    [:l3,',
                       '      [:l4]]]]']
    new_source = autocorrect_source(cop, original_source)
    expect(new_source).to eq(['[:l1,',
                              ' [:l2,',
                              '  [:l3,',
                              '   [:l4]]]]'].join("\n"))
  end

  it 'auto-corrects only elements that begin a line' do
    original_source = ['array = [:bar, {',
                       '         whiz: 2, bang: 3 }, option: 3]']
    new_source = autocorrect_source(cop, original_source)
    expect(new_source).to eq(original_source.join("\n"))
  end
end
