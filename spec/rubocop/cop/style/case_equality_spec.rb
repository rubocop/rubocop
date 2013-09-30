# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe CaseEquality do
        subject(:cop) { described_class.new }

        it 'registers an offence for ===' do
          inspect_source(cop, ['Array === var'])
          expect(cop.offences.size).to eq(1)
        end
      end
    end
  end
end
