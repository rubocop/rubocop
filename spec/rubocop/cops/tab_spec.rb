# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe Tab do
      let(:tab) { Tab.new }

      it 'registers an offence for a line indented with tab' do
        tab.inspect('file.rb', ["\tx = 0"], nil, nil)
        expect(tab.offences.size).to eq(1)
      end

      it 'accepts a line with tab in a string' do
        tab.inspect('file.rb', ["(x = \"\t\")"], nil, nil)
        expect(tab.offences).to be_empty
      end
    end
  end
end
