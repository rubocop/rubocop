# encoding: utf-8

require 'astrolabe/node'

module Astrolabe
  # RuboCop's extensions to Astrolabe::Node (which extends Parser::AST::Node)
  #
  # Contribute as much of this as possible to the `astrolabe` gem
  # If any of it is accepted, it can be deleted from here
  #
  class Node
    def multiline?
      expr = loc.expression
      expr && (expr.first_line != expr.last_line)
    end
  end
end
