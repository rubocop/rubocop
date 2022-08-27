# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      #
      # This cop emulates the following Ruby warnings in Ruby 2.6.
      #
      # [source,console]
      # ----
      # % cat example.rb
      # ERB.new('hi', nil, '-', '@output_buffer')
      # % ruby -rerb example.rb
      # example.rb:1: warning: Passing safe_level with the 2nd argument of ERB.new is
      # deprecated. Do not use it, and specify other arguments as keyword arguments.
      # example.rb:1: warning: Passing trim_mode with the 3rd argument of ERB.new is
      # deprecated. Use keyword argument like ERB.new(str, trim_mode:...) instead.
      # example.rb:1: warning: Passing eoutvar with the 4th argument of ERB.new is
      # deprecated. Use keyword argument like ERB.new(str, eoutvar: ...) instead.
      # ----
      #
      # Now non-keyword arguments other than first one are softly deprecated
      # and will be removed when Ruby 2.5 becomes EOL.
      # `ERB.new` with non-keyword arguments is deprecated since ERB 2.2.0.
      # Use `:trim_mode` and `:eoutvar` keyword arguments to `ERB.new`.
      # This cop identifies places where `ERB.new(str, trim_mode, eoutvar)` can
      # be replaced by `ERB.new(str, :trim_mode: trim_mode, eoutvar: eoutvar)`.
      #
      # @example
      #   # Target codes supports Ruby 2.6 and higher only
      #   # bad
      #   ERB.new(str, nil, '-', '@output_buffer')
      #
      #   # good
      #   ERB.new(str, trim_mode: '-', eoutvar: '@output_buffer')
      #
      #   # Target codes supports Ruby 2.5 and lower only
      #   # good
      #   ERB.new(str, nil, '-', '@output_buffer')
      #
      #   # Target codes supports Ruby 2.6, 2.5 and lower
      #   # bad
      #   ERB.new(str, nil, '-', '@output_buffer')
      #
      #   # good
      #   # Ruby standard library style
      #   # https://github.com/ruby/ruby/commit/3406c5d
      #   if ERB.instance_method(:initialize).parameters.assoc(:key) # Ruby 2.6+
      #     ERB.new(str, trim_mode: '-', eoutvar: '@output_buffer')
      #   else
      #     ERB.new(str, nil, '-', '@output_buffer')
      #   end
      #
      #   # good
      #   # Use `RUBY_VERSION` style
      #   if RUBY_VERSION >= '2.6'
      #     ERB.new(str, trim_mode: '-', eoutvar: '@output_buffer')
      #   else
      #     ERB.new(str, nil, '-', '@output_buffer')
      #   end
      #
      class ErbNewArguments < Base
        include RangeHelp
        extend AutoCorrector
        extend TargetRubyVersion

        minimum_target_ruby_version 2.6

        MESSAGES = [
          'Passing safe_level with the 2nd argument of `ERB.new` is ' \
          'deprecated. Do not use it, and specify other arguments as ' \
          'keyword arguments.',
          'Passing trim_mode with the 3rd argument of `ERB.new` is ' \
          'deprecated. Use keyword argument like ' \
          '`ERB.new(str, trim_mode: %<arg_value>s)` instead.',
          'Passing eoutvar with the 4th argument of `ERB.new` is ' \
          'deprecated. Use keyword argument like ' \
          '`ERB.new(str, eoutvar: %<arg_value>s)` instead.'
        ].freeze

        RESTRICT_ON_SEND = %i[new].freeze

        # @!method erb_new_with_non_keyword_arguments(node)
        def_node_matcher :erb_new_with_non_keyword_arguments, <<~PATTERN
          (send
            (const {nil? cbase} :ERB) :new $...)
        PATTERN

        def on_send(node)
          erb_new_with_non_keyword_arguments(node) do |arguments|
            return if arguments.empty? || correct_arguments?(arguments)

            arguments[1..3].each_with_index do |argument, i|
              next if !argument || argument.hash_type?

              message = format(MESSAGES[i], arg_value: argument.source)

              add_offense(
                argument.source_range, message: message
              ) do |corrector|
                autocorrect(corrector, node)
              end
            end
          end
        end

        private

        def autocorrect(corrector, node)
          str_arg = node.arguments[0].source

          kwargs = build_kwargs(node)
          overridden_kwargs = override_by_legacy_args(kwargs, node)

          good_arguments = [str_arg, overridden_kwargs].flatten.compact.join(', ')

          corrector.replace(arguments_range(node), good_arguments)
        end

        def correct_arguments?(arguments)
          arguments.size == 1 || (arguments.size == 2 && arguments[1].hash_type?)
        end

        def build_kwargs(node)
          return [nil, nil] unless node.arguments.last.hash_type?

          trim_mode_arg, eoutvar_arg = nil

          node.arguments.last.pairs.each do |pair|
            case pair.key.source
            when 'trim_mode'
              trim_mode_arg = "trim_mode: #{pair.value.source}"
            when 'eoutvar'
              eoutvar_arg = "eoutvar: #{pair.value.source}"
            end
          end

          [trim_mode_arg, eoutvar_arg]
        end

        def override_by_legacy_args(kwargs, node)
          arguments = node.arguments
          overridden_kwargs = kwargs.dup

          overridden_kwargs[0] = "trim_mode: #{arguments[2].source}" if arguments[2]

          if arguments[3] && !arguments[3].hash_type?
            overridden_kwargs[1] = "eoutvar: #{arguments[3].source}"
          end

          overridden_kwargs
        end

        def arguments_range(node)
          arguments = node.arguments

          range_between(arguments.first.source_range.begin_pos, arguments.last.source_range.end_pos)
        end
      end
    end
  end
end
