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
          CLASSLIKE_TYPES = %i[class module].freeze
          private_constant :FOLDABLE_TYPES, :CLASSLIKE_TYPES

          def initialize(node, processed_source, count_comments: false, foldable_types: [])
            @node = node
            @processed_source = processed_source
            @count_comments = count_comments
            @foldable_checks = build_foldable_checks(foldable_types)
            @foldable_types = normalize_foldable_types(foldable_types)
          end

          def calculate
            length = code_length(@node)
            return length if @foldable_types.empty?

            each_top_level_descendant(@node, @foldable_types) do |descendant|
              next unless foldable_node?(descendant)

              descendant_length = code_length(descendant)
              length = length - descendant_length + 1
              # Subtract 2 length of opening and closing brace if method argument omits hash braces.
              length -= 2 if descendant.hash_type? && !descendant.braces?
            end

            length
          end

          private

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
            if classlike_node?(node)
              classlike_code_length(node)
            elsif heredoc_node?(node)
              heredoc_length(node)
            else
              body = extract_body(node)
              return 0 unless body

              body.source.each_line.count { |line| !irrelevant_line?(line) }
            end
          end

          def heredoc_node?(node)
            node.respond_to?(:heredoc?) && node.heredoc?
          end

          def classlike_code_length(node)
            return 0 if namespace_module?(node)

            body_line_numbers = line_range(node).to_a[1...-1]

            target_line_numbers = body_line_numbers -
                                  line_numbers_of_inner_nodes(node, :module, :class)

            target_line_numbers.reduce(0) do |length, line_number|
              source_line = @processed_source[line_number]
              next length if irrelevant_line?(source_line)

              length + 1
            end
          end

          def namespace_module?(node)
            classlike_node?(node.body)
          end

          def line_numbers_of_inner_nodes(node, *types)
            line_numbers = Set.new

            node.each_descendant(*types) do |inner_node|
              line_range = line_range(inner_node)
              line_numbers.merge(line_range)
            end

            line_numbers.to_a
          end

          def heredoc_length(node)
            lines = node.loc.heredoc_body.source.lines
            lines.count { |line| !irrelevant_line?(line) } + 2
          end

          def each_top_level_descendant(node, types, &block)
            node.each_child_node do |child|
              next if classlike_node?(child)

              if types.include?(child.type)
                yield child
              else
                each_top_level_descendant(child, types, &block)
              end
            end
          end

          def classlike_node?(node)
            CLASSLIKE_TYPES.include?(node&.type)
          end

          def foldable_node?(node)
            @foldable_checks.any? { |check| check.call(node) }
          end

          def extract_body(node)
            case node.type
            when :class, :module, :block, :numblock, :def, :defs
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
            source_line.blank? || (!count_comments? && comment_line?(source_line))
          end

          def count_comments?
            @count_comments
          end
        end
      end
    end
  end
end
