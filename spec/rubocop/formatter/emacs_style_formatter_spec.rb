# encoding: utf-8

require 'spec_helper'
require 'stringio'

module Rubocop
  module Formatter
    describe EmacsStyleFormatter do
      subject(:formatter) { described_class.new(output) }
      let(:output) { StringIO.new }

      describe '#file_finished' do
        it 'displays parsable text' do
          cop = Cop::Cop.new
          source_buffer = Parser::Source::Buffer.new('test', 1)
          source_buffer.source = %w(a b cdefghi).join("\n")

          cop.add_offence(nil,
                          Parser::Source::Range.new(source_buffer, 0, 1),
                          'message 1')
          cop.add_offence(nil,
                          Parser::Source::Range.new(source_buffer, 9, 10),
                          'message 2')

          formatter.file_finished('test', cop.offences)
          expect(output.string).to eq ['test:1:1: C: message 1',
                                       "test:3:6: C: message 2\n"].join("\n")
        end

        context 'when the offence is automatically corrected' do
          let(:file) { '/path/to/file' }

          let(:offence) do
            Cop::Offence.new(:convention, location,
                             'This is a message.', 'CopName', corrected)
          end

          let(:location) do
            source_buffer = Parser::Source::Buffer.new('test', 1)
            source_buffer.source = "a\n"
            Parser::Source::Range.new(source_buffer, 0, 1)
          end

          let(:corrected) { true }

          it 'prints [Corrected] along with message' do
            formatter.file_finished(file, [offence])
            expect(output.string)
              .to include(': [Corrected] This is a message.')
          end
        end
      end

      describe '#finished' do
        it 'does not report summary' do
          formatter.finished(['/path/to/file'])
          expect(output.string).to be_empty
        end
      end
    end
  end
end
