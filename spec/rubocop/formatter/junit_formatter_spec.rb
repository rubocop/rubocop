# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::JUnitFormatter do
  subject(:formatter) { described_class.new(output) }

  let(:output) { StringIO.new }

  describe '#file_finished' do
    it 'displays parsable text' do
      cop = RuboCop::Cop::Cop.new
      source_buffer = Parser::Source::Buffer.new('test', 1)
      source_buffer.source = %w[foo bar baz].join("\n")

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

      formatter.file_finished('test_1', cop.offenses)
      formatter.file_finished('test_2', cop.offenses)

      formatter.finished(nil)

      expect(output.string).to eq(<<~XML.chop)
        <?xml version='1.0'?>
        <testsuites>
          <testsuite name='rubocop'>
            <testcase classname='test_1' name='Cop/Cop'>
              <failure type='Cop/Cop' message='message 1'>
                test:1:1
              </failure>
              <failure type='Cop/Cop' message='message 2'>
                test:3:2
              </failure>
            </testcase>
            <testcase classname='test_2' name='Cop/Cop'>
              <failure type='Cop/Cop' message='message 1'>
                test:1:1
              </failure>
              <failure type='Cop/Cop' message='message 2'>
                test:3:2
              </failure>
            </testcase>
          </testsuite>
        </testsuites>
      XML
    end
  end
end
