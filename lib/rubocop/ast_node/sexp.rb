# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  # This module provides a shorthand method to create a {Node} like `AST::Sexp`.
  #
  # @see http://rubydoc.info/gems/ast/AST/Sexp
  module Sexp
    # Creates a {Node} with type `type` and children `children`.
    def s(type, *children)
      Node.new(type, children)
    end
  end
end
