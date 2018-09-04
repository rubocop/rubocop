# frozen_string_literal: true

require 'pathname'

module RuboCop
  # Common methods for finding files.
  class CopFinder
    RELEASE_PATH = 'relnotes'.freeze
    IGNORED_FOLDERS = %w[. ..].freeze
    COP_NAME_PATTERN = /`(.*?)`/
    VERSION_PATTERN = /\d+(\.\d+)*/
    COP_ADDED_PATTERN = /^(?=.*\bnew\b)(?=.*\bcop\b).*$/i

    attr_reader :registry

    def initialize
      @registry = Cop::Cop.registry
    end

    def cops_with_version_added
      cops_with_version(regex_pattern: COP_ADDED_PATTERN)
    end

    def cops_with_version(regex_pattern:)
      {}.tap do |cops_with_version|
        release_notes = (Dir.entries(RELEASE_PATH) - IGNORED_FOLDERS)
        release_notes.each do |relnote|
          version = relnote[VERSION_PATTERN]
          found_cops = search_in_relnote(relnote: relnote,
                                         regex_pattern: regex_pattern)

          found_cops.each do |found_cop|
            qualified_cop_name = registry.qualified_cop_name(found_cop, Dir.pwd)
            next unless registry.contains_cop_matching?(qualified_cop_name)

            cops_with_version[qualified_cop_name] = version
          end
        end
      end
    end

    def search_in_relnote(relnote:, regex_pattern:)
      relnotes = File.readlines(File.join(RELEASE_PATH, relnote))

      [].tap do |found_cops|
        relnotes.grep(regex_pattern).each do |line|
          found_cops << line[COP_NAME_PATTERN, 1]
        end
      end.compact
    end
  end
end
