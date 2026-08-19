# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::JUnitFormatter, :config do
  subject(:formatter) { described_class.new(output) }

  let(:output) { StringIO.new }
  let(:cop_class) { RuboCop::Cop::Layout::SpaceInsideBlockBraces }
  let(:source) { %w[foo bar baz].join("\n") }

  before { cop.send(:begin_investigation, processed_source) }

  describe '#file_finished' do
    let(:offenses) do
      cop.add_offense(Parser::Source::Range.new(source_buffer, 0, 1), message: 'message 1')
      cop.add_offense(Parser::Source::Range.new(source_buffer, 9, 10), message: 'message 2')
    end

    context 'when `file_started` has not been called' do
      before do
        formatter.file_finished('test_1', offenses)
        formatter.file_finished('test_2', offenses)

        formatter.finished(nil)
      end

      it 'displays start of parsable text' do
        expect(output.string).to start_with(<<~XML)
          <?xml version='1.0'?>
          <testsuites>
            <testsuite name='rubocop' tests='2' failures='4'>
        XML
      end

      it 'displays end of parsable text' do
        expect(output.string).to end_with(<<~XML)
            </testsuite>
          </testsuites>
        XML
      end

      it "displays an offense for `classname='test_1'` in parsable text" do
        expect(output.string).to include(<<-XML)
    <testcase classname='test_1' name='Layout/SpaceInsideBlockBraces'>
      <failure type='Layout/SpaceInsideBlockBraces' message='message 1'>
        test:1:1
      </failure>
      <failure type='Layout/SpaceInsideBlockBraces' message='message 2'>
        test:3:2
      </failure>
    </testcase>
        XML
      end

      it "displays an offense for `classname='test_2'` in parsable text" do
        expect(output.string).to include(<<-XML)
    <testcase classname='test_2' name='Layout/SpaceInsideBlockBraces'>
      <failure type='Layout/SpaceInsideBlockBraces' message='message 1'>
        test:1:1
      </failure>
      <failure type='Layout/SpaceInsideBlockBraces' message='message 2'>
        test:3:2
      </failure>
    </testcase>
        XML
      end

      it 'displays a non-offense element in parsable text' do
        expect(output.string).to include(<<~XML)
          <testcase classname='test_1' name='Style/Alias'/>
        XML
      end
    end

    context 'when `file_started` is called with a config store' do
      let(:junit_config) do
        RuboCop::ConfigLoader.merge_with_default(
          RuboCop::Config.new('Style/Alias' => { 'Enabled' => false }), ''
        )
      end
      let(:config_store) { instance_double(RuboCop::ConfigStore, for_file: junit_config) }

      before do
        %w[test_1 test_2].each do |file|
          formatter.file_started(file, config_store: config_store)
          formatter.file_finished(file, offenses)
        end

        formatter.finished(nil)
      end

      it 'displays start of parsable text' do
        expect(output.string).to start_with(<<~XML)
          <?xml version='1.0'?>
          <testsuites>
            <testsuite name='rubocop' tests='2' failures='4'>
        XML
      end

      it "displays an offense for `classname='test_1'` in parsable text" do
        expect(output.string).to include(<<-XML)
    <testcase classname='test_1' name='Layout/SpaceInsideBlockBraces'>
      <failure type='Layout/SpaceInsideBlockBraces' message='message 1'>
        test:1:1
      </failure>
      <failure type='Layout/SpaceInsideBlockBraces' message='message 2'>
        test:3:2
      </failure>
    </testcase>
        XML
      end

      it 'displays a non-offense element for an enabled cop in parsable text' do
        expect(output.string).to include(<<~XML)
          <testcase classname='test_1' name='Style/AndOr'/>
        XML
      end

      it 'does not display an element for a disabled cop' do
        expect(output.string).not_to include("name='Style/Alias'")
      end

      context 'and the `only` option is given' do
        subject(:formatter) { described_class.new(output, only: ['Layout']) }

        it 'displays elements only for cops in the given department' do
          expect(output.string).to include("name='Layout/SpaceInsideBlockBraces'")
          expect(output.string).not_to include("name='Style/")
        end
      end

      context 'and the `except` option is given' do
        subject(:formatter) { described_class.new(output, except: ['Style/AndOr']) }

        it 'does not display an element for the excepted cop' do
          expect(output.string).to include(<<~XML)
            <testcase classname='test_1' name='Style/YodaCondition'/>
          XML
          expect(output.string).not_to include("name='Style/AndOr'")
        end
      end
    end
  end
end
