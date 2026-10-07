# frozen_string_literal: true

begin
  require 'mcp'

  required_mcp_version = '0.6.0'

  if Gem::Version.new(required_mcp_version) > Gem::Version.new(MCP::VERSION)
    # While `mcp` is not a runtime dependency, users may have an outdated version installed.
    warn <<~MESSAGE
      Error: `mcp` gem version #{MCP::VERSION} was loaded, but `rubocop --mcp` requires #{required_mcp_version}.
      - If you're using Bundler and don't yet have `gem 'mcp'` as a dependency, add it now.
      - If you're using Bundler and already have `gem 'mcp'` as a dependency, update it to the most recent version.
      - If you don't use Bundler, run `gem update mcp`.
    MESSAGE
    exit!
  end
rescue LoadError => e
  raise unless e.path == 'mcp'

  warn <<~MESSAGE
    Error: Unable to load `mcp` gem. Add `gem 'mcp', '~> 0.6'` to your Gemfile, or run `gem install mcp`.
  MESSAGE

  exit!
end

require_relative '../lsp'
require_relative '../lsp/runtime'
require_relative 'explain_tool'
require_relative 'scope'

module RuboCop
  module MCP
    # RuboCop MCP Server.
    # @api private
    class Server
      INSPECTION_DESCRIPTION =
        'Inspect Ruby code for offenses. ' \
        'Provide `source_code` to check inline code or `path` to check files. ' \
        'Either way the result lists offenses per file, with a summary, and the ' \
        'offenses use the `rubocop --format json` format, with 1-based lines. ' \
        '`correctable` says whether `rubocop_autocorrection` fixes an offense, ' \
        'and one whose `correction` is not `safe` needs `safety` set to false. ' \
        '`max_offenses_per_cop` caps what each cop reports, and the ' \
        'summary\'s `unreported_offenses` counts what was left out. ' \
        'A cop that crashes is listed in its file\'s `errors`; the rest still report.'

      def initialize(config_store)
        @config_store = config_store
        @runtime = RuboCop::LSP::Runtime.new(@config_store)
        # One cop crashing on one file should not cost an agent everything else
        # in the request, so cop errors are collected and reported per file.
        @runtime.raise_cop_error = false
        @options = {}
        # Offenses are reported the way `--format json` reports them, so an agent
        # sees the same 1-based locations and correction data either way.
        @json_formatter = RuboCop::Formatter::JSONFormatter.new(nil)
      end

      def start
        # No `protocol_version` is specified because draft feature by default can be used.
        server = ::MCP::Server.new(
          name: 'rubocop_mcp_server',
          version: RuboCop::Version::STRING,
          tools: [inspection_tool, autocorrection_tool, ExplainTool.new(@config_store).to_tool]
        )

        ::MCP::Server::Transports::StdioTransport.new(server).open
      end

      private

      def inspection_tool
        build_tool(
          name: 'rubocop_inspection',
          description: INSPECTION_DESCRIPTION,
          title: "RuboCop's inspection",
          destructive_hint: false,
          idempotent_hint: true,
          read_only_hint: true,
          properties: { max_offenses_per_cop: { type: 'integer', minimum: 1 } }
        ) do |scope:, path: nil, source_code: nil, max_offenses_per_cop: nil|
          run_inspection(path, source_code, max_offenses_per_cop, scope)
        end
      end

      def autocorrection_tool
        build_tool(
          name: 'rubocop_autocorrection',
          description: 'Autocorrect RuboCop offenses in Ruby code. ' \
                       'Provide `source_code` to correct inline code or `path` to correct files. ' \
                       'Set `safety` to false to include unsafe corrections.',
          title: "RuboCop's autocorrection",
          destructive_hint: true,
          idempotent_hint: false,
          read_only_hint: false,
          properties: { safety: { type: 'boolean' } },
          required: ['safety']
        ) do |scope:, path: nil, source_code: nil, safety: true|
          run_autocorrection(path, source_code, safety, scope)
        end
      end

      # A limit counts across the files of one request, so every request starts
      # from zero.
      def run_inspection(path, source_code, max_offenses_per_cop, scope)
        limit = OffenseLimit.new(max_offenses_per_cop) if max_offenses_per_cop
        result =
          if source_code
            file = path || 'example.rb'
            entry = inspect_source(file, source_code, limit, scope)
            build_result([file], [entry], filter_empty: true)
          else
            process_files(path, scope, filter_empty: true) do |file, src|
              inspect_source(file, src, limit, scope)
            end
          end
        # The agent never sees stderr, so the summary says what the limit left out.
        unreported = limit&.elided_per_cop
        result[:summary][:unreported_offenses] = unreported if unreported&.any?
        result.to_json
      end

      def inspect_source(file, source, limit, scope)
        offenses = @runtime.raw_offenses(file, source, cops: scope.cop_options)
        offenses = limit.filter(offenses) if limit
        entry = @json_formatter.hash_for_file(file, offenses)
        entry.merge(problems_of_last_run(file, entry[:path]))
      end

      def run_autocorrection(path, source_code, safety, scope)
        command = safety ? 'rubocop.formatAutocorrects' : 'rubocop.formatAutocorrectsAll'

        if source_code
          correct_inline(path, source_code, command, scope)
        else
          process_files(path, scope) { |file, source| correct_file(file, source, command, scope) }
            .to_json
        end
      end

      # Cops that keep undoing each other's corrections leave the file half
      # corrected, so it is left alone and the loop is reported instead.
      def correct_file(file, source, command, scope)
        corrected = @runtime.format(file, source, command: command, cops: scope.cop_options)
        looped = @runtime.errors.any?(Runner::InfiniteCorrectionLoop)
        write_file(file, corrected) unless looped

        path = PathUtil.relative_path(file)
        { path: path, corrected: !looped && source != corrected }
          .merge(problems_of_last_run(file, path))
      end

      # Corrected inline code comes back as plain text with nowhere to mention
      # a cop that crashed, so a crash fails the call instead of going unseen.
      def correct_inline(path, source_code, command, scope)
        file = path || 'example.rb'
        corrected = @runtime.format(file, source_code, command: command, cops: scope.cop_options)
        errors = problems_of_last_run(file, PathUtil.smart_path(file))[:errors]
        raise RuboCop::Error, errors.join("\n") if errors

        write_file(path, corrected) if path
        corrected
      end

      # A crashing cop fails once per node it visits, and again on every
      # autocorrection pass, so its messages lose their line and column and
      # collapse into one per cop. Messages name the file the way its entry
      # in the result does.
      def problems_of_last_run(file, path)
        return {} if @runtime.errors.empty? && @runtime.warnings.empty?

        location = /#{Regexp.escape(File.expand_path(file))}(:\d+)*/
        { errors: @runtime.errors, warnings: @runtime.warnings }.filter_map do |key, problems|
          messages = problems.map { |problem| plain_message(problem, location, path) }.uniq
          [key, messages] unless messages.empty?
        end.to_h
      end

      def plain_message(problem, location, path)
        Rainbow::StringUtils.uncolor(problem.to_s).sub(location, path)
      end

      def process_files(path, scope, filter_empty: false)
        target_finder = RuboCop::TargetFinder.new(@config_store, @options)
        target_files = scope.select_files(
          target_finder.find(path ? [path] : [], :only_recognized_file_types)
        )
        all_files = target_files.map { |file| yield(file, read_file(file)) }

        build_result(target_files, all_files, filter_empty: filter_empty)
      end

      # Inline code is reported as a single file, so an agent reads one shape
      # whichever way it asked.
      def build_result(target_files, all_files, filter_empty: false)
        files = filter_empty ? all_files.reject { |f| nothing_to_report?(f) } : all_files

        { files: files, summary: build_summary(target_files, all_files) }
      end

      def nothing_to_report?(file)
        file[:offenses].empty? && !file[:errors] && !file[:warnings]
      end

      def read_file(file)
        config = @config_store.for_file(file)
        RuboCop::ProcessedSource.from_file(
          file, config.target_ruby_version, parser_engine: config.parser_engine
        ).raw_source
      rescue Errno::ENOENT
        raise RuboCop::Error, "No such file or directory: #{file}"
      end

      def write_file(file, content)
        File.write(file, content)
      rescue Errno::EACCES
        raise RuboCop::Error, "Permission denied: #{file}"
      rescue Errno::ENOSPC
        raise RuboCop::Error, "No space left on device: #{file}"
      rescue Errno::EROFS
        raise RuboCop::Error, "Read-only file system: #{file}"
      end

      # NOTE: It is useful for RuboCop's result summary to be shown in the LLM's responses
      # during interactions, so the summary is returned in a form that is easy for the LLM
      # to reason about. Since LLM execution is non-deterministic, it is also sensible to
      # compute the summary deterministically at this stage.
      def build_summary(target_files, files)
        summary = { target_file_count: target_files.count }
        if files.first&.key?(:offenses)
          summary[:offense_count] = files.sum { |f| f[:offenses].size }
        else
          summary[:corrected_file_count] = files.count { |f| f[:corrected] }
        end
        summary.merge(problem_counts(files))
      end

      def problem_counts(files)
        {
          error_count: files.sum { |f| f[:errors]&.size.to_i },
          warning_count: files.sum { |f| f[:warnings]&.size.to_i }
        }.reject { |_, count| count.zero? }
      end

      # rubocop:disable-next Metrics/MethodLength, Metrics/ParameterLists
      def build_tool(
        name:, description:,
        title:, destructive_hint:, idempotent_hint:, read_only_hint:, properties:, required: nil
      )
        ::MCP::Tool.define(
          name: name,
          description: description,
          input_schema: {
            properties: {
              path: { type: 'string' },
              source_code: { type: 'string' }
            }.merge(properties, Scope::PROPERTIES),
            required: required
          }.compact,
          annotations: {
            title: title,
            destructive_hint: destructive_hint,
            idempotent_hint: idempotent_hint,
            open_world_hint: false,
            read_only_hint: read_only_hint
          }
        ) do |**arguments|
          # Taking any keywords makes the gem pass a `server_context` as well.
          # Each tool's own block names the arguments it accepts.
          arguments.delete(:server_context)
          selection = Scope::PROPERTIES.keys.to_h { |key| [key, arguments.delete(key)] }
          scope = Scope.new(inline: !arguments[:source_code].nil?, **selection)
          result = yield(**arguments, scope: scope)

          ::MCP::Tool::Response.new([{ type: 'text', text: result }])
        rescue RuboCop::Error, IncorrectCopNameError => e
          # The runner raises `IncorrectCopNameError` for a name in `only` or
          # `except` that it does not know, with suggestions.
          ::MCP::Tool::Response.new([{ type: 'text', text: e.message }], error: true)
        end
      end
    end
  end
end
