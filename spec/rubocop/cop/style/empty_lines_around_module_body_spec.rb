# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::EmptyLinesAroundModuleBody, :config do
  subject(:cop) { described_class.new(config) }

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
end
