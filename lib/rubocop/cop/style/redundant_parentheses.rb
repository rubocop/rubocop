# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for redundant parentheses.
      #
      # @example
      #
      #   # bad
      #   (x) if ((y.z).nil?)
      #
      #   # good
      #   x if y.z.nil?
      #
      class RedundantParentheses < Base # rubocop:disable Metrics/ClassLength
        include Parentheses
        include ReparsedEquivalence
        extend AutoCorrector

        ALLOWED_NODE_TYPES = %i[or send splat kwsplat].freeze

        # @!method square_brackets?(node)
        def_node_matcher :square_brackets?, <<~PATTERN
          (send `{(send _recv _msg) str array hash const #variable?} :[] ...)
        PATTERN

        # @!method rescue?(node)
        def_node_matcher :rescue?, '{^resbody ^^resbody}'

        # @!method allowed_pin_operator?(node)
        def_node_matcher :allowed_pin_operator?, '^(pin (begin !{lvar ivar cvar gvar}))'

        # Above this size, an unverifiable candidate is reported based on the
        # message logic alone (the pre-verification behavior) instead of
        # reparsing a huge fragment per candidate; in practice only
        # machine-generated files come near it.
        MAX_VERIFICATION_FRAGMENT_SIZE = 64 * 1024

        def on_new_investigation
          @pending_offenses = []
          super
        end

        def on_begin(node)
          return if !parentheses?(node) || parens_allowed?(node) || ignore_syntax?(node)

          check(node)
        end

        def on_investigation_end
          verified_offenses.each do |node, message|
            add_offense(node, message: message) do |corrector|
              ParenthesesCorrector.correct(corrector, node)
            end
          end

          super
        end

        private

        def variable?(node)
          node.respond_to?(:variable?) && node.variable?
        end

        def parens_allowed?(node)
          empty_parentheses?(node) ||
            rescue?(node) ||
            in_pattern_matching_in_method_argument?(node) ||
            allowed_pin_operator?(node) ||
            allowed_expression?(node)
        end

        def ignore_syntax?(node)
          return false unless (parent = node.parent)

          parent.type?(:while_post, :until_post, :match_with_lvasgn) ||
            like_method_argument_parentheses?(parent) || multiline_control_flow_statements?(node)
        end

        def allowed_expression?(node)
          allowed_ancestor?(node) ||
            allowed_multiple_expression?(node) ||
            allowed_ternary?(node) ||
            node.parent&.range_type?
        end

        def allowed_ancestor?(node)
          # Don't flag `break(1)`, etc
          keyword_ancestor?(node) && parens_required?(node)
        end

        def allowed_multiple_expression?(node)
          return false if node.children.one?

          ancestor = node.ancestors.first
          return false unless ancestor

          !ancestor.type?(:begin, :any_def, :any_block)
        end

        def allowed_ternary?(node)
          return false unless node&.parent&.if_type?

          node.parent.ternary? && ternary_parentheses_required?
        end

        def ternary_parentheses_required?
          config = @config.for_cop('Style/TernaryParentheses')
          allowed_styles = %w[require_parentheses require_parentheses_when_complex]

          config.fetch('Enabled') && allowed_styles.include?(config['EnforcedStyle'])
        end

        def like_method_argument_parentheses?(node)
          return false unless node.type?(:send, :super, :yield)

          node.arguments.one? && !node.parenthesized? &&
            !node.operator_method? && node.first_argument.begin_type?
        end

        def multiline_control_flow_statements?(node)
          return false unless (parent = node.parent)
          return false if parent.single_line?

          parent.type?(:return, :next, :break)
        end

        def empty_parentheses?(node)
          # Don't flag `()`
          node.children.empty?
        end

        def in_pattern_matching_in_method_argument?(begin_node)
          return false unless begin_node.parent&.call_type?
          return false unless (node = begin_node.children.first)

          target_ruby_version <= 2.7 ? node.match_pattern_type? : node.match_pattern_p_type?
        end

        def check(begin_node)
          node = begin_node.children.first

          if (message = find_offense_message(begin_node, node))
            return offense(begin_node, message) if message == 'block body'

            if node.range_type? && !argument_of_parenthesized_method_call?(begin_node, node)
              begin_node = begin_node.parent
            end

            return offense(begin_node, message)
          end

          check_send(begin_node, node) if call_node?(node)
        end

        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
        def find_offense_message(begin_node, node)
          return 'a keyword' if keyword_with_redundant_parentheses?(node)
          return 'a literal' if node.literal? && disallowed_literal?(begin_node, node)
          return 'a variable' if node.variable?
          return 'a constant' if node.const_type?
          return 'block body' if begin_node.parent&.any_block_type? || body_range?(begin_node, node)

          if node.assignment? && (begin_node.parent.nil? || begin_node.parent.begin_type?)
            return 'an assignment'
          end
          if node.lambda_or_proc? && (node.braces? || node.send_node.lambda_literal?)
            return 'an expression'
          end
          if disallowed_one_line_pattern_matching?(begin_node, node)
            return 'a one-line pattern matching'
          end
          return 'an interpolated expression' if interpolation?(begin_node)
          return 'a method argument' if argument_of_parenthesized_method_call?(begin_node, node)
          return 'a one-line rescue' if oneline_rescue_parentheses_required?(begin_node, node)

          return if begin_node.chained?

          if node.operator_keyword?
            return if node.semantic_operator? && begin_node.parent
            return if node.multiline? && allow_in_multiline_conditions?
            return if ALLOWED_NODE_TYPES.include?(begin_node.parent&.type)
            return if !node.and_type? && begin_node.parent&.and_type?
            return if begin_node.parent&.if_type? && begin_node.parent.ternary?

            'a logical expression'
          elsif node.respond_to?(:comparison_method?) && node.comparison_method?
            return unless begin_node.parent.nil?

            'a comparison expression'
          end
        end
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

        # @!method interpolation?(node)
        def_node_matcher :interpolation?, '[^begin ^^dstr]'

        def argument_of_parenthesized_method_call?(begin_node, node)
          if node.basic_conditional? || node.rescue_type? || method_call_parentheses_required?(node)
            return false
          end
          return false unless (parent = begin_node.parent)

          parent.call_type? && parent.parenthesized? && parent.receiver != begin_node
        end

        def oneline_rescue_parentheses_required?(begin_node, node)
          return false unless node.rescue_type?
          return false unless (parent = begin_node.parent)
          return false if parent.if_type? && parent.ternary?
          return false if parent.conditional? && parent.condition == begin_node

          !parent.type?(:call, :array, :pair)
        end

        def method_call_parentheses_required?(node)
          return false unless node.call_type?

          (node.receiver.nil? || node.loc.dot) && node.arguments.any?
        end

        def allow_in_multiline_conditions?
          !!config.for_enabled_cop('Style/ParenthesesAroundCondition')['AllowInMultilineConditions']
        end

        def call_node?(node)
          node.call_type? || (node.any_block_type? && node.braces? && !node.lambda_or_proc?)
        end

        def check_send(begin_node, node)
          node = node.send_node if node.any_block_type?

          return check_unary(begin_node, node) if node.unary_operation?

          return unless method_call_with_redundant_parentheses?(begin_node, node)

          offense(begin_node, 'a method call')
        end

        def check_unary(begin_node, node)
          return if begin_node.chained?

          node = node.children.first while suspect_unary?(node)
          return unless method_call_with_redundant_parentheses?(begin_node, node)

          offense(begin_node, 'a unary operation')
        end

        def offense(node, msg)
          @pending_offenses << [node, "Don't use parentheses around #{msg}."]
        end

        # Each candidate's exact correction is applied to a copy of the source
        # and verified to parse to the same AST (modulo the removed grouping)
        # before the offense is registered, so redundancy never depends on
        # hand-maintained knowledge of Ruby's grammar. Candidates sharing a
        # reparse scope are verified together with a single reparse first,
        # falling back to per-candidate verification only when the batch does
        # not hold.
        def verified_offenses
          # Group by scope identity: structurally identical definitions in
          # different places must not share a group.
          groups = {}.compare_by_identity
          @pending_offenses.each do |offense|
            (groups[reparse_scope(offense.first)] ||= []) << offense
          end

          groups.flat_map do |scope, offenses|
            if offenses.one? || !batch_verified?(scope, offenses)
              offenses.select { |node, _| verified_correction?(scope, node) }
            else
              offenses
            end
          end
        end

        # Method definitions and class/module bodies neither capture outer
        # local variables nor continue an outer expression, so they parse
        # standalone. Blocks and single statements do not qualify: an outer
        # local would reparse as a method call.
        def reparse_scope(node)
          scope = node.each_ancestor(:any_def, :class, :module, :sclass).first
          scope if scope&.source_range&.contains?(node.source_range)
        end

        def batch_verified?(scope, offenses)
          corrector = Corrector.new(processed_source)
          offenses.map(&:first).each { |node| ParenthesesCorrector.correct(corrector, node) }

          corrected_source_verified?(scope, corrector.process)
        rescue ::Parser::ClobberingError
          false
        end

        def verified_correction?(scope, node)
          return true if scope && scope.source_range.size > MAX_VERIFICATION_FRAGMENT_SIZE

          corrector = Corrector.new(processed_source)
          ParenthesesCorrector.correct(corrector, node)

          corrected_source_verified?(scope, corrector.process)
        end

        # The correction's edits are all contained within the scope, so the
        # corrected fragment can be cut out of the corrected source by
        # adjusting for the edits' length delta.
        def corrected_source_verified?(scope, corrected)
          if scope
            delta = corrected.length - processed_source.raw_source.length
            scope_range = scope.source_range
            fragment = corrected[scope_range.begin_pos...(scope_range.end_pos + delta)]

            parses_fragment_identically_ignoring_grouping?(scope, fragment)
          else
            parses_identically_ignoring_grouping?(corrected)
          end
        end

        # `&&` and `||` cannot be redefined, so regrouping a chain of the same
        # operator (`x && (y && z)` to `x && y && z`) is semantically
        # transparent even though the trees differ; normalize both to left
        # association before comparing.
        def collapse_groupings(node)
          collapsed = super
          return collapsed unless collapsed.is_a?(::Parser::AST::Node)

          left, right = collapsed.children
          if collapsed.type?(:and, :or) &&
             right.is_a?(::Parser::AST::Node) && right.type == collapsed.type
            inner_left, inner_right = right.children
            collapsed = collapse_groupings(
              collapsed.updated(nil, [collapsed.updated(nil, [left, inner_left]), inner_right])
            )
          end

          collapsed
        end

        def suspect_unary?(node)
          node.send_type? && node.unary_operation? && !node.prefix_not?
        end

        def keyword_ancestor?(node)
          node.parent&.keyword?
        end

        def disallowed_literal?(begin_node, node)
          return true unless node.range_type?
          return false unless (parent = begin_node.parent)

          parent.begin_type? && parent.children.one?
        end

        # rubocop:disable Metrics/CyclomaticComplexity
        def body_range?(begin_node, node)
          return false if begin_node.chained?
          return false unless node.range_type?
          return false unless (parent = begin_node.parent)
          return false unless parent.begin_type?

          (node.begin.nil? && begin_node == parent.children.first) ||
            (node.end.nil? && begin_node == parent.children.last)
        end
        # rubocop:enable Metrics/CyclomaticComplexity

        def disallowed_one_line_pattern_matching?(begin_node, node)
          if (parent = begin_node.parent)
            return false if parent.any_def_type? && parent.endless?
            return false if parent.assignment?
          end

          node.any_match_pattern_type? && node.each_ancestor.none?(&:operator_keyword?)
        end

        def keyword_with_redundant_parentheses?(node)
          return false unless node.keyword?
          return true if node.special_keyword?

          args = *node

          if only_begin_arg?(args)
            parentheses?(args.first)
          else
            args.empty? || parentheses?(node)
          end
        end

        def method_call_with_redundant_parentheses?(begin_node, node)
          return false unless node.type?(:call, :super, :yield, :defined?)
          return false if node.prefix_not?
          return true if singular_parenthesized_parent?(begin_node)

          node.arguments.empty? || parentheses?(node) || square_brackets?(node)
        end

        def singular_parenthesized_parent?(begin_node)
          return true unless (parent = begin_node.parent)
          return false if parent.type?(:splat, :kwsplat)

          parent.children.one?
        end

        def only_begin_arg?(args)
          args.one? && args.first&.begin_type?
        end
      end
    end
  end
end
