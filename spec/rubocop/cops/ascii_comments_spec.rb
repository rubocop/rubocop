# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe AsciiComments do
      let(:ascii) { AsciiComments.new }

      it 'registers an offence for a comment with non-ascii chars' do
        inspect_source(ascii,
                       'file.rb',
                       ['# 这是什么？'])
        expect(ascii.offences.size).to eq(1)
        expect(ascii.offences.map(&:message))
          .to eq([AsciiComments::ERROR_MESSAGE])
      end

      it 'accepts comments with only ascii chars' do
        inspect_source(ascii,
                       'file.rb',
                       ['# AZaz1@$%~,;*_`|'])
        expect(ascii.offences).to be_empty
      end
    end
  end
end
