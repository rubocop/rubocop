# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe StringLiterals do
        subject(:cop) { StringLiterals.new }

        it 'registers offence for double quotes when single quotes suffice' do
          inspect_source(cop, ['s = "abc"',
                               'x = "a\\\\b"',
                               'y ="\\\\b"',
                               'z = "a\\\\"'])
          expect(cop.offences.size).to eq(4)
        end

        it 'accepts double quotes when they are needed' do
          src = ['a = "\n"',
                 'b = "#{encode_severity}:' +
                 '#{sprintf("%3d", line_number)}: #{m}"',
                 'c = "\'"',
                 'd = "#@test"',
                 'e = "#$test"',
                 'f = "\e"',
                 'g = "#@@test"']
          inspect_source(cop, src)
          expect(cop.offences).to be_empty
        end

        it 'accepts double quotes at the start of regexp literals' do
          inspect_source(cop, ['s = /"((?:[^\\"]|\\.)*)"/'])
          expect(cop.offences).to be_empty
        end

        it 'accepts double quotes with some other special symbols' do
          # "Substitutions in double-quoted strings"
          # http://www.ruby-doc.org/docs/ProgrammingRuby/html/language.html
          src = ['g = "\xf9"',
                 'copyright = "\u00A9"']
          inspect_source(cop, src)
          expect(cop.offences).to be_empty
        end

        it 'accepts " in a %w' do
          inspect_source(cop, ['%w(")'])
          expect(cop.offences).to be_empty
        end

        it 'accepts \\\\\n in a string' do # this would be: "\\\n"
          inspect_source(cop, ['"foo \\\\\n bar"'])
          expect(cop.offences).to be_empty
        end

        it 'can handle double quotes within embedded expression' do
          src = ['"#{"A"}"']
          inspect_source(cop, src)
          expect(cop.offences).to be_empty
        end

        it 'can handle a built-in constant parsed as string' do
          # Parser will produce str nodes for constants such as __FILE__.
          src = ['if __FILE__ == $PROGRAM_NAME',
                 'end']
          inspect_source(cop, src)
          expect(cop.offences).to be_empty
        end

        it 'auto-corrects " with \'' do
          new_source = autocorrect_source(cop, 's = "abc"')
          expect(new_source).to eq("s = 'abc'")
        end
      end
    end
  end
end
