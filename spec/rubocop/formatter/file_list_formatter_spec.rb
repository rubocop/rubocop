# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::FileListFormatter, :config do
  subject(:formatter) { described_class.new(output) }

  let(:output) { StringIO.new }
  let(:cop_class) { RuboCop::Cop::Base }
  let(:source) { %w[a b cdefghi].join("\n") }

  before { cop.send(:begin_investigation, processed_source) }

  describe '#file_finished' do
    it 'displays parsable text' do
      cop.add_offense(Parser::Source::Range.new(source_buffer, 0, 1), message: 'message 1')
      offenses = cop.add_offense(
        Parser::Source::Range.new(source_buffer, 9, 10), message: 'message 2'
      )

      formatter.file_finished('test', offenses)
      formatter.file_finished('test_2', offenses)
      expect(output.string).to eq "test\ntest_2\n"
    end
  end
end
