# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe LineLength do
      let(:ll) { LineLength.new }
      before { LineLength.config = { 'Max' => 79 } }

      it "registers an offence for a line that's 80 characters wide" do
        ll.inspect('file.rb', ['#' * 80], nil, nil)
        expect(ll.offences.size).to eq(1)
        expect(ll.offences.first.message).to eq('Line is too long. [80/79]')
      end

      it "accepts a line that's 79 characters wide" do
        ll.inspect('file.rb', ['#' * 79], nil, nil)
        expect(ll.offences).to be_empty
      end
    end
  end
end
