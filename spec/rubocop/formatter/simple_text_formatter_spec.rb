# encoding: utf-8

require 'spec_helper'
require 'stringio'
require 'tempfile'

module Rubocop
  module Formatter
    describe SimpleTextFormatter do
      subject(:formatter) { described_class.new(output) }
      let(:output) { StringIO.new }

      describe '#report_file' do
        before do
          formatter.report_file(file, [offence])
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

        let(:corrected) { false }

        context 'the file is under the current working directory' do
          let(:file) { File.expand_path('spec/spec_helper.rb') }

          it 'prints as relative path' do
            expect(output.string).to include('== spec/spec_helper.rb ==')
          end
        end

        context 'the file is outside of the current working directory' do
          let(:file) do
            tempfile = Tempfile.new('')
            tempfile.close
            File.expand_path(tempfile.path)
          end

          it 'prints as absolute path' do
            expect(output.string).to include("== #{file} ==")
          end
        end

        context 'when the offence is not corrected' do
          let(:corrected) { false }

          it 'prints message as-is' do
            expect(output.string)
              .to include(': This is a message.')
          end
        end

        context 'when the offence is automatically corrected' do
          let(:corrected) { true }

          it 'prints [Corrected] along with message' do
            expect(output.string)
              .to include(': [Corrected] This is a message.')
          end
        end
      end

      describe '#report_summary' do
        context 'when no files inspected' do
          it 'handles pluralization correctly' do
            formatter.report_summary(0, 0, 0)
            expect(output.string).to eq(
              "\n0 files inspected, no offences detected\n")
          end
        end

        context 'when a file inspected and no offences detected' do
          it 'handles pluralization correctly' do
            formatter.report_summary(1, 0, 0)
            expect(output.string).to eq(
              "\n1 file inspected, no offences detected\n")
          end
        end

        context 'when a offence detected' do
          it 'handles pluralization correctly' do
            formatter.report_summary(1, 1, 0)
            expect(output.string).to eq(
              "\n1 file inspected, 1 offence detected\n")
          end
        end

        context 'when 2 offences detected' do
          it 'handles pluralization correctly' do
            formatter.report_summary(2, 2, 0)
            expect(output.string).to eq(
              "\n2 files inspected, 2 offences detected\n")
          end
        end

        context 'when an offence is corrected' do
          it 'prints about correction' do
            formatter.report_summary(1, 1, 1)
            expect(output.string).to eq(
              "\n1 file inspected, 1 offence detected, 1 offence corrected\n")
          end
        end

        context 'when 2 offences are corrected' do
          it 'handles pluralization correctly' do
            formatter.report_summary(1, 1, 2)
            expect(output.string).to eq(
              "\n1 file inspected, 1 offence detected, 2 offences corrected\n")
          end
        end
      end
    end
  end
end
