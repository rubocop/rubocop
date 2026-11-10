# frozen_string_literal: true

module RuboCop
  module Cop
    module Security
      # Checks for the use of JSON class methods which have potential
      # security issues.
      #
      # `JSON.load` and similar methods allow deserialization of arbitrary ruby objects:
      #
      # [source,ruby]
      # ----
      # require 'json/add/string'
      # result = JSON.load('{ "json_class": "String", "raw": [72, 101, 108, 108, 111] }')
      # pp result # => "Hello"
      # ----
      #
      # Never use `JSON.load` for untrusted user input. Prefer `JSON.parse` unless you have
      # a concrete use-case for `JSON.load`.
      #
      # NOTE: `json` gem version 2.8.0 started emitting a deprecation warning when this
      # behavior is triggered without an explicit `create_additions` keyword argument, and
      # version 3.0.0.rc1 removed the option altogether, which makes `JSON.load` safe by
      # default. Code that relied on `create_additions` can migrate to a custom serializer
      # built on `JSON::Coder`; passing the option now raises `ArgumentError`.
      #
      # Accordingly, `JSON.load` is not reported when the target depends on `json` directly
      # and its lockfile resolves that dependency to 3.0.0.rc1 or newer. A transitively
      # resolved `json` is not enough: RuboCop's own gemspec depends on `json`, so a project
      # that merely bundles RuboCop tends to lock a `json` version that nothing else needs,
      # and the code under inspection may well run against the version bundled with Ruby
      # instead. `JSON.restore` was removed in 3.0.0.rc1 as well, so it is always reported.
      #
      # NOTE: Before `json` gem version 2.17.0, `JSON.load` only takes options as its third
      # argument. A hash passed as the second argument is taken as the `proc` argument, so
      # its `create_additions` option is ignored. Which `json` version runs can't be told
      # statically (the lockfile may resolve a newer one than the default gem loaded in
      # production), so options passed as the second argument are always reported. Pass
      # `nil` as the second argument instead.
      #
      # @safety
      #   This cop's autocorrection is unsafe because it's potentially dangerous.
      #   If using a stream, like `JSON.load(open('file'))`, you will need to call
      #   `#read` manually, like `JSON.parse(open('file').read)`.
      #   Other similar issues may apply.
      #
      # @example
      #   # bad
      #   JSON.load('{}')
      #   JSON.restore('{}')
      #
      #   # bad - ignored by `json` older than 2.17.0
      #   JSON.load('{}', create_additions: false)
      #
      #   # good
      #   JSON.parse('{}')
      #   JSON.unsafe_load('{}')
      #
      #   # good - explicit use of `create_additions` option
      #   JSON.load('{}', nil, create_additions: true)
      #   JSON.load('{}', nil, create_additions: false)
      #
      class JSONLoad < Base
        extend AutoCorrector

        MSG = 'Prefer `JSON.parse` over `JSON.%<method>s`.'
        RESTRICT_ON_SEND = %i[load restore].freeze
        SAFE_JSON_LOAD_GEM_REQUIREMENT = Gem::Requirement.new('>= 3.0.0.rc1')

        # @!method insecure_json_load(node)
        def_node_matcher :insecure_json_load, <<~PATTERN
          (
            send (const {nil? cbase} :JSON) ${:load :restore}
            {
              _ hash
            | ... !`(pair (sym :create_additions) _)
            }
          )
        PATTERN

        def on_send(node)
          insecure_json_load(node) do |method|
            next if method == :load && json_load_safe_by_default?

            add_offense(node.loc.selector, message: format(MSG, method: method)) do |corrector|
              corrector.replace(node.loc.selector, 'parse')
            end
          end
        end

        def external_dependency_checksum
          direct_json_gem_version&.to_s
        end

        private

        def json_load_safe_by_default?
          json_version = direct_json_gem_version

          !json_version.nil? && SAFE_JSON_LOAD_GEM_REQUIREMENT.satisfied_by?(json_version)
        end

        def direct_json_gem_version
          direct_gem_versions = config.direct_gem_versions_in_target

          direct_gem_versions && direct_gem_versions['json']
        end
      end
    end
  end
end
