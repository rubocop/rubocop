# encoding: utf-8

module Rubocop
  module Cop
    class Token
      attr_reader :pos, :type, :text

      def initialize(pos, type, text)
        @pos, @type, @text = pos, type, text
      end

      def to_s
        "[[#{@pos.line}, #{@pos.column}], #{@type}, #{@text.inspect}]"
      end
    end

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

      def self.rails?
        false
      end

      def initialize
        @offences = []
        @debug = false
      end

      def inspect(source_buffer, source, tokens, ast, comments)
        if autocorrect
          filename = source.instance_variable_get(:@name)
          File.open(filename, 'w') { |f| f.write(rewrite(source, ast)) }
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
    end
  end
end
