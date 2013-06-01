# encoding: utf-8

require 'spec_helper'
require 'stringio'

module Rubocop
  module Formatter
    describe PlainTextFormatter do
      subject(:formatter) { PlainTextFormatter.new(output) }
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
    end
  end
end
