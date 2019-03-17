# frozen_string_literal: true

module RuboCop
  class Runner
    attr_writer :errors # Needed only for testing.
  end
end

RSpec.describe RuboCop::Runner, :isolated_environment do
  include FileHelper

  let(:formatter_output_path) { 'formatter_output.txt' }
  let(:formatter_output) { File.read(formatter_output_path) }

  context '#run when interrupted' do
    include_context 'cli spec behavior'

    let(:runner) { described_class.new({}, RuboCop::ConfigStore.new) }

    before do
      create_empty_file('example.rb')
    end

    def interrupt(pid)
      Process.kill 'INT', pid
    end

    def wait_for_input(io)
      line = nil

      until line
        line = io.gets
        sleep 0.1
      end

      line
    end

    around do |example|
      old_handler = Signal.trap('INT', 'DEFAULT')
      example.run
      Signal.trap('INT', old_handler)
    end

    context 'with SIGINT' do
      it 'returns false' do
        skip unless Process.respond_to?(:fork)

        # Make sure the runner works slowly and thus is interruptible
        allow(runner).to receive(:process_file) do
          sleep 99
        end

        rd, wr = IO.pipe

        pid = Process.fork do
          rd.close
          wr.puts 'READY'
          wr.puts runner.run(['example.rb'])
          wr.close
        end

        wr.close

        # Make sure the runner has started by waiting for a specific message
        line = wait_for_input(rd)
        expect(line.chomp).to eq('READY')

        # Interrupt the runner
        interrupt(pid)

        # Make sure the runner returns false
        line = wait_for_input(rd)
        expect(line.chomp).to eq('false')
      end
    end
  end

  describe '#run' do
    subject(:runner) { described_class.new(options, RuboCop::ConfigStore.new) }

    before do
      create_file('example.rb', source)
    end

    let(:options) { { formatters: [['progress', formatter_output_path]] } }

    context 'if there are no offenses in inspected files' do
      let(:source) { <<-RUBY.strip_indent }
        # frozen_string_literal: true

        def valid_code; end
      RUBY

      it 'returns true' do
        expect(runner.run([])).to be true
      end
    end

    context 'if there is an offense in an inspected file' do
      let(:source) { <<-RUBY.strip_indent }
        # frozen_string_literal: true

        def INVALID_CODE; end
      RUBY

      it 'returns false' do
        expect(runner.run([])).to be false
      end

      it 'sends the offense to a formatter' do
        runner.run([])
        expect(formatter_output).to eq <<-RESULT.strip_indent
          Inspecting 1 file
          C

          Offenses:

          example.rb:3:5: C: Naming/MethodName: Use snake_case for method names.
          def INVALID_CODE; end
              ^^^^^^^^^^^^

          1 file inspected, 1 offense detected
        RESULT
      end
    end

    context 'if a cop crashes' do
      before do
        # The cache responds that it's not valid, which means that new results
        # should normally be collected and saved...
        cache = instance_double(RuboCop::ResultCache, 'valid?' => false)
        # ... but there's a crash in one cop.
        runner.errors = ['An error occurred in ...']

        allow(RuboCop::ResultCache).to receive(:new) { cache }
      end

      let(:source) { '' }

      it 'does not call ResultCache#save' do
        # The double doesn't define #save, so we'd get an error if it were
        # called.
        runner.run([])
      end
    end

    context 'if -s/--stdin is used with an offense' do
      before do
        # Make Style/EndOfLine give same output regardless of platform.
        create_file('.rubocop.yml', <<-YAML.strip_indent)
          Layout/EndOfLine:
            EnforcedStyle: lf
        YAML
      end

      let(:options) do
        {
          formatters: [['progress', formatter_output_path]],
          stdin: <<-RUBY.strip_indent
            # frozen_string_literal: true

            def INVALID_CODE; end
          RUBY
        }
      end
      let(:source) { '' }

      it 'returns false' do
        expect(runner.run([])).to be false
      end

      it 'sends the offense to a formatter' do
        runner.run([])
        expect(formatter_output).to eq <<-RESULT.strip_indent
          Inspecting 1 file
          C

          Offenses:

          example.rb:3:5: C: Naming/MethodName: Use snake_case for method names.
          def INVALID_CODE; end
              ^^^^^^^^^^^^

          1 file inspected, 1 offense detected
        RESULT
      end
    end
  end

  describe '#run with cops autocorrecting each-other' do
    subject(:runner) do
      runner_class = Class.new(RuboCop::Runner) do
        def mobilized_cop_classes(_config)
          RuboCop::Cop::Registry.new(
            [
              RuboCop::Cop::Test::ClassMustBeAModuleCop,
              RuboCop::Cop::Test::ModuleMustBeAClassCop
            ]
          )
        end
      end
      runner_class.new(options, RuboCop::ConfigStore.new)
    end

    before do
      create_file('example.rb', source)
    end

    let(:options) do
      {
        auto_correct: true,
        formatters: [['progress', formatter_output_path]]
      }
    end

    context 'if there is an offense in an inspected file' do
      let(:source) { <<-RUBY.strip_indent }
        # frozen_string_literal: true
        class Klass
        end
      RUBY

      it 'aborts because of an infinite loop' do
        expect do
          runner.run([])
        end.to raise_error RuboCop::Runner::InfiniteCorrectionLoop
      end
    end
  end
end
