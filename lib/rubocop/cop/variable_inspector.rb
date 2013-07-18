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
      VARIABLE_DECLARATION_TYPES =
        (VARIABLE_ASSIGNMENT_TYPES + ARGUMENT_DECLARATION_TYPES).freeze
      VARIABLE_USE_TYPES = [:lvar].freeze
      SCOPE_TYPES = [:module, :class, :sclass, :def, :defs, :block].freeze

      # A VariableEntry represents existance of a local variable.
      # This holds a variable declaration node,
      # and some states of the variable.
      class VariableEntry
        attr_reader :node
        attr_accessor :used
        alias_method :used?, :used

        def initialize(node, name = nil)
          unless VARIABLE_DECLARATION_TYPES.include?(node.type)
            fail ArgumentError,
                 "Node type must be any of #{VARIABLE_DECLARATION_TYPES}, " +
                 "passed #{node.type}"
          end
          @node = node
          @name = name.to_sym if name
          @used = false
        end

        def name
          @name || @node.children.first
        end
      end

      # A Scope represents a context of local variable visibility.
      # This is a place where local variables belong to.
      # A scope instance holds a scope node and variable entries.
      class Scope
        attr_reader :node, :variable_entries

        def initialize(node)
          # Accept begin node for top level scope.
          unless SCOPE_TYPES.include?(node.type) || node.type == :begin
            fail ArgumentError,
                 "Node type must be any of #{SCOPE_TYPES}, " +
                 "passed #{node.type}"
          end
          @node = node
          @variable_entries = {}
        end
      end

      # A VariableTable manages the lifetime of all scopes and local variables
      # in a program.
      # This holds scopes as stack structure, and provides a way to add local
      # variables to current scope and find local variables by considering
      # variable visibility of the current scope.
      class VariableTable
        def initialize(hook_receiver = nil)
          @hook_receiver = hook_receiver
        end

        def invoke_hook(hook_name, *args)
          @hook_receiver.send(hook_name, *args) if @hook_receiver
        end

        def scope_stack
          @scope_stack ||= []
        end

        def push_scope(scope_node)
          scope = Scope.new(scope_node)
          invoke_hook(:before_entering_scope, scope)
          scope_stack.push(scope)
          invoke_hook(:after_entering_scope, scope)
          scope
        end

        def pop_scope
          scope = current_scope
          invoke_hook(:before_leaving_scope, scope)
          scope_stack.pop
          invoke_hook(:after_leaving_scope, scope)
          scope
        end

        def current_scope
          scope_stack.last
        end

        def current_scope_level
          scope_stack.count
        end

        def add_variable_entry(variable_declaration_node, name = nil)
          entry = VariableEntry.new(variable_declaration_node, name)
          invoke_hook(:before_declaring_variable, entry)
          current_scope.variable_entries[entry.name] = entry
          invoke_hook(:after_declaring_variable, entry)
          entry
        end

        def find_variable_entry(variable_name)
          scope_stack.reverse_each do |scope|
            entry = scope.variable_entries[variable_name]
            return entry if entry
            # Only block scope allows referencing outer scope variables.
            return nil unless scope.node.type == :block
          end
          nil
        end
      end

      # This provides a way to scan all nodes only in current scope.
      class NodeScanner
        TWISTED_SCOPE_NODE_TYPES = [:block, :sclass, :defs].freeze

        def self.scan_nodes_in_scope(origin_node, &block)
          instance = new(block)
          instance.scan_nodes_in_scope(origin_node)
        end

        def initialize(callback)
          @callback = callback
        end

        def scan_nodes_in_scope(origin_node, yield_origin_node = false)
          @callback.call(origin_node) if yield_origin_node

          origin_node.children.each_with_index do |child, index|
            next unless child.is_a?(Parser::AST::Node)
            node = child

            if index == 0 &&
               TWISTED_SCOPE_NODE_TYPES.include?(origin_node.type)
              next
            end

            @callback.call(node)

            handle_scope_border(node)
          end
        end

        def handle_scope_border(node)
          case node.type
          when *TWISTED_SCOPE_NODE_TYPES
            # The variable foo belongs to the top level scope,
            # but in AST, it's under the block node.
            #
            # Ruby:
            #   some_method(foo = 1) do
            #   end
            #   puts foo
            #
            # AST:
            #   (begin
            #     (block
            #       (send nil :some_method
            #         (lvasgn :foo
            #           (int 1)))
            #       (args) nil)
            #     (send nil :puts
            #       (lvar :foo)))
            #
            # So the the method argument nodes need to be processed
            # in current scope.
            #
            # Same thing.
            #
            # Ruby:
            #   instance = Object.new
            #   class << instance
            #     foo = 1
            #   end
            #
            # AST:
            #   (begin
            #     (lvasgn :instance
            #       (send
            #         (const nil :Object) :new))
            #     (sclass
            #       (lvar :instance)
            #       (begin
            #         (lvasgn :foo
            #           (int 1))
            scan_nodes_in_scope(node.children.first, true)
          when *SCOPE_TYPES
            # Do not go into inner scope.
          else
            scan_nodes_in_scope(node)
          end
        end
      end

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
          variable_table.add_variable_entry(node)
        when :lvasgn
          variable_name = node.children.first
          process_variable_assignment(node, variable_name)
        when :match_with_lvasgn
          process_named_captures(node)
        when *VARIABLE_USE_TYPES
          variable_name = node.children.first
          variable_entry = variable_table.find_variable_entry(variable_name)
          unless variable_entry
            fail "Using undeclared local variable \"#{variable_name}\" " +
                 "at #{node.loc.expression}, #{node.inspect}"
          end
          variable_entry.used = true
        when *SCOPE_TYPES
          inspect_variables_in_scope(node)
        end
      end

      def process_variable_assignment(node, name)
        entry = variable_table.find_variable_entry(name)
        if entry
          entry.used = true
        else
          variable_table.add_variable_entry(node, name)
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

      def before_declaring_variable(variable_entry)
      end

      def after_declaring_variable(variable_entry)
      end
    end
  end
end
