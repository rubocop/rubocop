# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Rails
      describe Validation do
        let(:val) { Validation.new }

        Validation::BLACKLIST.each do |validation|
          it "registers an offence for #{validation}" do
            inspect_source(val,
                           ["#{validation} :name"])
            expect(val.offences.size).to eq(1)
          end
        end

        it 'accepts sexy validations' do
          inspect_source(val,
                         ['validates :name'])
          expect(val.offences).to be_empty
        end
      end
    end
  end
end
