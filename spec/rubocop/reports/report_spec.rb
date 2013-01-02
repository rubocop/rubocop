# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Report
    describe Report do
      let (:report) { Report.new('test') }

      it 'initially has 0 entries' do
        report.entries.size.should == 0
      end

      it 'initially has nothing to report' do
        report.empty?.should be_true
      end

      it 'keeps track of offences' do
        cop = Cop::Cop.new
        cop.add_offence(:convention, 1, 'message')

        report << cop

        report.empty?.should be_false
        report.entries.size.should == 1
      end
    end
  end
end
