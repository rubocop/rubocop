# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe SpaceAfterComma do
      let(:space) { SpaceAfterComma.new }

      it 'registers an offence for block argument commas without space' do
        inspect_source(space, 'file.rb', ['each { |s,t| }'])
        expect(space.offences.map(&:message)).to eq(
          ['Space missing after comma.'])
      end

      it 'registers an offence for array index commas without space' do
        inspect_source(space, 'file.rb', ['formats[0,1]'])
        expect(space.offences.map(&:message)).to eq(
          ['Space missing after comma.'])
      end

      it 'registers an offence for method call arg commas without space' do
        inspect_source(space, 'file.rb', ['a(1,2)'])
        expect(space.offences.map(&:message)).to eq(
          ['Space missing after comma.'])
      end
    end
  end
end
