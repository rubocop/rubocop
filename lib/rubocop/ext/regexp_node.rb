# frozen_string_literal: true

module RuboCop
  module Ext
    # Extensions to AST::RegexpNode for our cached parsed regexp info
    module RegexpNode
      ANY = Object.new
      def ANY.==(_)
        true
      end
      private_constant :ANY

      class << self
        attr_reader :parsed_cache
      end
      @parsed_cache = {}

      # @return [Regexp::Expression::Root, nil]
      def parsed_tree
        str = with_interpolations_blanked
        Ext::RegexpNode.parsed_cache[str] ||= begin
          Regexp::Parser.parse(str, options: options)
        rescue StandardError
          nil
        end
      end

      def each_capture(named: ANY)
        return enum_for(__method__, named: named) unless block_given?

        parsed_tree&.traverse do |event, exp, _index|
          yield(exp) if event == :enter &&
                        named == exp.respond_to?(:name) &&
                        exp.respond_to?(:capturing?) &&
                        exp.capturing?
        end

        self
      end

      private

      def with_interpolations_blanked
        # Ignore the trailing regopt node
        children[0...-1].map do |child|
          source = child.source

          # We don't want to consider the contents of interpolations as part of the pattern source,
          # but need to preserve their width, to allow offsets to correctly line up with the
          # original source: spaces have no effect, and preserve width.
          if child.begin_type?
            ' ' * source.length
          else
            source
          end
        end.join
      end

      AST::RegexpNode.include self
    end
  end
end
