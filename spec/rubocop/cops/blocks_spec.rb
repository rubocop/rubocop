# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe Blocks do
      let (:blocks) { Blocks.new }

      it 'registers an offence for a multiline block with braces' do
        inspect_source(blocks, '', ['each { |x|',
                                    '}'])
        blocks.offences.map(&:message).should ==
          ['Avoid using {...} for multi-line blocks.']
      end

      it 'registers an offence for a single line block with do-end' do
        inspect_source(blocks, '', ['each do |x| end'])
        blocks.offences.map(&:message).should ==
          ['Prefer {...} over do...end for single-line blocks.']
      end

      it 'accepts a single line block with braces' do
        inspect_source(blocks, '', ['each { |x| }'])
        blocks.offences.map(&:message).should == []
      end

      it 'accepts a multiline block with do-end' do
        inspect_source(blocks, '', ['each do |x|',
                                    'end'])
        blocks.offences.map(&:message).should == []
      end
    end
  end
end
