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
        ind.inspect_source("file.rb", source)
        ind.offences.map(&:message).should == ["Indent when as deep as case.",
                                               "Indent when as deep as case."]
      end

      it "accepts a when clause that's equally indented with case" do
        source = ['y = case x',
                  '    when 0 then return',
                  '      z = case w',
                  '          when 0 then return',
                  '          when 1 then break',
                  '          end',
                  '    when 1 then break',
                  '    end',
                  '']
        ind.inspect_source("file.rb", source)
        ind.offences.size.should == 0
      end

      def check_offence(offence, line_number, message)
        offence.message.should == message
        offence.line_number.should == line_number
      end
    end
  end
end
