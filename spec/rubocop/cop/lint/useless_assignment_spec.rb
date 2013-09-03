# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Lint
      describe UselessAssignment do
        subject(:cop) { UselessAssignment.new }

        it 'registers an offence for def ending with lvar assignment' do
          inspect_source(cop,
                         ['def test',
                          '  something',
                          '  top = 5',
                          'end'
                         ])
          expect(cop.offences.size).to eq(1)
        end

        it 'registers an offence for defs ending with lvar assignment' do
          inspect_source(cop,
                         ['def Top.test',
                          '  something',
                          '  top = 5',
                          'end'
                         ])
          expect(cop.offences.size).to eq(1)
        end

        it 'registers an offence for def ending with lvar attr assignment' do
          inspect_source(cop,
                         ['def test',
                          '  top = Top.new',
                          '  top.attr = 5',
                          'end'
                         ])
          expect(cop.offences.size).to eq(1)
        end

        it 'registers an offence for defs ending with lvar attr assignment' do
          inspect_source(cop,
                         ['def Top.test',
                          '  top = Top.new',
                          '  top.attr = 5',
                          'end'
                         ])
          expect(cop.offences.size).to eq(1)
        end

        it 'accepts def ending with ivar assignment' do
          inspect_source(cop,
                         ['def test',
                          '  something',
                          '  @top = 5',
                          'end'
                         ])
          expect(cop.offences).to be_empty
        end

        it 'accepts def ending ivar attr assignment' do
          inspect_source(cop,
                         ['def test',
                          '  something',
                          '  @top.attr = 5',
                          'end'
                         ])
          expect(cop.offences).to be_empty
        end

        it 'accepts def ending with argument attr assignment' do
          inspect_source(cop,
                         ['def test(some_arg)',
                          '  unrelated_local_variable = Top.new',
                          '  some_arg.attr = 5',
                          'end'
                         ])
          expect(cop.offences).to be_empty
        end

        context 'when a lvar has an object passed as argument ' +
                'at the end of the method' do
          it 'accepts the lvar attr assignment' do
            inspect_source(cop,
                           ['def test(some_arg)',
                            '  @some_ivar = some_arg',
                            '  @some_ivar.do_something',
                            '  some_lvar = @some_ivar',
                            '  some_lvar.do_something',
                            '  some_lvar.attr = 5',
                            'end'
                           ])
            expect(cop.offences).to be_empty
          end
        end

        context 'when a lvar declared as an argument ' +
                'is no longer the passed object at the end of the method' do
          it 'registers an offence for the lvar attr assignment' do
            inspect_source(cop,
                           ['def test(some_arg)',
                            '  some_arg = Top.new',
                            '  some_arg.attr = 5',
                            'end'
                           ])
            expect(cop.offences.size).to eq(1)
          end
        end

        it 'is not confused by operators ending with =' do
          inspect_source(cop,
                         ['def test',
                          '  top == 5',
                          'end'
                         ])
          expect(cop.offences).to be_empty
        end
      end
    end
  end
end
