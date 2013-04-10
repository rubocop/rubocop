# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe SingleLineBlocks do
      let(:blocks) { SingleLineBlocks.new }

      it 'registers an offence for a single line block with do-end' do
        inspect_source(blocks, '', ['each do |x| end'])
        expect(blocks.offences.map(&:message)).to eq(
          ['Prefer {...} over do...end for single-line blocks.'])
      end

      it 'accepts a single line block with braces' do
        inspect_source(blocks, '', ['each { |x| }'])
        expect(blocks.offences.map(&:message)).to be_empty
      end
    end
  end
end
