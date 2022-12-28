# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::ProgressFormatter do
  subject(:formatter) { described_class.new(output) }

  let(:output) { StringIO.new }

  let(:files) do
    %w[lib/rubocop.rb spec/spec_helper.rb exe/rubocop].map do |path|
      File.expand_path(path)
    end
  end

  describe '#file_finished' do
    before do
      formatter.started(files)
      formatter.file_started(files.first, {})
    end

    shared_examples 'calls #report_file_as_mark' do
      it 'calls #report_as_with_mark' do
        expect(formatter).to receive(:report_file_as_mark)

        formatter.file_finished(files.first, offenses)
      end
    end

    context 'when no offenses are detected' do
      let(:offenses) { [] }

      include_examples 'calls #report_file_as_mark'
    end

    context 'when any offenses are detected' do
      let(:offenses) { [instance_double(RuboCop::Cop::Offense).as_null_object] }

      include_examples 'calls #report_file_as_mark'
    end
  end

  describe '#report_file_as_mark' do
    before { formatter.report_file_as_mark(offenses) }

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
      let(:offenses) { [offense_with_severity(:refactor), offense_with_severity(:error)] }

      it 'prints highest level mark' do
        expect(output.string).to eq('E')
      end
    end
  end

  describe '#finished' do
    before { formatter.started(files) }

    context 'when any offenses are detected' do
      before do
        source_buffer = Parser::Source::Buffer.new('test', 1)
        source = Array.new(9) { |index| "This is line #{index + 1}." }
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

        formatter.file_started(files[1], {})
        formatter.file_finished(files[1], [])

        formatter.file_started(files[2], {})
        formatter.file_finished(
          files[2],
          [
            RuboCop::Cop::Offense.new(
              :error,
              Parser::Source::Range.new(source_buffer,
                                        (line_length * 4) + 1,
                                        (line_length * 4) + 2),
              'bar',
              'Cop'
            ),
            RuboCop::Cop::Offense.new(
              :convention,
              Parser::Source::Range.new(source_buffer,
                                        line_length * 5,
                                        (line_length * 5) + 1),
              'foo',
              'Cop'
            )
          ]
        )
      end

      it 'reports all detected offenses for all failed files' do
        formatter.finished(files)
        expect(output.string).to include(<<~OUTPUT)
          Offenses:

          lib/rubocop.rb:2:3: C: [Correctable] foo
          This is line 2.
            ^
          exe/rubocop:5:2: E: [Correctable] bar
          This is line 5.
           ^
          exe/rubocop:6:1: C: [Correctable] foo
          This is line 6.
          ^
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
      expect(formatter).to receive(:report_summary)

      formatter.finished(files)
    end
  end
end
