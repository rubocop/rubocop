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

    context 'when a offense is detected in a file' do
      let(:location) { double(line: 1, column: 5) }
      let(:offenses) { [RuboCop::Cop::Offense.new(:error, location, 'message', 'CopA')] }

      it 'calls the step function with a dot' do
        expect(formatter).to receive(:step).with(Rainbow(described_class::GHOST).red)
        next_step
      end
    end
  end

  describe '#update_progress_line' do
    subject(:update_progress_line) { formatter.update_progress_line }
    before do
      formatter.instance_variable_set(:@total_files, total_files)
      allow(formatter).to receive(:cols).and_return(cols)
    end
    context 'when total_files is greater than columns in the terminal' do
      let(:total_files) { 10 }
      let(:cols) { 2 }
      it 'updates the progress_line properly' do
        update_progress_line
        expect(formatter.progress_line).to eq('••')
      end

      context 'when need to change the line' do
        let(:total_files) { 18 }
        let(:cols) { 10 }
        before do
          formatter.instance_variable_set(:@repetitions, 1)
        end

        it 'updates the progress_line properly' do
          update_progress_line
          expect(formatter.progress_line).to eq('••••••••')
        end
      end
    end

    context 'when total_files less than columns in the terminal' do
      let(:total_files) { 10 }
      let(:cols) { 11 }
      it 'updates the progress_line properly' do
        update_progress_line
        expect(formatter.progress_line).to eq('••••••••••')
      end
    end
  end

  describe '#step' do
    subject(:step) { formatter.step(character) }
    before do
      formatter.instance_variable_set(:@progress_line, '..••')
    end

    context 'character is Pacman' do
      let(:character) { described_class::PACMAN }
      it 'removes the first • and puts a ᗧ' do
        step
        expect(formatter.progress_line).to eq('..ᗧ•')
      end
    end

    context 'character is a Pacdot' do
      let(:character) { described_class::PACDOT }
      it 'leaves the progress_line as it is' do
        step
        expect(formatter.progress_line).to eq('..••')
      end
    end

    context 'character is normal dot' do
      let(:character) { '.' }
      it 'removes the first • and puts a .' do
        step
        expect(formatter.progress_line).to eq('...•')
      end
    end

    context 'character is ghost' do
      let(:character) { Rainbow(described_class::GHOST).red }
      it 'removes the first • and puts a ghosts' do
        step
        expect(formatter.progress_line).to eq('..ᗣ•')
      end
    end
  end
end
