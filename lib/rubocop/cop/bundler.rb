# frozen_string_literal: true

module RuboCop
  module Cop
    # Cops for the `Bundler` department. The department's cops are registered for lazy loading
    # and their files are loaded on demand.
    module Bundler
      extend LazyLoader

      register_cop :DuplicatedGem, "#{__dir__}/bundler/duplicated_gem"
      register_cop :DuplicatedGroup, "#{__dir__}/bundler/duplicated_group"
      register_cop :GemComment, "#{__dir__}/bundler/gem_comment"
      register_cop :GemFilename, "#{__dir__}/bundler/gem_filename"
      register_cop :GemVersion, "#{__dir__}/bundler/gem_version"
      register_cop :InsecureProtocolSource, "#{__dir__}/bundler/insecure_protocol_source"
      register_cop :OrderedGems, "#{__dir__}/bundler/ordered_gems"
    end
  end
end
