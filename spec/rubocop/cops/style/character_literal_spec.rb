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

        it 'registers an offence for literals like \n' do
          inspect_source(cop, ['x = ?\n'])
          expect(cop.offences.size).to eq(1)
        end

        it 'accepts literals like ?\C-\M-d' do
          inspect_source(cop, ['x = ?\C-\M-d'])
          expect(cop.offences).to be_empty
        end

        it 'accepts ? in a %w literal' do
          inspect_source(cop, ['%w{? A}'])
          expect(cop.offences).to be_empty
        end
      end
    end
  end
end
