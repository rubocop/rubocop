# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe BeginBlock do
        subject(:cop) { BeginBlock.new }

        it 'reports an offence for a BEGIN block' do
          src = ['BEGIN { test }']
          inspect_source(cop, src)
          expect(cop.offences.size).to eq(1)
        end
      end
    end
  end
end
