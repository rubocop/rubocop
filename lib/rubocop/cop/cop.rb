# encoding: utf-8

module Rubocop
  module Cop
    # A basic wrapper around Parser's tokens.
    class Token
      attr_reader :pos, :type, :text

      def initialize(pos, type, text)
        @pos, @type, @text = pos, type, text
      end

      def to_s
        "[[#{@pos.line}, #{@pos.column}], #{@type}, #{@text.inspect}]"
      end
    end

    # A scaffold for concrete cops.
    #
    # The Cop class is meant to be extended.
    #
    # Cops track offences and can autocorrect them of the fly.
    class Cop < Parser::Rewriter
      extend AST::Sexp

      attr_accessor :offences
      attr_accessor :debug
      attr_accessor :autocorrect
      attr_writer :disabled_lines

      @all = []
      @config = {}

      class << self
        attr_accessor :all
        attr_accessor :config
      end

      def self.inherited(subclass)
        all << subclass
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

      def self.rails?
        cop_type == :rails
      end

      def initialize
        @offences = []
        @debug = false
        @autocorrect = false
      end

      def inspect(source_buffer, source, tokens, ast, comments)
        if autocorrect
          filename = source_buffer.instance_variable_get(:@name)
          new_source = rewrite(source_buffer, ast)
          unless new_source == source_buffer.source
            File.open(filename, 'w') { |f| f.write(new_source) }
            source_buffer.instance_variable_set(:@source, nil)
            source_buffer.read
          end
        else
          process(ast)
        end
      end

      def do_autocorrect(node)
        autocorrect_action(node) if autocorrect
      end

      def autocorrect_action(node)
      end

      def ignore_node(node)
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

      private

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
