# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe FavorSprintf do
        let(:fs) { FavorSprintf.new }

        it 'registers an offence for a string followed by something' do
          inspect_source(fs,
                         ['puts "%d" % 10'])
          expect(fs.offences.size).to eq(1)
          expect(fs.messages)
            .to eq([FavorSprintf::MSG])
        end

        it 'registers an offence for something followed by an array' do
          inspect_source(fs,
                         ['puts x % [10, 11]'])
          expect(fs.offences.size).to eq(1)
          expect(fs.messages)
            .to eq([FavorSprintf::MSG])
        end

        it 'does not register an offence for numbers' do
          inspect_source(fs,
                         ['puts 10 % 4'])
          expect(fs.offences).to be_empty
        end

        it 'does not register an offence for ambiguous cases' do
          inspect_source(fs,
                         ['puts x % 4'])
          expect(fs.offences).to be_empty

          inspect_source(fs,
                         ['puts x % Y'])
          expect(fs.offences).to be_empty
        end

        it 'works if the first operand contains embedded expressions' do
          inspect_source(fs,
                         ['puts "#{x * 5} %d #{@test}" % 10'])
          expect(fs.offences.size).to eq(1)
          expect(fs.messages)
            .to eq([FavorSprintf::MSG])
        end
      end
    end
  end
end
