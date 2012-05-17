require 'spec_helper'

module Rubocop
  module Cop
    describe Cop do
      let (:cop) { Cop.new }

      it 'initially has 0 offences' do
        cop.offences.size.should == 0
      end

      it 'initially has nothing to report' do
        cop.has_report?.should be_false
      end

      it 'keeps track of offences' do
        cop.add_offence("file", 0, "line", "message")

        cop.offences.size.should == 1
      end

      it 'will report registered offences' do
        cop.add_offence("file", 0, "line", "message")

        cop.has_report?.should be_true
      end
    end
  end
end
