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
require_relative 'autocorrection_request'
require_relative 'explain_tool'
require_relative 'scope'
require_relative 'source_files'

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
        'One with a `correction` that is not `correctable` is held back while code is ' \
        'being written, and only fixed with `contextual` set to true. ' \
        '`max_offenses_per_cop` caps what each cop reports, and the ' \
        'summary\'s `unreported_offenses` counts what was left out. ' \
        'A cop that crashes is listed in its file\'s `errors`; the rest still report.'

      AUTOCORRECTION_DESCRIPTION =
        'Autocorrect RuboCop offenses in Ruby code. ' \
        'Provide `source_code` to correct inline code, which comes back corrected as ' \
        'plain text, or `path` to correct files. ' \
        'Set `safety` to false to include unsafe corrections, and `contextual` to true ' \
        'to include the ones held back while code is being written, such as removing ' \
        'an unused variable. ' \
        'Set `dry_run` to true to preview: nothing is written, and each corrected file ' \
        'comes with its `diff`. ' \
        'For files, the result lists each file that was corrected or still has offenses, ' \
        'with the offenses left in the `rubocop_inspection` format, located in the ' \
        'corrected file. One whose `correction` is not `safe` needs `safety` set to false, ' \
        'and one with a `correction` that is not `correctable` needs `contextual` set to ' \
        'true. Each cop lists at most `max_offenses_per_cop` of them, 5 unless ' \
        'set, and the summary\'s `unreported_offenses` counts the rest. ' \
        'A cop that crashes is listed in its file\'s `errors`, and a file whose ' \
        'corrections loop is left unchanged.'

      def initialize(config_store)
        @config_store = config_store
        # An agent isn't an editor, so offenses are located and worded the way
        # the command line does it. Only contextual corrections are held back.
        @runtime = RuboCop::LSP::Runtime.new(@config_store, lsp_mode: false)
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
          description: AUTOCORRECTION_DESCRIPTION,
          title: "RuboCop's autocorrection",
          destructive_hint: true,
          idempotent_hint: false,
          read_only_hint: false,
          properties: AutocorrectionRequest::PROPERTIES,
          required: ['safety']
        ) do |scope:, path: nil, source_code: nil, **arguments|
          run_autocorrection(path, source_code, AutocorrectionRequest.new(scope, **arguments))
        end
      end

      # A limit counts across the files of one request, so every request starts
      # from zero.
      def run_inspection(path, source_code, max_offenses_per_cop, scope)
        limit = OffenseLimit.new(max_offenses_per_cop) if max_offenses_per_cop
        result =
          if source_code
            file = path || 'example.rb'
            build_result([file], [inspect_source(file, source_code, limit, scope)])
          else
            process_files(path, scope) { |file, src| inspect_source(file, src, limit, scope) }
          end
        result_json(result, limit)
      end

      def inspect_source(file, source, limit, scope)
        options = { **scope.cop_options, editing: true }
        offenses = @runtime.raw_offenses(file, source, options: options)
        offense_entry(file, offenses, limit).merge(problems_of_last_run(file))
      end

      # The offenses of a file the way `--format json` lists them, capped across
      # the files of a request.
      def offense_entry(file, offenses, limit)
        offenses = limit.filter(offenses) if limit
        @json_formatter.hash_for_file(file, offenses)
      end

      def run_autocorrection(path, source_code, request)
        return correct_inline(path, source_code, request) if source_code

        result = process_files(path, request.scope) do |file, source|
          correct_file(file, source, request)
        end
        result[:summary][:corrected_file_count] = result[:files].count { |file| file[:corrected] }
        result_json(result, request.limit)
      end

      # The agent never sees stderr, so the summary says what the limit left out.
      def result_json(result, limit)
        unreported = limit&.elided_per_cop
        result[:summary][:unreported_offenses] = unreported if unreported&.any?
        result.to_json
      end

      # Cops that keep undoing each other's corrections leave the file half
      # corrected, so it is left alone and the loop is reported instead. A file
      # with nothing to correct is left alone too, so its modification time
      # doesn't tell editors and agents it changed. The offenses left over are
      # the ones an agent has to fix itself, which saves it inspecting again.
      def correct_file(file, source, request)
        corrected = @runtime.format(file, source, **request.format_options)
        problems = problems_of_last_run(file)
        looped = @runtime.errors.any?(Runner::InfiniteCorrectionLoop)
        changed = !looped && source != corrected
        leftovers = leftover_offenses(file, source, corrected, changed, request)
        entry = offense_entry(file, leftovers, request.limit)
        diff = write_or_diff(file, entry[:path], source, corrected, request) if changed

        { path: entry[:path], corrected: changed, diff: diff, **entry, **problems }.compact
      end

      # A dry run writes nothing and returns the diff a real run would have
      # applied, line endings included.
      def write_or_diff(file, path, source, corrected, request)
        if request.dry_run?
          UnifiedDiff.new(path, source, Util.emulate_write_read_cycle(corrected)).to_s
        else
          SourceFiles.write(file, corrected)
          nil
        end
      end

      # What's left is in the file as written, or as a dry run would have
      # written it, or as it was when its corrections loop. The runner checks
      # corrected code with LF line endings, which writing turns into CRLF on
      # Windows, so there the file is checked again as written.
      def leftover_offenses(file, source, corrected, changed, request)
        on_disk = changed ? Util.emulate_write_read_cycle(corrected) : source
        return @runtime.uncorrected_offenses if on_disk == corrected

        @runtime.raw_offenses(file, on_disk, options: request.runtime_options)
      end

      # Corrected inline code comes back as plain text with nowhere to mention
      # a cop that crashed, so a crash fails the call instead of going unseen.
      def correct_inline(path, source_code, request)
        file = path || 'example.rb'
        corrected = @runtime.format(file, source_code, **request.format_options)
        errors = problems_of_last_run(file)[:errors]
        raise RuboCop::Error, errors.join("\n") if errors

        SourceFiles.write(path, corrected) if path && !request.dry_run?
        corrected
      end

      # Collapsed the way `--format json` collapses them, which also folds the
      # repeats from each autocorrection pass a crashing cop fails on.
      def problems_of_last_run(file)
        errors, warnings = [@runtime.errors, @runtime.warnings].map do |problems|
          problems.map { |problem| Rainbow::StringUtils.uncolor(problem.to_s) }
        end
        @json_formatter.hash_for_problems(file, errors, warnings)
      end

      def process_files(path, scope)
        target_finder = RuboCop::TargetFinder.new(@config_store, @options)
        target_files = scope.select_files(
          target_finder.find(path ? [path] : [], :only_recognized_file_types)
        )
        all_files = target_files.map do |file|
          yield(file, SourceFiles.read(file, @config_store.for_file(file)))
        end

        build_result(target_files, all_files)
      end

      # Inline code is reported as a single file, so an agent reads one shape
      # whichever way it asked. Files with nothing to report are only counted.
      def build_result(target_files, all_files)
        files = all_files.reject { |f| nothing_to_report?(f) }

        { files: files, summary: build_summary(target_files, all_files) }
      end

      def nothing_to_report?(file)
        file[:offenses].empty? && !file[:corrected] && !file[:errors] && !file[:warnings]
      end

      # NOTE: It is useful for RuboCop's result summary to be shown in the LLM's responses
      # during interactions, so the summary is returned in a form that is easy for the LLM
      # to reason about. Since LLM execution is non-deterministic, it is also sensible to
      # compute the summary deterministically at this stage.
      def build_summary(target_files, files)
        offense_count = files.sum { |f| f[:offenses].size }
        { target_file_count: target_files.count, offense_count: offense_count }
          .merge(@json_formatter.problem_counts(files))
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
            required: required,
            # The gem checks arguments against the schema, so one the tool
            # doesn't take is refused by name rather than failing the call.
            additionalProperties: false
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
