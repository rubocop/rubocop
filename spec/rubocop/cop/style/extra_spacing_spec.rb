# encoding: utf-8

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

    it 'can handle extra space before a float' do
      source = ['{:a => "a",',
                ' :b => [nil,  2.5]}']
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
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
    ]
  }

  context 'when AllowForAlignment is true' do
    let(:cop_config) { { 'AllowForAlignment' => true } }

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
    let(:cop_config) { { 'AllowForAlignment' => false } }

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
end
