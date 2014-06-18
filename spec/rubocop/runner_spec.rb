# encoding: utf-8

require 'spec_helper'

module RuboCop
  class Runner
    attr_writer :errors # Needed only for testing.
  end
end

describe RuboCop::Runner do
  subject(:runner) { described_class.new(options) }
  let(:options) { {} }
  let(:offenses) { [] }
  let(:errors) { [] }

  before(:each) do
    $stdout = StringIO.new
    $stderr = StringIO.new

    allow(runner).to receive(:process_source) do
      [double('ProcessedSource').as_null_object, []]
    end

    allow(runner).to receive(:inspect_file) do
      runner.errors = errors
      [offenses, !:updated_source_file]
    end
  end

  after(:each) do
    $stdout = STDOUT
    $stderr = STDERR
  end

  describe '#run' do
    context 'if there are no offenses in inspected files' do
      it 'returns false' do
        result = runner.run(['file.rb'], nil) {}
        expect(result).to eq(false)
      end
    end

    context 'if there is an offense in an inspected file' do
      let(:offenses) do
        [RuboCop::Cop::Offense.new(:convention,
                                   Struct.new(:line, :column,
                                              :source_line).new(1, 0, ''),
                                   'Use alias_method instead of alias.',
                                   'Alias')]
      end

      it 'returns true' do
        expect(runner.run(['file.rb'], nil) {}).to eq(true)
      end

      it 'sends the offense to a formatter' do
        runner.run(['file.rb'], nil) {}
        expect($stdout.string.split("\n"))
          .to eq(['Inspecting 1 file',
                  'C',
                  '',
                  'Offenses:',
                  '',
                  "file.rb:1:1: C: #{offenses.first.message}",
                  '',
                  '1 file inspected, 1 offense detected'])
      end
    end
  end
end
