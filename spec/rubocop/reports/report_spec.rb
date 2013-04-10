# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Report
    describe Report do
      let(:report) { Report.new('test') }

      it 'initially has 0 entries' do
        expect(report.entries.size).to be_zero
      end

      it 'initially has nothing to report' do
        expect(report.empty?).to be_true
      end

      it 'keeps track of offences' do
        cop = Cop::Cop.new
        cop.add_offence(:convention, 1, 'message')

        report << cop

        expect(report.empty?).to be_false
        expect(report.entries.size).to eq(1)
      end
    end
  end
end
