# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe CaseEquality do
        subject(:ce) { CaseEquality.new }

        it 'registers an offence for ===' do
          inspect_source(ce, ['Array === var'])
          expect(ce.offences.size).to eq(1)
        end
      end
    end
  end
end
