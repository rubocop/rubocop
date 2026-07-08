# frozen_string_literal: true

require 'English'

# fileutils is autoloaded by pathname,
# but must be explicitly loaded here for inclusion in `$LOADED_FEATURES`.
require 'fileutils'

before_us = $LOADED_FEATURES.dup
require 'rainbow'

require 'regexp_parser'
require 'set'
require 'stringio'
require 'unicode/display_width'

# we have to require RuboCop's version, before rubocop-ast's
require_relative 'rubocop/version'
require 'rubocop-ast'

require_relative 'rubocop/ast_aliases'
require_relative 'rubocop/ext/comment'
require_relative 'rubocop/ext/range'
require_relative 'rubocop/ext/regexp_node'
require_relative 'rubocop/ext/regexp_parser'

require_relative 'rubocop/core_ext/string'
require_relative 'rubocop/ext/processed_source'

require_relative 'rubocop/error'
require_relative 'rubocop/file_finder'
require_relative 'rubocop/file_patterns'
require_relative 'rubocop/name_similarity'
require_relative 'rubocop/path_util'
require_relative 'rubocop/platform'
require_relative 'rubocop/string_interpreter'
require_relative 'rubocop/util'
require_relative 'rubocop/warning'

# rubocop:disable Style/RequireOrder

require_relative 'rubocop/project_index_loader'
require_relative 'rubocop/cop/util'
require_relative 'rubocop/cop/offense'
require_relative 'rubocop/cop/message_annotator'
require_relative 'rubocop/cop/ignored_node'
require_relative 'rubocop/cop/autocorrect_logic'
require_relative 'rubocop/cop/exclude_limit'
require_relative 'rubocop/cop/badge'
require_relative 'rubocop/cop/registry'
require_relative 'rubocop/cop/lazy_loader'
require_relative 'rubocop/cop/base'
require_relative 'rubocop/cop/cop'
require_relative 'rubocop/cop/commissioner'
require_relative 'rubocop/cop/documentation'
require_relative 'rubocop/cop/corrector'
require_relative 'rubocop/cop/correctors'
require_relative 'rubocop/cop/force'
require_relative 'rubocop/cop/severity'
require_relative 'rubocop/cop/generator'
require_relative 'rubocop/cop/generator/configuration_injector'
require_relative 'rubocop/cop/generator/registration_injector'
require_relative 'rubocop/cop/generator/require_file_injector'
require_relative 'rubocop/magic_comment'

require_relative 'rubocop/cop/variable_force'
require_relative 'rubocop/cop/variable_force/branch'
require_relative 'rubocop/cop/variable_force/branchable'
require_relative 'rubocop/cop/variable_force/variable'
require_relative 'rubocop/cop/variable_force/assignment'
require_relative 'rubocop/cop/variable_force/reference'
require_relative 'rubocop/cop/variable_force/scope'
require_relative 'rubocop/cop/variable_force/variable_table'

require_relative 'rubocop/cop/mixin'

require_relative 'rubocop/cop/utils/format_string'

require_relative 'rubocop/cop/bundler'
require_relative 'rubocop/cop/gemspec'
require_relative 'rubocop/cop/layout'
require_relative 'rubocop/cop/lint'
require_relative 'rubocop/cop/metrics'
require_relative 'rubocop/cop/migration'
require_relative 'rubocop/cop/naming'
require_relative 'rubocop/cop/security'
require_relative 'rubocop/cop/style'

require_relative 'rubocop/cop/team'
require_relative 'rubocop/formatter'

require_relative 'rubocop/cached_data'
require_relative 'rubocop/config'
require_relative 'rubocop/config_loader_resolver'
require_relative 'rubocop/config_loader'
require_relative 'rubocop/config_obsoletion/rule'
require_relative 'rubocop/config_obsoletion/cop_rule'
require_relative 'rubocop/config_obsoletion/parameter_rule'
require_relative 'rubocop/config_obsoletion/changed_enforced_styles'
require_relative 'rubocop/config_obsoletion/changed_parameter'
require_relative 'rubocop/config_obsoletion/extracted_cop'
require_relative 'rubocop/config_obsoletion/removed_cop'
require_relative 'rubocop/config_obsoletion/renamed_cop'
require_relative 'rubocop/config_obsoletion/split_cop'
require_relative 'rubocop/config_obsoletion'
require_relative 'rubocop/config_store'
require_relative 'rubocop/config_validator'
require_relative 'rubocop/feature_loader'
require_relative 'rubocop/lockfile'
require_relative 'rubocop/lsp'
require_relative 'rubocop/target_finder'
require_relative 'rubocop/directive_comment'
require_relative 'rubocop/comment_config'
require_relative 'rubocop/result_cache'
require_relative 'rubocop/runner'
require_relative 'rubocop/cli'
require_relative 'rubocop/cli/command'
require_relative 'rubocop/cli/environment'
require_relative 'rubocop/cli/command/base'
require_relative 'rubocop/cli/command/auto_generate_config'
require_relative 'rubocop/cli/command/execute_runner'
require_relative 'rubocop/cli/command/init_dotfile'
require_relative 'rubocop/cli/command/lsp'
require_relative 'rubocop/cli/command/list_enabled_cops_for'
require_relative 'rubocop/cli/command/mcp'
require_relative 'rubocop/cli/command/show_cops'
require_relative 'rubocop/cli/command/show_docs_url'
require_relative 'rubocop/cli/command/suggest_extensions'
require_relative 'rubocop/cli/command/version'
require_relative 'rubocop/config_regeneration'
require_relative 'rubocop/options'
require_relative 'rubocop/remote_config'
require_relative 'rubocop/target_ruby'
require_relative 'rubocop/yaml_duplication_checker'
require_relative 'rubocop/pending_cops_reporter'

# rubocop:enable Style/RequireOrder

unless File.exist?("#{__dir__}/../rubocop.gemspec") # Check if we are a gem
  # Include all of RuboCop's own files, even those that are lazily loaded later (the cops),
  # so that the cache key relies solely on the gem version instead of varying with which
  # cop files end up loaded.
  features = $LOADED_FEATURES - before_us
  RuboCop::ResultCache.rubocop_required_features = features | Dir["#{__dir__}/rubocop/**/*.rb"]
end

RuboCop::AST.rubocop_loaded if RuboCop::AST.respond_to?(:rubocop_loaded)
