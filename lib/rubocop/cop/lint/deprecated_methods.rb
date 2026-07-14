# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for calls to methods that have been configured as deprecated.
      #
      # No methods are deprecated by default. The cop is configured with a list
      # of the project's own deprecation rules:
      #
      # [source,yaml]
      # ----
      # Lint/DeprecatedMethods:
      #   Rules:
      #     - Method: serialize
      #       Replacement: serialize_with_codec
      #     - Method: find
      #       Receiver: Book
      #       Replacement: BookRepository.fetch
      #     - Pattern: '(call (const {cbase nil?} :Book) :find_by (hash (pair (sym :id) $_)))'
      #       Replacement: 'BookRepository.find_by_custom_id!($1)'
      # ----
      #
      # Each rule matches calls either by method name or by node pattern:
      #
      # * `Method` matches every call to a method with that name, regardless of
      #   the receiver, including safe navigation (`&.`) calls. With the optional
      #   `Receiver` key, only calls on that class or module (with or without a
      #   leading `::`) are matched. When autocorrecting, `Replacement` replaces
      #   only the method name (or the receiver and the method name when
      #   `Receiver` is given) and keeps all arguments and blocks in place.
      # * `Pattern` is a
      #   https://docs.rubocop.org/rubocop-ast/node_pattern.html[node pattern]
      #   that is matched against every method call (`send` and `csend` node),
      #   for deprecations that need to take receivers or arguments into
      #   account. Use `call` instead of `send` to also match safe navigation
      #   calls. When autocorrecting, `Replacement` replaces the entire matched
      #   call and can refer to the values captured by the pattern's `$`
      #   captures: `$1` expands to the source of the first capture, `$2` to the
      #   second, and so on. Custom `#method` calls and `%` parameters are not
      #   supported.
      #
      # `Replacement` and `Message` are both optional; without a `Replacement`
      # the call is flagged but not autocorrected, and without a `Message` a
      # default offense message is built from the deprecated call and its
      # replacement. When a call matches multiple rules, only the first
      # matching rule is applied.
      #
      # @safety
      #   Autocorrection is unsafe because a configured `Replacement` may not be
      #   a drop-in replacement for the deprecated method.
      #
      # @example
      #   # Given the rules from the configuration above:
      #
      #   # bad
      #   book.serialize
      #   Book.find(1)
      #   Book.find_by(id: 42)
      #
      #   # good
      #   book.serialize_with_codec
      #   BookRepository.fetch(1)
      #   BookRepository.find_by_custom_id!(42)
      #
      class DeprecatedMethods < Base
        extend AutoCorrector

        MSG = '`%<current>s` is deprecated.'
        MSG_WITH_REPLACEMENT = 'Use `%<prefer>s` instead of `%<current>s`.'

        Match = Struct.new(:range, :message, :replacement)

        # A single validated entry of the `Rules` configuration.
        class Rule
          RULE_KEYS = %w[Method Receiver Pattern Replacement Message].freeze
          CAPTURE_REFERENCE = /\$(\d+)/.freeze

          def self.create(cop_name, index, rule_config)
            if rule_config.is_a?(Hash) && rule_config.key?('Pattern')
              PatternRule.new(cop_name, index, rule_config)
            else
              MethodRule.new(cop_name, index, rule_config)
            end
          end

          def initialize(cop_name, index, rule_config)
            @cop_name = cop_name
            @index = index
            validate_rule_config(rule_config)
            parse(rule_config)
            @replacement_template = validate_template('Replacement', rule_config['Replacement'])
            @message_template = validate_template('Message', rule_config['Message'])
          end

          private

          def validate_rule_config(rule_config)
            unless rule_config.is_a?(Hash)
              error('must be a mapping with a `Method` or `Pattern` key, ' \
                    "found `#{rule_config.inspect}`")
            end

            unknown_keys = rule_config.keys - RULE_KEYS
            return if unknown_keys.none?

            error("contains unknown key#{'s' if unknown_keys.size > 1} " \
                  "#{keys_description(unknown_keys)}, " \
                  "valid keys are #{keys_description(RULE_KEYS)}")
          end

          def keys_description(keys)
            keys.map { |key| "`#{key}`" }.join(', ')
          end

          def validate_template(key, template)
            return nil if template.nil?

            error("`#{key}` must be a string") unless template.is_a?(String)

            validate_capture_references(key, template)
            template
          end

          def capture_references(template)
            template.scan(CAPTURE_REFERENCE).map { |(number)| number.to_i }
          end

          def error(message)
            raise ValidationError, "#{@cop_name}: rule #{@index} #{message}."
          end
        end

        # A rule matching calls by method name, with an optional constant receiver.
        class MethodRule < Rule
          def match(node)
            return unless node.method_name.to_s == @method && receiver_match?(node)
            return unless (selector = node.loc.selector)

            range = offense_range(node, selector)
            Match.new(range, message(range.source), replacement(node))
          end

          private

          def parse(rule_config)
            error('is missing a `Method` or `Pattern` key') unless rule_config.key?('Method')
            error('`Method` must be a string') unless rule_config['Method'].is_a?(String)

            @method = rule_config['Method']

            receiver = rule_config['Receiver']
            return if receiver.nil?

            error('`Receiver` must be a string') unless receiver.is_a?(String)

            @receiver = receiver.delete_prefix('::')
          end

          def receiver_match?(node)
            return true unless @receiver

            node.receiver&.const_type? && node.receiver.const_name == @receiver
          end

          def offense_range(node, selector)
            @receiver ? node.receiver.source_range.join(selector) : selector
          end

          def message(current)
            return @message_template if @message_template

            if @replacement_template
              format(MSG_WITH_REPLACEMENT, prefer: @replacement_template, current: current)
            else
              format(MSG, current: current)
            end
          end

          def replacement(node)
            return unless @replacement_template
            return if node.operator_method? || node.assignment_method?

            @replacement_template
          end

          def validate_capture_references(key, template)
            reference = capture_references(template).first
            return unless reference

            error("`#{key}` references capture `$#{reference}`, but captures can only " \
                  'be used together with `Pattern`')
          end
        end

        # A rule matching calls by node pattern, with optional `$` captures.
        class PatternRule < Rule
          def match(node)
            captures = @pattern.match(node) { |*values| values }
            return unless captures

            replacement = expand(@replacement_template, captures) if @replacement_template
            Match.new(node.source_range, message(node, captures, replacement), replacement)
          end

          private

          def parse(rule_config)
            if rule_config.key?('Method')
              error('contains both `Method` and `Pattern` keys, use either one or the other')
            end
            if rule_config.key?('Receiver')
              error('contains a `Receiver` key, which can only be used together with `Method`')
            end
            error('`Pattern` must be a string') unless rule_config['Pattern'].is_a?(String)

            @pattern = compile_pattern(rule_config['Pattern'])
          end

          def compile_pattern(pattern_source)
            pattern = AST::NodePattern.new(pattern_source)

            if function_call?(pattern.ast)
              error('uses a custom `#method` call in `Pattern`, which is not supported')
            end
            if pattern.positional_parameters.positive? || pattern.named_parameters.any?
              error('uses a `%` parameter in `Pattern`, which is not supported')
            end

            pattern
          rescue AST::NodePattern::Invalid => e
            error("contains an invalid `Pattern`: #{e.message}")
          end

          def function_call?(pattern_node)
            return true if pattern_node.type == :function_call

            pattern_node.children.any? do |child|
              child.is_a?(AST::NodePattern::Node) && function_call?(child)
            end
          end

          def message(node, captures, replacement)
            if @message_template
              expand(@message_template, captures)
            elsif replacement
              format(MSG_WITH_REPLACEMENT, prefer: replacement, current: node.source)
            else
              format(MSG, current: node.source)
            end
          end

          def validate_capture_references(key, template)
            invalid_reference = capture_references(template).find do |number|
              number.zero? || number > @pattern.captures
            end
            return unless invalid_reference

            error("`#{key}` references capture `$#{invalid_reference}`, but `Pattern` " \
                  "contains #{@pattern.captures} capture#{'s' unless @pattern.captures == 1}")
          end

          def expand(template, captures)
            template.gsub(CAPTURE_REFERENCE) do
              capture_source(captures[Regexp.last_match(1).to_i - 1])
            end
          end

          def capture_source(capture)
            case capture
            when nil then ''
            when Array then capture.map { |element| capture_source(element) }.join(', ')
            when AST::Node then capture.source
            else capture.to_s
            end
          end
        end

        def initialize(config = nil, options = nil)
          super
          rules # validate the configured rules eagerly to fail fast on mistakes
        end

        def on_send(node)
          rules.each do |rule|
            next unless (match = rule.match(node))

            add_offense(match.range, message: match.message) do |corrector|
              corrector.replace(match.range, match.replacement) if match.replacement
            end
            break
          end
        end
        alias on_csend on_send

        private

        def rules
          @rules ||= (cop_config.fetch('Rules', nil) || []).each_with_index.map do |rule, index|
            Rule.create(cop_name, index + 1, rule)
          end
        end
      end
    end
  end
end
