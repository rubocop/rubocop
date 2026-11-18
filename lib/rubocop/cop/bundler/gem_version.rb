# frozen_string_literal: true

module RuboCop
  module Cop
    module Bundler
      # Enforce that Gem version specifications or a commit reference (branch,
      # ref, or tag) are either required, forbidden, or exact.
      #
      # The `exact` style requires a single exact version (`'1.2.3'` or
      # `'= 1.2.3'`), or a `ref` or `tag`. A `branch` is not exact, because the
      # commit it points to moves. When the project has a lockfile, the version
      # must also match the locked one, and autocorrection writes the locked
      # version. `*.gemfile` files (e.g. `gemfiles/rails_7.gemfile`) are not
      # compared to the lockfile, since they are locked separately.
      #
      # Exact versions suit applications whose dependency updates come from a
      # bot (e.g. Renovate or Dependabot) that bumps the version in the Gemfile:
      # with a range, the bot can only update the lockfile, and `bundle lock`
      # may resolve a newer release than the one it was asked for.
      #
      # @example EnforcedStyle: required (default)
      #   # bad
      #   gem 'rubocop'
      #
      #   # good
      #   gem 'rubocop', '~> 1.12'
      #
      #   # good
      #   gem 'rubocop', '>= 1.10.0'
      #
      #   # good
      #   gem 'rubocop', '>= 1.5.0', '< 1.10.0'
      #
      #   # good
      #   gem 'rubocop', branch: 'feature-branch'
      #
      #   # good
      #   gem 'rubocop', ref: '74b5bfbb2c4b6fd6cdbbc7254bd7084b36e0c85b'
      #
      #   # good
      #   gem 'rubocop', tag: 'v1.17.0'
      #
      # @example EnforcedStyle: forbidden
      #   # good
      #   gem 'rubocop'
      #
      #   # bad
      #   gem 'rubocop', '~> 1.12'
      #
      #   # bad
      #   gem 'rubocop', '>= 1.10.0'
      #
      #   # bad
      #   gem 'rubocop', '>= 1.5.0', '< 1.10.0'
      #
      #   # bad
      #   gem 'rubocop', branch: 'feature-branch'
      #
      #   # bad
      #   gem 'rubocop', ref: '74b5bfbb2c4b6fd6cdbbc7254bd7084b36e0c85b'
      #
      #   # bad
      #   gem 'rubocop', tag: 'v1.17.0'
      #
      #
      # @example EnforcedStyle: exact
      #   # bad
      #   gem 'rubocop'
      #
      #   # bad
      #   gem 'rubocop', '~> 1.12'
      #
      #   # bad
      #   gem 'rubocop', '>= 1.5.0', '< 1.10.0'
      #
      #   # bad
      #   gem 'rubocop', branch: 'feature-branch'
      #
      #   # good
      #   gem 'rubocop', '1.17.0'
      #
      #   # good
      #   gem 'rubocop', '= 1.17.0'
      #
      #   # good
      #   gem 'rubocop', ref: '74b5bfbb2c4b6fd6cdbbc7254bd7084b36e0c85b'
      #
      #   # good
      #   gem 'rubocop', tag: 'v1.17.0'
      #
      #   # bad (when the lockfile resolves rubocop to 1.17.0)
      #   gem 'rubocop', '1.16.0'
      #
      class GemVersion < Base
        include ConfigurableEnforcedStyle
        include GemDeclaration
        extend AutoCorrector

        REQUIRED_MSG = 'Gem version specification is required.'
        FORBIDDEN_MSG = 'Gem version specification is forbidden.'
        EXACT_MSG = 'Gem version specification must be a single exact version.'
        EXACT_LOCKED_MSG = 'Gem version specification must be the locked version `%<locked>s`.'
        LOCKED_MISMATCH_MSG = 'Gem version `%<version>s` does not match the locked version ' \
                              '`%<locked>s`.'
        RESTRICT_ON_SEND = %i[gem].freeze
        VERSION_SPECIFICATION_REGEX = /^\s*[~<>=]*\s*[0-9.]+/.freeze
        EXACT_VERSION_REGEX = /\A\s*(?:=\s*)?(\d+(?:\.[0-9a-zA-Z]+)*)\s*\z/.freeze

        # @!method includes_version_specification?(node)
        def_node_matcher :includes_version_specification?, <<~PATTERN
          (send nil? :gem <(str #version_specification?) ...>)
        PATTERN

        # @!method includes_commit_reference?(node)
        def_node_matcher :includes_commit_reference?, <<~PATTERN
          (send nil? :gem <(hash <(pair (sym {:branch :ref :tag}) (str _)) ...>) ...>)
        PATTERN

        # @!method includes_exact_commit_reference?(node)
        def_node_matcher :includes_exact_commit_reference?, <<~PATTERN
          (send nil? :gem <(hash <(pair (sym {:ref :tag}) (str _)) ...>) ...>)
        PATTERN

        def on_send(node)
          return unless gem_declaration?(node)
          return if allowed_gem?(node)

          detected_styles = detected_styles(node)

          if detected_styles.include?(style)
            correct_style_detected
          else
            register_offense(node)
            ambiguous_style_detected(*detected_styles)
          end
        end

        private

        def allowed_gem?(node)
          allowed_gems.include?(node.first_argument.value)
        end

        def allowed_gems
          Array(cop_config['AllowedGems'])
        end

        def detected_styles(node)
          if exact?(node)
            %i[required exact]
          elsif includes_version_specification?(node) || includes_commit_reference?(node)
            %i[required]
          else
            %i[forbidden]
          end
        end

        def register_offense(node)
          case style
          when :required then add_offense(node, message: REQUIRED_MSG)
          when :forbidden then add_offense(node, message: FORBIDDEN_MSG)
          else register_exact_offense(node)
          end
        end

        def register_exact_offense(node)
          locked = locked_version(node)

          add_offense(node, message: exact_message(node, locked)) do |corrector|
            next if locked.nil? || includes_commit_reference?(node)

            correct_to_locked_version(corrector, node, locked)
          end
        end

        def exact_message(node, locked)
          return EXACT_MSG unless locked

          version = exact_version(node)
          if version
            format(LOCKED_MISMATCH_MSG, version: version, locked: locked)
          else
            format(EXACT_LOCKED_MSG, locked: locked)
          end
        end

        def exact?(node)
          versions = version_nodes(node)
          return includes_exact_commit_reference?(node) if versions.empty?

          version = exact_version(node)
          return false unless version

          locked = locked_version(node)
          locked.nil? || Gem::Version.new(version) == locked
        end

        def exact_version(node)
          versions = version_nodes(node)
          return unless versions.one?

          versions.first.value[EXACT_VERSION_REGEX, 1]
        end

        # Every positional string after the gem name is a version requirement.
        def version_nodes(node)
          node.arguments.drop(1).select(&:str_type?)
        end

        def locked_version(node)
          return if separately_locked_gemfile?

          target_gem_version(node.first_argument.value)
        end

        # The lockfile belongs to the `Gemfile` (or `gems.rb`); `*.gemfile` files
        # such as `gemfiles/rails_7.gemfile` have lockfiles of their own.
        def separately_locked_gemfile?
          processed_source.file_path.to_s.end_with?('.gemfile')
        end

        def correct_to_locked_version(corrector, node, locked)
          name = node.first_argument
          quote = name.source.start_with?('"') ? '"' : "'"
          replacement = "#{quote}#{locked}#{quote}"
          versions = version_nodes(node)

          if versions.empty?
            corrector.insert_after(name, ", #{replacement}")
          else
            corrector.replace(versions.first.source_range.join(versions.last.source_range),
                              replacement)
          end
        end

        def version_specification?(expression)
          expression.match?(VERSION_SPECIFICATION_REGEX)
        end
      end
    end
  end
end
