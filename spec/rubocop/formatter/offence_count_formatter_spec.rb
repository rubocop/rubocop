# encoding: utf-8

require 'spec_helper'
require 'stringio'
require 'tempfile'

module Rubocop
  module Formatter
    describe OffenceCountFormatter do
      subject(:formatter) { described_class.new(output) }
      let(:output) { StringIO.new }

      let(:files) do
        %w(lib/rubocop.rb spec/spec_helper.rb bin/rubocop).map do |path|
          File.expand_path(path)
        end
      end

      describe '#file_finished' do
        before { formatter.started(files) }

        let(:finish) { formatter.file_finished(files.first, offences) }

        context 'when no offences are detected' do
          let(:offences) { [] }
          it 'shouldn\'t add to offence_counts' do
            expect { finish }.to_not change { formatter.offence_counts }
          end
        end

        context 'when any offences are detected' do
          let(:offences) { [double('offence', cop_name: 'OffendedCop')] }
          it 'should increment the count for the cop in offence_counts' do
            expect { finish }.to change { formatter.offence_counts }
          end
        end
      end

      describe '#report_summary' do
        context 'when a offence detected' do
          let(:cop_counts) { { 'OffendedCop' => 1 } }
          it 'shows the cop and the offence count' do
            formatter.report_summary(1, cop_counts)
            expect(output.string).to include(
              "\n1  OffendedCop")
          end
        end
      end

    end
  end
end
