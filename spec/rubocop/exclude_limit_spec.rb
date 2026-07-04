# frozen_string_literal: true

RSpec.describe RuboCop::ExcludeLimit do
  describe '.read_limits' do
    around do |example|
      original = described_class.tmp_dir
      begin
        example.run
      ensure
        described_class.tmp_dir = original
      end
    end

    context 'when `tmp_dir` is not set' do
      before { described_class.tmp_dir = nil }

      it 'returns an empty hash' do
        expect(described_class.read_limits('Metrics/MethodLength')).to eq({})
      end
    end

    context 'when `tmp_dir` is set' do
      around do |example|
        Dir.mktmpdir('rubocop-exclude-limit') do |dir|
          described_class.tmp_dir = Pathname.new(dir)
          example.run
        end
      end

      it 'returns an empty hash when no values were written for the cop' do
        expect(described_class.read_limits('Metrics/MethodLength')).to eq({})
      end

      it 'ignores parameter files with no values' do
        cop_dir = described_class.cop_dir_for('Metrics/MethodLength')
        cop_dir.mkpath
        cop_dir.join('Max').write('')

        expect(described_class.read_limits('Metrics/MethodLength')).to eq({})
      end

      it 'returns the maximum of the written values for each parameter' do
        cop_dir = described_class.cop_dir_for('Metrics/MethodLength')
        cop_dir.mkpath
        cop_dir.join('Max').write("12\n81\n47\n")

        expect(described_class.read_limits('Metrics/MethodLength')).to eq('Max' => 81)
      end
    end
  end
end
