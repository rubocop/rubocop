# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Rails
      describe ReadAttribute do
        subject(:cop) { described_class.new }

        it 'registers an offence for read_attribute' do
          inspect_source(cop,
                         ['res = read_attribute(:test)'])
          expect(cop.offences.size).to eq(1)
        end
      end
    end
  end
end
