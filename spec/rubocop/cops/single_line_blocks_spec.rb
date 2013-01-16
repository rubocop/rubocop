# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe SingleLineBlocks do
      let (:blocks) { SingleLineBlocks.new }

      it 'registers an offence for a single line block with do-end' do
        inspect_source(blocks, '', ['each do |x| end'])
        blocks.offences.map(&:message).should ==
          ['Prefer {...} over do...end for single-line blocks.']
      end

      it 'accepts a single line block with braces' do
        inspect_source(blocks, '', ['each { |x| }'])
        blocks.offences.map(&:message).should == []
      end
    end
  end
end
