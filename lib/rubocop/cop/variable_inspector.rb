# encoding: utf-8

module Rubocop
  module Cop
    # This module provides a way to track local variables and scopes of Ruby.
    # This is intended to be used as mix-in, and the user class may override
    # some of hook methods.
    module VariableInspector
      VARIABLE_ASSIGNMENT_TYPES = [:lvasgn, :match_with_lvasgn].freeze
      ARGUMENT_DECLARATION_TYPES = [
        :arg, :optarg, :restarg, :blockarg,
        :kwarg, :kwoptarg, :kwrestarg,
        :shadowarg
      ].freeze
      VARIABLE_USE_TYPES = [:lvar].freeze
      SCOPE_TYPES = [:module, :class, :sclass, :def, :defs, :block].freeze

      def variable_table
        @variable_table ||= VariableTable.new(self)
      end

      # Starting point.
      def inspect_variables(root_node)
        return unless root_node

        # Wrap with begin node if it's standalone node.
        unless root_node.type == :begin
          root_node = Parser::AST::Node.new(:begin, [root_node])
        end

        inspect_variables_in_scope(root_node)
      end

      # This is called for each scope recursively.
      def inspect_variables_in_scope(scope_node)
        variable_table.push_scope(scope_node)

        NodeScanner.scan_nodes_in_scope(scope_node) do |node|
          # puts "scope:#{variable_table.current_scope_level} node:#{node}"
          process_node(node)
        end

        variable_table.pop_scope
      end

      def process_node(node)
        case node.type
        when *ARGUMENT_DECLARATION_TYPES
          variable_table.add_variable(node)
        when :lvasgn
          variable_name = node.children.first
          process_variable_assignment(node, variable_name)
        when :match_with_lvasgn
          process_named_captures(node)
        when *VARIABLE_USE_TYPES
          variable_name = node.children.first
          variable = variable_table.find_variable(variable_name)
          unless variable
            fail "Using undeclared local variable \"#{variable_name}\" " +
                 "at #{node.loc.expression}, #{node.inspect}"
          end
          variable.used = true
        when *SCOPE_TYPES
          inspect_variables_in_scope(node)
        end
      end

      def process_variable_assignment(node, name)
        variable = variable_table.find_variable(name)
        if variable
          variable.used = true
        else
          variable_table.add_variable(node, name)
        end
      end

      def process_named_captures(match_with_lvasgn_node)
        regexp_string = match_with_lvasgn_node.children[0]
                                              .children[0]
                                              .children[0]
        regexp = Regexp.new(regexp_string)
        variable_names = regexp.named_captures.keys

        variable_names.each do |name|
          process_variable_assignment(match_with_lvasgn_node, name)
        end
      end

      # Hooks

      def before_entering_scope(scope)
      end

      def after_entering_scope(scope)
      end

      def before_leaving_scope(scope)
      end

      def after_leaving_scope(scope)
      end

      def before_declaring_variable(variable)
      end

      def after_declaring_variable(variable)
      end
    end
  end
end
