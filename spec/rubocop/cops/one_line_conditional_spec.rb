# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe OneLineConditional do
      let(:olc) { OneLineConditional.new }

      it 'registers an offence for one line if/then/end' do
        inspect_source(olc, '', ['if cond then run else dont end'])
        expect(olc.offences.map(&:message)).to eq([olc.error_message])
      end
    end
  end
end
