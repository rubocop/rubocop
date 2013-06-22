# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop looks for unused local variables in each scope.
      # Actually this is a mimic of the warning
      # "assigned but unused variable - foo" from `ruby -cw`.
      class UnusedLocalVariable < Cop
        class VariableEntry
          attr_reader :node
          attr_accessor :used
          alias_method :used?, :used

          def initialize(node)
            unless VARIABLE_DECLARATION_TYPES.include?(node.type)
              fail ArgumentError,
                   "Node type must be any of #{VARIABLE_DECLARATION_TYPES}, " +
                   "passed #{node.type}"
            end
            @node = node
            @used = false
          end

          def name
            @node.children.first
          end
        end

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

        class VariableTable
          def scope_stack
            @scope_stack ||= []
          end

          def push_scope(scope_node)
            scope_stack.push(Scope.new(scope_node))
          end

          def pop_scope
            scope_stack.pop
          end

          def current_scope
            scope_stack.last
          end

          def current_scope_level
            scope_stack.count
          end

          def add_variable_entry(variable_declaration_node)
            entry = VariableEntry.new(variable_declaration_node)
            current_scope.variable_entries[entry.name] = entry
          end

          def find_variable_entry(variable_name)
            # Block allows referencing outer scope variables.
            if current_scope.node.type == :block
              scope_stack.reverse_each do |scope|
                entry = scope.variable_entries[variable_name]
                return entry if entry
              end
              nil
            else
              current_scope.variable_entries[variable_name]
            end
          end
        end

        class NodeScanner
          def self.scan_nodes_in_scope(origin_node, &block)
            new.scan_nodes_in_scope(origin_node, &block)
          end

          def initialize
            @node_index = 0
          end

          def scan_nodes_in_scope(origin_node, &block)
            origin_node.children.each do |child|
              next unless child.is_a?(Parser::AST::Node)
              node = child

              catch(:skip_children) do
                yield node, @node_index

                # Do not go into inner scope.
                unless SCOPE_TYPES.include?(node.type)
                  scan_nodes_in_scope(node, &block)
                end
              end

              @node_index += 1
            end
          end
        end

        VARIABLE_ASSIGNMENT_TYPES = [:lvasgn].freeze
        ARGUMENT_DECLARATION_TYPES = [
          :arg, :optarg, :restarg, :blockarg,
          :kwarg, :kwoptarg, :kwsplatarg
        ].freeze
        VARIABLE_DECLARATION_TYPES =
          (VARIABLE_ASSIGNMENT_TYPES + ARGUMENT_DECLARATION_TYPES).freeze
        VARIABLE_USE_TYPES = [:lvar].freeze
        TYPES_TO_ACCEPT_UNUSED = ARGUMENT_DECLARATION_TYPES
        SCOPE_TYPES = [:module, :class, :sclass, :def, :block].freeze

        MSG = 'Assigned but unused variable - %s'

        def inspect(source_buffer, source, tokens, ast, comments)
          return unless ast

          # Wrap with begin node if it's standalone node.
          ast = Parser::AST::Node.new(:begin, [ast]) unless ast.type == :begin

          detect_unused_variables_in_scope(ast)
        end

        def variable_table
          @variable_table ||= VariableTable.new
        end

        def detect_unused_variables_in_scope(scope_node)
          variable_table.push_scope(scope_node)

          NodeScanner.scan_nodes_in_scope(scope_node) do |node, index|
            if scope_node.type == :block && index == 0 && node.type == :send
              # Avoid processing method argument nodes of outer scope
              # in current block scope.
              # See #process_node.
              throw :skip_children
            elsif scope_node.type == :sclass && index == 0
              throw :skip_children
            end

            process_node(node)
          end

          finishing_scope = variable_table.pop_scope
          finishing_scope.variable_entries.each_value do |entry|
            next if entry.used?
            next if TYPES_TO_ACCEPT_UNUSED.include?(entry.node.type)
            next if entry.name.to_s.start_with?('_')
            message = sprintf(MSG, entry.name)
            add_offence(:warning, entry.node.loc.expression, message)
          end
        end

        def process_node(node)
          case node.type
          when *ARGUMENT_DECLARATION_TYPES
            variable_table.add_variable_entry(node)
          when *VARIABLE_ASSIGNMENT_TYPES
            variable_name = node.children.first
            variable_entry = variable_table.find_variable_entry(variable_name)
            if variable_entry
              variable_entry.used = true
            else
              variable_table.add_variable_entry(node)
            end
          when *VARIABLE_USE_TYPES
            variable_name = node.children.first
            variable_entry = variable_table.find_variable_entry(variable_name)
            unless variable_entry
              fail "Using undeclared local variable \"#{variable_name}\" " +
                   "at #{node.loc.expression}, #{node.inspect}"
            end
            variable_entry.used = true
          when :block
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
            # So the nodes of the method argument need to be processed
            # in current scope before dive into the block scope.
            send_node = node.children.first
            NodeScanner.scan_nodes_in_scope(send_node) do |n|
              process_node(n)
            end
            # Now go into the block scope.
            detect_unused_variables_in_scope(node)
          when :sclass
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
            variable_node = node.children.first
            process_node(variable_node)
            detect_unused_variables_in_scope(node)
          when *SCOPE_TYPES
            detect_unused_variables_in_scope(node)
          end
        end
      end
    end
  end
end
