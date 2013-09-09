# encoding: utf-8

module ASTHelper
  def scan_node(node, options = {}, &block)
    yield node if options[:include_origin_node]

    node.children.each do |child|
      next unless child.is_a?(Parser::AST::Node)
      yield child
      scan_node(child, &block)
    end

    nil
  end
end
