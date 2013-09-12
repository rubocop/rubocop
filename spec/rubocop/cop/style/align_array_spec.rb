# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe AlignArray do
        subject(:cop) { described_class.new }

        it 'registers an offence for misaligned array elements' do
          inspect_source(cop, ['array = [',
                               '  a,',
                               '   b,',
                               '  c,',
                               '   d',
                               ']'])
          expect(cop.messages).to eq(['Align the elements of an array ' +
                                      'literal if they span more than ' +
                                      'one line.'] * 2)
          expect(cop.highlights).to eq(%w(b d))
        end

        it 'accepts aligned array keys' do
          inspect_source(cop, ['array = [',
                               '  a,',
                               '  b,',
                               '  c,',
                               '  d',
                               ']'])
          expect(cop.offences).to be_empty
        end

        it 'accepts single line array' do
          inspect_source(cop, 'array = [ a, b ]')
          expect(cop.offences).to be_empty
        end

        it 'accepts several elements per line' do
          inspect_source(cop, ['array = [ a, b,',
                               '          c, d ]'])
          expect(cop.offences).to be_empty
        end

        it 'auto-corrects alignment' do
          new_source = autocorrect_source(cop, ['array = [',
                                                '  a,',
                                                '   b,',
                                                '  c,',
                                                ' d',
                                                ']'])
          expect(new_source).to eq(['array = [',
                                    '  a,',
                                    '  b,',
                                    '  c,',
                                    '  d',
                                    ']'].join("\n"))
        end
      end
    end
  end
end
