# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe Offence do
      it 'has a few required attributes' do
        offence = Offence.new(:convention, Location.new(1, 0),
                              'message', 'CopName')

        expect(offence.severity).to eq(:convention)
        expect(offence.line).to eq(1)
        expect(offence.message).to eq('message')
        expect(offence.cop_name).to eq('CopName')
      end

      it 'overrides #to_s' do
        offence = Offence.new(:convention, Location.new(1, 0),
                              'message', 'CopName')

        expect(offence.to_s).to eq('C:  1:  0: message')
      end

      it 'does not blow up if a message contains %' do
        offence = Offence.new(:convention, Location.new(1, 0),
                              'message % test', 'CopName')

        expect(offence.to_s).to eq('C:  1:  0: message % test')
      end

      it 'redefines == to compare offences based on their contents' do
        o1 = Offence.new(:test, Location.new(1, 0), 'message', 'CopName')
        o2 = Offence.new(:test, Location.new(1, 0), 'message', 'CopName')

        expect(o1 == o2).to be_true
      end
    end
  end
end
