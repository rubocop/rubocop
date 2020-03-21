# frozen_string_literal: true

module RuboCop
  class CLI
    module Command
      # Generate a configuration file acting as a TODO list.
      class AutoGenerateConfig < Base
        self.command_name = :auto_gen_config

        PHASE_1 = 'Phase 1 of 2: run Layout/LineLength cop'
        PHASE_2 = 'Phase 2 of 2: run all cops'

        PHASE_1_OVERRIDDEN =
          '(skipped because the default Layout/LineLength:Max is overridden)'
        PHASE_1_DISABLED =
          '(skipped because Layout/LineLength is disabled)'

        def run
          add_formatter
          reset_config_and_auto_gen_file
          line_length_contents = maybe_run_line_length_cop
          run_all_cops(line_length_contents)
        end

        private

        def maybe_run_line_length_cop
          if !line_length_enabled?(@config_store.for(Dir.pwd))
            skip_line_length_cop(PHASE_1_DISABLED)
          elsif !same_max_line_length?(
            @config_store.for(Dir.pwd), ConfigLoader.default_configuration
          )
            skip_line_length_cop(PHASE_1_OVERRIDDEN)
          else
            run_line_length_cop
          end
        end

        def skip_line_length_cop(reason)
          puts Rainbow("#{PHASE_1} #{reason}").yellow
          ''
        end

        def line_length_enabled?(config)
          line_length_cop(config)['Enabled']
        end

        def same_max_line_length?(config1, config2)
          max_line_length(config1) == max_line_length(config2)
        end

        def max_line_length(config)
          line_length_cop(config)['Max']
        end

        def line_length_cop(config)
          config.for_cop('Layout/LineLength')
        end

        # Do an initial run with only Layout/LineLength so that cops that
        # depend on Layout/LineLength:Max get the correct value for that
        # parameter.
        def run_line_length_cop
          puts Rainbow(PHASE_1).yellow
          @options[:only] = ['Layout/LineLength']
          execute_runner
          @options.delete(:only)
          @config_store = ConfigStore.new
          # Save the todo configuration of the LineLength cop.
          IO.read(ConfigLoader::AUTO_GENERATED_FILE)
            .lines
            .drop_while { |line| line.start_with?('#') }
            .join
        end

        def run_all_cops(line_length_contents)
          puts Rainbow(PHASE_2).yellow
          result = execute_runner
          # This run was made with the current maximum length allowed, so append
          # the saved setting for LineLength.
          File.open(ConfigLoader::AUTO_GENERATED_FILE, 'a') do |f|
            f.write(line_length_contents)
          end
          result
        end

        def reset_config_and_auto_gen_file
          @config_store = ConfigStore.new
          @config_store.options_config = @options[:config] if @options[:config]
          File.open(ConfigLoader::AUTO_GENERATED_FILE, 'w') {}
          ConfigLoader.add_inheritance_from_auto_generated_file
        end

        def add_formatter
          @options[:formatters] << [Formatter::DisabledConfigFormatter,
                                    ConfigLoader::AUTO_GENERATED_FILE]
        end

        def execute_runner
          Environment.new(@options, @config_store, @paths).run(:execute_runner)
        end
      end
    end
  end
end
