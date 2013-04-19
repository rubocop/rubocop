# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe AsciiIdentifiersAndComments do
      let(:ascii) { AsciiIdentifiersAndComments.new }

      it 'registers an offence for a variable name with non-ascii chars' do
        inspect_source(ascii,
                       'file.rb',
                       ['älg = 1'])
        expect(ascii.offences.size).to eq(1)
        expect(ascii.offences.map(&:message))
          .to eq([AsciiIdentifiersAndComments::ERROR_MESSAGE])
      end

      it 'registers an offence for a comment with non-ascii chars' do
        inspect_source(ascii,
                       'file.rb',
                       ['# 这是什么？'])
        expect(ascii.offences.size).to eq(1)
        expect(ascii.offences.map(&:message))
          .to eq([AsciiIdentifiersAndComments::ERROR_MESSAGE])
      end

      it 'accepts comments and identifiers with only ascii chars' do
        inspect_source(ascii,
                       'file.rb',
                       ['# AZaz1@$%~,;*_`|',
                        'x.empty?'])
        expect(ascii.offences.size).to eq(0)
        expect(ascii.offences.map(&:message)).to be_empty
      end
    end
  end
end
