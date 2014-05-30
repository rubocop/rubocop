# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::Encoding, :config do
  subject(:cop) { described_class.new(config) }

  context 'when_needed' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'when_needed' }
    end

    it 'registers no offense when no encoding present but only ASCII ' \
       'characters', ruby: 1.9 do
      inspect_source(cop, ['def foo() end'])

      expect(cop.offenses).to be_empty
    end

    it 'registers an offense when there is no encoding present but non ' \
       'ASCII characters', ruby: 1.9 do
      inspect_source(cop, ['def foo() \'ä\' end'])

      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(
        ['Missing utf-8 encoding comment.'])
    end

    it 'registers an offense when encoding present but only ASCII ' \
       'characters', ruby: 1.9 do
      inspect_source(cop, ['# encoding: utf-8',
                           'def foo() end'])

      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(
        ['Unnecessary utf-8 encoding comment.'])
    end

    it 'accepts an empty file', ruby: 1.9 do
      inspect_source(cop, '')

      expect(cop.offenses).to be_empty
    end

    it 'accepts encoding on first line', ruby: 1.9 do
      inspect_source(cop, ['# encoding: utf-8',
                           'def foo() \'ä\' end'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts encoding on second line when shebang present', ruby: 1.9 do
      inspect_source(cop, ['#!/usr/bin/env ruby',
                           '# encoding: utf-8',
                           'def foo() \'ä\' end'])

      expect(cop.messages).to be_empty
    end

    it 'books an offense when encoding is in the wrong place', ruby: 1.9 do
      inspect_source(cop, ['def foo() \'ä\' end',
                           '# encoding: utf-8'])

      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(
        ['Missing utf-8 encoding comment.'])
    end

    it 'does not register an offense on Ruby 2.0', ruby: 2.0 do
      inspect_source(cop, ['def foo() \'ä\' end'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts encoding inserted by magic_encoding gem', ruby: 1.9 do
      inspect_source(cop, ['# -*- encoding : utf-8 -*-',
                           'def foo() \'ä\' end'])

      expect(cop.messages).to be_empty
    end

    it 'accepts vim-style encoding comments', ruby: 1.9 do
      inspect_source(cop, ['# vim:fileencoding=utf-8',
                           'def foo() \'ä\' end'])
      expect(cop.messages).to be_empty
    end
  end

  context 'always' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'always' }
    end

    it 'registers an offense when no encoding present', ruby: 1.9 do
      inspect_source(cop, ['def foo() end'])

      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(
        ['Missing utf-8 encoding comment.'])
    end

    it 'accepts an empty file', ruby: 1.9 do
      inspect_source(cop, '')

      expect(cop.offenses).to be_empty
    end

    it 'accepts encoding on first line', ruby: 1.9 do
      inspect_source(cop, ['# encoding: utf-8',
                           'def foo() end'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts encoding on second line when shebang present', ruby: 1.9 do
      inspect_source(cop, ['#!/usr/bin/env ruby',
                           '# encoding: utf-8',
                           'def foo() end'])

      expect(cop.messages).to be_empty
    end

    it 'books an offense when encoding is in the wrong place', ruby: 1.9 do
      inspect_source(cop, ['def foo() end',
                           '# encoding: utf-8'])

      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(
        ['Missing utf-8 encoding comment.'])
    end

    it 'does not register an offense on Ruby 2.0', ruby: 2.0 do
      inspect_source(cop, ['def foo() end'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts encoding inserted by magic_encoding gem', ruby: 1.9 do
      inspect_source(cop, ['# -*- encoding : utf-8 -*-',
                           'def foo() end'])

      expect(cop.messages).to be_empty
    end

    it 'accepts vim-style encoding comments', ruby: 1.9 do
      inspect_source(cop, ['# vim:fileencoding=utf-8',
                           'def foo() end'])
      expect(cop.messages).to be_empty
    end
  end
end
