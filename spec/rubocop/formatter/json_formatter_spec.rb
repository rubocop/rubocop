# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::JSONFormatter do
  subject(:formatter) { described_class.new(output) }

  let(:output) { StringIO.new }
  let(:files) { %w[/path/to/file1 /path/to/file2] }
  let(:location) do
    source_buffer = Parser::Source::Buffer.new('test', 1)
    source_buffer.source = %w[a b cdefghi].join("\n")
    Parser::Source::Range.new(source_buffer, 2, 10)
  end
  let(:offense) do
    RuboCop::Cop::Offense.new(:convention, location,
                              'This is message', 'CopName', :corrected)
  end

  describe '#started' do
    let(:summary) { formatter.output_hash[:summary] }

    it 'sets target file count in summary' do
      expect(summary[:target_file_count].nil?).to be(true)
      formatter.started(%w[/path/to/file1 /path/to/file2])
      expect(summary[:target_file_count]).to eq(2)
    end
  end

  describe '#file_finished' do
    before do
      count = 0
      allow(formatter).to receive(:hash_for_file) do
        count += 1
      end
    end

    let(:summary) { formatter.output_hash[:summary] }

    it 'adds detected offense count in summary' do
      expect(summary[:offense_count]).to eq(0)

      formatter.file_started(files[0], {})
      expect(summary[:offense_count]).to eq(0)
      formatter.file_finished(files[0], [
                                double('offense1'), double('offense2')
                              ])
      expect(summary[:offense_count]).to eq(2)
    end

    it 'adds value of #hash_for_file to #output_hash[:files]' do
      expect(formatter.output_hash[:files].empty?).to be(true)

      formatter.file_started(files[0], {})
      expect(formatter.output_hash[:files].empty?).to be(true)
      formatter.file_finished(files[0], [])
      expect(formatter.output_hash[:files]).to eq([1])

      formatter.file_started(files[1], {})
      expect(formatter.output_hash[:files]).to eq([1])
      formatter.file_finished(files[1], [])
      expect(formatter.output_hash[:files]).to eq([1, 2])
    end
  end

  describe '#finished' do
    let(:summary) { formatter.output_hash[:summary] }

    it 'sets inspected file count in summary' do
      expect(summary[:inspected_file_count].nil?).to be(true)
      formatter.finished(%w[/path/to/file1 /path/to/file2])
      expect(summary[:inspected_file_count]).to eq(2)
    end

    it 'outputs #output_hash as JSON' do
      formatter.finished(files)
      json = output.string
      restored_hash = JSON.parse(json, symbolize_names: true)
      expect(restored_hash).to eq(formatter.output_hash)
    end
  end

  describe '#hash_for_file' do
    subject(:hash) { formatter.hash_for_file(file, offenses) }

    let(:file) { File.expand_path('spec/spec_helper.rb') }
    let(:offenses) { [double('offense1'), double('offense2')] }

    it 'sets relative file path for :path key' do
      expect(hash[:path]).to eq('spec/spec_helper.rb')
    end

    before do
      count = 0
      allow(formatter).to receive(:hash_for_offense) do
        count += 1
      end
    end

    it 'sets an array of #hash_for_offense values for :offenses key' do
      expect(hash[:offenses]).to eq([1, 2])
    end
  end

  describe '#hash_for_offense' do
    subject(:hash) { formatter.hash_for_offense(offense) }

    it 'sets Offense#severity value for :severity key' do
      expect(hash[:severity]).to eq(:convention)
    end

    it 'sets Offense#message value for :message key' do
      expect(hash[:message]).to eq('This is message')
    end

    it 'sets Offense#cop_name value for :cop_name key' do
      expect(hash[:cop_name]).to eq('CopName')
    end

    it 'sets Offense#corrected? value for :corrected key' do
      expect(hash[:corrected]).to be_truthy
    end

    it 'sets value of #hash_for_location for :location key' do
      location_hash = {
        start_line: 2,
        start_column: 1,
        last_line: 3,
        last_column: 6,
        length: 8,
        line: 2,
        column: 1
      }
      expect(hash[:location]).to eq(location_hash)
    end
  end

  describe '#hash_for_location' do
    subject(:hash) { formatter.hash_for_location(offense) }

    it 'sets line value for :line key' do
      expect(hash[:line]).to eq(2)
    end

    it 'sets column value for :column key' do
      expect(hash[:column]).to eq(1)
    end

    it 'sets length value for :length key' do
      expect(hash[:length]).to eq(8)
    end
  end
end
