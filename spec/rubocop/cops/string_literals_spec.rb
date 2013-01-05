# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe StringLiterals do
      let (:sl) { StringLiterals.new }

      it 'registers an offence for double quotes when single quotes suffice' do
        inspect_source(sl, 'file.rb', ['s = "abc"'])
        sl.offences.map(&:message).should ==
          ["Prefer single-quoted strings when you don't need string " +
           'interpolation or special symbols.']
      end

      it 'accepts double quotes when they are needed' do
        src = ['a = "\n"',
               'b = "#{encode_severity}:#{sprintf("%3d", line_number)}: #{m}"',
               'c = "\'"']
        inspect_source(sl, 'file.rb', src)
        sl.offences.map(&:message).should == []
      end

      it 'can handle double quotes within embedded expression' do
        src = ['"#{"A"}"']
        inspect_source(sl, 'file.rb', src)
        sl.offences.map(&:message).should == []
      end
    end
  end
end
