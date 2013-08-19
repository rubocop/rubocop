# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Rails
      describe HasAndBelongsToMany do
        let(:val) { described_class.new }

        it 'registers an offence for has_and_belongs_to_many' do
          inspect_source(val,
                         ['has_and_belongs_to_many :groups'])
          expect(val.offences.size).to eq(1)
        end
      end
    end
  end
end
