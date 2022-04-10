# frozen_string_literal: true

module RuboCop
  class CLI
    module Command
      # Output a JSON Schema file for the for the current directory's RuboCop
      # configuration file.
      #
      # @api private
      class JSONSchema < Base
        # Cop attributes that shouldn't appear in a user config
        NON_USER_COP_KEYS = %w[
          Description StyleGuide Reference Safe SafeAutoCorrect VersionAdded
          VersionChanged
        ].freeze

        self.command_name = :json_schema

        def initialize(env)
          super

          # we need "require" so can't just do "@config_store.force_default_config!"
          stripped_config = build_stripped_config
          @config = load_stripped_config(stripped_config)
        end

        def run
          schema = build_json_schema
          puts JSON.pretty_generate(schema)
        end

        def build_json_schema
          cops = RuboCop::Cop::Registry.global
          department_definitions = build_department_definitions(cops)
          cop_definitions = cops.to_a.map do |cop|
            [cop.cop_name, build_cop_definition(cop)]
          end.to_h

          template_file = File.join(File.dirname(__FILE__), 'json_schema_template.yml')
          schema = YAML.safe_load(File.read(template_file))
          schema['properties'].merge!(department_definitions)
          schema['properties'].merge!(cop_definitions)
          schema
        end

        private

        # Take just the "require" part of the user config to get RuboCop to load
        # custom cops without also loading the user's settings.
        def build_stripped_config
          path = ConfigLoader.configuration_file_for(Dir.pwd)
          hash = ConfigLoader.load_yaml_configuration(path)
          hash.slice('require')
        end

        # RuboCop config init is tightly coupled to file loading, so we'll write
        # our stripped-down config into a tempfile and then read it.
        def load_stripped_config(stripped_config)
          require 'tempfile'

          Tempfile.open('rubocop_config_temp') do |f|
            f.write(stripped_config.to_yaml)
            f.rewind
            begin
              # silence RuboCop's "pending" warning
              old_verbose = $VERBOSE
              $VERBOSE = nil
              ConfigLoader.configuration_from_file(f.path)
            ensure
              $VERBOSE = old_verbose
            end
          end
        end

        def build_department_definitions(cops)
          cops.departments.map do |dept|
            [dept.to_s, { '$ref' => '#/definitions/copProperties' }]
          end.to_h
        end

        def build_cop_definition(cop)
          cop_config = @config.for_cop(cop)
          properties = get_cop_properties(cop)
          {
            'title' => cop.cop_name,
            # could add more metadata to description (safety, versions)
            'description' => cop_config['Description'],
            'allOf' => [
              { '$ref' => '#/definitions/copProperties' },
              { 'properties' => properties }
            ]
          }.compact
        end

        # One-off handling:
        # - 'Exclude' converts relative paths to absolute paths
        # - One of the rules has Float::INFINITY as its default
        def get_cop_properties(cop)
          cop_config = @config.for_cop(cop)
          attributes = cop_config.reject { |k| NON_USER_COP_KEYS.include?(k) }
          properties = {}
          attributes.each do |name, default|
            property = get_property_for_attribute(name, default, attributes)
            next unless property

            property['default'] = default if json_serializable?(default) && name != 'Exclude'

            properties[name] = property.compact
          end

          properties['AutoCorrect'] = { 'type' => 'boolean' } if cop.support_autocorrect?
          properties
        end

        # One-off handling:
        # - 'IndentationWidth' is { type: integer }
        # - Rails/BulkChangeTable#Databases acts like it's named
        #   "EnforcedDatabases" and gets its options from #SupportedDatabases
        # - Layout/MultilineAssignmentLayout#SupportedTypes starts with
        #   "Supported" but is actually a user-facing configuration attribute
        #   and not part of a Supported/Enforced pair.
        #
        # rubocop:disable Metrics/MethodLength
        def get_property_for_attribute(name, default, cop_attributes)
          case name
          # Attributes starting with "Supported" not user-configurable. They are
          # available options for a corresponding attribute starting with
          # "Enforced", except in a couple of cases.
          when /^Supported(?!Types$)/
            nil
          when /^Enforced/
            enum_name = RuboCop::Cop::Util.to_supported_styles(name)
            options = cop_attributes[enum_name]
            {
              'type' => 'string',
              'enum' => options
            }
          when 'Database'
            options = cop_attributes['SupportedDatabases']
            {
              'type' => 'string',
              'enum' => options
            }
          when 'IndentationWidth'
            { 'type' => 'integer' }
          when 'Enabled'
            {}
          else
            get_type_from_attribute_default(default)
          end
        end
        # rubocop:enable Metrics/MethodLength

        # return a JSON schema type based on the property's default value
        # rubocop:disable Metrics/MethodLength
        def get_type_from_attribute_default(default_value)
          case default_value
          when true, false
            { 'type' => 'boolean' }
          when String
            { 'type' => 'string' }
          when Integer
            { 'type' => 'integer' }
          when Float
            { 'type' => 'number' }
          when Array
            # always an array of strings so far
            { '$ref' => '#/definitions/stringArray' }
          when Hash
            # hard to make any assumptions beyond that it's an object
            { 'type' => 'object' }
          else
            # don't try to enforce a type otherwise
            {}
          end
        end
        # rubocop:enable Metrics/MethodLength

        # Don't use the default value if serializing it to json is going to
        # cause an error
        def json_serializable?(value)
          value != Float::INFINITY
        end
      end
    end
  end
end
