# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe HashMethods do
        let(:cop) { described_class.new }

        it 'registers an offence for has_key? with one arg' do
          inspect_source(cop,
                         ['o.has_key?(o)'])
          expect(cop.offences.size).to eq(1)
          expect(cop.messages)
            .to eq(['has_key? is deprecated in favor of key?.'])
        end

        it 'accepts has_key? with no args' do
          inspect_source(cop,
                         ['o.has_key?'])
          expect(cop.offences).to be_empty
        end

        it 'registers an offence for has_value? with one arg' do
          inspect_source(cop,
                         ['o.has_value?(o)'])
          expect(cop.offences.size).to eq(1)
          expect(cop.messages)
            .to eq(['has_value? is deprecated in favor of value?.'])
        end

        it 'accepts has_value? with no args' do
          inspect_source(cop,
                         ['o.has_value?'])
          expect(cop.offences).to be_empty
        end
      end
    end
  end
end
