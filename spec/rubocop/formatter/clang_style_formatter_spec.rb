# encoding: utf-8

require 'spec_helper'
require 'stringio'

module Rubocop
  module Formatter
    describe ClangStyleFormatter do
      subject(:formatter) { described_class.new(output) }
      let(:output) { StringIO.new }

      describe '#report_file' do
        it 'displays text containing the offending source line' do
          cop = Cop::Cop.new
          source_buffer = Parser::Source::Buffer.new('test', 1)
          source_buffer.source = ('aa'..'az').to_a.join($RS)
          cop.add_offence(:convention, nil,
                          Parser::Source::Range.new(source_buffer, 0, 2),
                          'message 1')
          cop.add_offence(:fatal, nil,
                          Parser::Source::Range.new(source_buffer, 30, 32),
                          'message 2')

          formatter.report_file('test', cop.offences)
          expect(output.string).to eq ['test:1:1: C: message 1',
                                       'aa',
                                       '^^',
                                       'test:11:1: F: message 2',
                                       'ak',
                                       '^^',
                                       ''].join("\n")
        end

        context 'when the source line is blank' do
          it 'does not display offending source line' do
            cop = Cop::Cop.new
            source_buffer = Parser::Source::Buffer.new('test', 1)
            source_buffer.source = (['     ', 'yaba']).to_a.join($RS)
            cop.add_offence(:convention, nil,
                            Parser::Source::Range.new(source_buffer, 0, 2),
                            'message 1')
            cop.add_offence(:fatal, nil,
                            Parser::Source::Range.new(source_buffer, 6, 10),
                            'message 2')

            formatter.report_file('test', cop.offences)
            expect(output.string).to eq ['test:1:1: C: message 1',
                                         'test:2:1: F: message 2',
                                         'yaba',
                                         '^^^^',
                                         ''].join("\n")
          end
        end

        context 'when the offending source spans multiple lines' do
          it 'does not display the source line' do
            cop = Cop::Cop.new
            source_buffer = Parser::Source::Buffer.new('test', 1)
            source_buffer.source = %w(foobar bazbop).to_a.join($RS)
            cop.add_offence(:convention, nil,
                            Parser::Source::Range.new(source_buffer, 5, 10),
                            'message 1')

            formatter.report_file('test', cop.offences)
            expect(output.string).to eq ['test:1:6: C: message 1',
                                         ''].join("\n")
          end
        end

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

        context 'when the offence is not corrected' do
          let(:corrected) { false }

          it 'prints message as-is' do
            formatter.report_file(file, [offence])
            expect(output.string)
              .to include(': This is a message.')
          end
        end

        context 'when the offence is automatically corrected' do
          let(:corrected) { true }

          it 'prints [Corrected] along with message' do
            formatter.report_file(file, [offence])
            expect(output.string)
              .to include(': [Corrected] This is a message.')
          end
        end
      end
    end
  end
end
