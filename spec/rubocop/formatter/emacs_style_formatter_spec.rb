# encoding: utf-8

require 'spec_helper'
require 'stringio'

module Rubocop
  module Formatter
    describe EmacsStyleFormatter do
      let(:formatter) { EmacsStyleFormatter.new(output) }
      let(:output) { StringIO.new }

      describe '#report_file' do
        it 'displays parsable text' do
          cop = Cop::Cop.new
          cop.add_offence(:convention, 1, 'message 1')
          cop.add_offence(:fatal,     11, 'message 2')

          formatter.report_file('test', cop.offences)
          expect(output.string).to eq ['test:1: C: message 1',
                                       "test:11: F: message 2\n"].join("\n")
        end
      end
    end
  end
end
