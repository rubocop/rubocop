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

    it 'autocorrects class body containing nothing' do
      corrected = autocorrect_source(cop,
                                     ['class SomeClass',
                                      'end'])
      expect(corrected).to eq ['class SomeClass',
                               '',
                               'end'].join("\n")
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

    it 'autocorrects singleton class body containing nothing' do
      corrected = autocorrect_source(cop,
                                     ['class << self',
                                      'end'])
      expect(corrected).to eq ['class << self',
                               '',
                               'end'].join("\n")
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

  context 'when EnforcedStyle is top_level_only' do
    let(:cop_config) { { 'EnforcedStyle' => 'top_level_only' } }

    it 'registers an offense for top-level class with no blanks' do
      inspect_source(cop, ['class A',
                           '  def method',
                           '  end',
                           'end'])
      expect(cop.offenses.size).to eq(2)
      expect(cop.messages).to eq([
        'Empty line missing at class body beginning.',
        'Empty line missing at class body end.'])
    end

    it 'does not register offense for nested class with no blanks' do
      inspect_source(cop, ['class A',
                           '',
                           '  class B',
                           '    def method',
                           '    end',
                           '  end',
                           '',
                           'end'])
      expect(cop.offenses).to be_empty
    end

    it 'autocorrects top-level class' do
      new_source = autocorrect_source(cop, ['class A',
                                            '  def method',
                                            '  end',
                                            'end'])
      expect(new_source).to eq(['class A',
                                '',
                                '  def method',
                                '  end',
                                '',
                                'end'].join("\n"))
    end

    it 'autocorrects nested class' do
      new_source = autocorrect_source(cop, ['class A',
                                            '  class B',
                                            '',
                                            '    def method',
                                            '    end',
                                            '',
                                            '  end',
                                            'end'])
      expect(new_source).to eq(['class A',
                                '',
                                '  class B',
                                '    def method',
                                '    end',
                                '  end',
                                '',
                                'end'].join("\n"))
    end
  end

  context 'when EnforcedStyle is empty_lines' do
    let(:cop_config) { { 'EnforcedStyle' => 'body_start_only' } }

    it 'registers an offense for class body not starting with a blank' do
      inspect_source(cop,
                     ['class SomeClass',
                      '  do_something',
                      'end'])
      expect(cop.messages).to eq(
        ['Empty line missing at class body beginning.'])
    end

    it 'autocorrects class body containing nothing' do
      corrected = autocorrect_source(cop,
                                     ['class SomeClass',
                                      'end'])
      expect(corrected).to eq ['class SomeClass',
                               '',
                               'end'].join("\n")
    end

    it 'autocorrects beginning and end' do
      new_source = autocorrect_source(cop,
                                      ['class SomeClass',
                                       '  do_something',
                                       '',
                                       'end'])
      expect(new_source).to eq(['class SomeClass',
                                '',
                                '  do_something',
                                'end'].join("\n"))
    end

    it 'registers offense for singleton class body not starting with a blank' do
      inspect_source(cop,
                     ['class << self',
                      '  do_something',
                      'end'])
      expect(cop.messages).to eq(
        ['Empty line missing at class body beginning.'])
    end

    it 'autocorrects beginning and end' do
      new_source = autocorrect_source(cop,
                                      ['class << self',
                                       '  do_something',
                                       '',
                                       'end'])
      expect(new_source).to eq(['class << self',
                                '',
                                '  do_something',
                                'end'].join("\n"))
    end
  end
end
