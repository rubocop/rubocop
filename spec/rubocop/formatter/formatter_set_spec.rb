# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::FormatterSet do
  subject(:formatter_set) { described_class.new }

  win_close = lambda do |fset|
    fset.close_output_files
    fset.each { |f| f.instance_variable_set :@output, nil }
  end

  it 'responds to all formatter API methods' do
    %i[started file_started file_finished finished].each do |method|
      expect(formatter_set.respond_to?(method)).to be(true)
    end
  end

  describe 'formatter API method' do
    let(:files) { ['/path/to/file1', '/path/to/file2'] }

    it 'invokes the same method of all containing formatters' do
      formatter_set.add_formatter('simple')
      formatter_set.add_formatter('emacs')
      expect(formatter_set[0]).to receive(:started).with(files)
      expect(formatter_set[1]).to receive(:started).with(files)
      formatter_set.started(files)
    end
  end

  describe 'add_formatter' do
    it 'adds a formatter to itself' do
      formatter_set.add_formatter('simple')
      expect(formatter_set.size).to eq(1)
    end

    it 'adds a formatter with specified formatter type' do
      formatter_set.add_formatter('simple')
      expect(formatter_set.first.class).to eq(RuboCop::Formatter::SimpleTextFormatter)
    end

    it 'can add multiple formatters by being invoked multiple times' do
      formatter_set.add_formatter('simple')
      formatter_set.add_formatter('emacs')
      expect(formatter_set[0].class).to eq(RuboCop::Formatter::SimpleTextFormatter)
      expect(formatter_set[1].class).to eq(RuboCop::Formatter::EmacsStyleFormatter)
    end

    context 'when output path is omitted' do
      it 'adds a formatter outputs to $stdout' do
        formatter_set.add_formatter('simple')
        expect(formatter_set.first.output).to eq($stdout)
      end
    end

    context 'when output path is specified' do
      it 'adds a formatter outputs to the specified file' do
        output_path = Tempfile.new('').path
        formatter_set.add_formatter('simple', output_path)
        expect(formatter_set.first.output.class).to eq(File)
        expect(formatter_set.first.output.path).to eq(output_path)
        win_close.call(formatter_set) if RuboCop::Platform.windows?
      end

      context "when parent directories don't exist" do
        let(:tmpdir) { Dir.mktmpdir }

        after { FileUtils.rm_rf(tmpdir) }

        it 'creates them' do
          output_path = File.join(tmpdir, 'path/does/not/exist')
          formatter_set.add_formatter('simple', output_path)
          expect(formatter_set.first.output.class).to eq(File)
          expect(formatter_set.first.output.path).to eq(output_path)
          win_close.call(formatter_set) if RuboCop::Platform.windows?
        end
      end
    end
  end

  describe '#close_output_files' do
    before do
      2.times do
        output_path = Tempfile.new('').path
        formatter_set.add_formatter('simple', output_path)
      end
      formatter_set.add_formatter('simple')
    end

    around do |example|
      $stdout = StringIO.new
      example.run
    ensure
      $stdout = STDOUT
    end

    it 'closes all output files' do
      formatter_set.close_output_files
      formatter_set[0..1].each { |formatter| expect(formatter.output.closed?).to be(true) }
      win_close.call(formatter_set) if RuboCop::Platform.windows?
    end

    it 'does not close non file output' do
      expect(formatter_set[2].output.closed?).to be(false)
      win_close.call(formatter_set) if RuboCop::Platform.windows?
    end
  end

  describe '#builtin_formatter_class' do
    def builtin_formatter_class(string)
      described_class.new.send(:builtin_formatter_class, string)
    end

    it 'returns class which matches passed alias name exactly' do
      expect(builtin_formatter_class('simple')).to eq(RuboCop::Formatter::SimpleTextFormatter)
    end

    it 'returns class which matches double character alias name' do
      expect(builtin_formatter_class('pa')).to eq(RuboCop::Formatter::PacmanFormatter)
    end

    it 'returns class which matches single character alias name' do
      expect(builtin_formatter_class('p')).to eq(RuboCop::Formatter::ProgressFormatter)
    end
  end

  describe '#custom_formatter_class' do
    def custom_formatter_class(string)
      described_class.new.send(:custom_formatter_class, string)
    end

    it 'returns constant represented by the passed string' do
      expect(custom_formatter_class('RuboCop')).to eq(RuboCop)
    end

    it 'can handle namespaced constant name' do
      expect(custom_formatter_class('RuboCop::CLI')).to eq(RuboCop::CLI)
    end

    it 'can handle top level namespaced constant name' do
      expect(custom_formatter_class('::RuboCop::CLI')).to eq(RuboCop::CLI)
    end

    context 'when non-existent constant name is passed' do
      it 'raises error' do
        expect { custom_formatter_class('RuboCop::NonExistentClass') }.to raise_error(NameError)
      end
    end
  end
end
