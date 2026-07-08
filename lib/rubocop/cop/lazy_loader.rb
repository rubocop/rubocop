# frozen_string_literal: true

module RuboCop
  module Cop
    # Extend a department module with this module and call `register_cop` to register
    # the department's cops with the global registry without loading their files until
    # a cop class itself is needed:
    #
    #   module RuboCop
    #     module Cop
    #       # The Foo department.
    #       module Foo
    #         extend LazyLoader
    #
    #         register_cop :BarBaz, "#{__dir__}/foo/bar_baz"
    #       end
    #     end
    #   end
    module LazyLoader
      # Registers a cop for lazy loading. The cop appears in the registry by name right away,
      # but its file is loaded only when the cop class is needed, e.g. when the cop is enabled
      # for an inspection run.
      #
      # The path must be absolute so that loading does not depend on `$LOAD_PATH` and cannot resolve
      # to another RuboCop installation.
      #
      # @param constant_name [Symbol] name of the cop class, e.g. `:BarBaz`
      # @param path [String] absolute path to the file defining the cop class,
      #   with or without the `.rb` extension
      def register_cop(constant_name, path)
        raise ArgumentError, "cop path must be absolute: #{path}" unless File.absolute_path?(path)

        autoload constant_name, path

        qualified_name = "#{name}::#{constant_name}"

        Registry.global.lazy_load(Badge.for(qualified_name), qualified_name)
      end
    end
  end
end
