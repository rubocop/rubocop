# encoding: utf-8

require 'spec_helper'
require 'stringio'
require 'tempfile'

module Rubocop
  module Formatter
    describe SimpleTextFormatter do
      subject(:formatter) { SimpleTextFormatter.new(output) }
      let(:output) { StringIO.new }

      describe '#report_file' do
        before do
          formatter.report_file(file, [])
        end

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
      end

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
    end
  end
end
