# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe Indentation do
      let (:ind) { Indentation.new }

      it "registers an offence for a when clause that's deeper than case" do
        source = ['case a',
                  '    when 0 then return',
                  '        case b',
                  '         when 1 then return',
                  '        end',
                  'end']
        ind.inspect_source('file.rb', source)
        ind.offences.size.should == 2
      end

      it "accepts a when clause that's equally indented with case" do
        source = ['y = case a',
                  '    when 0 then break',
                  '    when 0 then return',
                  '      z = case b',
                  '          when 1 then return',
                  '          when 1 then break',
                  '          end',
                  '    end',
                  'case c',
                  'when 2 then encoding',
                  'end',
                  '']
        ind.inspect_source('file.rb', source)
        ind.offences.size.should == 0
      end

      it "doesn't get confused by strings with case in them" do
        source = ['a = "case"',
                  'case x',
                  'when 0',
                  'end',
                  '']
        ind.inspect_source('file.rb', source)
        ind.offences.map(&:message).should == []
      end

      it "doesn't get confused by symbols named case or when" do
        source = ['KEYWORDS = { :case => true, :when => true }',
                  'case type',
                  'when 0',
                  '  ParameterNode',
                  'when 1',
                  '  MethodCallNode',
                  'end',
                  '']
        ind.inspect_source('file.rb', source)
        ind.offences.map(&:message).should == []
      end
    end
  end
end
