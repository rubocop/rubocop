# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe FavorSprintf do
      let(:fs) { FavorSprintf.new }

      it 'registers an offence for a string followed by something' do
        inspect_source(fs,
                       'file.rb',
                       ['puts "%d" % 10'])
        expect(fs.offences.size).to eq(1)
        expect(fs.offences.map(&:message))
          .to eq([FavorSprintf::ERROR_MESSAGE])
      end

      it 'registers an offence for something followed by an array' do
        inspect_source(fs,
                       'file.rb',
                       ['puts x % [10, 11]'])
        expect(fs.offences.size).to eq(1)
        expect(fs.offences.map(&:message))
          .to eq([FavorSprintf::ERROR_MESSAGE])
      end

      it 'does not register an offence for numbers' do
        inspect_source(fs,
                       'file.rb',
                       ['puts 10 % 4'])
        expect(fs.offences).to be_empty
      end

      it 'does not register an offence for ambiguous cases' do
        inspect_source(fs,
                       'file.rb',
                       ['puts x % 4'])
        expect(fs.offences).to be_empty

        inspect_source(fs,
                       'file.rb',
                       ['puts x % Y'])
        expect(fs.offences).to be_empty
      end

      it 'works if the first operand contains embedded expressions' do
        inspect_source(fs,
                       'file.rb',
                       ['puts "#{x * 5} %d #{@test}" % 10'])
        expect(fs.offences.size).to eq(1)
        expect(fs.offences.map(&:message))
          .to eq([FavorSprintf::ERROR_MESSAGE])
      end
    end
  end
end
