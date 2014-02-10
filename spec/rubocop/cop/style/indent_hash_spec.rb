# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::IndentHash do
  subject(:cop) { described_class.new }

  context 'when hash is operand' do
    it 'accepts correctly indented first pair' do
      inspect_source(cop,
                     ['a << {',
                      '  a: 1',
                      '}'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for incorrectly indented first pair' do
      inspect_source(cop,
                     ['a << {',
                      ' a: 1',
                      '}'])
      expect(cop.highlights).to eq(['a: 1'])
    end

    it 'auto-corrects incorrectly indented first pair' do
      corrected = autocorrect_source(cop, ['a << {',
                                           ' a: 1',
                                           '}'])
      expect(corrected).to eq ['a << {',
                               '  a: 1',
                               '}'].join("\n")
    end
  end

  context 'when hash is argument to setter' do
    it 'accepts correctly indented first pair' do
      inspect_source(cop,
                     ['   config.rack_cache = {',
                      '     :metastore => "rails:/",',
                      '     :entitystore => "rails:/",',
                      '     :verbose => false',
                      '   }'])
      expect(cop.offenses).to be_empty
    end
  end

  context 'when hash is right hand side in assignment' do
    it 'registers an offense for incorrectly indented first pair' do
      inspect_source(cop, ['a = {',
                           '    a: 1,',
                           '  b: 2,',
                           ' c: 3',
                           '}'])
      expect(cop.messages)
        .to eq(['Use 2 spaces for indentation in a hash, relative to the ' \
                'start of the line where the left curly brace is.'])
      expect(cop.highlights).to eq(['a: 1'])
    end

    it 'auto-corrects incorrectly indented first pair' do
      corrected = autocorrect_source(cop, ['a = {',
                                           '    a: 1,',
                                           '  b: 2,',
                                           ' c: 3',
                                           '}'])
      expect(corrected).to eq ['a = {',
                               '  a: 1,',
                               '  b: 2,',
                               ' c: 3',
                               '}'].join("\n")
    end

    it 'accepts correctly indented first pair' do
      inspect_source(cop,
                     ['a = {',
                      '  a: 1',
                      '}'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts several pairs per line' do
      inspect_source(cop,
                     ['a = {',
                      '  a: 1, b: 2',
                      '}'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts a first pair on the same line as the left brace' do
      inspect_source(cop,
                     ['a = { "a" => 1,',
                      '      "b" => 2 }'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts single line hash' do
      inspect_source(cop,
                     ['a = { a: 1, b: 2 }'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts an empty hash' do
      inspect_source(cop,
                     ['a = {}'])
      expect(cop.offenses).to be_empty
    end
  end

  context 'when hash is method argument' do
    context 'and arguments are surrounded by parentheses' do
      it 'accepts special indentation for first argument' do
        inspect_source(cop,
                       ['func({',
                        '       a: 1',
                        '     })'])
        expect(cop.offenses).to be_empty
      end

      it 'registers an offense for incorrect indentation' do
        inspect_source(cop,
                       ['func({',
                        '  a: 1', # Start-of-line indentation is wrong here.
                        '})'])
        expect(cop.messages)
          .to eq(['Use 2 spaces for indentation in a hash, relative to the ' \
                  'first position after the preceding left parenthesis.'])
      end

      it 'accepts special indentation for second argument' do
        inspect_source(cop,
                       ['body.should have_tag("input", :attributes => {',
                        '                       :name => /q\[(id_eq)\]/ })'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts normal indentation for hash within hash' do
        inspect_source(cop,
                       ['scope = scope.where(',
                        '  klass.table_name => {',
                        '    reflection.type => model.base_class.sti_name',
                        '  }',
                        ')'])
        expect(cop.offenses).to be_empty
      end
    end

    context 'and argument are not surrounded by parentheses' do
      it 'accepts braceless hash' do
        inspect_source(cop,
                       ['func a: 1, b: 2'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts single line hash with braces' do
        inspect_source(cop,
                       ['func x, { a: 1, b: 2 }'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts a correctly indented multi-line hash with braces' do
        inspect_source(cop,
                       ['func x, {',
                        '  a: 1, b: 2 }'])
        expect(cop.offenses).to be_empty
      end
    end
  end
end
