# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::SpaceInsideHashLiteralBraces, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'EnforcedStyle' => 'space' } }

  context 'with a custom message' do
    let(:cop_config) do
      {
        'EnforcedStyleForEmptyBraces' => 'no_space',
        'Message' => 'Christian side hug inside %s.'
      }
    end

    it 'allows a user-defined message' do
      inspect_source(cop, ['h = { }'])
      expect(cop.messages)
        .to(
          eq([
            'Christian side hug inside empty hash literal braces detected.'
          ])
        )
    end
  end

  context 'with space inside empty braces not allowed' do
    let(:cop_config) { { 'EnforcedStyleForEmptyBraces' => 'no_space' } }

    it 'accepts empty braces with no space inside' do
      inspect_source(cop, ['h = {}'])
      expect(cop.messages).to be_empty
    end

    it 'registers an offence for empty braces with space inside' do
      inspect_source(cop, ['h = { }'])
      expect(cop.messages)
        .to eq(['Space inside empty hash literal braces detected.'])
      expect(cop.highlights).to eq([' '])
    end

    it 'auto-corrects unwanted space' do
      new_source = autocorrect_source(cop, 'h = { }')
      expect(new_source).to eq('h = {}')
    end
  end

  context 'with space inside empty braces allowed' do
    let(:cop_config) { { 'EnforcedStyleForEmptyBraces' => 'space' } }

    it 'accepts empty braces with space inside' do
      inspect_source(cop, ['h = { }'])
      expect(cop.messages).to be_empty
    end

    it 'registers an offence for empty braces with no space inside' do
      inspect_source(cop, ['h = {}'])
      expect(cop.messages)
        .to eq(['Space inside empty hash literal braces missing.'])
      expect(cop.highlights).to eq(['{'])
    end

    it 'auto-corrects missing space' do
      new_source = autocorrect_source(cop, 'h = {}')
      expect(new_source).to eq('h = { }')
    end
  end

  it 'registers an offence for hashes with no spaces if so configured' do
    inspect_source(cop,
                   ['h = {a: 1, b: 2}',
                    'h = {a => 1}'])
    expect(cop.messages).to eq(['Space inside { missing.',
                                'Space inside } missing.',
                                'Space inside { missing.',
                                'Space inside } missing.'])
    expect(cop.highlights).to eq(['{', '}', '{', '}'])
    expect(cop.config_to_allow_offences).to eq('EnforcedStyle' => 'no_space')
  end

  it 'registers an offence for correct + opposite' do
    inspect_source(cop,
                   ['h = { a: 1}'])
    expect(cop.messages).to eq(['Space inside } missing.'])
    expect(cop.config_to_allow_offences).to eq('Enabled' => false)
  end

  it 'auto-corrects missing space' do
    new_source = autocorrect_source(cop, ['h = {a: 1, b: 2}',
                                          'h = {a => 1 }'])
    expect(new_source).to eq(['h = { a: 1, b: 2 }',
                              'h = { a => 1 }'].join("\n"))
  end

  context 'when EnforcedStyle is no_space' do
    let(:cop_config) { { 'EnforcedStyle' => 'no_space' } }

    it 'registers an offence for hashes with spaces' do
      inspect_source(cop,
                     ['h = { a: 1, b: 2 }'])
      expect(cop.messages).to eq(['Space inside { detected.',
                                  'Space inside } detected.'])
      expect(cop.highlights).to eq([' ', ' '])
      expect(cop.config_to_allow_offences).to eq('EnforcedStyle' => 'space')
    end

    it 'registers an offence for opposite + correct' do
      inspect_source(cop,
                     ['h = {a: 1 }'])
      expect(cop.messages).to eq(['Space inside } detected.'])
      expect(cop.config_to_allow_offences).to eq('Enabled' => false)
    end

    it 'auto-corrects unwanted space' do
      new_source = autocorrect_source(cop, ['h = { a: 1, b: 2 }',
                                            'h = {a => 1 }'])
      expect(new_source).to eq(['h = {a: 1, b: 2}',
                                'h = {a => 1}'].join("\n"))
    end

    it 'accepts hashes with no spaces' do
      inspect_source(cop,
                     ['h = {a: 1, b: 2}',
                      'h = {a => 1}'])
      expect(cop.offences).to be_empty
    end

    it 'accepts multiline hashes for no space' do
      inspect_source(cop,
                     ['h = {',
                      '      a: 1,',
                      '      b: 2,',
                      '}'])
      expect(cop.offences).to be_empty
    end
  end

  it 'accepts hashes with spaces by default' do
    inspect_source(cop,
                   ['h = { a: 1, b: 2 }',
                    'h = { a => 1 }'])
    expect(cop.offences).to be_empty
  end

  it 'accepts hash literals with no braces' do
    inspect_source(cop, ['x(a: b.c)'])
    expect(cop.offences).to be_empty
  end

  it 'can handle interpolation in a braceless hash literal' do
    # A tricky special case where the closing brace of the
    # interpolation risks getting confused for a hash literal brace.
    inspect_source(cop, ['f(get: "#{x}")'])
    expect(cop.offences).to be_empty
  end
end
