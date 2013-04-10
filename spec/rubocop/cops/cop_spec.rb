# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe Cop do
      let(:cop) { Cop.new }

      it 'initially has 0 offences' do
        expect(cop.offences).to be_empty
      end

      it 'initially has nothing to report' do
        expect(cop.has_report?).to be_false
      end

      it 'keeps track of offences' do
        cop.add_offence(:convention, 1, 'message')

        expect(cop.offences.size).to eq(1)
      end

      it 'will report registered offences' do
        cop.add_offence(:convention, 1, 'message')

        expect(cop.has_report?).to be_true
      end
    end
  end
end
