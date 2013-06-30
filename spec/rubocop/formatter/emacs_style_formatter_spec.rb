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
          source_buffer = Parser::Source::Buffer.new('test', 1)
          source_buffer.source = %w(a b cdefghi).join("\n")

          cop.add_offence(:convention,
                          Parser::Source::Range.new(source_buffer, 0, 1),
                          'message 1')
          cop.add_offence(:fatal,
                          Parser::Source::Range.new(source_buffer, 9, 10),
                          'message 2')

          formatter.report_file('test', cop.offences)
          expect(output.string).to eq ['test:1:1: C: message 1',
                                       "test:3:6: F: message 2\n"].join("\n")
        end
      end
    end
  end
end
