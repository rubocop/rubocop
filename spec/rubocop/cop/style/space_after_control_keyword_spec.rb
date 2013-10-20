# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::SpaceAfterControlKeyword do
  subject(:cop) { described_class.new }

  it 'registers an offence for normal if' do
    inspect_source(cop,
                   ['if(test) then result end'])
    expect(cop.offences.size).to eq(1)
  end

  it 'registers an offence for modifier unless' do
    inspect_source(cop, ['action unless(test)'])

    expect(cop.offences.size).to eq(1)
  end

  it 'does not get confused by keywords' do
    inspect_source(cop, ['[:if, :unless].action'])
    expect(cop.offences).to be_empty
  end

  it 'does not get confused by the ternary operator' do
    inspect_source(cop, ['a ? b : c'])
    expect(cop.offences).to be_empty
  end

  it 'registers an offence for if, elsif, and unless' do
    inspect_source(cop,
                   ['if(a)',
                    'elsif(b)',
                    '  unless(c)',
                    '  end',
                    'end'])
    expect(cop.offences.map(&:line)).to eq([1, 2, 3])
  end

  it 'registers an offence for case and when' do
    inspect_source(cop,
                   ['case(a)',
                    'when(0) then 1',
                    'end'])
    expect(cop.offences.map(&:line)).to eq([1, 2])
  end

  it 'registers an offence for while and until' do
    inspect_source(cop,
                   ['while(a)',
                    '  b until(c)',
                    'end'])
    expect(cop.offences.map(&:line)).to eq([1, 2])
  end

  it 'auto-corrects missing space' do
    new_source = autocorrect_source(cop, ['if(test) then result end',
                                          'action unless(test)',
                                          'if(a)',
                                          'elsif(b)',
                                          '  unless(c)',
                                          '  end',
                                          'end',
                                          'case(a)',
                                          'when(0) then 1',
                                          'end',
                                          'while(a)',
                                          '  b until(c)',
                                          'end'])
    expect(new_source).to eq(['if (test) then result end',
                              'action unless (test)',
                              'if (a)',
                              'elsif (b)',
                              '  unless (c)',
                              '  end',
                              'end',
                              'case (a)',
                              'when (0) then 1',
                              'end',
                              'while (a)',
                              '  b until (c)',
                              'end'].join("\n"))
  end
end
