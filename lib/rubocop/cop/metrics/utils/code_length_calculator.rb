# frozen_string_literal: true

module RuboCop
  module Cop
    module Metrics
      module Utils
        # Helps to calculate code length for the provided node.
        class CodeLengthCalculator
          extend NodePattern::Macros
          include Util

          FOLDABLE_TYPES = %i[array hash heredoc].freeze
          CLASSISH_TYPES = %i[class module].freeze

          def initialize(node, count_comments: false, foldable_types: [])
            @node = node
            @count_comments = count_comments
            @foldable_checks = build_foldable_checks(foldable_types)
            @foldable_types = normalize_foldable_types(foldable_types)
          end

          def calculate
            length = code_length(@node)

            each_top_level_descendant(@node, *@foldable_types, *CLASSISH_TYPES) do |descendant|
              descendant_length = code_length(descendant)

              if classlike_node?(descendant)
                length -= (descendant_length + 2)
              elsif foldable_node?(descendant)
                length = length - descendant_length + 1
              end
            end

            length
          end

          private

          def_node_matcher :class_definition?, <<~PATTERN
            (casgn nil? _ (block (send (const nil? :Class) :new) ...))
          PATTERN

          def_node_matcher :module_definition?, <<~PATTERN
            (casgn nil? _ (block (send (const nil? :Module) :new) ...))
          PATTERN

          def build_foldable_checks(types)
            types.map do |type|
              case type
              when :array
                ->(node) { node.array_type? }
              when :hash
                ->(node) { node.hash_type? }
              when :heredoc
                ->(node) { heredoc_node?(node) }
              else
                raise ArgumentError, "Unknown foldable type: #{type.inspect}. "\
                  "Valid foldable types are: #{FOLDABLE_TYPES.join(', ')}."
              end
            end
          end

          def normalize_foldable_types(types)
            types.concat(%i[str dstr]) if types.delete(:heredoc)
            types
          end

          def code_length(node)
            return heredoc_length(node) if heredoc_node?(node)

            body = extract_body(node)
            lines = body&.source&.lines || []
            lines.count { |line| !irrelevant_line?(line) }
          end

          def heredoc_node?(node)
            node.respond_to?(:heredoc?) && node.heredoc?
          end

          def heredoc_length(node)
            lines = node.loc.heredoc_body.source.lines
            lines.count { |line| !irrelevant_line?(line) } + 2
          end

          def each_top_level_descendant(node, *types, &block)
            node.each_child_node do |child|
              if types.include?(child.type)
                yield child
              else
                each_top_level_descendant(child, *types, &block)
              end
            end
          end

          def classlike_node?(node)
            CLASSISH_TYPES.include?(node.type) ||
              (node.casgn_type? && (class_definition?(node) || module_definition?(node)))
          end

          def foldable_node?(node)
            @foldable_checks.any? { |check| check.call(node) }
          end

          def extract_body(node)
            case node.type
            when :class, :module, :block, :def, :defs
              node.body
            when :casgn
              _scope, _name, value = *node
              extract_body(value)
            else
              node
            end
          end

          # Returns true for lines that shall not be included in the count.
          def irrelevant_line?(source_line)
            source_line.blank? || !count_comments? && comment_line?(source_line)
          end

          def count_comments?
            @count_comments
          end
        end
      end
    end
  end
end
