# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::FileListFormatter do
  subject(:formatter) { described_class.new(output) }

  let(:output) { StringIO.new }

  describe '#file_finished' do
    it 'displays parsable text' do
      cop = RuboCop::Cop::Cop.new
      source_buffer = Parser::Source::Buffer.new('test', 1)
      source_buffer.source = %w[a b cdefghi].join("\n")

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
      formatter.file_finished('test_2', cop.offenses)
      expect(output.string).to eq "test\ntest_2\n"
    end
  end
end
