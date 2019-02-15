# frozen_string_literal: true

module RuboCop
  # Find duplicated keys from YAML.
  module YAMLDuplicationChecker
    def self.check(yaml_string, filename, &on_duplicated)
      # Specify filename to display helpful message when it raises an error.
      tree = YAML.parse(yaml_string, filename: filename)
      return unless tree

      traverse(tree, &on_duplicated)
    end

    def self.traverse(tree, &on_duplicated)
      case tree
      when Psych::Nodes::Mapping
        tree.children.each_slice(2).with_object([]) do |(key, value), keys|
          exist = keys.find { |key2| key2.value == key.value }
          on_duplicated.call(exist, key) if exist
          keys << key
          traverse(value, &on_duplicated)
        end
      else
        children = tree.children
        return unless children

        children.each { |c| traverse(c, &on_duplicated) }
      end
    end

    private_class_method :traverse
  end
end
