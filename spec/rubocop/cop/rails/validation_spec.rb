# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Rails
      describe Validation do
        let(:cop) { described_class.new }

        Validation::BLACKLIST.each do |validation|
          it "registers an offence for #{validation}" do
            inspect_source(cop,
                           ["#{validation} :name"])
            expect(cop.offences.size).to eq(1)
          end
        end

        it 'accepts sexy validations' do
          inspect_source(cop,
                         ['validates :name'])
          expect(cop.offences).to be_empty
        end
      end
    end
  end
end
