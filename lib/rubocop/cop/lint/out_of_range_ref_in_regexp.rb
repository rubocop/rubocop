# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cops looks for out of range referencing for Regexp, as while capturing groups out of
      # out of range reference always returns nil.

      # @example
      #   /(foo)bar/ =~ 'foobar'\

      #   # bad - always returns nil
      #   puts $2 # => nil

      #   # good
      #   puts $1 # => foo
      #
      class OutOfRangeRefInRegexp < Cop
        MSG = 'Do not use out of range reference for the Regexp.'

        def investigate(processed_source)
          ast = processed_source.ast
          valid_ref = cop_config['Count']
          ast.each_node do |node|
            if node.regexp_type?
              break if contain_non_literal?(node)

              tree = parse_node(node.content)
              break if tree.nil?

              valid_ref = regexp_captures(tree)
            elsif node.nth_ref_type?
              backref, = *node
              add_offense(node) if backref > valid_ref
            end
          end
        end

        private

        def contain_non_literal?(node)
          if node.respond_to?(:type) && (node.variable? || node.send_type? || node.const_type?)
            return true
          end
          return false unless node.respond_to?(:children)

          node.children.any? { |child| contain_non_literal?(child) }
        end

        def parse_node(content)
          Regexp::Parser.parse(content)
        rescue Regexp::Scanner::ScannerError
          nil
        end

        def regexp_captures(tree)
          named_capture = numbered_capture = 0
          tree.each_expression do |e|
            named_capture += 1 if e.instance_of?(Regexp::Expression::Group::Named)
            numbered_capture += 1 if e.instance_of?(Regexp::Expression::Group::Capture)
          end
          return named_capture if numbered_capture.zero?

          return numbered_capture if named_capture.zero?

          named_capture
        end
      end
    end
  end
end
