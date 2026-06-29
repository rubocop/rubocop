# frozen_string_literal: true

module RuboCop
  # Exposes a method to autoload a cop class and lazy-load the cop in the registry
  module CopLazyLoader
    def register_cop(constant_name, require_path)
      autoload constant_name, require_path

      fully_qualified_constant_name = "#{name}::#{constant_name}"
      cop_name = RuboCop::Cop::Badge.for(fully_qualified_constant_name).to_s
      RuboCop::Cop::Registry.global.lazy_load(cop_name, fully_qualified_constant_name)
    end
  end
end
