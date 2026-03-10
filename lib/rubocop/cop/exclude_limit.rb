# frozen_string_literal: true

module RuboCop
  # Allows specified configuration options to have an exclude limit
  # ie. a maximum value tracked that it can be used by `--auto-gen-config`.
  module ExcludeLimit
    class << self
      attr_accessor :tmp_dir

      # Reads the aggregated exclude limit values for a cop from tmp files.
      # Returns a hash like { 'Max' => 81 } or an empty hash if no values were written.
      def read_limits(cop_name)
        cop_dir = cop_dir_for(cop_name)
        return {} unless cop_dir&.directory?

        limits = {}
        cop_dir.children.each do |filepath|
          next unless filepath.file?

          values = filepath.readlines.map(&:to_i)
          limits[filepath.basename.to_s] = values.max unless values.empty?
        end
        limits
      end

      # Returns the tmp directory path for a given cop, or nil if tmp_dir is not set.
      def cop_dir_for(cop_name)
        tmp_dir&.join(cop_name.tr('/', '-'))
      end
    end

    # Sets up a configuration option to have an exclude limit tracked.
    # The parameter name given is transformed into a method name (eg. `Max`
    # becomes `self.max=` and `MinDigits` becomes `self.min_digits=`).
    def exclude_limit(parameter_name, method_name: transform(parameter_name))
      define_method(:"#{method_name}=") do |value|
        cop_dir = RuboCop::ExcludeLimit.cop_dir_for(self.class.badge.to_s)
        return unless cop_dir

        cop_dir.mkpath
        filepath = cop_dir.join(parameter_name)
        filepath.write("#{value}\n", mode: 'a')
      end
    end

    private

    def transform(parameter_name)
      parameter_name.gsub(/(?<!\A)(?=[A-Z])/, '_').downcase
    end
  end
end
