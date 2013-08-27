# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe LineLength, :config do
        subject(:ll) { LineLength.new(config) }
        let(:cop_config) { { 'Max' => 79 } }

        it "registers an offence for a line that's 80 characters wide" do
          inspect_source(ll, ['#' * 80])
          expect(ll.offences.size).to eq(1)
          expect(ll.offences.first.message).to eq('Line is too long. [80/79]')
        end

        it "accepts a line that's 79 characters wide" do
          inspect_source(ll, ['#' * 79])
          expect(ll.offences).to be_empty
        end
      end
    end
  end
end
