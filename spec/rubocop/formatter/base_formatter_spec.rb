# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::BaseFormatter do
  include_context 'cli spec behavior'

  describe 'how the API methods are invoked', :isolated_environment do
    subject(:formatter) { instance_double(described_class).as_null_object }

    let(:runner) { RuboCop::Runner.new({}, RuboCop::ConfigStore.new) }
    let(:output) { $stdout.string }

    before do
      create_file('1_offense.rb', '#' * 90)

      create_file('4_offenses.rb', ['puts x ', 'test;', 'top;', '#' * 90])

      create_file('no_offense.rb', '# frozen_string_literal: true')

      allow(RuboCop::Formatter::SimpleTextFormatter)
        .to receive(:new).and_return(formatter)
      # avoid intermittent failure caused when another test set global
      # options on ConfigLoader
      RuboCop::ConfigLoader.clear_options
    end

    def run
      runner.run([])
    end

    describe 'invocation order' do
      subject(:formatter) do
        formatter = instance_spy(described_class)
        %i[started file_started file_finished finished output]
          .each do |message|
          allow(formatter).to receive(message) do
            puts message.to_s unless message == :output
          end
        end
        formatter
      end

      it 'is called in the proper sequence' do
        run
        expect(output).to eq(<<-OUTPUT.strip_indent)
          started
          file_started
          file_finished
          file_started
          file_finished
          file_started
          file_finished
          finished
        OUTPUT
      end
    end

    shared_examples 'receives all file paths' do |method_name|
      before { run }

      it 'receives all file paths' do
        expected_paths = [
          '1_offense.rb',
          '4_offenses.rb',
          'no_offense.rb'
        ].map { |path| File.expand_path(path) }.sort

        expect(formatter).to have_received(method_name) do |all_files|
          expect(all_files.sort).to eq(expected_paths)
        end
      end

      describe 'the passed files paths' do
        it 'is frozen' do
          expect(formatter).to have_received(method_name) do |all_files|
            all_files.each do |path|
              expect(path.frozen?).to be(true)
            end
          end
        end
      end
    end

    describe '#started' do
      include_examples 'receives all file paths', :started
    end

    describe '#finished' do
      context 'when RuboCop finished inspecting all files normally' do
        include_examples 'receives all file paths', :started
      end

      context 'when RuboCop is interrupted by user' do
        it 'receives only processed file paths' do
          class << formatter
            attr_reader :processed_file_count

            def file_finished(_file, _offenses)
              @processed_file_count ||= 0
              @processed_file_count += 1
            end
          end

          allow(runner).to receive(:process_file)
            .and_wrap_original do |m, *args|
              raise Interrupt if formatter.processed_file_count == 2

              m.call(*args)
            end

          run

          expect(formatter).to have_received(:finished) do |processed_files|
            expect(processed_files.size).to eq(2)
          end
        end
      end
    end

    shared_examples 'receives a file path' do |method_name|
      before { run }

      it 'receives a file path' do
        expect(formatter).to have_received(method_name)
          .with(File.expand_path('1_offense.rb'), anything)

        expect(formatter).to have_received(method_name)
          .with(File.expand_path('4_offenses.rb'), anything)

        expect(formatter).to have_received(method_name)
          .with(File.expand_path('no_offense.rb'), anything)
      end

      describe 'the passed path' do
        it 'is frozen' do
          expect(formatter)
            .to have_received(method_name).exactly(3).times do |path|
            expect(path.frozen?).to be(true)
          end
        end
      end
    end

    describe '#file_started' do
      include_examples 'receives a file path', :file_started

      it 'receives file specific information hash' do
        expect(formatter).to have_received(:file_started)
          .with(anything, an_instance_of(Hash)).exactly(3).times
      end
    end

    describe '#file_finished' do
      include_examples 'receives a file path', :file_finished

      it 'receives an array of detected offenses for the file' do
        expect(formatter).to have_received(:file_finished)
          .exactly(3).times do |file, offenses|
          case File.basename(file)
          when '1_offense.rb'
            expect(offenses.size).to eq(1)
          when '4_offenses.rb'
            expect(offenses.size).to eq(4)
          when 'no_offense.rb'
            expect(offenses.empty?).to be(true)
          else
            raise
          end
          expect(offenses.all? { |o| o.is_a?(RuboCop::Cop::Offense) })
            .to be_truthy
        end
      end
    end
  end
end
