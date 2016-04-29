# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::Encoding, :config do
  subject(:cop) { described_class.new(config) }

  context 'when_needed' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'when_needed' }
    end

    it 'registers no offense when no encoding present but only ASCII ' \
       'characters' do
      inspect_source(cop, 'def foo() end')

      expect(cop.offenses).to be_empty
    end

    it 'registers an offense when there is no encoding present but non ' \
       'ASCII characters' do
      inspect_source(cop, 'def foo() \'ä\' end')

      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(
        ['Missing utf-8 encoding comment.']
      )
    end

    it 'registers an offense when encoding present but only ASCII ' \
       'characters' do
      inspect_source(cop, ['# encoding: utf-8',
                           'def foo() end'])

      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(
        ['Unnecessary utf-8 encoding comment.']
      )
    end

    it 'accepts an empty file' do
      inspect_source(cop, '')

      expect(cop.offenses).to be_empty
    end

    it 'accepts encoding on first line' do
      inspect_source(cop, ['# encoding: utf-8',
                           'def foo() \'ä\' end'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts encoding on second line when shebang present' do
      inspect_source(cop, ['#!/usr/bin/env ruby',
                           '# encoding: utf-8',
                           'def foo() \'ä\' end'])

      expect(cop.messages).to be_empty
    end

    it 'registers an offense when encoding is in the wrong place' do
      inspect_source(cop, ['def foo() \'ä\' end',
                           '# encoding: utf-8'])

      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(
        ['Missing utf-8 encoding comment.']
      )
    end

    it 'accepts encoding inserted by magic_encoding gem' do
      inspect_source(cop, ['# -*- encoding : utf-8 -*-',
                           'def foo() \'ä\' end'])

      expect(cop.messages).to be_empty
    end

    it 'accepts vim-style encoding comments' do
      inspect_source(cop, ['# vim:fileencoding=utf-8',
                           'def foo() \'ä\' end'])
      expect(cop.messages).to be_empty
    end

    context 'auto-correct' do
      it 'inserts an encoding comment on the first line when there are ' \
         'non ASCII characters in the file' do
        new_source = autocorrect_source(cop, 'def foo() \'ä\' end')

        expect(new_source).to eq(['# encoding: utf-8',
                                  'def foo() \'ä\' end'].join("\n"))
      end

      it "removes encoding comment on first line when it's not needed" do
        new_source = autocorrect_source(cop, "# encoding: utf-8\nblah")

        expect(new_source).to eq('blah')
      end
    end
  end

  context 'always' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'always' }
    end

    it 'registers an offense when no encoding present' do
      inspect_source(cop, 'def foo() end')

      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(
        ['Missing utf-8 encoding comment.']
      )
    end

    it 'accepts an empty file' do
      inspect_source(cop, '')

      expect(cop.offenses).to be_empty
    end

    it 'accepts encoding on first line' do
      inspect_source(cop, ['# encoding: utf-8',
                           'def foo() end'])

      expect(cop.offenses).to be_empty
    end

    it 'accepts encoding on second line when shebang present' do
      inspect_source(cop, ['#!/usr/bin/env ruby',
                           '# encoding: utf-8',
                           'def foo() end'])

      expect(cop.messages).to be_empty
    end

    it 'books an offense when encoding is in the wrong place' do
      inspect_source(cop, ['def foo() end',
                           '# encoding: utf-8'])

      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(
        ['Missing utf-8 encoding comment.']
      )
    end

    it 'accepts encoding inserted by magic_encoding gem' do
      inspect_source(cop, ['# -*- encoding : utf-8 -*-',
                           'def foo() end'])

      expect(cop.messages).to be_empty
    end

    it 'accepts vim-style encoding comments' do
      inspect_source(cop, ['# vim:fileencoding=utf-8',
                           'def foo() end'])
      expect(cop.messages).to be_empty
    end

    context 'auto-correct' do
      context 'valid auto correct encoding comment' do
        it 'inserts an encoding comment on the first line of files without ' \
           'a shebang' do
          cop_config['AutoCorrectEncodingComment'] = '# encoding: utf-8'
          new_source = autocorrect_source(cop, 'def foo() end')

          expect(new_source).to eq("# encoding: utf-8\ndef foo() end")
        end

        it 'inserts an encoding comment on the first line and leaves ' \
           'the wrong encoding line when encoding is in the wrong place' do
          cop_config['AutoCorrectEncodingComment'] = '# encoding: utf-8'
          new_source = autocorrect_source(cop, ['def foo() end',
                                                '# encoding: utf-8'])

          expect(new_source).to eq(['# encoding: utf-8',
                                    'def foo() end',
                                    '# encoding: utf-8'].join("\n"))
        end

        it 'inserts an encoding comment on the second line when the first ' \
           'line is a shebang' do
          new_source = autocorrect_source(cop, ['#!/usr/bin/env ruby',
                                                'def foo',
                                                'end'])

          expect(new_source).to eq(['#!/usr/bin/env ruby',
                                    '# encoding: utf-8',
                                    'def foo',
                                    'end'].join("\n"))
        end

        it "doesn't infinite-loop when the first line is blank" do
          new_source = autocorrect_source(cop, ['',
                                                'module Toto',
                                                'end'])
          expect(new_source).to eq(['# encoding: utf-8',
                                    '',
                                    'module Toto',
                                    'end'].join("\n"))
        end
      end

      context 'invalid auto correct comment' do
        it 'throws an exception' do
          cop_config['AutoCorrectEncodingComment'] = 'invalid'
          expect { autocorrect_source(cop, 'def foo() end') }
            .to raise_error(RuntimeError, 'invalid does not match ' \
                          '(?-mix:#.*coding\s?[:=]\s?(?:UTF|utf)-8)')
        end
      end
    end
  end

  context 'never' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'never' }
    end

    it 'registers no offense when no encoding present but only ASCII ' \
       'characters' do
      inspect_source(cop, 'def foo() end')

      expect(cop.offenses).to be_empty
    end

    it 'registers no offense when there is no encoding present but non ' \
       'ASCII characters' do
      inspect_source(cop, 'def foo() \'ä\' end')

      expect(cop.offenses).to be_empty
    end

    it 'registers an offense when encoding present but only ASCII ' \
       'characters' do
      inspect_source(cop, ['# encoding: utf-8',
                           'def foo() end'])

      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(
        ['Unnecessary utf-8 encoding comment.']
      )
    end

    context 'auto-correct' do
      it 'removes encoding comment on first line when there are ' \
         'non ASCII characters in the file' do
        new_source = autocorrect_source(cop, 'def foo() \'ä\' end')

        expect(new_source).to eq('def foo() \'ä\' end')
      end

      it "removes encoding comment on first line when it's not needed" do
        new_source = autocorrect_source(cop, "# encoding: utf-8\nblah")

        expect(new_source).to eq('blah')
      end
    end
  end
end
