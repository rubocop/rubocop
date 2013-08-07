# encoding: utf-8

require 'spec_helper'
require 'stringio'

module Rubocop
  module Formatter
    describe ClangStyleFormatter do
      subject(:formatter) { ClangStyleFormatter.new(output) }
      let(:output) { StringIO.new }

      describe '#report_summary' do
        context 'when no files inspected' do
          it 'handles pluralization correctly' do
            formatter.report_summary(0, 0)
            expect(output.string).to eq(
              "\n0 files inspected, no offences detected\n")
          end
        end

        context 'when a file inspected and no offences detected' do
          it 'handles pluralization correctly' do
            formatter.report_summary(1, 0)
            expect(output.string).to eq(
              "\n1 file inspected, no offences detected\n")
          end
        end

        context 'when a offence detected' do
          it 'handles pluralization correctly' do
            formatter.report_summary(1, 1)
            expect(output.string).to eq(
              "\n1 file inspected, 1 offence detected\n")
          end
        end

        context 'when 2 offences detected' do
          it 'handles pluralization correctly' do
            formatter.report_summary(2, 2)
            expect(output.string).to eq(
              "\n2 files inspected, 2 offences detected\n")
          end
        end
      end

      describe '#report_file' do
        it 'displays text containing the offending source line' do
          cop = Cop::Cop.new
          source_buffer = Parser::Source::Buffer.new('test', 1)
          source_buffer.source = ('aa'..'az').to_a.join($RS)
          cop.add_offence(:convention,
                          Parser::Source::Range.new(source_buffer, 0, 2),
                          'message 1')
          cop.add_offence(:fatal,
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

        it 'does not display offending source line if it is blank' do
          cop = Cop::Cop.new
          source_buffer = Parser::Source::Buffer.new('test', 1)
          source_buffer.source = (['     ', 'yaba']).to_a.join($RS)
          cop.add_offence(:convention,
                          Parser::Source::Range.new(source_buffer, 0, 2),
                          'message 1')
          cop.add_offence(:fatal,
                          Parser::Source::Range.new(source_buffer, 6, 4),
                          'message 2')

          formatter.report_file('test', cop.offences)
          expect(output.string).to eq ['test:1:1: C: message 1',
                                       'test:2:1: F: message 2',
                                       'yaba',
                                       '^^^^',
                                       ''].join("\n")
        end
      end
    end
  end
end
