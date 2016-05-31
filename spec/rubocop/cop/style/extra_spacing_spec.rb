# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::ExtraSpacing, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'common behavior' do
    it 'registers an offense for alignment with token not preceded by space' do
      # The = and the ( are on the same column, but this is not for alignment,
      # it's just a mistake.
      inspect_source(cop, ['website("example.org")',
                           'name   = "Jill"'])
      expect(cop.offenses.size).to eq(1)
    end

    it 'accepts aligned values of an implicit hash literal' do
      source = ["register(street1:    '1 Market',",
                "         street2:    '#200',",
                "         :city =>    'Some Town',",
                "         state:      'CA',",
                "         postal_code:'99999-1111')"]
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end

    it 'accepts space between key and value in a hash with hash rockets' do
      source = [
        'ospf_h = {',
        "  'ospfTest'    => {",
        "    'foo'      => {",
        "      area: '0.0.0.0', cost: 10, hello: 30, pass: true },",
        "    'longname' => {",
        "      area: '1.1.1.38', pass: false },",
        "    'vlan101'  => {",
        "      area: '2.2.2.101', cost: 5, hello: 20, pass: true }",
        '  },',
        "  'TestOspfInt' => {",
        "    'x'               => {",
        "      area: '0.0.0.19' },",
        "    'vlan290'         => {",
        "      area: '2.2.2.29', cost: 200, hello: 30, pass: true },",
        "    'port-channel100' => {",
        "      area: '3.2.2.29', cost: 25, hello: 50, pass: false }",
        '  }',
        '}'
      ]
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end

    it 'can handle extra space before a float' do
      source = ['{:a => "a",',
                ' :b => [nil,  2.5]}']
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end

    it 'can handle unary plus in an argument list' do
      source = ['assert_difference(MyModel.count, +2,',
                '                  3,  +3,', # Extra spacing only here.
                '                  4,+4)']
      inspect_source(cop, source)
      expect(cop.offenses.map { |o| o.location.line }).to eq([2])
    end

    it 'gives the correct line' do
      inspect_source(cop, ['class A   < String',
                           'end'])
      expect(cop.offenses.first.location.line).to eq(1)
    end

    it 'registers an offense for double extra spacing on variable assignment' do
      inspect_source(cop, 'm    = "hello"')
      expect(cop.offenses.size).to eq(1)
    end

    it 'ignores whitespace at the beginning of the line' do
      inspect_source(cop, '  m = "hello"')
      expect(cop.offenses.size).to eq(0)
    end

    it 'ignores whitespace inside a string' do
      inspect_source(cop, 'm = "hello   this"')
      expect(cop.offenses.size).to eq(0)
    end

    it 'ignores trailing whitespace' do
      inspect_source(cop, ['      class Benchmarker < Performer     ',
                           '      end'])
      expect(cop.offenses.size).to eq(0)
    end

    it 'registers an offense on class inheritance' do
      inspect_source(cop, ['class A   < String',
                           'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it 'auto-corrects a line indented with mixed whitespace' do
      new_source = autocorrect_source(cop, ['website("example.org")',
                                            'name    = "Jill"'])
      expect(new_source).to eq(['website("example.org")',
                                'name = "Jill"'].join("\n"))
    end

    it 'auto-corrects the class inheritance' do
      new_source = autocorrect_source(cop, ['class A   < String',
                                            'end'])
      expect(new_source).to eq(['class A < String',
                                'end'].join("\n"))
    end
  end

  SOURCES = {
    'lining up assignments' => [
      'website = "example.org"',
      'name    = "Jill"'
    ],

    'lining up assignments with empty lines and comments in between' => [
      'a   += 1',
      '',
      '# Comment',
      'aa   = 2',
      'bb   = 3',
      '',
      'a  ||= 1'
    ],

    'aligning with the same character' => [
      '      y, m = (year * 12 + (mon - 1) + n).divmod(12)',
      '      m,   = (m + 1)                    .divmod(1)'
    ],

    'lining up different kinds of assignments' => [
      'type_name ||= value.class.name if value',
      'type_name   = type_name.to_s   if type_name',
      '',
      'type_name  = value.class.name if     value',
      'type_name += type_name.to_s   unless type_name',
      '',
      'a  += 1',
      'aa -= 2'
    ],

    'aligning comments on non-adjacent lines' => [
      %(include_examples 'aligned',   'var = until',  'test'),
      '',
      %(include_examples 'unaligned', "var = if",     'test')
    ],

    'aligning = on lines where there are trailing comments' => [
      'a_long_var_name = 100 # this is 100',
      'short_name1     = 2',
      '',
      'clear',
      '',
      'short_name2     = 2',
      'a_long_var_name = 100 # this is 100',
      '',
      'clear',
      '',
      'short_name3     = 2   # this is 2',
      'a_long_var_name = 100 # this is 100'
    ],

    'aligning tokens with empty line between' => [
      'unless nochdir',
      '  Dir.chdir "/"    # Release old working directory.',
      'end',
      '',
      'File.umask 0000    # Ensure sensible umask.'
    ],

    'aligning long assignment expressions that include line breaks' => [
      'size_attribute_name    = FactoryGirl.create(:attribute,',
      "                                            name:   'Size',",
      '                                            values: %w{small large})',
      'carrier_attribute_name = FactoryGirl.create(:attribute,',
      "                                            name:   'Carrier',",
      '                                            values: %w{verizon})'
    ]
  }.freeze

  context 'when AllowForAlignment is true' do
    let(:cop_config) do
      { 'AllowForAlignment' => true, 'ForceEqualSignAlignment' => false }
    end

    include_examples 'common behavior'

    context 'with extra spacing for alignment purposes' do
      SOURCES.each do |reason, src|
        context "such as #{reason}" do
          it 'allows it' do
            inspect_source(cop, src)
            expect(cop.offenses).to be_empty
          end
        end
      end
    end
  end

  context 'when AllowForAlignment is false' do
    let(:cop_config) do
      { 'AllowForAlignment' => false, 'ForceEqualSignAlignment' => false }
    end

    include_examples 'common behavior'

    context 'with extra spacing for alignment purposes' do
      SOURCES.each do |reason, src|
        context "such as #{reason}" do
          it 'registers offense(s)' do
            inspect_source(cop, src)
            expect(cop.offenses).not_to be_empty
          end
        end
      end
    end
  end

  context 'when ForceEqualSignAlignment is true' do
    let(:cop_config) do
      { 'AllowForAlignment' => true, 'ForceEqualSignAlignment' => true }
    end

    it 'registers an offense if consecutive assignments are not aligned' do
      inspect_source(cop, ['a = 1',
                           'bb = 2',
                           'ccc = 3'])
      expect(cop.offenses.size).to eq(3)
      expect(cop.messages).to eq(
        ['`=` is not aligned with the following assignment.',
         '`=` is not aligned with the preceding assignment.',
         '`=` is not aligned with the preceding assignment.']
      )
    end

    it 'does not register an offense if assignments are separated by blanks' do
      inspect_source(cop, ['a = 1',
                           '',
                           'bb = 2',
                           '',
                           'ccc = 3'])
      expect(cop.offenses.size).to eq(0)
    end

    it 'does not register an offense if assignments are aligned' do
      inspect_source(cop, ['a   = 1',
                           'bb  = 2',
                           'ccc = 3'])
      expect(cop.offenses.size).to eq(0)
    end

    it 'aligns the first assignment with the following assignment' do
      inspect_source(cop, ['# comment',
                           'a   = 1',
                           'bb  = 2'])
      expect(cop.offenses.size).to eq(0)
    end

    it 'autocorrects consecutive assignments which are not aligned' do
      new_source = autocorrect_source(cop, ['a = 1',
                                            'bb = 2',
                                            'ccc = 3',
                                            '',
                                            'abcde        = 1',
                                            'a                 = 2',
                                            'abc = 3'])
      expect(new_source).to eq(['a   = 1',
                                'bb  = 2',
                                'ccc = 3',
                                '',
                                'abcde = 1',
                                'a     = 2',
                                'abc   = 3'].join("\n"))
    end

    it 'autocorrects consecutive operator assignments which are not aligned' do
      new_source = autocorrect_source(cop, ['a += 1',
                                            'bb = 2',
                                            'ccc <<= 3',
                                            '',
                                            'abcde        = 1',
                                            'a                 *= 2',
                                            'abc ||= 3'])
      expect(new_source).to eq(['a    += 1',
                                'bb    = 2',
                                'ccc <<= 3',
                                '',
                                'abcde = 1',
                                'a    *= 2',
                                'abc ||= 3'].join("\n"))
    end

    it 'autocorrects consecutive aref assignments which are not aligned' do
      new_source = autocorrect_source(cop, ['a[1] = 1',
                                            'bb[2,3] = 2',
                                            'ccc[:key] = 3',
                                            '',
                                            'abcde[0]        = 1',
                                            'a                 = 2',
                                            'abc += 3'])
      expect(new_source).to eq(['a[1]      = 1',
                                'bb[2,3]   = 2',
                                'ccc[:key] = 3',
                                '',
                                'abcde[0] = 1',
                                'a        = 2',
                                'abc     += 3'].join("\n"))
    end

    it 'autocorrects consecutive attribute assignments which are not aligned' do
      new_source = autocorrect_source(cop, ['a.attr = 1',
                                            'bb &&= 2',
                                            'ccc.s = 3',
                                            '',
                                            'abcde.blah        = 1',
                                            'a.attribute_name              = 2',
                                            'abc[1] = 3'])
      expect(new_source).to eq(['a.attr = 1',
                                'bb   &&= 2',
                                'ccc.s  = 3',
                                '',
                                'abcde.blah       = 1',
                                'a.attribute_name = 2',
                                'abc[1]           = 3'].join("\n"))
    end

    it 'does not register an offense when optarg equals is not aligned with ' \
       'assignment equals sign' do
      inspect_source(cop, ['def method(arg = 1)',
                           '  var = arg',
                           'end'])
      expect(cop.offenses).to be_empty
    end
  end
end
