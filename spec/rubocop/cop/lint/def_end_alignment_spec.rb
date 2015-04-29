# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Lint::DefEndAlignment, :config do
  subject(:cop) { described_class.new(config) }
  let(:opposite) do
    cop_config['AlignWith'] == 'def' ? 'start_of_line' : 'def'
  end

  let(:source) do
    ['private def a',
     '  a1',
     'end',
     '',
     'private def b',
     '          b1',
     '        end']
  end

  context 'when AlignWith is start_of_line' do
    let(:cop_config) do
      { 'AlignWith' => 'start_of_line', 'AutoCorrect' => true }
    end

    include_examples 'misaligned', '', 'def', 'test',      '  end'
    include_examples 'misaligned', '', 'def', 'Test.test', '  end', 'defs'

    include_examples 'aligned', 'def', 'test',      'end'
    include_examples 'aligned', 'def', 'Test.test', 'end', 'defs'

    context 'in ruby 2.1 or later' do
      include_examples 'aligned', 'public def',               'test', 'end'
      include_examples 'aligned', 'protected def',            'test', 'end'
      include_examples 'aligned', 'private def',              'test', 'end'
      include_examples 'aligned', 'module_function def',      'test', 'end'
      include_examples 'aligned', 'private_class_method def', 'test', 'end'
      include_examples 'aligned', 'public_class_method def',  'test', 'end'

      include_examples('misaligned', '',
                       'public def', 'test',
                       '       end')
      include_examples('misaligned', '',
                       'protected def', 'test',
                       '          end')
      include_examples('misaligned', '',
                       'private def', 'test',
                       '        end')
      include_examples('misaligned', '',
                       'module_function def', 'test',
                       '                end')
      include_examples('misaligned', '',
                       'private_class_method def', 'test',
                       '                     end')
      include_examples('misaligned', '',
                       'public_class_method def', 'test',
                       '                    end')
    end

    context 'correct + opposite' do
      it 'registers an offense' do
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages.first)
          .to eq('`end` at 7, 8 is not aligned with `private def` at 5, 8')
        expect(cop.highlights.first).to eq('end')
        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      end

      it 'does auto-correction' do
        corrected = autocorrect_source(cop, source)
        expect(corrected).to eq(['private def a',
                                 '  a1',
                                 'end',
                                 '',
                                 'private def b',
                                 '          b1',
                                 'end'].join("\n"))
      end
    end
  end

  context 'when AlignWith is def' do
    let(:cop_config) do
      { 'AlignWith' => 'def', 'AutoCorrect' => true }
    end

    include_examples 'misaligned', '', 'def', 'test',      '  end'
    include_examples 'misaligned', '', 'def', 'Test.test', '  end', 'defs'

    include_examples 'aligned', 'def', 'test',      'end'
    include_examples 'aligned', 'def', 'Test.test', 'end', 'defs'

    context 'in ruby 2.1 or later' do
      include_examples('aligned',
                       'public def',          'test',
                       '       end')
      include_examples('aligned',
                       'protected def',       'test',
                       '          end')
      include_examples('aligned',
                       'private def', 'test',
                       '        end')
      include_examples('aligned',
                       'module_function def', 'test',
                       '                end')

      include_examples('misaligned',
                       'public ', 'def', 'test',
                       'end')
      include_examples('misaligned',
                       'protected ', 'def', 'test',
                       'end')
      include_examples('misaligned',
                       'private ', 'def', 'test',
                       'end')
      include_examples('misaligned',
                       'module_function ', 'def', 'test',
                       'end')

      context 'correct + opposite' do
        it 'registers an offense' do
          inspect_source(cop, source)
          expect(cop.offenses.size).to eq(1)
          expect(cop.messages.first)
            .to eq('`end` at 3, 0 is not aligned with `def` at 1, 8')
          expect(cop.highlights.first).to eq('end')
          expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
        end

        it 'does auto-correction' do
          corrected = autocorrect_source(cop, source)
          expect(corrected).to eq(['private def a',
                                   '  a1',
                                   '        end',
                                   '',
                                   'private def b',
                                   '          b1',
                                   '        end'].join("\n"))
        end
      end
    end
  end
end
