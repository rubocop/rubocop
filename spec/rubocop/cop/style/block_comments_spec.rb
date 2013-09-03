# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe BlockComments do
        subject(:block) { BlockComments.new }

        it 'registers an offence for block comments' do
          inspect_source(block,
                         ['=begin',
                          'comment',
                          '=end'])
          expect(block.offences.size).to eq(1)
        end

        it 'accepts regular comments' do
          inspect_source(block,
                         ['# comment'])
          expect(block.offences).to be_empty
        end
      end
    end
  end
end
