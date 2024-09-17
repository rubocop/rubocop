# frozen_string_literal: true

module RuboCop
  # Find duplicated keys from YAML.
  # @api private
  module YAMLDuplicationChecker
    def self.check(yaml_string, filename, &on_duplicated)
      handler = DuplicationCheckHandler.new(&on_duplicated)
      parser = Psych::Parser.new(handler)
      parser.parse(yaml_string, filename)
      parser.handler.root.children[0]
    end

    class DuplicationCheckHandler < Psych::TreeBuilder # :nodoc:
      def initialize(&block)
        super()
        @block = block
      end

      def end_mapping
        mapping_node = super
        mapping_node.children.each_slice(2).with_object([]) do |(key, _value), keys|
          exist = keys.find { |key2| key2.value == key.value }
          @block.call(exist, key) if exist
          keys << key
        end
        mapping_node
      end
    end
  end
end
