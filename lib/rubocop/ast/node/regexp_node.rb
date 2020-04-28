# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `regexp` nodes. This will be used in place of a plain
    # node when the builder constructs the AST, making its methods available
    # to all `regexp` nodes within RuboCop.
    class RegexpNode < Node
      OPTIONS = {
        x: Regexp::EXTENDED,
        i: Regexp::IGNORECASE,
        m: Regexp::MULTILINE,
        n: Regexp::NOENCODING
      }.freeze

      # @return [Regexp] a regexp of this node
      def to_regexp
        option = regopt.children.map { |opt| OPTIONS[opt] }.inject(:|)
        Regexp.new(content, option)
      end

      # @return [RuboCop::AST::Node] a regopt node
      def regopt
        children.last
      end

      # @return [String] a string of regexp content
      def content
        children.select(&:str_type?).map(&:str_content).join
      end
    end
  end
end
