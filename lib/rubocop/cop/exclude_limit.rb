# frozen_string_literal: true

module RuboCop
  # Allows specified configuration options to have an exclude limit
  # ie. a maximum value tracked that it can be used by `--auto-gen-config`.
  module ExcludeLimit
    class << self
      attr_accessor :tmp_dir
    end

    # Sets up a configuration option to have an exclude limit tracked.
    # The parameter name given is transformed into a method name (eg. `Max`
    # becomes `self.max=` and `MinDigits` becomes `self.min_digits=`).
    def exclude_limit(parameter_name, method_name: transform(parameter_name))
      define_method(:"#{method_name}=") do |value|
        return unless (tmp_dir = RuboCop::ExcludeLimit.tmp_dir)

        # Create a directory for this cop and a file for the parameter
        # e.g., "Layout-LineLength/Max"
        cop_name = self.class.badge.to_s.tr('/', '-')
        cop_dir = tmp_dir.join(cop_name)
        cop_dir.mkpath
        filepath = cop_dir.join(parameter_name)

        # Append the value to the file (multiple processes may write)
        filepath.write("#{value}\n", mode: 'a')
      end
    end

    private

    def transform(parameter_name)
      parameter_name.gsub(/(?<!\A)(?=[A-Z])/, '_').downcase
    end
  end
end
