# frozen_string_literal: true

RSpec.describe RuboCop::Runner, :isolated_environment do
  describe 'how formatter is invoked' do
    subject(:runner) { described_class.new({}, RuboCop::ConfigStore.new) }

    include_context 'cli spec behavior'

    let(:formatter) { instance_double(RuboCop::Formatter::BaseFormatter).as_null_object }
    let(:output) { $stdout.string }

    before do
      create_file('2_offense.rb', '#' * 130)
      create_file('5_offenses.rb', ['puts x ', 'test;', 'top;', '#' * 130])
      create_file('no_offense.rb', '# frozen_string_literal: true')

      allow(RuboCop::Formatter::SimpleTextFormatter).to receive(:new).and_return(formatter)
      # avoid intermittent failure caused when another test set global
      # options on ConfigLoader
      RuboCop::ConfigLoader.clear_options
    end

    def run
      runner.run([])
    end

    describe 'invocation order' do
      let(:formatter) do
        formatter = instance_spy(RuboCop::Formatter::BaseFormatter)
        %i[started file_started file_finished finished output]
          .each do |message|
          allow(formatter).to receive(message) do
            puts message unless message == :output
          end
        end
        formatter
      end

      it 'is called in the proper sequence' do
        run
        expect(output).to eq(<<~OUTPUT)
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

    shared_examples 'sends all file paths' do |method_name|
      it 'sends all file paths' do
        expected_paths = [
          '2_offense.rb',
          '5_offenses.rb',
          'no_offense.rb'
        ].map { |path| File.expand_path(path) }.sort

        expect(formatter).to receive(method_name) do |all_files|
          expect(all_files.sort).to eq(expected_paths)
        end

        run
      end

      describe 'the passed files paths' do
        it 'is frozen' do
          expect(formatter).to receive(method_name) do |all_files|
            all_files.each { |path| expect(path.frozen?).to be(true) }
          end

          run
        end
      end
    end

    describe '#started' do
      include_examples 'sends all file paths', :started
    end

    describe '#finished' do
      context 'when RuboCop finished inspecting all files normally' do
        include_examples 'sends all file paths', :started
      end

      context 'when RuboCop is interrupted by user' do
        it 'sends only processed file paths' do
          class << formatter
            attr_reader :reported_file_count

            def file_finished(_file, _offenses)
              @reported_file_count ||= 0
              @reported_file_count += 1
            end
          end

          class << runner
            attr_reader :processed_file_count

            def process_file(_file)
              raise Interrupt if processed_file_count == 2

              @processed_file_count ||= 0
              @processed_file_count += 1

              super
            end
          end

          run

          expect(formatter.reported_file_count).to eq(2)
        end
      end
    end

    shared_examples 'sends a file path' do |method_name|
      it 'sends a file path' do
        expect(formatter).to receive(method_name).with(File.expand_path('2_offense.rb'), anything)

        expect(formatter).to receive(method_name).with(File.expand_path('5_offenses.rb'), anything)

        expect(formatter).to receive(method_name).with(File.expand_path('no_offense.rb'), anything)

        run
      end

      describe 'the passed path' do
        it 'is frozen' do
          expect(formatter).to receive(method_name).exactly(3).times do |path|
            expect(path.frozen?).to be(true)
          end

          run
        end
      end
    end

    describe '#file_started' do
      include_examples 'sends a file path', :file_started

      it 'sends file specific information hash' do
        expect(formatter).to receive(:file_started)
          .with(anything, an_instance_of(Hash)).exactly(3).times

        run
      end
    end

    describe '#file_finished' do
      include_examples 'sends a file path', :file_finished

      it 'sends an array of detected offenses for the file' do
        expect(formatter).to receive(:file_finished).exactly(3).times do |file, offenses|
          case File.basename(file)
          when '2_offense.rb'
            expect(offenses.size).to eq(2)
          when '5_offenses.rb'
            expect(offenses.size).to eq(5)
          when 'no_offense.rb'
            expect(offenses.empty?).to be(true)
          else
            raise
          end
          expect(offenses).to all be_a(RuboCop::Cop::Offense)
        end

        run
      end
    end
  end
end
