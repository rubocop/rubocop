# frozen_string_literal: true

require 'spec_helper'

module RuboCop
  module Formatter
    describe OffenseCountFormatter do
      subject(:formatter) { described_class.new(output) }
      let(:output) { StringIO.new }

      let(:files) do
        %w[lib/rubocop.rb spec/spec_helper.rb bin/rubocop].map do |path|
          File.expand_path(path)
        end
      end

      let(:finish) { formatter.file_finished(files.first, offenses) }

      describe '#file_finished' do
        before { formatter.started(files) }

        context 'when no offenses are detected' do
          let(:offenses) { [] }
          it 'does not add to offense_counts' do
            expect { finish }.to_not change { formatter.offense_counts }
          end
        end

        context 'when any offenses are detected' do
          let(:offenses) { [double('offense', cop_name: 'OffendedCop')] }
          it 'increments the count for the cop in offense_counts' do
            expect { finish }.to change { formatter.offense_counts }
          end
        end
      end

      describe '#report_summary' do
        context 'when an offense is detected' do
          let(:cop_counts) { { 'OffendedCop' => 1 } }
          it 'shows the cop and the offense count' do
            formatter.report_summary(cop_counts)
            expect(output.string).to include(
              "\n1  OffendedCop\n--\n1  Total"
            )
          end
        end
      end

      describe '#finished' do
        context 'when there are many offenses' do
          let(:offenses) do
            %w[CopB CopA CopC CopC].map { |c| double('offense', cop_name: c) }
          end

          before do
            formatter.started(files)
            finish
          end

          it 'sorts by offense count first and then by cop name' do
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
