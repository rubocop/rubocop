# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe Cop do
      let(:cop) { Cop.new }
      let(:location) do
        source_buffer = Parser::Source::Buffer.new('test', 1)
        source_buffer.source = "a\n"
        Parser::Source::Range.new(source_buffer, 0, 1)
      end

      it 'initially has 0 offences' do
        expect(cop.offences).to be_empty
      end

      it 'keeps track of offences' do
        cop.add_offence(:convention, location, 'message')

        expect(cop.offences.size).to eq(1)
      end

      it 'will report registered offences' do
        cop.add_offence(:convention, location, 'message')

        expect(cop.offences).not_to be_empty
      end

      it 'registers offence with its name' do
        cop = Style::AvoidFor.new
        cop.add_offence(:convention, location, 'message')
        expect(cop.offences.first.cop_name).to eq('AvoidFor')
      end
    end
  end
end
