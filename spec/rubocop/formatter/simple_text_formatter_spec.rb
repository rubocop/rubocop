# frozen_string_literal: true

module RuboCop
  module Formatter
    describe SimpleTextFormatter do
      before do
        Rainbow.enabled = true
      end

      subject(:formatter) { described_class.new(output) }
      let(:output) { StringIO.new }

      describe '#report_file' do
        before do
          formatter.report_file(file, [offense])
        end

        let(:file) { '/path/to/file' }

        let(:offense) do
          Cop::Offense.new(:convention, location,
                           'This is a message with `colored text`.',
                           'CopName', status)
        end

        let(:location) do
          source_buffer = Parser::Source::Buffer.new('test', 1)
          source_buffer.source = "a\n"
          Parser::Source::Range.new(source_buffer, 0, 1)
        end

        let(:status) { :uncorrected }

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

        context 'when the offense is not corrected' do
          let(:status) { :uncorrected }

          it 'prints message as-is' do
            expect(output.string)
              .to include(': This is a message with colored text.')
          end
        end

        context 'when the offense is automatically corrected' do
          let(:status) { :corrected }

          it 'prints [Corrected] along with message' do
            expect(output.string)
              .to include(': [Corrected] This is a message with colored text.')
          end
        end
      end

      describe '#report_summary' do
        context 'when no files inspected' do
          it 'handles pluralization correctly' do
            formatter.report_summary(0, 0, 0)
            expect(output.string).to eq(<<-OUTPUT.strip_indent)

              0 files inspected, no offenses detected
            OUTPUT
          end
        end

        context 'when a file inspected and no offenses detected' do
          it 'handles pluralization correctly' do
            formatter.report_summary(1, 0, 0)
            expect(output.string).to eq(<<-OUTPUT.strip_indent)

              1 file inspected, no offenses detected
            OUTPUT
          end
        end

        context 'when a offense detected' do
          it 'handles pluralization correctly' do
            formatter.report_summary(1, 1, 0)
            expect(output.string).to eq(<<-OUTPUT.strip_indent)

              1 file inspected, 1 offense detected
            OUTPUT
          end
        end

        context 'when 2 offenses detected' do
          it 'handles pluralization correctly' do
            formatter.report_summary(2, 2, 0)
            expect(output.string).to eq(<<-OUTPUT.strip_indent)

              2 files inspected, 2 offenses detected
            OUTPUT
          end
        end

        context 'when an offense is corrected' do
          it 'prints about correction' do
            formatter.report_summary(1, 1, 1)
            expect(output.string).to eq(<<-OUTPUT.strip_indent)

              1 file inspected, 1 offense detected, 1 offense corrected
            OUTPUT
          end
        end

        context 'when 2 offenses are corrected' do
          it 'handles pluralization correctly' do
            formatter.report_summary(1, 1, 2)
            expect(output.string).to eq(<<-OUTPUT.strip_indent)

              1 file inspected, 1 offense detected, 2 offenses corrected
            OUTPUT
          end
        end
      end

      after do
        Rainbow.enabled = false
      end
    end
  end
end
