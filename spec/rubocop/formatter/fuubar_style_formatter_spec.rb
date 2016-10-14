# frozen_string_literal: true

require 'spec_helper'

module RuboCop
  describe Formatter::FuubarStyleFormatter do
    subject(:formatter) { described_class.new(output) }
    let(:output) { StringIO.new }

    let(:files) do
      %w[lib/rubocop.rb spec/spec_helper.rb].map do |path|
        File.expand_path(path)
      end
    end

    describe '#with_color' do
      around do |example|
        original_state = formatter.rainbow.enabled

        begin
          example.run
        ensure
          formatter.rainbow.enabled = original_state
        end
      end

      context 'when color is enabled' do
        before do
          formatter.rainbow.enabled = true
        end

        it 'outputs coloring sequence code at the beginning and the end' do
          formatter.with_color { formatter.output.write 'foo' }
          expect(output.string).to eq("\e[32mfoo\e[0m")
        end
      end

      context 'when color is enabled' do
        before do
          formatter.rainbow.enabled = false
        end

        it 'outputs nothing' do
          formatter.with_color { formatter.output.write 'foo' }
          expect(output.string).to eq('foo')
        end
      end
    end

    describe '#progressbar_color' do
      before do
        formatter.started(files)
      end

      def offense(severity, status = :uncorrected)
        source_range = double('source_range').as_null_object
        Cop::Offense.new(severity, source_range, 'message', 'Cop', status)
      end

      context 'initially' do
        it 'is green' do
          expect(formatter.progressbar_color).to eq(:green)
        end
      end

      context 'when no offenses are detected in a file' do
        before do
          formatter.file_finished(files[0], [])
        end

        it 'is still green' do
          expect(formatter.progressbar_color).to eq(:green)
        end
      end

      context 'when a convention offense is detected in a file' do
        before do
          formatter.file_finished(files[0], [offense(:convention)])
        end

        it 'is yellow' do
          expect(formatter.progressbar_color).to eq(:yellow)
        end
      end

      context 'when an error offense is detected in a file' do
        before do
          formatter.file_finished(files[0], [offense(:error)])
        end

        it 'is red' do
          expect(formatter.progressbar_color).to eq(:red)
        end

        context 'and then a convention offense is detected in the next file' do
          before do
            formatter.file_finished(files[1], [offense(:convention)])
          end

          it 'is still red' do
            expect(formatter.progressbar_color).to eq(:red)
          end
        end
      end

      context 'when convention and error offenses are detected in a file' do
        before do
          offenses = [offense(:convention), offense(:error)]
          formatter.file_finished(files[0], offenses)
        end

        it 'is red' do
          expect(formatter.progressbar_color).to eq(:red)
        end
      end

      context 'when a offense is detected in a file and auto-corrected' do
        before do
          formatter.file_finished(files[0], [offense(:convention, :corrected)])
        end

        it 'is green' do
          expect(formatter.progressbar_color).to eq(:green)
        end
      end
    end
  end
end
