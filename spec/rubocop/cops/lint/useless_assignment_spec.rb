# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Lint
      describe UselessAssignment do
        let(:cop) { UselessAssignment.new }

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
