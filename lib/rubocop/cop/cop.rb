# encoding: utf-8

module Rubocop
  module Cop
    # Store for all cops with helper functions
    class CopStore < ::Array

      # @return [Array<String>] list of types for current cops.
      def types
        @types = map(&:cop_type).uniq! unless defined? @types
        @types
      end

      # @return [Array<Cop>] Cops for that specific type.
      def with_type(type)
        select { |c| c.cop_type == type }
      end
    end

    # A scaffold for concrete cops.
    #
    # The Cop class is meant to be extended.
    #
    # Cops track offences and can autocorrect them of the fly.
    #
    # A commissioner object is responsible for traversing the AST and invoking
    # the specific callbacks on each cop.
    # If a cop needs to do its own processing of the AST or depends on
    # something else it should define the `#investigate` method and do
    # the processing there.
    #
    # @example
    #
    #   class CustomCop < Cop
    #     def investigate(processed_source)
    #       # Do custom processing
    #     end
    #   end
    class Cop
      extend AST::Sexp

      attr_accessor :offences
      attr_accessor :debug
      attr_accessor :autocorrect
      attr_writer :disabled_lines
      attr_reader :corrections

      @all = CopStore.new
      @config = {}

      class << self
        attr_accessor :config
      end

      def self.all
        @all.clone
      end

      def self.inherited(subclass)
        @all << subclass
      end

      def self.cop_name
        name.to_s.split('::').last
      end

      def self.cop_type
        name.to_s.split('::')[-2].downcase.to_sym
      end

      def self.style?
        cop_type == :style
      end

      def self.lint?
        cop_type == :lint
      end

      # Extracts the first line out of the description
      def self.short_description
        desc = full_description
        desc ? desc.lines.first.strip : ''
      end

      # Gets the full description of the cop or nil if no description is set.
      def self.full_description
        config['Description']
      end

      def self.rails?
        cop_type == :rails
      end

      def initialize
        @offences = []
        @debug = false
        @autocorrect = false
        @ignored_nodes = []
        @corrections = []
      end

      def do_autocorrect(node, *args)
        autocorrect_action(node, *args) if autocorrect
      end

      def autocorrect_action(node, *args)
      end

      def add_offence(severity, location, message)
        unless @disabled_lines && @disabled_lines.include?(location.line)
          message = debug ? "#{name}: #{message}" : message
          @offences << Offence.new(severity, location, message, name)
        end
      end

      def name
        self.class.cop_name
      end

      def ignore_node(node)
        @ignored_nodes << node
      end

      private

      def part_of_ignored_node?(node)
        expression = node.loc.expression
        @ignored_nodes.each do |ignored_node|
          if ignored_node.loc.expression.begin_pos <= expression.begin_pos &&
            ignored_node.loc.expression.end_pos >= expression.end_pos
            return true
          end
        end

        false
      end

      def ignored_node?(node)
        @ignored_nodes.include?(node)
      end

      def on_node(syms, sexp, excludes = [])
        yield sexp if Array(syms).include?(sexp.type)

        return if Array(excludes).include?(sexp.type)

        sexp.children.each do |elem|
          if elem.is_a?(Parser::AST::Node)
            on_node(syms, elem, excludes) { |s| yield s }
          end
        end
      end

      def command?(name, node)
        return unless node.type == :send

        receiver, method_name, _args = *node

        # commands have no explicit receiver
        !receiver && method_name == name
      end

      def source_range(source_buffer, preceding_lines, begin_column,
                       column_count)
        newline_length = 1
        begin_pos = preceding_lines.reduce(0) do |a, e|
          a + e.length + newline_length
        end + begin_column
        Parser::Source::Range.new(source_buffer, begin_pos,
                                  begin_pos + column_count)
      end
    end
  end
end
