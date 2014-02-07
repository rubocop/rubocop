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

      let(:finish) { formatter.file_finished(files.first, offences) }

      describe '#file_finished' do
        before { formatter.started(files) }

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
        context 'when an offence is detected' do
          let(:cop_counts) { { 'OffendedCop' => 1 } }
          it 'shows the cop and the offence count' do
            formatter.report_summary(1, cop_counts)
            expect(output.string).to include(
              "\n1  OffendedCop\n--\n1  Total")
          end
        end
      end

      describe '#finished' do
        context 'when there are many offences' do
          let(:offences) do
            %w(CopB CopA CopC CopC).map { |c| double('offence', cop_name: c) }
          end

          before do
            formatter.started(files)
            finish
          end

          it 'sorts by offence count first and then by cop name' do
            formatter.finished(files)
            expect(output.string).to eq(['',
                                         '2  CopC',
                                         '1  CopA',
                                         '1  CopB',
                                         '--',
                                         '4  Total',
                                         '',
                                         ''].join("\n"))
          end
        end
      end

    end
  end
end
