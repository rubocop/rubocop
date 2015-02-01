# encoding: utf-8

require 'spec_helper'
require 'stringio'

module RuboCop
  module Formatter
    describe DisabledLinesFormatter do
      subject(:formatter) { described_class.new(output) }
      let(:output) { StringIO.new }

      let(:files) do
        %w(lib/rubocop.rb spec/spec_helper.rb bin/rubocop).map do |path|
          File.expand_path(path)
        end
      end

      let(:file_started) do
        formatter.file_started(files.first, cop_disabled_line_ranges)
      end

      describe '#file_started' do
        before { formatter.started(files) }

        context 'when no disable cop comments are detected' do
          let(:cop_disabled_line_ranges) { {} }
          it 'does not add to cop_disabled_line_ranges' do
            expect { file_started }.to_not(
              change { formatter.cop_disabled_line_ranges })
          end
        end

        context 'when any disable cop comments are detected' do
          let(:cop_disabled_line_ranges) do
            { cop_disabled_line_ranges: { 'LineLength' => [1..1] } }
          end
          it 'merges the changes into cop_disabled_line_ranges' do
            expect { file_started }.to(
              change { formatter.cop_disabled_line_ranges })
          end
        end
      end

      describe '#finished' do
        context 'when there disabled cops detected' do
          let(:cop_disabled_line_ranges) do
            { cop_disabled_line_ranges: { 'LineLength' => [1..1] } }
          end

          before do
            formatter.started(files)
            formatter.file_started('lib/rubocop.rb', cop_disabled_line_ranges)
          end

          it 'lists disabled cops by file' do
            formatter.finished(files)
            expect(output.string).to eq(['',
                                         'Cops disabled line ranges:',
                                         '',
                                         'lib/rubocop.rb:1..1: LineLength',
                                         ''].join("\n"))
          end
        end
      end
    end
  end
end
