require 'spec_helper'

module Rubocop
  module Cop
    describe LineLength do
      let (:ll) { LineLength.new }

      it "registers an offence for a line that's 80 characters wide" do
        ll.inspect 'file.rb', ['#' * 80], [], []
        ll.offences.size.should == 1
        ll.offences.first.message.should == 'Line is too long. [80/79]'
      end

      it "accepts a line that's 79 characters wide" do
        ll.inspect 'file.rb', ['#' * 79], [], []
        ll.offences.size.should == 0
      end
    end
  end
end
