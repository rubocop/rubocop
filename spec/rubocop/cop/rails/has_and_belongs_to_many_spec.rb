# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Rails
      describe HasAndBelongsToMany do
        let(:cop) { described_class.new }

        it 'registers an offence for has_and_belongs_to_many' do
          inspect_source(cop,
                         ['has_and_belongs_to_many :groups'])
          expect(cop.offences.size).to eq(1)
        end
      end
    end
  end
end
