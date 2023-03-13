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

      # @return [Regexp::Expression::Root, nil]
      # Note: we extend Regexp nodes to provide `loc` and `expression`
      # see `ext/regexp_parser`.
      attr_reader :parsed_tree

      if Gem::Version.new(Regexp::Parser::VERSION) >= Gem::Version.new('2.0')
        def assign_properties(*)
          super

          str = with_interpolations_blanked
          @parsed_tree = begin
            Regexp::Parser.parse(str, options: options)
          rescue StandardError
            nil
          end
          origin = loc.begin.end
          @parsed_tree&.each_expression(true) { |e| e.origin = origin }
        end
      # Please remove this `else` branch when support for regexp_parser 1.8 will be dropped.
      # It's for compatibility with regexp_parser 1.8 and will never be maintained.
      else
        def assign_properties(*)
          super

          str = with_interpolations_blanked
          begin
            @parsed_tree = Regexp::Parser.parse(str, options: options)
          rescue StandardError
            @parsed_tree = nil
          else
            origin = loc.begin.end
            source = @parsed_tree.to_s
            @parsed_tree.each_expression(true) do |e|
              e.origin = origin
              e.source = source
            end
          end
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
