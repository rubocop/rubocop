# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe ReduceArguments do
      let(:reduce_arguments) { ReduceArguments.new }

      it 'find wrong argument names in calls with different syntax' do
        inspect_source(reduce_arguments, '',
                       ['def m',
                        '  [0, 1].reduce { |c, d| c + d }',
                        '  [0, 1].reduce{ |c, d| c + d }',
                        '  [0, 1].reduce(5) { |c, d| c + d }',
                        '  [0, 1].reduce(5){ |c, d| c + d }',
                        '  [0, 1].reduce (5) { |c, d| c + d }',
                        '  [0, 1].reduce(5) { |c, d| c + d }',
                        'end'])
        expect(reduce_arguments.offences.size).to eq(6)
        expect(reduce_arguments.offences
                               .map(&:line_number).sort).to eq((2..7).to_a)
      end

      it 'allows calls with proper argument names' do
        inspect_source(reduce_arguments, '',
                       ['def m',
                        '  [0, 1].reduce { |a, e| a + e }',
                        '  [0, 1].reduce{ |a, e| a + e }',
                        '  [0, 1].reduce(5) { |a, e| a + e }',
                        '  [0, 1].reduce(5){ |a, e| a + e }',
                        '  [0, 1].reduce (5) { |a, e| a + e }',
                        '  [0, 1].reduce(5) { |a, e| a + e }',
                        'end'])
        expect(reduce_arguments.offences).to be_empty
      end

      it 'ignores do..end blocks' do
        inspect_source(reduce_arguments, '',
                       ['def m',
                        '  [0, 1].reduce do |c, d|',
                        '    c + d',
                        '  end',
                        'end'])
        expect(reduce_arguments.offences).to be_empty
      end

      it 'ignores :reduce symbols' do
        inspect_source(reduce_arguments, '',
                       ['def m',
                        '  call_method(:reduce) { |a, b| a + b}',
                        'end'])
        expect(reduce_arguments.offences).to be_empty
      end
    end
  end
end
