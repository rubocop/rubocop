# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe VariableInterpolation do
      let(:vi) { VariableInterpolation.new }

      it 'registers an offence for interpolated global variables' do
        inspect_source(vi,
                       'file.rb',
                       ['puts "this is a #$test"'])
        expect(vi.offences.size).to eq(1)
        expect(vi.offences.map(&:message))
          .to eq(['Replace interpolated var $test with expression #{$test}.'])
      end

      it 'registers an offence for interpolated regexp back references' do
        inspect_source(vi,
                       'file.rb',
                       ['puts "this is a #$1"'])
        expect(vi.offences.size).to eq(1)
        expect(vi.offences.map(&:message))
          .to eq(['Replace interpolated var $1 with expression #{$1}.'])
      end

      it 'registers an offence for interpolated instance variables' do
        inspect_source(vi,
                       'file.rb',
                       ['puts "this is a #@test"'])
        expect(vi.offences.size).to eq(1)
        expect(vi.offences.map(&:message))
          .to eq(['Replace interpolated var @test with expression #{@test}.'])
      end

      it 'registers an offence for interpolated class variables' do
        inspect_source(vi,
                       'file.rb',
                       ['puts "this is a #@@t"'])
        expect(vi.offences.size).to eq(1)
        expect(vi.offences.map(&:message))
          .to eq(['Replace interpolated var @@t with expression #{@@t}.'])
      end

      it 'does not register an offence for variables in expressions' do
        inspect_source(vi,
                       'file.rb',
                       ['puts "this is a #{@test} #{@@t} #{$t} #{$1}"'])
        expect(vi.offences).to be_empty
      end
    end
  end
end
