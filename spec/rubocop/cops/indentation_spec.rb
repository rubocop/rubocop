require 'spec_helper'

module Rubocop
  module Cop
    describe Indentation do
      let (:indentation) { Indentation.new }

      it "registers an offence for a when clause that's deeper than case" do
        source = ['case x',
                  '    when 0 then return',
                  '        case y',
                  '         when 1 then return',
                  '        end',
                  'end']
        indentation.inspect("file.rb", source, Ripper.lex(source.join("\n")),
                            Ripper.sexp(source.join("\n")))
        indentation.offences.size.should == 2
        check_offence indentation.offences.first, 1, "Indent when as deep as case."
        check_offence indentation.offences.last, 3, "Indent when as deep as case."
      end

      it "accepts a when clause that's equally indented with case" do
        source = ['case x',
                  'when 0 then return',
                  'end']
        indentation.inspect("file.rb", source, Ripper.lex(source.join("\n")),
                            Ripper.sexp(source.join("\n")))
        indentation.offences.size.should == 0
      end

      def check_offence(offence, line_number, message)
        offence.message.should == message
        offence.line_number.should == line_number
      end
    end
  end
end
