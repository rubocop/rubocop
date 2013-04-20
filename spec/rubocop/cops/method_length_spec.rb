# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe MethodLength do
      let(:method_length) { MethodLength.new }
      before { MethodLength.stub(:max).and_return(10) }

      it 'rejects a method with more than 10 lines' do
        inspect_source(method_length, '', ['class K',
                                           '  def m()',
                                           '    a = 1',
                                           '    a = 2',
                                           '    a = 3',
                                           '    #a = 4',
                                           '    a = 5',
                                           '    a = 6',
                                           '    a = 7',
                                           '    a = 8',
                                           '    #a = 9',
                                           '    a = 10',
                                           '    a = 11',
                                           '  end',
                                           'end'])
        expect(method_length.offences.size).to eq(1)
        expect(method_length.offences.map(&:line_number).sort).to eq([2])
      end

      it 'accepts a method with less than 10 lines' do
        inspect_source(method_length, '', ['class K',
                                           '  def m()',
                                           '    a = 1',
                                           '    a = 2',
                                           '    a = 3',
                                           '    a = 4',
                                           '  end',
                                           'end'])
        expect(method_length.offences).to be_empty
      end

      it 'does not count blank lines' do
        inspect_source(method_length, '', ['class K',
                                           '  def m()',
                                           '    a = 1',
                                           '    a = 2',
                                           '    a = 3',
                                           '    a = 4',
                                           '',
                                           '',
                                           '    a = 7',
                                           '    a = 8',
                                           '',
                                           '    a = 10',
                                           '    a = 11',
                                           '  end',
                                           'end'])
        expect(method_length.offences).to be_empty
      end

      it 'accepts empty methods' do
        inspect_source(method_length, '', ['class K',
                                           '  def m()',
                                           '  end',
                                           'end'])
        expect(method_length.offences).to be_empty
      end

      it 'checks class methods, syntax #1' do
        inspect_source(method_length, '', ['class K',
                                           '  def self.m()',
                                           '    a = 1',
                                           '    a = 2',
                                           '    a = 3',
                                           '    #a = 4',
                                           '    a = 5',
                                           '    a = 6',
                                           '    a = 7',
                                           '    a = 8',
                                           '    #a = 9',
                                           '    a = 10',
                                           '    a = 11',
                                           '  end',
                                           'end'])
        expect(method_length.offences.size).to eq(1)
        expect(method_length.offences.map(&:line_number).sort).to eq([2])
      end

      it 'checks class methods, syntax #2' do
        inspect_source(method_length, '', ['class K',
                                           '  class << self',
                                           '    def m()',
                                           '      a = 1',
                                           '      a = 2',
                                           '      a = 3',
                                           '      #a = 4',
                                           '      a = 5',
                                           '      a = 6',
                                           '      a = 7',
                                           '      a = 8',
                                           '      #a = 9',
                                           '      a = 10',
                                           '      a = 11',
                                           '    end',
                                           '  end',
                                           'end'])
        expect(method_length.offences.size).to eq(1)
        expect(method_length.offences.map(&:line_number).sort).to eq([3])
      end

      it 'properly counts lines when method ends with block' do
        inspect_source(method_length, '', ['class K',
                                            '  def m()',
                                            '    do',
                                            '      a = 2',
                                            '      a = 3',
                                            '      a = 4',
                                            '      a = 5',
                                            '      a = 6',
                                            '      a = 7',
                                            '      a = 8',
                                            '      a = 9',
                                            '      a = 10',
                                            '    end',
                                            '  end',
                                            'end'])
         expect(method_length.offences.size).to eq(1)
         expect(method_length.offences.map(&:line_number).sort).to eq([2])
       end
    end
  end
end
