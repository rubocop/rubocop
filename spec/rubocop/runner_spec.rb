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

  describe '#run when interrupted' do
    include_context 'cli spec behavior'

    let(:runner) { described_class.new({}, RuboCop::ConfigStore.new) }

    before { create_empty_file('example.rb') }

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
        skip '`Process` does not respond to `fork` method.' unless Process.respond_to?(:fork)

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

    before { create_file('example.rb', source) }

    let(:options) { { formatters: [['progress', formatter_output_path]] } }

    context 'if there are no offenses in inspected files' do
      let(:source) { <<~RUBY }
        # frozen_string_literal: true

        def valid_code; end
      RUBY

      it 'returns true' do
        expect(runner.run([])).to be true
      end
    end

    context 'if there is an offense in an inspected file' do
      let(:source) { <<~RUBY }
        # frozen_string_literal: true

        def INVALID_CODE; end
      RUBY

      it 'returns false' do
        expect(runner.run([])).to be false
      end

      it 'sends the offense to a formatter' do
        runner.run([])
        expect(formatter_output).to eq <<~RESULT
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

    context 'with available custom ruby extractor' do
      before do
        described_class.ruby_extractors.unshift(custom_ruby_extractor)

        # Make Style/EndOfLine give same output regardless of platform.
        create_file('.rubocop.yml', <<~YAML)
          Layout/EndOfLine:
            EnforcedStyle: lf
        YAML
      end

      after do
        described_class.ruby_extractors.shift
      end

      let(:custom_ruby_extractor) do
        lambda do |_processed_source|
          [
            {
              offset: 1,
              processed_source: RuboCop::ProcessedSource.new(<<~RUBY, 3.1, 'dummy.rb')
                # frozen_string_literal: true

                def valid_code; end
              RUBY
            },
            {
              offset: 2,
              processed_source: RuboCop::ProcessedSource.new(source, 3.1, 'dummy.rb')
            }
          ]
        end
      end

      let(:source) do
        <<~RUBY
          # frozen_string_literal: true

          def INVALID_CODE; end
        RUBY
      end

      it 'sends the offense to a formatter' do
        runner.run([])
        expect(formatter_output).to eq <<~RESULT
          Inspecting 1 file
          C

          Offenses:

          example.rb:3:7: C: Naming/MethodName: Use snake_case for method names.
          def INVALID_CODE; end
                ^^^^^^^^^^^^

          1 file inspected, 1 offense detected
        RESULT
      end
    end

    context 'with unavailable custom ruby extractor' do
      before do
        described_class.ruby_extractors.unshift(custom_ruby_extractor)
      end

      after do
        described_class.ruby_extractors.shift
      end

      let(:custom_ruby_extractor) do
        lambda do |_processed_source|
        end
      end

      let(:source) { <<~RUBY }
        # frozen_string_literal: true

        def INVALID_CODE; end
      RUBY

      it 'sends the offense to a formatter' do
        runner.run([])
        expect(formatter_output).to eq <<~RESULT
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
        expect(runner.run([])).to be true
      end
    end

    context 'if -s/--stdin is used with an offense' do
      before do
        # Make Style/EndOfLine give same output regardless of platform.
        create_file('.rubocop.yml', <<~YAML)
          Layout/EndOfLine:
            EnforcedStyle: lf
        YAML
      end

      let(:options) do
        {
          formatters: [['progress', formatter_output_path]],
          stdin: <<~RUBY
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
        expect(formatter_output).to eq <<~RESULT
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
    let(:source_file_path) { create_file('example.rb', source) }

    let(:options) { { autocorrect: true, formatters: [['progress', formatter_output_path]] } }

    context 'with two conflicting cops' do
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

      context 'if there is an offense in an inspected file' do
        let(:source) { <<~RUBY }
          # frozen_string_literal: true
          class Klass
          end
        RUBY

        it 'aborts because of an infinite loop' do
          expect do
            runner.run([])
          end.to raise_error(
            RuboCop::Runner::InfiniteCorrectionLoop,
            "Infinite loop detected in #{source_file_path} and caused by " \
            'Test/ClassMustBeAModuleCop -> Test/ModuleMustBeAClassCop'
          )
        end
      end

      context 'if there are multiple offenses in an inspected file' do
        let(:source) { <<~RUBY }
          # frozen_string_literal: true
          class Klass
          end
          class AnotherKlass
          end
        RUBY

        it 'aborts because of an infinite loop' do
          expect do
            runner.run([])
          end.to raise_error(
            RuboCop::Runner::InfiniteCorrectionLoop,
            "Infinite loop detected in #{source_file_path} and caused by " \
            'Test/ClassMustBeAModuleCop -> Test/ModuleMustBeAClassCop'
          )
        end
      end
    end

    context 'with two pairs of conflicting cops' do
      subject(:runner) do
        runner_class = Class.new(RuboCop::Runner) do
          def mobilized_cop_classes(_config)
            RuboCop::Cop::Registry.new(
              [
                RuboCop::Cop::Test::ClassMustBeAModuleCop,
                RuboCop::Cop::Test::ModuleMustBeAClassCop,
                RuboCop::Cop::Test::AtoB,
                RuboCop::Cop::Test::BtoA
              ]
            )
          end
        end
        runner_class.new(options, RuboCop::ConfigStore.new)
      end

      context 'if there is an offense in an inspected file' do
        let(:source) { <<~RUBY }
          # frozen_string_literal: true
          class A_A
          end
        RUBY

        it 'aborts because of an infinite loop' do
          expect do
            runner.run([])
          end.to raise_error(
            RuboCop::Runner::InfiniteCorrectionLoop,
            "Infinite loop detected in #{source_file_path} and caused by " \
            'Test/ClassMustBeAModuleCop, Test/AtoB ' \
            '-> Test/ModuleMustBeAClassCop, Test/BtoA'
          )
        end
      end

      context 'with three cop cycle' do
        subject(:runner) do
          runner_class = Class.new(RuboCop::Runner) do
            def mobilized_cop_classes(_config)
              RuboCop::Cop::Registry.new(
                [
                  RuboCop::Cop::Test::AtoB,
                  RuboCop::Cop::Test::BtoC,
                  RuboCop::Cop::Test::CtoA
                ]
              )
            end
          end
          runner_class.new(options, RuboCop::ConfigStore.new)
        end

        context 'if there is an offense in an inspected file' do
          let(:source) { <<~RUBY }
            # frozen_string_literal: true
            class A
            end
          RUBY

          it 'aborts because of an infinite loop' do
            expect do
              runner.run([])
            end.to raise_error(
              RuboCop::Runner::InfiniteCorrectionLoop,
              "Infinite loop detected in #{source_file_path} and caused by " \
              'Test/AtoB -> Test/BtoC -> Test/CtoA'
            )
          end
        end
      end

      context 'with display options' do
        subject(:runner) { described_class.new(options, RuboCop::ConfigStore.new) }

        before { create_file('example.rb', source) }

        context '--display-only-safe-correctable' do
          let(:options) do
            {
              formatters: [['progress', formatter_output_path]],
              display_only_safe_correctable: true
            }
          end
          let(:source) { <<~RUBY }

            def foo()
            end
          RUBY

          it 'returns false' do
            expect(runner.run([])).to be false
          end

          it 'omits unsafe correctable `Style/FrozenStringLiteral`' do
            runner.run([])
            expect(formatter_output).to eq <<~RESULT
              Inspecting 1 file
              C

              Offenses:

              example.rb:2:1: C: [Correctable] Layout/LeadingEmptyLines: Unnecessary blank line at the beginning of the source.
              def foo()
              ^^^
              example.rb:2:1: C: [Correctable] Style/EmptyMethod: Put empty method definitions on a single line.
              def foo() ...
              ^^^^^^^^^
              example.rb:2:8: C: [Correctable] Style/DefWithParentheses: Omit the parentheses in defs when the method doesn't accept any arguments.
              def foo()
                     ^^

              1 file inspected, 3 offenses detected, 3 offenses autocorrectable
            RESULT
          end
        end

        context '--display-only-correctable' do
          let(:options) do
            {
              formatters: [['progress', formatter_output_path]],
              display_only_correctable: true
            }
          end

          let(:source) { <<~RUBY }

            def foo()
            end

            'very-long-string-to-earn-un-autocorrectable-offense very-long-string-to-earn-un-autocorrectable-offense very-long-string-to-earn-un-autocorrectable-offense'
          RUBY

          it 'returns false' do
            expect(runner.run([])).to be false
          end

          it 'omits uncorrectable `Layout/LineLength`' do
            runner.run([])
            expect(formatter_output).to eq <<~RESULT
              Inspecting 1 file
              C

              Offenses:

              example.rb:1:1: C: [Correctable] Style/FrozenStringLiteralComment: Missing frozen string literal comment.
              example.rb:2:1: C: [Correctable] Layout/LeadingEmptyLines: Unnecessary blank line at the beginning of the source.
              def foo()
              ^^^
              example.rb:2:1: C: [Correctable] Style/EmptyMethod: Put empty method definitions on a single line.
              def foo() ...
              ^^^^^^^^^
              example.rb:2:8: C: [Correctable] Style/DefWithParentheses: Omit the parentheses in defs when the method doesn't accept any arguments.
              def foo()
                     ^^

              1 file inspected, 4 offenses detected, 4 offenses autocorrectable
            RESULT
          end
        end
      end
    end
  end
end
