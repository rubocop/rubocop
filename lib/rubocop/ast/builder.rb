# frozen_string_literal: true

module RuboCop
  module AST
    # `RuboCop::Builder` is an AST builder that is utilized to let `Parser`
    # generate ASTs with {RuboCop::AST::Node}.
    #
    # @example
    #   buffer = Parser::Source::Buffer.new('(string)')
    #   buffer.source = 'puts :foo'
    #
    #   builder = RuboCop::Builder.new
    #   parser = Parser::CurrentRuby.new(builder)
    #   root_node = parser.parse(buffer)
    class Builder < Parser::Builders::Default
      NODE_MAP = {
        AndNode          => [:and],
        ArgsNode         => [:args],
        ArrayNode        => [:array],
        BlockNode        => [:block],
        CaseNode         => [:case],
        DefNode          => %i[def defs],
        EnsureNode       => [:ensure],
        ForNode          => [:for],
        HashNode         => [:hash],
        IfNode           => [:if],
        KeywordSplatNode => [:kwsplat],
        OrNode           => [:or],
        PairNode         => [:pair],
        RegexpNode       => [:regexp],
        ResbodyNode      => [:resbody],
        SendNode         => %i[csend send],
        SuperNode        => %i[super zsuper],
        UntilNode        => %i[until until_post],
        WhenNode         => [:when],
        WhileNode        => %i[while while_post],
        YieldNode        => [:yield]
      }.freeze

      # Generates {Node} from the given information.
      #
      # @return [Node] the generated node
      def n(type, children, source_map)
        node_klass(type).new(type, children, location: source_map)
      end

      # TODO: Figure out what to do about literal encoding handling...
      # More details here https://github.com/whitequark/parser/issues/283
      def string_value(token)
        value(token)
      end

      private

      def node_klass(type)
        node_map[type] || Node
      end

      # Take the human readable constant and generate a hash map where each
      # (mapped) node type is a key with its constant as the value.
      def node_map
        @node_map ||= begin
          NODE_MAP.each_pair.each_with_object({}) do |(klass, types), map|
            types.each { |type| map[type] = klass }
          end
        end
      end
    end
  end
end
