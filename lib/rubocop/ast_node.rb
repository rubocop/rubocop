# encoding: utf-8

require 'astrolabe/node'

module Astrolabe
  # RuboCop's extensions to Astrolabe::Node (which extends Parser::AST::Node)
  #
  # Contribute as much of this as possible to the `astrolabe` gem
  # If any of it is accepted, it can be deleted from here
  #
  class Node
    # def_matcher can be used to define a pattern-matching method on Node:
    class << self
      extend RuboCop::NodePattern::Macros

      # define both Node.method_name(node), and also node.method_name
      def def_matcher(method_name, pattern_str)
        singleton_class.def_node_matcher method_name, pattern_str
        class_eval("def #{method_name}; Node.#{method_name}(self); end")
      end
    end

    ## Destructuring

    def_matcher :method_name, '{(send _ $_ ...) (block (send _ $_ ...) ...)}'
    # Note: for masgn, #asgn_rhs will be an array node
    def_matcher :asgn_rhs, '[assignment? (... $_)]'

    ## Predicates

    def multiline?
      expr = loc.expression
      expr && (expr.first_line != expr.last_line)
    end

    def single_line?
      !multiline?
    end

    def asgn_method_call?
      method_name != :== && method_name.to_s.end_with?('=')
    end

    def_matcher :equals_asgn?, '{lvasgn ivasgn cvasgn gvasgn casgn masgn}'
    def_matcher :shorthand_asgn?, '{op_asgn or_asgn and_asgn}'
    def_matcher :assignment?, '{equals_asgn? shorthand_asgn? asgn_method_call?}'
  end
end
