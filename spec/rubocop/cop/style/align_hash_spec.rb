# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::AlignHash, :config do
  shared_examples 'not on separate lines' do
    it 'accepts single line hash' do
      inspect_source(cop, 'func(a: 0, bb: 1)')
      expect(cop.offences).to be_empty
    end

    it 'accepts several pairs per line' do
      inspect_source(cop, ['func(a: 1, bb: 2,',
                           '     ccc: 3, dddd: 4)'])
      expect(cop.offences).to be_empty
    end
  end

  subject(:cop) { described_class.new(config) }
  let(:cop_config) do
    {
      'EnforcedHashRocketStyle' => 'key',
      'EnforcedColonStyle' => 'key'
    }
  end

  context 'with default configuration' do
    it 'registers an offence for misaligned hash keys' do
      inspect_source(cop, ['hash1 = {',
                           '  a: 0,',
                           '   bb: 1',
                           '}',
                           'hash2 = {',
                           "  'ccc' => 2,",
                           " 'dddd'  =>  2",
                           '}'])
      expect(cop.messages).to eq(['Align the elements of a hash ' \
                                  'literal if they span more than ' +
                                  'one line.'] * 2)
      expect(cop.highlights).to eq(['bb: 1',
                                    "'dddd'  =>  2"])
    end

    it 'accepts aligned hash keys' do
      inspect_source(cop, ['hash1 = {',
                           '  a: 0,',
                           '  bb: 1,',
                           '}',
                           'hash2 = {',
                           "  'ccc' => 2,",
                           "  'dddd'  =>  2",
                           '}'])
      expect(cop.offences).to be_empty
    end

    it 'registers an offence for separator alignment' do
      inspect_source(cop, ['hash = {',
                           "    'a' => 0,",
                           "  'bbb' => 1",
                           '}'])
      expect(cop.offences.size).to eq(1)
      expect(cop.highlights).to eq(["'bbb' => 1"])
    end

    context 'with braceless hash as last argument' do
      it 'registers an offence for misaligned hash keys' do
        inspect_source(cop, ['func(a: 0,',
                             '  b: 1)'])
        expect(cop.offences.size).to eq(1)
      end

      it 'registers an offence for right alignment of keys' do
        inspect_source(cop, ['func(a: 0,',
                             '   bbb: 1)'])
        expect(cop.offences.size).to eq(1)
      end

      it 'accepts aligned hash keys' do
        inspect_source(cop, ['func(a: 0,',
                             '     b: 1)'])
        expect(cop.offences).to be_empty
      end

      it 'accepts an empty hash' do
        inspect_source(cop, 'h = {}')
        expect(cop.offences).to be_empty
      end
    end

    it 'auto-corrects alignment' do
      new_source = autocorrect_source(cop, ['hash1 = { a: 0,',
                                            '     bb: 1,',
                                            '           ccc: 2 }',
                                            'hash2 = { :a   => 0,',
                                            '     :bb  => 1,',
                                            '          :ccc  =>2 }'
                                           ])
      expect(new_source).to eq(['hash1 = { a: 0,',
                                '          bb: 1,',
                                '          ccc: 2 }',
                                'hash2 = { :a   => 0,',
                                '          :bb  => 1,',
                                # Separator and value are not corrected
                                # in 'key' mode.
                                '          :ccc  =>2 }'].join("\n"))
    end
  end

  include_examples 'not on separate lines'

  context 'with table alignment configuration' do
    let(:cop_config) do
      {
        'EnforcedHashRocketStyle' => 'table',
        'EnforcedColonStyle' => 'table'
      }
    end

    include_examples 'not on separate lines'

    it 'accepts aligned hash keys' do
      inspect_source(cop, ['hash1 = {',
                           "  'a'   => 0,",
                           "  'bbb' => 1",
                           '}',
                           'hash2 = {',
                           '  a:   0,',
                           '  bbb: 1',
                           '}'
                          ])
      expect(cop.offences).to be_empty
    end

    it 'accepts an empty hash' do
      inspect_source(cop, 'h = {}')
      expect(cop.offences).to be_empty
    end

    it 'accepts a multiline array of single line hashes' do
      inspect_source(cop, ['def self.scenarios_order',
                           '    [',
                           '      { before:   %w( l k ) },',
                           '      { ending:   %w( m l ) },',
                           '      { starting: %w( m n ) },',
                           '      { after:    %w( n o ) }',
                           '    ]',
                           '  end'])
      expect(cop.offences).to be_empty
    end

    it 'registers an offence for misaligned hash values' do
      inspect_source(cop, ['hash1 = {',
                           "  'a'   =>  0,",
                           "  'bbb' => 1",
                           '}',
                           'hash2 = {',
                           '  a:   0,',
                           '  bbb:1',
                           '}'
                          ])
      expect(cop.highlights).to eq(["'a'   =>  0",
                                    'bbb:1'])
    end

    it 'registers an offence for misaligned hash rockets' do
      inspect_source(cop, ['hash = {',
                           "  'a'   => 0,",
                           "  'bbb'  => 1",
                           '}'])
      expect(cop.offences.size).to eq(1)
    end

    it 'auto-corrects alignment' do
      new_source = autocorrect_source(cop, ['hash1 = { a: 0,',
                                            '     bb:   1,',
                                            '           ccc: 2 }',
                                            "hash2 = { 'a' => 0,",
                                            "     'bb' =>   1,",
                                            "           'ccc'  =>2 }"])
      expect(new_source).to eq(['hash1 = { a:   0,',
                                '          bb:  1,',
                                '          ccc: 2 }',
                                "hash2 = { 'a'   => 0,",
                                "          'bb'  => 1,",
                                "          'ccc' => 2 }"].join("\n"))
    end
  end

  context 'with table+separator alignment configuration' do
    let(:cop_config) do
      {
        'EnforcedHashRocketStyle' => 'table',
        'EnforcedColonStyle' => 'separator'
      }
    end

    it 'accepts a single method argument entry with colon' do
      inspect_source(cop, ['merge(parent: nil)'])
      expect(cop.offences).to be_empty
    end
  end

  context 'with invalid configuration' do
    let(:cop_config) do
      {
        'EnforcedHashRocketStyle' => 'junk',
        'EnforcedColonStyle' => 'junk'
      }
    end
    it 'fails' do
      src = ['hash = {',
             '  a: 0,',
             '  bb: 1',
             '}']
      expect { inspect_source(cop, src) }.to raise_error(RuntimeError)
    end
  end

  context 'with separator alignment configuration' do
    let(:cop_config) do
      {
        'EnforcedHashRocketStyle' => 'separator',
        'EnforcedColonStyle' => 'separator'
      }
    end

    it 'accepts aligned hash keys' do
      inspect_source(cop, ['hash1 = {',
                           '    a: 0,',
                           '  bbb: 1',
                           '}',
                           'hash2 = {',
                           "    'a' => 0,",
                           "  'bbb' => 1",
                           '}'])
      expect(cop.offences).to be_empty
    end

    it 'accepts an empty hash' do
      inspect_source(cop, 'h = {}')
      expect(cop.offences).to be_empty
    end

    it 'registers an offence for misaligned hash values' do
      inspect_source(cop, ['hash = {',
                           "    'a' =>  0,",
                           "  'bbb' => 1",
                           '}'])
      expect(cop.offences.size).to eq(1)
    end

    it 'registers an offence for misaligned hash rockets' do
      inspect_source(cop, ['hash = {',
                           "    'a'  => 0,",
                           "  'bbb' =>  1",
                           '}'])
      expect(cop.offences.size).to eq(1)
    end

    include_examples 'not on separate lines'

    it 'auto-corrects alignment' do
      new_source = autocorrect_source(cop, ['hash1 = { a: 0,',
                                            '     bb:    1,',
                                            '           ccc: 2 }',
                                            'hash2 = { a => 0,',
                                            '     bb =>    1,',
                                            '           ccc  =>2 }'])
      expect(new_source).to eq(['hash1 = { a: 0,',
                                '         bb: 1,',
                                '        ccc: 2 }',
                                'hash2 = { a => 0,',
                                '         bb => 1,',
                                '        ccc => 2 }'].join("\n"))
    end
  end

  context 'with different settings for => and :' do
    let(:cop_config) do
      {
        'EnforcedHashRocketStyle' => 'key',
        'EnforcedColonStyle' => 'separator'
      }
    end

    it 'registers offences for misaligned entries' do
      inspect_source(cop, ['hash1 = {',
                           '  a:   0,',
                           '  bbb: 1',
                           '}',
                           'hash2 = {',
                           "    'a' => 0,",
                           "  'bbb' => 1",
                           '}'])
      expect(cop.highlights).to eq(['bbb: 1', "'bbb' => 1"])
    end

    it 'accepts aligned entries' do
      inspect_source(cop, ['hash1 = {',
                           '    a: 0,',
                           '  bbb: 1',
                           '}',
                           'hash2 = {',
                           "  'a' => 0,",
                           "  'bbb' => 1",
                           '}'])
      expect(cop.offences).to be_empty
    end
  end
end
