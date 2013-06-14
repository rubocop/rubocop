# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe Blocks do
        let(:blocks) { Blocks.new }

        it 'registers an offence for a multiline block with braces' do
          inspect_source(blocks, ['each { |x|',
                                  '}'])
          expect(blocks.messages).to eq([Blocks::MULTI_LINE_MSG])
        end

        it 'accepts a multiline block with do-end' do
          inspect_source(blocks, ['each do |x|',
                                  'end'])
          expect(blocks.offences.map(&:message)).to be_empty
        end

        it 'registers an offence for a single line block with do-end' do
          inspect_source(blocks, ['each do |x| end'])
          expect(blocks.messages).to eq([Blocks::SINGLE_LINE_MSG])
        end

        it 'accepts a single line block with braces' do
          inspect_source(blocks, ['each { |x| }'])
          expect(blocks.offences.map(&:message)).to be_empty
        end
      end
    end
  end
end
