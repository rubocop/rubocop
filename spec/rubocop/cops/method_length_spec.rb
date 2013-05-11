# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe MethodLength do
      let(:method_length) { MethodLength.new }
      before { MethodLength.config = { 'Max' => 5, 'CountComments' => false } }

      it 'rejects a method with more than 5 lines' do
        inspect_source(method_length, '', ['def m()',
                                           '  a = 1',
                                           '  a = 2',
                                           '  a = 3',
                                           '  a = 4',
                                           '  a = 5',
                                           '  a = 6',
                                           'end'])
        expect(method_length.offences.size).to eq(1)
        expect(method_length.offences.map(&:line_number).sort).to eq([1])
      end

      it 'accepts a method with less than 5 lines' do
        inspect_source(method_length, '', ['def m()',
                                           '  a = 1',
                                           '  a = 2',
                                           '  a = 3',
                                           '  a = 4',
                                           'end'])
        expect(method_length.offences).to be_empty
      end

      it 'does not count blank lines' do
        inspect_source(method_length, '', ['def m()',
                                           '  a = 1',
                                           '  a = 2',
                                           '  a = 3',
                                           '  a = 4',
                                           '',
                                           '',
                                           '  a = 7',
                                           'end'])
        expect(method_length.offences).to be_empty
      end

      it 'accepts empty methods' do
        inspect_source(method_length, '', ['def m()',
                                           'end'])
        expect(method_length.offences).to be_empty
      end

      it 'is not fooled by one-liner methods, syntax #1' do
        inspect_source(method_length, '', ['def one_line; 10 end',
                                           'def self.m()',
                                           '  a = 1',
                                           '  a = 2',
                                           '  a = 4',
                                           '  a = 5',
                                           '  a = 6',
                                           'end'])
        expect(method_length.offences).to be_empty
      end

      it 'is not fooled by one-liner methods, syntax #2' do
        inspect_source(method_length, '', ['def one_line(test) 10 end',
                                           'def self.m()',
                                           '  a = 1',
                                           '  a = 2',
                                           '  a = 4',
                                           '  a = 5',
                                           '  a = 6',
                                           'end'])
        expect(method_length.offences).to be_empty
      end

      it 'checks class methods, syntax #1' do
        inspect_source(method_length, '', ['def self.m()',
                                           '  a = 1',
                                           '  a = 2',
                                           '  a = 3',
                                           '  a = 4',
                                           '  a = 5',
                                           '  a = 6',
                                           'end'])
        expect(method_length.offences.size).to eq(1)
        expect(method_length.offences.map(&:line_number).sort).to eq([1])
      end

      it 'checks class methods, syntax #2' do
        inspect_source(method_length, '', ['class K',
                                           '  class << self',
                                           '    def m()',
                                           '      a = 1',
                                           '      a = 2',
                                           '      a = 3',
                                           '      a = 4',
                                           '      a = 5',
                                           '      a = 6',
                                           '    end',
                                           '  end',
                                           'end'])
        expect(method_length.offences.size).to eq(1)
        expect(method_length.offences.map(&:line_number).sort).to eq([3])
      end

      it 'properly counts lines when method ends with block' do
        inspect_source(method_length, '', ['def m()',
                                           '  something do',
                                           '    a = 2',
                                           '    a = 3',
                                           '    a = 4',
                                           '    a = 5',
                                           '  end',
                                           'end'])
        expect(method_length.offences.size).to eq(1)
        expect(method_length.offences.map(&:line_number).sort).to eq([1])
      end

      it 'does not count commented lines by default' do
        inspect_source(method_length, '', ['def m()',
                                           '  a = 1',
                                           '  #a = 2',
                                           '  a = 3',
                                           '  #a = 4',
                                           '  a = 5',
                                           '  a = 6',
                                           'end'])
        expect(method_length.offences).to be_empty
      end

      it 'has the option of counting commented lines' do
        MethodLength.config['CountComments'] = true
        inspect_source(method_length, '', ['def m()',
                                           '  a = 1',
                                           '  #a = 2',
                                           '  a = 3',
                                           '  #a = 4',
                                           '  a = 5',
                                           '  a = 6',
                                           'end'])
        expect(method_length.offences.size).to eq(1)
        expect(method_length.offences.map(&:line_number).sort).to eq([1])
      end
    end
  end
end
