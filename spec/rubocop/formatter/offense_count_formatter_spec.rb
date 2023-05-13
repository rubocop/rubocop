# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::OffenseCountFormatter do
  subject(:formatter) { described_class.new(output, options) }

  let(:output) { StringIO.new }
  let(:options) { { display_style_guide: false } }

  let(:files) do
    %w[lib/rubocop.rb spec/spec_helper.rb exe/rubocop].map do |path|
      File.expand_path(path)
    end
  end

  let(:finish) { files.each { |file| formatter.file_finished(file, offenses) } }

  describe '#file_finished' do
    before { formatter.started(files) }

    context 'when no offenses are detected' do
      let(:offenses) { [] }

      it 'does not add to offense_counts' do
        expect { finish }.not_to change(formatter, :offense_counts)
      end
    end

    context 'when any offenses are detected' do
      let(:offenses) { [instance_double(RuboCop::Cop::Offense, cop_name: 'OffendedCop')] }

      before { offenses.each { |o| allow(o).to receive(:message).and_return('') } }

      it 'increments the count for the cop in offense_counts' do
        expect { finish }.to change(formatter, :offense_counts)
      end
    end
  end

  describe '#report_summary' do
    context 'when an offense is detected' do
      let(:cop_counts) { { 'OffendedCop' => 3 } }

      before { formatter.started(files) }

      it 'shows the cop and the offense count' do
        formatter.report_summary(cop_counts, 2)
        expect(output.string.include?(<<~OUTPUT)).to be(true)
          3  OffendedCop
          --
          3  Total in 2 files
        OUTPUT
      end
    end
  end

  describe '#finished' do
    context 'when there are many offenses' do
      let(:files) { super().take(1) }

      let(:offenses) do
        %w[CopB CopA CopC CopC].map do |cop|
          instance_double(RuboCop::Cop::Offense, cop_name: cop)
        end
      end

      before do
        allow(output).to receive(:tty?).and_return(false)
        formatter.started(files)
        offenses.each do |o|
          allow(o).to receive(:message)
            .and_return(format('Unwanted. (https://rubystyle.guide#no-good-%s)', o.cop_name))
        end
        finish
      end

      context 'when --display-style-guide was not given' do
        it 'sorts by offense count first and then by cop name' do
          formatter.finished(files)
          expect(output.string).to eq(<<~OUTPUT)

            2  CopC
            1  CopA
            1  CopB
            --
            4  Total in 1 files

          OUTPUT
        end
      end

      context 'when --display-style-guide was given' do
        let(:options) { { display_style_guide: true } }

        it 'shows links and sorts by offense count first and then by cop name' do
          formatter.finished(files)
          expect(output.string).to eq(<<~OUTPUT)

            2  CopC (https://rubystyle.guide#no-good-CopC)
            1  CopA (https://rubystyle.guide#no-good-CopA)
            1  CopB (https://rubystyle.guide#no-good-CopB)
            --
            4  Total in 1 files

          OUTPUT
        end
      end
    end

    context 'when output tty is true' do
      let(:offenses) do
        %w[CopB CopA CopC CopC].map do |cop|
          instance_double(RuboCop::Cop::Offense, cop_name: cop)
        end
      end

      before do
        allow(output).to receive(:tty?).and_return(true)
        offenses.each { |o| allow(o).to receive(:message).and_return('') }
        formatter.started(files)
        finish
      end

      it 'has a progress bar' do
        formatter.finished(files)
        expect(formatter.instance_variable_get(:@progressbar).progress).to eq 3
      end
    end
  end
end
