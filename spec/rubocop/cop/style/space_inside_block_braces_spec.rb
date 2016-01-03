# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::SpaceInsideBlockBraces do
  SUPPORTED_STYLES = %w(space no_space).freeze

  subject(:cop) { described_class.new(config) }
  let(:config) do
    merged = RuboCop::ConfigLoader
             .default_configuration['Style/SpaceInsideBlockBraces']
             .merge(cop_config)
    RuboCop::Config.new('Style/BlockDelimiters' => { 'Enabled' => false },
                        'Style/SpaceInsideBlockBraces' => merged)
  end
  let(:cop_config) do
    {
      'EnforcedStyle' => 'space',
      'SupportedStyles' => SUPPORTED_STYLES,
      'SpaceBeforeBlockParameters' => true
    }
  end

  context 'with space inside empty braces not allowed' do
    let(:cop_config) { { 'EnforcedStyleForEmptyBraces' => 'no_space' } }

    it 'accepts empty braces with no space inside' do
      inspect_source(cop, 'each {}')
      expect(cop.messages).to be_empty
    end

    it 'accepts empty braces with line break inside' do
      inspect_source(cop, ['  each {',
                           '  }'])
      expect(cop.messages).to be_empty
    end

    it 'accepts empty braces with comment and line break inside' do
      inspect_source(cop, ['  each { # Comment',
                           '  }'])
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for empty braces with space inside' do
      inspect_source(cop, 'each { }')
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
      inspect_source(cop, 'each { }')
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for empty braces with no space inside' do
      inspect_source(cop, 'each {}')
      expect(cop.messages).to eq(['Space missing inside empty braces.'])
      expect(cop.highlights).to eq(['{}'])
    end

    it 'auto-corrects missing space' do
      new_source = autocorrect_source(cop, 'each {}')
      expect(new_source).to eq('each { }')
    end
  end

  context 'with invalid value for EnforcedStyleForEmptyBraces' do
    let(:cop_config) { { 'EnforcedStyleForEmptyBraces' => 'unknown' } }

    it 'fails with an error' do
      expect { inspect_source(cop, 'each { }') }
        .to raise_error('Unknown EnforcedStyleForEmptyBraces selected!')
    end
  end

  it 'accepts braces surrounded by spaces' do
    inspect_source(cop, 'each { puts }')
    expect(cop.messages).to be_empty
    expect(cop.highlights).to be_empty
  end

  it 'accepts left brace without outer space' do
    inspect_source(cop, 'each{ puts }')
    expect(cop.highlights).to be_empty
  end

  it 'registers an offense for left brace without inner space' do
    inspect_source(cop, 'each {puts }')
    expect(cop.messages).to eq(['Space missing inside {.'])
    expect(cop.highlights).to eq(['p'])
    expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
  end

  it 'registers an offense for right brace without inner space' do
    inspect_source(cop, 'each { puts}')
    expect(cop.messages).to eq(['Space missing inside }.'])
    expect(cop.highlights).to eq(['}'])
    expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
  end

  it 'registers offenses for both braces without inner space' do
    inspect_source(cop, ['a {}',
                         'b { }',
                         'each {puts}'])
    expect(cop.messages).to eq(['Space inside empty braces detected.',
                                'Space missing inside {.',
                                'Space missing inside }.'])
    expect(cop.highlights).to eq([' ', 'p', '}'])

    # Both correct and incorrect code has been found in relation to
    # EnforcedStyleForEmptyBraces, but that doesn't matter. EnforcedStyle can
    # be changed to get rid of the EnforcedStyle offenses.
    expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' =>
                                               'no_space')
  end

  it 'auto-corrects missing space' do
    new_source = autocorrect_source(cop, 'each {puts}')
    expect(new_source).to eq('each { puts }')
  end

  context 'with passed in parameters' do
    it 'accepts left brace with inner space' do
      inspect_source(cop, 'each { |x| puts }')
      expect(cop.messages).to be_empty
      expect(cop.highlights).to be_empty
    end

    it 'registers an offense for left brace without inner space' do
      inspect_source(cop, 'each {|x| puts }')
      expect(cop.messages).to eq(['Space between { and | missing.'])
      expect(cop.highlights).to eq(['{|'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'accepts new lambda syntax' do
      inspect_source(cop, '->(x) { x }')
      expect(cop.messages).to be_empty
    end

    it 'auto-corrects missing space' do
      new_source = autocorrect_source(cop, 'each {|x| puts }')
      expect(new_source).to eq('each { |x| puts }')
    end

    context 'and BlockDelimiters cop enabled' do
      let(:config) do
        RuboCop::Config.new('Style/BlockDelimiters' => { 'Enabled' => true },
                            'Style/SpaceInsideBlockBraces' => cop_config)
      end

      it 'does auto-correction for single-line blocks' do
        new_source = autocorrect_source(cop, 'each {|x| puts}')
        expect(new_source).to eq('each { |x| puts }')
      end

      it 'does not do auto-correction for multi-line blocks' do
        # {} will be changed to do..end by the BlockDelimiters cop, and then
        # this cop is not relevant anymore.
        old_source = ['each {|x|',
                      '  puts',
                      '}']
        new_source = autocorrect_source(cop, old_source)
        expect(new_source).to eq(old_source.join("\n"))
      end
    end

    context 'and space before block parameters not allowed' do
      let(:cop_config) do
        {
          'EnforcedStyle'              => 'space',
          'SupportedStyles'            => SUPPORTED_STYLES,
          'SpaceBeforeBlockParameters' => false
        }
      end

      it 'registers an offense for left brace with inner space' do
        inspect_source(cop, 'each { |x| puts }')
        expect(cop.messages).to eq(['Space between { and | detected.'])
        expect(cop.highlights).to eq([' '])
        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      end

      it 'accepts new lambda syntax' do
        inspect_source(cop, '->(x) { x }')
        expect(cop.messages).to be_empty
      end

      it 'auto-corrects unwanted space' do
        new_source = autocorrect_source(cop, 'each { |x| puts }')
        expect(new_source).to eq('each {|x| puts }')
      end

      it 'accepts left brace without inner space' do
        inspect_source(cop, 'each {|x| puts }')
        expect(cop.messages).to be_empty
        expect(cop.highlights).to be_empty
      end
    end
  end

  context 'configured with no_space' do
    let(:cop_config) do
      {
        'EnforcedStyle'              => 'no_space',
        'SupportedStyles'            => SUPPORTED_STYLES,
        'SpaceBeforeBlockParameters' => true
      }
    end

    it 'accepts braces without spaces inside' do
      inspect_source(cop, 'each {puts}')
      expect(cop.messages).to be_empty
      expect(cop.highlights).to be_empty
    end

    it 'registers an offense for left brace with inner space' do
      inspect_source(cop, 'each { puts}')
      expect(cop.messages).to eq(['Space inside { detected.'])
      expect(cop.highlights).to eq([' '])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'registers an offense for right brace with inner space' do
      inspect_source(cop, 'each {puts  }')
      expect(cop.messages).to eq(['Space inside } detected.'])
      expect(cop.highlights).to eq(['  '])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'registers offenses for both braces with inner space' do
      inspect_source(cop, 'each { puts  }')
      expect(cop.messages).to eq(['Space inside { detected.',
                                  'Space inside } detected.'])
      expect(cop.highlights).to eq([' ', '  '])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' =>
                                                 'space')
    end

    it 'accepts left brace without outer space' do
      inspect_source(cop, 'each {puts}')
      expect(cop.highlights).to be_empty
    end

    it 'auto-corrects unwanted space' do
      new_source = autocorrect_source(cop, 'each{ puts }')
      expect(new_source).to eq('each{puts}')
    end

    context 'with passed in parameters' do
      context 'and space before block parameters allowed' do
        it 'accepts left brace with inner space' do
          inspect_source(cop, 'each { |x| puts}')
          expect(cop.messages).to eq([])
          expect(cop.highlights).to eq([])
        end

        it 'registers an offense for left brace without inner space' do
          inspect_source(cop, 'each {|x| puts}')
          expect(cop.messages).to eq(['Space between { and | missing.'])
          expect(cop.highlights).to eq(['{|'])
          expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
        end

        it 'accepts new lambda syntax' do
          inspect_source(cop, '->(x) {x}')
          expect(cop.messages).to be_empty
        end

        it 'auto-corrects missing space' do
          new_source = autocorrect_source(cop, 'each {|x| puts}')
          expect(new_source).to eq('each { |x| puts}')
        end
      end

      context 'and space before block parameters not allowed' do
        let(:cop_config) do
          {
            'EnforcedStyle'              => 'no_space',
            'SupportedStyles'            => SUPPORTED_STYLES,
            'SpaceBeforeBlockParameters' => false
          }
        end

        it 'registers an offense for left brace with inner space' do
          inspect_source(cop, 'each { |x| puts}')
          expect(cop.messages).to eq(['Space between { and | detected.'])
          expect(cop.highlights).to eq([' '])
          expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
        end

        it 'accepts new lambda syntax' do
          inspect_source(cop, '->(x) {x}')
          expect(cop.messages).to be_empty
        end

        it 'auto-corrects unwanted space' do
          new_source = autocorrect_source(cop, 'each { |x| puts}')
          expect(new_source).to eq('each {|x| puts}')
        end
      end
    end
  end
end
