# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe Semicolon do
      let(:s) { Semicolon.new }

      it 'registers an offence for a single expression' do
        inspect_source(s,
                       'file.rb',
                       ['puts "this is a test";'])
        expect(s.offences.size).to eq(1)
        expect(s.offences.map(&:message))
          .to eq([Semicolon::ERROR_MESSAGE])
      end

      it 'registers an offence for several expressions' do
        inspect_source(s,
                       'file.rb',
                       ['puts "this is a test"; puts "So is this"'])
        expect(s.offences.size).to eq(1)
        expect(s.offences.map(&:message))
          .to eq([Semicolon::ERROR_MESSAGE])
      end
    end
  end
end
