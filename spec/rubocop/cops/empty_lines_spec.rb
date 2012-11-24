require 'spec_helper'

module Rubocop
  module Cop
    describe EmptyLines do
      let (:empty_lines) { EmptyLines.new }

      it 'registers an offence for a def that follows a line with code' do
        empty_lines.inspect "", ["x = 0",
                                 "def m",
                                 "end"], [], []
        empty_lines.offences.size.should == 1
        empty_lines.offences.first.message.should == 'Use empty lines between defs.'
      end

      it 'registers an offence for a def that follows code and a comment' do
        empty_lines.inspect "", ["  x = 0",
                                 "  # 123",
                                 "  def m",
                                 "  end"], [], []
        empty_lines.offences.size.should == 1
        empty_lines.offences.first.message.should == 'Use empty lines between defs.'
      end

      it 'accepts a def that follows an empty line' do
        empty_lines.inspect "", ["  x = 0",
                                 "",
                                 "  def m",
                                 "  end"], [], []
        empty_lines.offences.size.should == 0
      end

      it 'accepts a def that follows an empty line and then a comment' do
        empty_lines.inspect "", ["x = 0",
                                 "",
                                 "# calculates value",
                                 "# or height",
                                 "def m",
                                 "end"], [], []
        empty_lines.offences.size.should == 0
      end
    end
  end
end
