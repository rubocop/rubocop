# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe CharacterLiteral do
        let(:cop) { CharacterLiteral.new }

        it 'registers an offence for character literals' do
          inspect_source(cop, ['x = ?x'])
          expect(cop.offences.size).to eq(1)
        end
      end
    end
  end
end
