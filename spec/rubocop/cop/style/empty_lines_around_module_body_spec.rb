# frozen_string_literal: true

describe RuboCop::Cop::Style::EmptyLinesAroundModuleBody, :config do
  subject(:cop) { described_class.new(config) }
  let(:extra_begin) { 'Extra empty line detected at module body beginning.' }
  let(:extra_end) { 'Extra empty line detected at module body end.' }
  let(:missing_begin) { 'Empty line missing at module body beginning.' }
  let(:missing_end) { 'Empty line missing at module body end.' }
  let(:missing_def) { 'Empty line missing before first def definition' }
  let(:missing_type) { 'Empty line missing before first module definition' }

  context 'when EnforcedStyle is no_empty_lines' do
    let(:cop_config) { { 'EnforcedStyle' => 'no_empty_lines' } }

    it 'registers an offense for module body starting with a blank' do
      inspect_source(cop,
                     ['module SomeModule',
                      '',
                      '  do_something',
                      'end'])
      expect(cop.messages)
        .to eq(['Extra empty line detected at module body beginning.'])
    end

    it 'registers an offense for module body ending with a blank' do
      inspect_source(cop,
                     ['module SomeModule',
                      '  do_something',
                      '',
                      'end'])
      expect(cop.messages)
        .to eq(['Extra empty line detected at module body end.'])
    end

    it 'autocorrects beginning and end' do
      new_source = autocorrect_source(cop,
                                      ['module SomeModule',
                                       '',
                                       '  do_something',
                                       '',
                                       'end'])
      expect(new_source).to eq(['module SomeModule',
                                '  do_something',
                                'end'].join("\n"))
    end
  end

  context 'when EnforcedStyle is empty_lines' do
    let(:cop_config) { { 'EnforcedStyle' => 'empty_lines' } }

    it 'registers an offense for module body not starting or ending with a ' \
       'blank' do
      inspect_source(cop,
                     ['module SomeModule',
                      '  do_something',
                      'end'])
      expect(cop.messages)
        .to eq(['Empty line missing at module body beginning.',
                'Empty line missing at module body end.'])
    end

    it 'registers an offense for module body not ending with a blank' do
      inspect_source(cop,
                     ['module SomeModule',
                      '',
                      '  do_something',
                      'end'])
      expect(cop.messages).to eq(['Empty line missing at module body end.'])
    end

    it 'autocorrects beginning and end' do
      new_source = autocorrect_source(cop,
                                      ['module SomeModule',
                                       '  do_something',
                                       'end'])
      expect(new_source).to eq(['module SomeModule',
                                '',
                                '  do_something',
                                '',
                                'end'].join("\n"))
    end

    it 'ignores modules with an empty body' do
      source = "module A\nend"
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq(source)
    end
  end

  context 'when EnforcedStyle is empty_lines_except_namespace' do
    let(:cop_config) { { 'EnforcedStyle' => 'empty_lines_except_namespace' } }

    context 'when only child is class' do
      it 'requires no empty lines for namespace' do
        inspect_source(cop,
                       ['module Parent',
                        '  module Child',
                        '',
                        '    do_something',
                        '',
                        '  end',
                        'end'])
        expect(cop.messages).to eq([])
      end

      it 'registers offence for namespace body starting with a blank' do
        inspect_source(cop,
                       ['module Parent',
                        '',
                        '  module Child',
                        '',
                        '    do_something',
                        '',
                        '  end',
                        'end'])
        expect(cop.messages).to eq([extra_begin])
      end

      it 'registers offence for namespace body ending with a blank' do
        inspect_source(cop,
                       ['module Parent',
                        '  module Child',
                        '',
                        '    do_something',
                        '',
                        '  end',
                        '',
                        'end'])
        expect(cop.messages).to eq([extra_end])
      end

      it 'registers offences for namespaced module body not starting '\
          'with a blank' do
        inspect_source(cop,
                       ['module Parent',
                        '  module Child',
                        '    do_something',
                        '',
                        '  end',
                        'end'])
        expect(cop.messages).to eq([missing_begin])
      end

      it 'registers offences for namespaced module body not ending '\
          'with a blank' do
        inspect_source(cop,
                       ['module Parent',
                        '  module Child',
                        '',
                        '    do_something',
                        '  end',
                        'end'])
        expect(cop.messages).to eq([missing_end])
      end

      it 'autocorrects beginning and end' do
        new_source = autocorrect_source(cop,
                                        ['module Parent',
                                         '',
                                         '  module Child',
                                         '    do_something',
                                         '  end',
                                         '',
                                         'end'])
        expect(new_source).to eq(['module Parent',
                                  '  module Child',
                                  '',
                                  '    do_something',
                                  '',
                                  '  end',
                                  'end'].join("\n"))
      end
    end

    context 'when only child is class' do
      it 'requires no empty lines for namespace' do
        inspect_source(cop,
                       ['module Parent',
                        '  class SomeClass',
                        '    do_something',
                        '  end',
                        'end'])
        expect(cop.messages).to eq([])
      end

      it 'registers offence for namespace body starting with a blank' do
        inspect_source(cop,
                       ['module Parent',
                        '',
                        '  class SomeClass',
                        '    do_something',
                        '  end',
                        'end'])
        expect(cop.messages).to eq([extra_begin])
      end

      it 'registers offence for namespace body ending with a blank' do
        inspect_source(cop,
                       ['module Parent',
                        '  class SomeClass',
                        '    do_something',
                        '  end',
                        '',
                        'end'])
        expect(cop.messages).to eq([extra_end])
      end
    end

    context 'when has multiple child modules' do
      it 'requires empty lines for namespace' do
        inspect_source(cop,
                       ['module Parent',
                        '',
                        '  module Mom',
                        '',
                        '    do_something',
                        '',
                        '  end',
                        '  module Dad',
                        '',
                        '  end',
                        '',
                        'end'])
        expect(cop.messages).to eq([])
      end

      it 'registers offences for namespace body starting '\
        'and ending without a blank' do
        inspect_source(cop,
                       ['module Parent',
                        '  module Mom',
                        '',
                        '    do_something',
                        '',
                        '  end',
                        '  module Dad',
                        '',
                        '  end',
                        'end'])
        expect(cop.messages).to eq([missing_begin, missing_end])
      end
    end
  end

  include_examples 'empty_lines_around_class_or_module_body', 'module'
end
