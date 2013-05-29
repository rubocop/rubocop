# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe StringLiterals do
      let(:sl) { StringLiterals.new }

      it 'registers an offence for double quotes when single quotes suffice' do
        inspect_source(sl, ['s = "abc"'])
        expect(sl.offences.size).to eq(1)
      end

      it 'accepts double quotes when they are needed' do
        src = ['a = "\n"',
               'b = "#{encode_severity}:#{sprintf("%3d", line_number)}: #{m}"',
               'c = "\'"',
               'd = "#@test"',
               'e = "#$test"',
               'f = "#@@test"']
        inspect_source(sl, src)
        expect(sl.offences).to be_empty
      end

      it 'accepts double quotes at the start of regexp literals' do
        inspect_source(sl, ['s = /"((?:[^\\"]|\\.)*)"/'])
        expect(sl.offences).to be_empty
      end

      it 'accepts double quotes with some other special symbols' do
        pending
        # "Substitutions in double-quoted strings"
        # http://www.ruby-doc.org/docs/ProgrammingRuby/html/language.html
        src = ['g = "\xf9"']
        inspect_source(sl, src)
        expect(sl.offences).to be_empty
      end

      it 'can handle double quotes within embedded expression' do
        # This seems to be a Parser bug
        pending do
          src = ['"#{"A"}"']
          inspect_source(sl, src)
          expect(sl.offences).to be_empty
        end
      end

      it 'can handle a typical main call condition' do
        src = ['if __FILE__ == $PROGRAM_NAME',
               'end']
        inspect_source(sl, src)
        expect(sl.offences).to be_empty
      end
    end
  end
end
