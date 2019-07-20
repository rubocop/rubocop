# frozen_string_literal: true

module RuboCop
  # This class handles obsolete configuration.
  class ConfigObsoletion
    RENAMED_COPS = {
      'Style/SingleSpaceBeforeFirstArg' => 'Layout/SpaceBeforeFirstArg',
      'Style/MethodCallParentheses' => 'Style/MethodCallWithoutArgsParentheses',
      'Style/DeprecatedHashMethods' => 'Style/PreferredHashMethods',
      'Style/OpMethod' => 'Naming/BinaryOperatorParameterName',
      'Layout/FirstParameterIndentation' => 'Layout/IndentFirstArgument',
      'Layout/IndentArray' => 'Layout/IndentFirstArrayElement',
      'Layout/IndentHash' => 'Layout/IndentFirstHashElement'
    }.map do |old_name, new_name|
      [old_name, "The `#{old_name}` cop has been renamed to `#{new_name}`."]
    end

    MOVED_COPS = {
      'Security' => 'Lint/Eval',
      'Naming' => %w[Style/ClassAndModuleCamelCase Style/ConstantName
                     Style/FileName Style/MethodName Style/PredicateName
                     Style/VariableName Style/VariableNumber
                     Style/AccessorMethodName Style/AsciiIdentifiers],
      'Layout' => %w[Lint/BlockAlignment Lint/EndAlignment
                     Lint/DefEndAlignment],
      'Lint' => 'Style/FlipFlop'
    }.map do |new_department, old_names|
      Array(old_names).map do |old_name|
        [old_name, "The `#{old_name}` cop has been moved to " \
                   "`#{new_department}/#{old_name.split('/').last}`."]
      end
    end

    REMOVED_COPS = {
      'Rails/DefaultScope' => nil,
      'Layout/SpaceAfterControlKeyword' => 'Layout/SpaceAroundKeyword',
      'Layout/SpaceBeforeModifierKeyword' => 'Layout/SpaceAroundKeyword',
      'Style/SpaceAfterControlKeyword' => 'Layout/SpaceAroundKeyword',
      'Style/SpaceBeforeModifierKeyword' => 'Layout/SpaceAroundKeyword',
      'Style/TrailingComma' => 'Style/TrailingCommaInArguments, ' \
                               'Style/TrailingCommaInArrayLiteral, and/or ' \
                               'Style/TrailingCommaInHashLiteral',
      'Style/TrailingCommaInLiteral' => 'Style/TrailingCommaInArrayLiteral ' \
                                        'and/or ' \
                                        'Style/TrailingCommaInHashLiteral',
      'Lint/RescueWithoutErrorClass' => 'Style/RescueStandardError'
    }.map do |old_name, other_cops|
      if other_cops
        more = ". Please use #{other_cops} instead".gsub(%r{[A-Z]\w+/\w+},
                                                         '`\&`')
      end
      [old_name, "The `#{old_name}` cop has been removed#{more}."]
    end

    REMOVED_COPS_WITH_REASON = {
      'Lint/InvalidCharacterLiteral' => 'it was never being actually triggered',
      'Lint/SpaceBeforeFirstArg' =>
        'it was a duplicate of `Layout/SpaceBeforeFirstArg`. Please use ' \
        '`Layout/SpaceBeforeFirstArg` instead'
    }.map do |cop_name, reason|
      [cop_name, "The `#{cop_name}` cop has been removed since #{reason}."]
    end

    SPLIT_COPS = {
      'Style/MethodMissing' =>
        'The `Style/MethodMissing` cop has been split into ' \
        '`Style/MethodMissingSuper` and `Style/MissingRespondToMissing`.'
    }.to_a

    OBSOLETE_COPS = Hash[*(RENAMED_COPS + MOVED_COPS + REMOVED_COPS +
                           REMOVED_COPS_WITH_REASON + SPLIT_COPS).flatten]

    OBSOLETE_PARAMETERS = [
      {
        cops: %w[Layout/SpaceAroundOperators Style/SpaceAroundOperators],
        parameters: 'MultiSpaceAllowedForOperators',
        alternative: 'If your intention was to allow extra spaces for ' \
                     'alignment, please use AllowForAlignment: true instead.'
      },
      {
        cops: 'Style/Encoding',
        parameters: %w[EnforcedStyle SupportedStyles
                       AutoCorrectEncodingComment],
        alternative: 'Style/Encoding no longer supports styles. ' \
                     'The "never" behavior is always assumed.'
      },
      {
        cops: 'Style/IfUnlessModifier',
        parameters: 'MaxLineLength',
        alternative: '`Style/IfUnlessModifier: MaxLineLength` has been ' \
                     'removed. Use `Metrics/LineLength: Max` instead'
      },
      {
        cops: 'Style/WhileUntilModifier',
        parameters: 'MaxLineLength',
        alternative: '`Style/WhileUntilModifier: MaxLineLength` has been ' \
                     'removed. Use `Metrics/LineLength: Max` instead'
      },
      {
        cops: 'AllCops',
        parameters: 'RunRailsCops',
        alternative: "Use the following configuration instead:\n" \
                     "Rails:\n  Enabled: true"
      },
      {
        cops: 'Layout/CaseIndentation',
        parameters: 'IndentWhenRelativeTo',
        alternative: '`IndentWhenRelativeTo` has been renamed to ' \
                     '`EnforcedStyle`'
      },
      {
        cops: %w[Lint/BlockAlignment Layout/BlockAlignment Lint/EndAlignment
                 Layout/EndAlignment Lint/DefEndAlignment
                 Layout/DefEndAlignment],
        parameters: 'AlignWith',
        alternative: '`AlignWith` has been renamed to `EnforcedStyleAlignWith`'
      },
      {
        cops: 'Rails/UniqBeforePluck',
        parameters: 'EnforcedMode',
        alternative: '`EnforcedMode` has been renamed to `EnforcedStyle`'
      }
    ].freeze

    OBSOLETE_ENFORCED_STYLES = [
      {
        cop: 'Layout/IndentationConsistency',
        parameter: 'EnforcedStyle',
        enforced_style: 'rails',
        alternative: '`EnforcedStyle: rails` has been renamed to ' \
                     '`EnforcedStyle: indented_internal_methods`'
      }
    ].freeze

    def initialize(config)
      @config = config
    end

    def reject_obsolete_cops_and_parameters
      messages = [obsolete_cops, obsolete_parameters,
                  obsolete_enforced_style].flatten.compact
      return if messages.empty?

      raise ValidationError, messages.join("\n")
    end

    private

    def obsolete_cops
      OBSOLETE_COPS.map do |cop_name, message|
        next unless @config.key?(cop_name) ||
                    @config.key?(Cop::Badge.parse(cop_name).cop_name)

        message + "\n(obsolete configuration found in " \
                  "#{smart_loaded_path}, please update it)"
      end
    end

    def obsolete_enforced_style
      OBSOLETE_ENFORCED_STYLES.map do |params|
        obsolete_enforced_style_message(params[:cop], params[:parameter],
                                        params[:enforced_style],
                                        params[:alternative])
      end
    end

    def obsolete_enforced_style_message(cop, param, enforced_style, alternative)
      style = @config[cop]&.detect { |key, _| key.start_with?(param) }

      return unless style && style[1] == enforced_style

      "obsolete `#{param}: #{enforced_style}` (for #{cop}) found in " \
      "#{smart_loaded_path}\n#{alternative}"
    end

    def obsolete_parameters
      OBSOLETE_PARAMETERS.map do |params|
        obsolete_parameter_message(params[:cops], params[:parameters],
                                   params[:alternative])
      end
    end

    def obsolete_parameter_message(cops, parameters, alternative)
      Array(cops).map do |cop|
        obsolete_parameters = Array(parameters).select do |param|
          @config[cop]&.key?(param)
        end
        next if obsolete_parameters.empty?

        obsolete_parameters.map do |parameter|
          "obsolete parameter #{parameter} (for #{cop}) found in " \
          "#{smart_loaded_path}\n#{alternative}"
        end
      end
    end

    def smart_loaded_path
      PathUtil.smart_path(@config.loaded_path)
    end
  end
end
