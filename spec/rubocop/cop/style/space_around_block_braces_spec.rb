# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::SpaceAroundBlockBraces do
  SUPPORTED_STYLES = %w(space_inside_braces no_space_inside_braces)

  subject(:cop) { described_class.new(config) }
  let(:config) do
    merged = Rubocop::ConfigLoader
      .default_configuration['SpaceAroundBlockBraces'].merge(cop_config)
    Rubocop::Config.new('Blocks' => { 'Enabled' => false },
                        'SpaceAroundBlockBraces' => merged)
  end
  let(:cop_config) do
    {
      'EnforcedStyle' => 'space_inside_braces',
      'SupportedStyles' => SUPPORTED_STYLES,
      'SpaceBeforeBlockParameters' => true
    }
  end

  context 'with space inside empty braces not allowed' do
    let(:cop_config) { { 'EnforcedStyleForEmptyBraces' => 'no_space' } }

    it 'accepts empty braces with no space inside' do
      inspect_source(cop, ['each {}'])
      expect(cop.messages).to be_empty
    end

    it 'accepts empty braces with line break inside' do
      inspect_source(cop, ['  each {',
                           '  }'])
      expect(cop.messages).to be_empty
    end

    it 'registers an offence for empty braces with space inside' do
      inspect_source(cop, ['each { }'])
      expect(cop.messages).to eq(['Space inside empty braces detected.'])
      expect(cop.highlights).to eq([' '])
    end

    it 'auto-corrects unwanted space' do
      new_source = autocorrect_source(cop, 'each { }')
      expect(new_source).to eq('each {}')
    end

    it 'does not auto-correct when braces are not empty' do
      old_source = <<-END
        a {
          b
        }
      END
      new_source = autocorrect_source(cop, old_source)
      expect(new_source).to eq(old_source)
    end
  end

  context 'with space inside empty braces allowed' do
    let(:cop_config) { { 'EnforcedStyleForEmptyBraces' => 'space' } }

    it 'accepts empty braces with space inside' do
      inspect_source(cop, ['each { }'])
      expect(cop.messages).to be_empty
    end

    it 'registers an offence for empty braces with no space inside' do
      inspect_source(cop, ['each {}'])
      expect(cop.messages).to eq(['Space missing inside empty braces.'])
      expect(cop.highlights).to eq(['{}'])
    end

    it 'auto-corrects missing space' do
      new_source = autocorrect_source(cop, 'each {}')
      expect(new_source).to eq('each { }')
    end
  end

  it 'accepts braces surrounded by spaces' do
    inspect_source(cop, ['each { puts }'])
    expect(cop.messages).to be_empty
    expect(cop.highlights).to be_empty
  end

  it 'registers an offence for left brace without outer space' do
    inspect_source(cop, ['each{ puts }'])
    expect(cop.messages).to eq(['Space missing to the left of {.'])
    expect(cop.highlights).to eq(['{'])
  end

  it 'registers an offence for left brace without inner space' do
    inspect_source(cop, ['each {puts }'])
    expect(cop.messages).to eq(['Space missing inside {.'])
    expect(cop.highlights).to eq(['p'])
  end

  it 'registers an offence for right brace without inner space' do
    inspect_source(cop, ['each { puts}'])
    expect(cop.messages).to eq(['Space missing inside }.'])
    expect(cop.highlights).to eq(['}'])
    expect(cop.config_to_allow_offences).to eq('Enabled' => false)
  end

  it 'registers offences for both braces without inner space' do
    inspect_source(cop, ['a {}',
                         'b { }',
                         'each {puts}'])
    expect(cop.messages).to eq(['Space inside empty braces detected.',
                                'Space missing inside {.',
                                'Space missing inside }.'])
    expect(cop.highlights).to eq([' ', 'p', '}'])

    # Both correct and incorrect code has been found in relation to
    # EnforcedStyleForEmptyBraces, but that doesn't matter. EnforcedStyle can
    # be changed to get rid of the EnforcedStyle offences.
    expect(cop.config_to_allow_offences).to eq('EnforcedStyle' =>
                                               'no_space_inside_braces')
  end

  it 'auto-corrects missing space' do
    new_source = autocorrect_source(cop, 'each {puts}')
    expect(new_source).to eq('each { puts }')
  end

  context 'with passed in parameters' do
    it 'accepts left brace with inner space' do
      inspect_source(cop, ['each { |x| puts }'])
      expect(cop.messages).to be_empty
      expect(cop.highlights).to be_empty
    end

    it 'registers an offence for left brace without inner space' do
      inspect_source(cop, ['each {|x| puts }'])
      expect(cop.messages).to eq(['Space between { and | missing.'])
      expect(cop.highlights).to eq(['{|'])
    end

    it 'auto-corrects missing space' do
      new_source = autocorrect_source(cop, 'each{|x| puts }')
      expect(new_source).to eq('each { |x| puts }')
    end

    context 'and Blocks cop enabled' do
      let(:config) do
        Rubocop::Config.new('Blocks'                 => { 'Enabled' => true },
                            'SpaceAroundBlockBraces' => cop_config)
      end

      it 'does auto-correction for single-line blocks' do
        new_source = autocorrect_source(cop, 'each{|x| puts}')
        expect(new_source).to eq('each { |x| puts }')
      end

      it 'does not do auto-correction for multi-line blocks' do
        # {} will be changed to do..end by the Blocks cop, and then this cop is
        # not relevant anymore.
        old_source = ['each{|x|',
                      '  puts',
                      '}']
        new_source = autocorrect_source(cop, old_source)
        expect(new_source).to eq(old_source.join("\n"))
      end
    end

    context 'and space before block parameters not allowed' do
      let(:cop_config) do
        {
          'EnforcedStyle'              => 'space_inside_braces',
          'SupportedStyles'            => SUPPORTED_STYLES,
          'SpaceBeforeBlockParameters' => false
        }
      end

      it 'registers an offence for left brace with inner space' do
        inspect_source(cop, ['each { |x| puts }'])
        expect(cop.messages).to eq(['Space between { and | detected.'])
        expect(cop.highlights).to eq([' '])
      end

      it 'auto-corrects unwanted space' do
        new_source = autocorrect_source(cop, 'each { |x| puts }')
        expect(new_source).to eq('each {|x| puts }')
      end

      it 'accepts left brace without inner space' do
        inspect_source(cop, ['each {|x| puts }'])
        expect(cop.messages).to be_empty
        expect(cop.highlights).to be_empty
      end
    end
  end

  context 'configured with no_space_inside_braces' do
    let(:cop_config) do
      {
        'EnforcedStyle'              => 'no_space_inside_braces',
        'SupportedStyles'            => SUPPORTED_STYLES,
        'SpaceBeforeBlockParameters' => true
      }
    end

    it 'accepts braces without spaces inside' do
      inspect_source(cop, ['each {puts}'])
      expect(cop.messages).to be_empty
      expect(cop.highlights).to be_empty
    end

    it 'registers an offence for left brace with inner space' do
      inspect_source(cop, ['each { puts}'])
      expect(cop.messages).to eq(['Space inside { detected.'])
      expect(cop.highlights).to eq([' '])
      expect(cop.config_to_allow_offences).to eq('Enabled' => false)
    end

    it 'registers an offence for right brace with inner space' do
      inspect_source(cop, ['each {puts  }'])
      expect(cop.messages).to eq(['Space inside } detected.'])
      expect(cop.highlights).to eq(['  '])
    end

    it 'registers offences for both braces with inner space' do
      inspect_source(cop, ['each { puts  }'])
      expect(cop.messages).to eq(['Space inside { detected.',
                                  'Space inside } detected.'])
      expect(cop.highlights).to eq([' ', '  '])
      expect(cop.config_to_allow_offences).to eq('EnforcedStyle' =>
                                                 'space_inside_braces')
    end

    it 'registers an offence for left brace without outer space' do
      inspect_source(cop, ['each{puts}'])
      expect(cop.messages).to eq(['Space missing to the left of {.'])
      expect(cop.highlights).to eq(['{'])
    end

    it 'auto-corrects missing space' do
      new_source = autocorrect_source(cop, 'each{ puts }')
      expect(new_source).to eq('each {puts}')
    end

    context 'with passed in parameters' do
      context 'and space before block parameters allowed' do
        it 'accepts left brace with inner space' do
          inspect_source(cop, ['each { |x| puts}'])
          expect(cop.messages).to eq([])
          expect(cop.highlights).to eq([])
        end

        it 'registers an offence for left brace without inner space' do
          inspect_source(cop, ['each {|x| puts}'])
          expect(cop.messages).to eq(['Space between { and | missing.'])
          expect(cop.highlights).to eq(['{|'])
        end

        it 'auto-corrects missing space' do
          new_source = autocorrect_source(cop, 'each {|x| puts}')
          expect(new_source).to eq('each { |x| puts}')
        end
      end

      context 'and space before block parameters not allowed' do
        let(:cop_config) do
          {
            'EnforcedStyle'              => 'no_space_inside_braces',
            'SupportedStyles'            => SUPPORTED_STYLES,
            'SpaceBeforeBlockParameters' => false
          }
        end

        it 'registers an offence for left brace with inner space' do
          inspect_source(cop, ['each { |x| puts}'])
          expect(cop.messages).to eq(['Space between { and | detected.'])
          expect(cop.highlights).to eq([' '])
        end

        it 'auto-corrects unwanted space' do
          new_source = autocorrect_source(cop, 'each { |x| puts}')
          expect(new_source).to eq('each {|x| puts}')
        end
      end
    end
  end
end
