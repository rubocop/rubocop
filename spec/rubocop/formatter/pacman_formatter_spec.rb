# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::PacmanFormatter do
  subject(:formatter) { described_class.new(output) }

  let(:output) { StringIO.new }

  describe '#next_step' do
    subject(:next_step) { formatter.next_step(offenses) }

    context 'when no offenses are detected' do
      let(:offenses) { [] }

      it 'calls the step function with a dot' do
        expect(formatter).to receive(:step).with('.')
        next_step
      end
    end

    context 'when an offense is detected in a file' do
      let(:location) { FakeLocation.new(line: 1, column: 5) }
      let(:expected_character) { Rainbow(described_class::GHOST).red }
      let(:offenses) { [RuboCop::Cop::Offense.new(:error, location, 'message', 'CopA')] }

      it 'calls the step function with a dot' do
        expect(formatter).to receive(:step).with(expected_character)
        next_step
      end
    end
  end

  describe '#update_progress_line' do
    subject(:update_progress_line) { formatter.update_progress_line }

    before do
      formatter.instance_variable_set(:@total_files, files)
      allow(formatter).to receive(:cols).and_return(cols)
    end

    context 'when total_files is greater than columns in the terminal' do
      let(:files) { 10 }
      let(:cols) { 2 }

      it 'updates the progress_line properly' do
        update_progress_line
        expect(formatter.progress_line).to eq(described_class::PACDOT * cols)
      end

      context 'when need to change the line' do
        let(:files) { 18 }
        let(:cols) { 10 }

        before { formatter.instance_variable_set(:@repetitions, 1) }

        it 'updates the progress_line properly' do
          update_progress_line
          expect(formatter.progress_line).to eq(described_class::PACDOT * 8)
        end
      end
    end

    context 'when total_files less than columns in the terminal' do
      let(:files) { 10 }
      let(:cols) { 11 }

      it 'updates the progress_line properly' do
        update_progress_line
        expect(formatter.progress_line).to eq(described_class::PACDOT * files)
      end
    end
  end

  describe '#step' do
    subject(:step) { formatter.step(character) }

    let(:initial_progress_line) { format('..%s', described_class::PACDOT * 2) }

    before { formatter.instance_variable_set(:@progress_line, initial_progress_line) }

    context 'character is Pacman' do
      let(:character) { described_class::PACMAN }
      let(:expected_progress_line) { format('..%s%s', character, described_class::PACDOT) }

      it 'removes the first • and puts a ᗧ' do
        step
        expect(formatter.progress_line).to eq(expected_progress_line)
      end
    end

    context 'character is a Pacdot' do
      let(:character) { described_class::PACDOT }

      it 'leaves the progress_line as it is' do
        expect { step }.not_to change(formatter, :progress_line)
      end
    end

    context 'character is normal dot' do
      let(:character) { '.' }

      it 'removes the first • and puts a .' do
        step
        expect(formatter.progress_line).to eq("...#{described_class::PACDOT}")
      end
    end

    context 'character is ghost' do
      let(:character) { Rainbow(described_class::GHOST).red }
      let(:expected_progress_line) { format('..%s%s', character, described_class::PACDOT) }

      it 'removes the first • and puts a ghosts' do
        step
        expect(formatter.progress_line).to eq(expected_progress_line)
      end
    end
  end
end
