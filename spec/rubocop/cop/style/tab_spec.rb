# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe Tab do
        let(:tab) { Tab.new }

        it 'registers an offence for a line indented with tab' do
          inspect_source(tab, ["\tx = 0"])
          expect(tab.offences.size).to eq(1)
        end

        it 'accepts a line with tab in a string' do
          inspect_source(tab, ["(x = \"\t\")"])
          expect(tab.offences).to be_empty
        end
      end
    end
  end
end
