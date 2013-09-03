# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe EndBlock do
        subject(:cop) { EndBlock.new }

        it 'reports an offence for an END block' do
          src = ['END { test }']
          inspect_source(cop, src)
          expect(cop.offences.size).to eq(1)
        end
      end
    end
  end
end
