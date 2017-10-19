# frozen_string_literal: true

module RuboCop
  module Formatter
    describe WorstOffendersFormatter do
      subject(:formatter) { described_class.new(output) }

      let(:output) { StringIO.new }

      let(:files) do
        %w[lib/rubocop.rb spec/spec_helper.rb bin/rubocop].map do |path|
          File.expand_path(path)
        end
      end

      describe '#finished' do
        context 'when there are many offenses' do
          let(:offense) { double('offense') }

          before do
            formatter.started(files)
            files.each_with_index do |file, index|
              formatter.file_finished(file, [offense] * (index + 2))
            end
          end

          it 'sorts by offense count first and then by cop name' do
            formatter.finished(files)
            expect(output.string).to eq(<<-OUTPUT.strip_indent)

              4  bin/rubocop
              3  spec/spec_helper.rb
              2  lib/rubocop.rb
              --
              9  Total

            OUTPUT
          end
        end
      end
    end
  end
end
