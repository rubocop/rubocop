# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe AvoidLiteralStringArray do
      let(:string_array) { AvoidLiteralStringArray.new }

      it 'registers an offence for literal string array with double quotes' do
        inspect_source(string_array,
                       'file.rb',
                       ['STATES = ["draft", "open", "closed"]'])
        expect(string_array.offences.size).to eq(1)
        expect(string_array.offences.map(&:message))
          .to eq([AvoidLiteralStringArray::ERROR_MESSAGE])
      end

      it 'registers an offence for literal string array with single quotes' do
        inspect_source(string_array,
                       'file.rb',
                       ['STATES = [\'draft\', \'open\', \'closed\']'])
        expect(string_array.offences.size).to eq(1)
        expect(string_array.offences.map(&:message))
          .to eq([AvoidLiteralStringArray::ERROR_MESSAGE])
      end

      it 'registers an offence for literal string array with size 2' do
        inspect_source(string_array,
                       'file.rb',
                       ['STATES = ["draft", "open"]'])
        expect(string_array.offences.size).to eq(1)
        expect(string_array.offences.map(&:message))
          .to eq([AvoidLiteralStringArray::ERROR_MESSAGE])
      end

      it 'registers an offence for literal string array with size 1' do
        inspect_source(string_array,
                       'file.rb',
                       ['STATES = ["draft"]'])
        expect(string_array.offences.size).to eq(1)
        expect(string_array.offences.map(&:message))
          .to eq([AvoidLiteralStringArray::ERROR_MESSAGE])
      end

      it 'does not register an offence for literal array for not string' do
        inspect_source(string_array,
                       'file.rb',
                       ['STATES = ["draft", 1, "closed"]'])
        expect(string_array.offences.size).to eq(0)
        expect(string_array.offences.map(&:message))
          .to be_empty
      end
      
      it 'does not register an offence for selecting a value from hash' do
        inspect_source(string_array,
                       'file.rb',
                       ['STATES = Brazil["MG"]'])
        expect(string_array.offences.size).to eq(0)
        expect(string_array.offences.map(&:message))
          .to be_empty
      end

      it 'does not register an offence for the ideal syntax' do
        inspect_source(string_array,
                       'file.rb',
                       ['STATES = w%(draft open closed)'])
        expect(string_array.offences.size).to eq(0)
        expect(string_array.offences.map(&:message))
          .to be_empty
      end
    end
  end
end