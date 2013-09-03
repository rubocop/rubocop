# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe ParameterLists do
        subject(:list) { ParameterLists.new }
        before do
          ParameterLists.config = {
            'Max' => 4,
            'CountKeywordArgs' => true
          }
        end

        it 'registers an offence for a method def with 5 parameters' do
          inspect_source(list, ['def meth(a, b, c, d, e)',
                                'end'])
          expect(list.offences.size).to eq(1)
        end

        it 'accepts a method def with 4 parameters' do
          inspect_source(list, ['def meth(a, b, c, d)',
                                'end'])
          expect(list.offences).to be_empty
        end

        context 'When CountKeywordArgs is true' do
          it 'counts keyword arguments as well', ruby: 2.0 do
            inspect_source(list, ['def meth(a, b, c, d: 1, e: 2)',
                                  'end'])
            expect(list.offences.size).to eq(1)
          end
        end

        context 'When CountKeywordArgs is false' do
          before { ParameterLists.config['CountKeywordArgs'] = false }

          it 'it does not count keyword arguments', ruby: 2.0 do
            inspect_source(list, ['def meth(a, b, c, d: 1, e: 2)',
                                  'end'])
            expect(list.offences).to be_empty
          end
        end
      end
    end
  end
end
