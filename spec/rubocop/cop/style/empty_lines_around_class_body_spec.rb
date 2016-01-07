# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::EmptyLinesAroundClassBody, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is no_empty_lines' do
    let(:cop_config) { { 'EnforcedStyle' => 'no_empty_lines' } }

    it 'registers an offense for class body starting with a blank' do
      inspect_source(cop,
                     ['class SomeClass',
                      '',
                      '  do_something',
                      'end'])
      expect(cop.messages)
        .to eq(['Extra empty line detected at class body beginning.'])
    end

    it 'autocorrects class body containing only a blank' do
      corrected = autocorrect_source(cop,
                                     ['class SomeClass',
                                      '',
                                      'end'])
      expect(corrected).to eq ['class SomeClass',
                               'end'].join("\n")
    end

    it 'registers an offense for class body ending with a blank' do
      inspect_source(cop,
                     ['class SomeClass',
                      '  do_something',
                      '',
                      'end'])
      expect(cop.messages)
        .to eq(['Extra empty line detected at class body end.'])
    end

    it 'registers an offense for singleton class body starting with a blank' do
      inspect_source(cop,
                     ['class << self',
                      '',
                      '  do_something',
                      'end'])
      expect(cop.messages)
        .to eq(['Extra empty line detected at class body beginning.'])
    end

    it 'autocorrects singleton class body containing only a blank' do
      corrected = autocorrect_source(cop,
                                     ['class << self',
                                      '',
                                      'end'])
      expect(corrected).to eq ['class << self',
                               'end'].join("\n")
    end

    it 'registers an offense for singleton class body ending with a blank' do
      inspect_source(cop,
                     ['class << self',
                      '  do_something',
                      '',
                      'end'])
      expect(cop.messages)
        .to eq(['Extra empty line detected at class body end.'])
    end
  end

  context 'when EnforcedStyle is empty_lines' do
    let(:cop_config) { { 'EnforcedStyle' => 'empty_lines' } }

    it 'registers an offense for class body not starting or ending with a ' \
       'blank' do
      inspect_source(cop,
                     ['class SomeClass',
                      '  do_something',
                      'end'])
      expect(cop.messages).to eq(['Empty line missing at class body beginning.',
                                  'Empty line missing at class body end.'])
    end

    it 'ignores classes with an empty body' do
      source = "class SomeClass\nend"
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq(source)
    end

    it 'autocorrects beginning and end' do
      new_source = autocorrect_source(cop,
                                      ['class SomeClass',
                                       '  do_something',
                                       'end'])
      expect(new_source).to eq(['class SomeClass',
                                '',
                                '  do_something',
                                '',
                                'end'].join("\n"))
    end

    it 'registers an offense for singleton class body not starting or ending ' \
       'with a blank' do
      inspect_source(cop,
                     ['class << self',
                      '  do_something',
                      'end'])
      expect(cop.messages).to eq(['Empty line missing at class body beginning.',
                                  'Empty line missing at class body end.'])
    end

    it 'ignores singleton classes with an empty body' do
      source = "class << self\nend"
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq(source)
    end

    it 'autocorrects beginning and end' do
      new_source = autocorrect_source(cop,
                                      ['class << self',
                                       '  do_something',
                                       'end'])
      expect(new_source).to eq(['class << self',
                                '',
                                '  do_something',
                                '',
                                'end'].join("\n"))
    end
  end
end
