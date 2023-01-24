# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::EmacsStyleFormatter, :config do
  subject(:formatter) { described_class.new(output) }

  let(:cop_class) { RuboCop::Cop::Cop }
  let(:source) { %w[a b cdefghi].join("\n") }
  let(:output) { StringIO.new }

  before { cop.send(:begin_investigation, processed_source) }

  describe '#file_finished' do
    it 'displays parsable text' do
      cop.add_offense(
        nil,
        location: Parser::Source::Range.new(source_buffer, 0, 1),
        message: 'message 1'
      )
      cop.add_offense(
        nil,
        location: Parser::Source::Range.new(source_buffer, 9, 10),
        message: 'message 2'
      )

      formatter.file_finished('test', cop.offenses)
      expect(output.string).to eq <<~OUTPUT
        test:1:1: C: message 1
        test:3:6: C: message 2
      OUTPUT
    end

    context 'when the offense is automatically corrected' do
      let(:file) { '/path/to/file' }

      let(:offense) do
        RuboCop::Cop::Offense.new(:convention, location, 'This is a message.', 'CopName', status)
      end

      let(:location) do
        source_buffer = Parser::Source::Buffer.new('test', 1)
        source_buffer.source = "a\n"
        Parser::Source::Range.new(source_buffer, 0, 1)
      end

      let(:status) { :corrected }

      it 'prints [Corrected] along with message' do
        formatter.file_finished(file, [offense])
        expect(output.string.include?(': [Corrected] This is a message.')).to be(true)
      end
    end

    context 'when the offense is marked as todo' do
      let(:file) { '/path/to/file' }

      let(:offense) do
        RuboCop::Cop::Offense.new(:convention, location, 'This is a message.', 'CopName', status)
      end

      let(:location) do
        source_buffer = Parser::Source::Buffer.new('test', 1)
        source_buffer.source = "a\n"
        Parser::Source::Range.new(source_buffer, 0, 1)
      end

      let(:status) { :corrected_with_todo }

      it 'prints [Todo] along with message' do
        formatter.file_finished(file, [offense])
        expect(output.string.include?(': [Todo] This is a message.')).to be(true)
      end
    end

    context 'when the offense message contains a newline' do
      let(:file) { '/path/to/file' }

      let(:offense) do
        RuboCop::Cop::Offense.new(:error, location,
                                  "unmatched close parenthesis: /\n   world " \
                                  "# Some comment containing a )\n/",
                                  'CopName', :uncorrected)
      end

      let(:location) do
        source_buffer = Parser::Source::Buffer.new('test', 1)
        source_buffer.source = "a\n"
        Parser::Source::Range.new(source_buffer, 0, 1)
      end

      it 'strips newlines out of the error message' do
        formatter.file_finished(file, [offense])
        expect(output.string).to eq(
          '/path/to/file:1:1: E: [Correctable] unmatched close parenthesis: /    ' \
          "world # Some comment containing a ) /\n"
        )
      end
    end
  end

  describe '#finished' do
    it 'does not report summary' do
      formatter.finished(['/path/to/file'])
      expect(output.string.empty?).to be(true)
    end
  end
end
