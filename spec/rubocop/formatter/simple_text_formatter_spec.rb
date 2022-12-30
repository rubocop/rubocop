# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::SimpleTextFormatter do
  subject(:formatter) { described_class.new(output) }

  before { Rainbow.enabled = true }

  after { Rainbow.enabled = false }

  let(:output) { StringIO.new }

  shared_examples 'report for severity' do |severity|
    let(:offense) do
      RuboCop::Cop::Offense.new(severity, location,
                                'This is a message with `colored text`.',
                                'CopName', status)
    end

    context 'the file is under the current working directory' do
      let(:file) { File.expand_path('spec/spec_helper.rb') }

      it 'prints as relative path' do
        expect(output.string.include?('== spec/spec_helper.rb ==')).to be(true)
      end
    end

    context 'the file is outside of the current working directory' do
      let(:file) do
        tempfile = Tempfile.new('')
        tempfile.close
        File.expand_path(tempfile.path)
      end

      it 'prints as absolute path' do
        expect(output.string.include?("== #{file} ==")).to be(true)
      end
    end

    context 'when the offense is not corrected' do
      let(:status) { :unsupported }

      it 'prints message as-is' do
        expect(output.string.include?(': This is a message with colored text.')).to be(true)
      end
    end

    context 'when the offense is correctable' do
      let(:status) { :uncorrected }

      it 'prints message as-is' do
        expect(output.string.include?(': [Correctable] This is a message with colored text.'))
          .to be(true)
      end
    end

    context 'when the offense is automatically corrected' do
      let(:status) { :corrected }

      it 'prints [Corrected] along with message' do
        expect(output.string.include?(': [Corrected] This is a message with colored text.'))
          .to be(true)
      end
    end

    context 'when the offense is marked as todo' do
      let(:status) { :corrected_with_todo }

      it 'prints [Todo] along with message' do
        expect(output.string.include?(': [Todo] This is a message with colored text.')).to be(true)
      end
    end
  end

  describe '#report_file' do
    before { formatter.report_file(file, [offense]) }

    let(:file) { '/path/to/file' }

    let(:location) do
      source_buffer = Parser::Source::Buffer.new('test', 1)
      source_buffer.source = "a\n"
      Parser::Source::Range.new(source_buffer, 0, 1)
    end

    let(:status) { :uncorrected }

    it_behaves_like 'report for severity', :info
    it_behaves_like 'report for severity', :refactor
    it_behaves_like 'report for severity', :convention
    it_behaves_like 'report for severity', :warning
    it_behaves_like 'report for severity', :error
    it_behaves_like 'report for severity', :fatal
  end

  describe '#report_summary' do
    context 'when no files inspected' do
      it 'handles pluralization correctly' do
        formatter.report_summary(0, 0, 0, 0)
        expect(output.string).to eq(<<~OUTPUT)

          0 files inspected, no offenses detected
        OUTPUT
      end
    end

    context 'when a file inspected and no offenses detected' do
      it 'handles pluralization correctly' do
        formatter.report_summary(1, 0, 0, 0)
        expect(output.string).to eq(<<~OUTPUT)

          1 file inspected, no offenses detected
        OUTPUT
      end
    end

    context 'when an offense detected' do
      it 'handles pluralization correctly' do
        formatter.report_summary(1, 1, 0, 0)
        expect(output.string).to eq(<<~OUTPUT)

          1 file inspected, 1 offense detected
        OUTPUT
      end
    end

    context 'when an offense detected and an offense autocorrectable' do
      it 'handles pluralization correctly' do
        formatter.report_summary(1, 1, 0, 1)
        expect(output.string).to eq(<<~OUTPUT)

          1 file inspected, 1 offense detected, 1 offense autocorrectable
        OUTPUT
      end
    end

    context 'when 2 offenses detected' do
      it 'handles pluralization correctly' do
        formatter.report_summary(2, 2, 0, 0)
        expect(output.string).to eq(<<~OUTPUT)

          2 files inspected, 2 offenses detected
        OUTPUT
      end
    end

    context 'when 2 offenses detected and 2 offenses autocorrectable' do
      it 'handles pluralization correctly' do
        formatter.report_summary(2, 2, 0, 2)
        expect(output.string).to eq(<<~OUTPUT)

          2 files inspected, 2 offenses detected, 2 offenses autocorrectable
        OUTPUT
      end
    end

    context 'when an offense is corrected' do
      it 'prints about correction' do
        formatter.report_summary(1, 1, 1, 0)
        expect(output.string).to eq(<<~OUTPUT)

          1 file inspected, 1 offense detected, 1 offense corrected
        OUTPUT
      end
    end

    context 'when 2 offenses are corrected' do
      it 'handles pluralization correctly' do
        formatter.report_summary(1, 1, 2, 0)
        expect(output.string).to eq(<<~OUTPUT)

          1 file inspected, 1 offense detected, 2 offenses corrected
        OUTPUT
      end
    end

    context 'when 2 offenses are corrected and 2 offenses autocorrectable' do
      it 'handles pluralization correctly' do
        formatter.report_summary(1, 1, 2, 2)
        expect(output.string).to eq(<<~OUTPUT)

          1 file inspected, 1 offense detected, 2 offenses corrected, 2 offenses autocorrectable
        OUTPUT
      end
    end
  end
end
