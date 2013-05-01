# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe BlockComments do
      let(:block) { BlockComments.new }

      it 'registers an offence for block comments' do
        inspect_source(block,
                       'file.rb',
                       ['=begin',
                        'comment',
                        '=end'])
        expect(block.offences.size).to eq(1)
        expect(block.offences.map(&:message))
          .to eq([BlockComments::ERROR_MESSAGE])
      end

      it 'accepts regular comments' do
        inspect_source(block,
                       'file.rb',
                       ['# comment'])
        expect(block.offences).to be_empty
      end
    end
  end
end
