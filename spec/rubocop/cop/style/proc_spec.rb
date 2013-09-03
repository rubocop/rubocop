# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe Proc do
        subject(:proc) { Proc.new }

        it 'registers an offence for a Proc.new call' do
          inspect_source(proc, ['f = Proc.new { |x| puts x }'])
          expect(proc.offences.size).to eq(1)
        end

        it 'accepts the proc method' do
          inspect_source(proc, ['f = proc { |x| puts x }'])
          expect(proc.offences).to be_empty
        end

        it 'accepts the Proc.new call outside of block' do
          inspect_source(proc, ['p = Proc.new'])
          expect(proc.offences).to be_empty
        end
      end
    end
  end
end
