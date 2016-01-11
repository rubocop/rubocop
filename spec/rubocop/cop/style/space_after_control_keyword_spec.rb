# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::SpaceAfterControlKeyword do
  subject(:cop) { described_class.new }

  it 'registers an offense for normal if' do
    inspect_source(cop,
                   'if(test) then result end')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for modifier unless' do
    inspect_source(cop, 'action unless(test)')

    expect(cop.offenses.size).to eq(1)
  end

  it 'does not get confused by keywords' do
    inspect_source(cop, '[:if, :unless].action')
    expect(cop.offenses).to be_empty
  end

  it 'does not get confused by the ternary operator' do
    inspect_source(cop, 'a ? b : c')
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for if, elsif, and unless' do
    inspect_source(cop,
                   ['if(a)',
                    'elsif(b)',
                    '  unless(c)',
                    '  end',
                    'end'])
    expect(cop.offenses.map(&:line)).to eq([1, 2, 3])
  end

  it 'registers an offense for case and when' do
    inspect_source(cop,
                   ['case(a)',
                    'when(0) then 1',
                    'end'])
    expect(cop.offenses.map(&:line)).to eq([1, 2])
  end

  it 'registers an offense for while and until' do
    inspect_source(cop,
                   ['while(a)',
                    '  b until(c)',
                    'end'])
    expect(cop.offenses.map(&:line)).to eq([1, 2])
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
