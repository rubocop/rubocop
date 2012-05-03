require 'spec_helper'

module Rubocop
  module Cop
    describe Offence do
      it 'has a few required attributes' do
        offence = Offence.new('filename', 1, 'line', 'message')

        offence.filename.should == 'filename'
        offence.line_number.should == 1
        offence.line.should == 'line'
        offence.message.should == 'message'
      end

      it 'overrides #to_s' do
        offence = Offence.new('filename', 1, 'line', 'message')

        offence.to_s.should == 'filename:1:line - message'
      end
    end
  end
end
