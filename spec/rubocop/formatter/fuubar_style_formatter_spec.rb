# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::FuubarStyleFormatter do
  subject(:formatter) { described_class.new(output) }

  let(:output) { StringIO.new }

  let(:files) { %w[lib/rubocop.rb spec/spec_helper.rb].map { |path| File.expand_path(path) } }

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
      before { formatter.rainbow.enabled = true }

      it 'outputs coloring sequence code at the beginning and the end' do
        formatter.with_color { formatter.output.write 'foo' }
        expect(output.string).to eq("\e[32mfoo\e[0m")
      end
    end

    context 'when color is disabled' do
      before { formatter.rainbow.enabled = false }

      it 'outputs nothing' do
        formatter.with_color { formatter.output.write 'foo' }
        expect(output.string).to eq('foo')
      end
    end
  end

  describe '#progressbar_color' do
    before { formatter.started(files) }

    def offense(severity, status = :uncorrected)
      source_buffer = Parser::Source::Buffer.new('test', 1)
      source = Array.new(9) { |index| "This is line #{index + 1}." }
      source_buffer.source = source.join("\n")
      line_length = source[0].length + 1

      source_range = Parser::Source::Range.new(source_buffer, line_length + 2, line_length + 3)

      RuboCop::Cop::Offense.new(severity, source_range, 'message', 'Cop', status)
    end

    context 'initially' do
      it 'is green' do
        expect(formatter.progressbar_color).to eq(:green)
      end
    end

    context 'when no offenses are detected in a file' do
      before { formatter.file_finished(files[0], []) }

      it 'is still green' do
        expect(formatter.progressbar_color).to eq(:green)
      end
    end

    context 'when a convention offense is detected in a file' do
      before { formatter.file_finished(files[0], [offense(:convention)]) }

      it 'is yellow' do
        expect(formatter.progressbar_color).to eq(:yellow)
      end
    end

    context 'when an error offense is detected in a file' do
      before { formatter.file_finished(files[0], [offense(:error)]) }

      it 'is red' do
        expect(formatter.progressbar_color).to eq(:red)
      end

      context 'and then a convention offense is detected in the next file' do
        before { formatter.file_finished(files[1], [offense(:convention)]) }

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

    context 'when an offense is detected in a file and autocorrected' do
      before { formatter.file_finished(files[0], [offense(:convention, :corrected)]) }

      it 'is green' do
        expect(formatter.progressbar_color).to eq(:green)
      end
    end
  end
end
