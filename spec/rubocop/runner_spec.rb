# encoding: utf-8

require 'spec_helper'

module RuboCop
  class Runner
    attr_writer :errors # Needed only for testing.
  end
end

describe RuboCop::Runner, :isolated_environment do
  include FileHelper

  subject(:runner) { described_class.new(options, RuboCop::ConfigStore.new) }
  let(:options) { { formatters: [['progress', formatter_output_path]] } }
  let(:formatter_output_path) { 'formatter_output.txt' }
  let(:formatter_output) { File.read(formatter_output_path) }

  before do
    create_file('example.rb', source)
  end

  describe '#run' do
    context 'if there are no offenses in inspected files' do
      let(:source) { <<-END.strip_indent }
        # coding: utf-8
        def valid_code
        end
      END

      it 'returns true' do
        expect(runner.run([])).to be true
      end
    end

    context 'if there is an offense in an inspected file' do
      let(:source) { <<-END.strip_indent }
        # coding: utf-8
        def INVALID_CODE
        end
      END

      it 'returns false' do
        expect(runner.run([])).to be false
      end

      it 'sends the offense to a formatter' do
        runner.run([])
        expect(formatter_output).to eq <<-END.strip_indent
          Inspecting 1 file
          C

          Offenses:

          example.rb:2:5: C: Use snake_case for method names.
          def INVALID_CODE
              ^^^^^^^^^^^^

          1 file inspected, 1 offense detected
        END
      end
    end
  end
end
