# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::AutoGenConfigFormatter do
  subject(:formatter) { described_class.new(output) }

  let(:output) { StringIO.new }

  let(:files) do
    %w[lib/rubocop.rb spec/spec_helper.rb exe/rubocop].map do |path|
      File.expand_path(path)
    end
  end

  describe '#report_file_as_mark' do
    before do
      formatter.report_file_as_mark(offenses)
    end

    def offense_with_severity(severity)
      source_buffer = Parser::Source::Buffer.new('test', 1)
      source_buffer.source = "a\n"
      RuboCop::Cop::Offense.new(severity,
                                Parser::Source::Range.new(source_buffer, 0, 1),
                                'message',
                                'CopName')
    end

    context 'when no offenses are detected' do
      let(:offenses) { [] }

      it 'prints "."' do
        expect(output.string).to eq('.')
      end
    end

    context 'when a refactor severity offense is detected' do
      let(:offenses) { [offense_with_severity(:refactor)] }

      it 'prints "R"' do
        expect(output.string).to eq('R')
      end
    end

    context 'when a refactor convention offense is detected' do
      let(:offenses) { [offense_with_severity(:convention)] }

      it 'prints "C"' do
        expect(output.string).to eq('C')
      end
    end

    context 'when different severity offenses are detected' do
      let(:offenses) do
        [
          offense_with_severity(:refactor),
          offense_with_severity(:error)
        ]
      end

      it 'prints highest level mark' do
        expect(output.string).to eq('E')
      end
    end
  end

  describe '#finished' do
    before do
      formatter.started(files)
    end

    context 'when any offenses are detected' do
      before do
        source_buffer = Parser::Source::Buffer.new('test', 1)
        source = Array.new(9) do |index|
          "This is line #{index + 1}."
        end
        source_buffer.source = source.join("\n")
        line_length = source[0].length + 1

        formatter.file_started(files[0], {})
        formatter.file_finished(
          files[0],
          [
            RuboCop::Cop::Offense.new(
              :convention,
              Parser::Source::Range.new(source_buffer,
                                        line_length + 2,
                                        line_length + 3),
              'foo',
              'Cop'
            )
          ]
        )
      end

      it 'does not report offenses' do
        formatter.finished(files)
        expect(output.string).not_to include('Offenses:')
      end

      it 'outputs report summary' do
        formatter.finished(files)
        expect(output.string).to include <<-OUTPUT.strip_indent
          3 files inspected, 1 offense detected
        OUTPUT
      end
    end

    context 'when no offenses are detected' do
      before do
        files.each do |file|
          formatter.file_started(file, {})
          formatter.file_finished(file, [])
        end
      end

      it 'does not report offenses' do
        formatter.finished(files)
        expect(output.string).not_to include('Offenses:')
      end
    end

    it 'calls #report_summary' do
      formatter.finished(files)
      expect(output.string).to include <<-OUTPUT.strip_indent
        3 files inspected, no offenses detected
      OUTPUT
    end
  end
end
