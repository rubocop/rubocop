# frozen_string_literal: true

module RuboCop
  class CLI
    module Command
      # Generate a configuration file acting as a TODO list.
      # @api private
      class AutoGenerateConfig < Base
        self.command_name = :auto_gen_config

        AUTO_GENERATED_FILE = '.rubocop_todo.yml'

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
          if !line_length_enabled?(@config_store.for_pwd)
            skip_line_length_cop(PHASE_1_DISABLED)
          elsif !same_max_line_length?(
            @config_store.for_pwd, ConfigLoader.default_configuration
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
          IO.read(AUTO_GENERATED_FILE)
            .lines
            .drop_while { |line| line.start_with?('#') }
            .join
        end

        def run_all_cops(line_length_contents)
          puts Rainbow(PHASE_2).yellow
          result = execute_runner
          # This run was made with the current maximum length allowed, so append
          # the saved setting for LineLength.
          File.open(AUTO_GENERATED_FILE, 'a') do |f|
            f.write(line_length_contents)
          end
          result
        end

        def reset_config_and_auto_gen_file
          @config_store = ConfigStore.new
          @config_store.options_config = @options[:config] if @options[:config]
          File.open(AUTO_GENERATED_FILE, 'w') {}
          add_inheritance_from_auto_generated_file(@options[:config])
        end

        def add_formatter
          @options[:formatters] << [Formatter::DisabledConfigFormatter,
                                    AUTO_GENERATED_FILE]
        end

        def execute_runner
          Environment.new(@options, @config_store, @paths).run(:execute_runner)
        end

        def add_inheritance_from_auto_generated_file(config_file)
          file_string = " #{AUTO_GENERATED_FILE}"

          config_file ||= ConfigLoader::DOTFILE

          if File.exist?(config_file)
            files = Array(ConfigLoader.load_yaml_configuration(config_file)['inherit_from'])

            return if files.include?(AUTO_GENERATED_FILE)

            files.unshift(AUTO_GENERATED_FILE)
            file_string = "\n  - #{files.join("\n  - ")}" if files.size > 1
            rubocop_yml_contents = existing_configuration(config_file)
          end

          write_config_file(config_file, file_string, rubocop_yml_contents)

          puts "Added inheritance from `#{AUTO_GENERATED_FILE}` in `#{ConfigLoader::DOTFILE}`."
        end

        def existing_configuration(config_file)
          IO.read(config_file, encoding: Encoding::UTF_8)
            .sub(/^inherit_from: *[^\n]+/, '')
            .sub(/^inherit_from: *(\n *- *[^\n]+)+/, '')
        end

        def write_config_file(file_name, file_string, rubocop_yml_contents)
          File.open(file_name, 'w') do |f|
            f.write "inherit_from:#{file_string}\n"
            f.write "\n#{rubocop_yml_contents}" if /\S/.match?(rubocop_yml_contents)
          end
        end
      end
    end
  end
end
