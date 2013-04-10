# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe MultilineBlocks do
      let(:blocks) { MultilineBlocks.new }

      it 'registers an offence for a multiline block with braces' do
        inspect_source(blocks, '', ['each { |x|',
                                    '}'])
        expect(blocks.offences.map(&:message)).to eq(
          ['Avoid using {...} for multi-line blocks.'])
      end

      it 'accepts a multiline block with do-end' do
        inspect_source(blocks, '', ['each do |x|',
                                    'end'])
        expect(blocks.offences.map(&:message)).to be_empty
      end
    end
  end
end
