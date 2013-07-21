# encoding: utf-8

require 'spec_helper'

module Rubocop
  module AutoCorrection
    describe AndOr do
      let(:cop) { Cop::Style::AndOr.new }
      let(:correction) { AndOr.new }

      it 'auto-corrects "and" with &&' do
        new_source = autocorrect_source(cop, correction, 'true and false')
        expect(new_source).to eq('true && false')
      end

      it 'auto-corrects "or" with ||' do
        new_source = autocorrect_source(cop, correction, 'true or false')
        expect(new_source).to eq('true || false')
      end
    end
  end
end
