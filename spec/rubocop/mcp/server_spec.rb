# frozen_string_literal: true

RSpec.describe RuboCop::MCP::Server, :isolated_environment, :lsp do
  include MCPHelper
  include FailingCopHelper

  subject(:result) { run_server_on_requests(*requests) }

  let(:messages) { result[0] }
  let(:response) { messages.first }
  let(:parsed_result) do
    JSON.parse(response[:result][:content].first[:text], symbolize_names: true)
  end
  let(:stderr) { result[1].string }

  describe 'initialize' do
    let(:requests) do
      [{
        jsonrpc: '2.0',
        id: '42',
        method: 'initialize',
        params: {
          protocolVersion: '2025-06-18',
          capabilities: {},
          clientInfo: { name: 'test_client', version: '1.0.0' }
        }
      }]
    end

    it 'handles requests' do
      expect(stderr).to be_blank
      expect(messages.count).to eq(1)
      expect(messages.first).to include(jsonrpc: '2.0', id: '42')
      expect(messages.first[:result]).to include(
        protocolVersion: a_kind_of(String), # RuboCop MCP Server uses the latest protocol version.
        capabilities: {
          logging: {},
          tools: { listChanged: true },
          prompts: { listChanged: true },
          resources: { listChanged: true }
        },
        serverInfo: {
          name: 'rubocop_mcp_server',
          version: RuboCop::Version::STRING
        }
      )
    end
  end

  describe 'tools/list' do
    let(:requests) do
      [{
        jsonrpc: '2.0',
        id: '42',
        method: 'tools/list'
      }]
    end

    it 'handles requests' do
      expect(stderr).to be_blank
      expect(messages.count).to eq(1)
      expect(messages.first).to eq(
        id: '42',
        jsonrpc: '2.0',
        result: {
          tools: [{
            annotations: {
              destructiveHint: false,
              idempotentHint: true,
              openWorldHint: false,
              readOnlyHint: true,
              title: "RuboCop's inspection"
            },
            description: 'Inspect Ruby code for offenses. ' \
                         'Provide `source_code` to check inline code or `path` to check files. ' \
                         'Either way the result lists offenses per file, with a summary, and the ' \
                         'offenses use the `rubocop --format json` format, with 1-based lines. ' \
                         '`correctable` says whether `rubocop_autocorrection` fixes an offense, ' \
                         'and one whose `correction` is not `safe` needs `safety` set to false. ' \
                         '`max_offenses_per_cop` caps what each cop reports, and the ' \
                         'summary\'s `unreported_offenses` counts what was left out. ' \
                         'A cop that crashes is listed in its file\'s `errors`; ' \
                         'the rest still report.',
            inputSchema: {
              '$schema': 'https://json-schema.org/draft/2020-12/schema',
              properties: {
                max_offenses_per_cop: { type: 'integer', minimum: 1 },
                path: { type: 'string' },
                source_code: { type: 'string' },
                **RuboCop::MCP::Scope::PROPERTIES
              },
              type: 'object'
            },
            name: 'rubocop_inspection'
          }, {
            annotations: {
              destructiveHint: true,
              idempotentHint: false,
              openWorldHint: false,
              readOnlyHint: false,
              title: "RuboCop's autocorrection"
            },
            description: described_class::AUTOCORRECTION_DESCRIPTION,
            inputSchema: {
              '$schema': 'https://json-schema.org/draft/2020-12/schema',
              properties: {
                max_offenses_per_cop: { type: 'integer', minimum: 1 },
                path: { type: 'string' },
                safety: { type: 'boolean' },
                source_code: { type: 'string' },
                **RuboCop::MCP::Scope::PROPERTIES
              },
              required: ['safety'], type: 'object'
            },
            name: 'rubocop_autocorrection'
          }, {
            annotations: {
              destructiveHint: false,
              idempotentHint: true,
              openWorldHint: false,
              readOnlyHint: true,
              title: "RuboCop's cop explanation"
            },
            description: 'Explain what cops do: the problem each one targets, ' \
                         'bad and good examples, its configuration as this project ' \
                         'resolves it, and whether it autocorrects. Takes cop names ' \
                         'as offenses report them, such as `Style/StringLiterals`. ' \
                         'Pass the `path` of a file to see the configuration that ' \
                         'applies to it.',
            inputSchema: {
              '$schema': 'https://json-schema.org/draft/2020-12/schema',
              properties: {
                cop_names: { type: 'array', items: { type: 'string' }, minItems: 1 },
                path: { type: 'string' }
              },
              required: ['cop_names'], type: 'object'
            },
            name: 'rubocop_explain'
          }]
        }
      )
    end
  end

  describe 'tools/call to explain' do
    let(:requests) do
      [{
        jsonrpc: '2.0',
        id: '42',
        method: 'tools/call',
        params: { name: 'rubocop_explain', arguments: { cop_names: cop_names, path: path }.compact }
      }]
    end
    let(:path) { nil }
    let(:text) { response[:result][:content].first[:text] }

    context 'with cops that exist' do
      let(:cop_names) { %w[Style/StringLiterals Lint/UselessAssignment] }

      it 'explains each of them the way `--explain` does' do
        expect(stderr).to be_blank
        expect(response[:result][:isError]).to be false
        expect(text).to start_with("Style/StringLiterals\n")
        expect(text).to include('Autocorrect: safe, applied by -a')
        expect(text).to include("\n\nLint/UselessAssignment\n")
        expect(text).to include('Autocorrect: safe, applied by -a, but not through LSP or MCP')
      end
    end

    context 'with the configuration of the project' do
      let(:cop_names) { %w[Style/StringLiterals] }

      before do
        File.write('.rubocop.yml', <<~YAML)
          Style/StringLiterals:
            EnforcedStyle: double_quotes
        YAML
      end

      it 'reports the values the project resolves' do
        expect(text).to include('EnforcedStyle: double_quotes')
      end
    end

    context 'with the path of a file that has its own configuration' do
      let(:cop_names) { %w[Style/StringLiterals] }
      let(:path) { 'engine/lib/engine.rb' }

      before do
        FileUtils.mkdir_p('engine/lib')
        File.write('engine/.rubocop.yml', <<~YAML)
          Style/StringLiterals:
            EnforcedStyle: double_quotes
        YAML
        File.write(path, "puts 'engine'\n")
      end

      it 'reports the values that apply to that file' do
        expect(response[:result][:isError]).to be false
        expect(text).to include('EnforcedStyle: double_quotes')
      end
    end

    context 'with a name that is not a cop' do
      let(:cop_names) { %w[Style/StringLiteral Metrics] }

      it 'reports an error with suggestions' do
        expect(response[:result][:isError]).to be true
        expect(text).to include('Unrecognized cop: Style/StringLiteral.')
        expect(text).to include('Did you mean? Style/StringLiterals')
        expect(text).to include('Metrics is a department, not a cop.')
      end
    end

    context 'with a name that is not a cop alongside one that is' do
      let(:cop_names) { %w[Style/Semicolon Style/StringLiteral] }

      it 'explains the cop it recognizes before reporting the error' do
        expect(response[:result][:isError]).to be true
        expect(text).to start_with("Style/Semicolon\n")
        expect(text).to match(%r{\n\nUnrecognized cop: Style/StringLiteral\.\nDid you mean\? .*\z})
      end
    end
  end

  describe 'tools/call to inspection' do
    let(:requests) do
      [{
        jsonrpc: '2.0',
        id: '42',
        method: 'tools/call',
        params: { name: 'rubocop_inspection', arguments: { source_code: '?a' } }
      }]
    end
    let(:offenses) { parsed_result[:files].first[:offenses] }
    let(:character_literal) do
      offenses.find { |o| o[:cop_name] == 'Style/CharacterLiteral' }
    end
    let(:frozen_string) do
      offenses.find { |o| o[:cop_name] == 'Style/FrozenStringLiteralComment' }
    end
    let(:trailing_lines) do
      offenses.find { |o| o[:cop_name] == 'Layout/TrailingEmptyLines' }
    end

    it 'handles requests' do
      expect(stderr).to be_blank
      expect(messages.count).to eq(1)
      expect(response).to include(id: '42', jsonrpc: '2.0')
      expect(response[:result][:isError]).to be false
      expected_count = RuboCop::Platform.windows? ? 4 : 3
      expect(parsed_result[:files].map { |file| file[:path] }).to eq(['example.rb'])
      expect(offenses.size).to eq(expected_count)
      expect(parsed_result[:summary]).to eq(target_file_count: 1, offense_count: expected_count)

      expect(character_literal).to include(
        severity: 'convention',
        correctable: true,
        location: a_hash_including(start_line: 1, start_column: 1, last_line: 1, last_column: 2),
        correction: {
          safe: true,
          edits: [{
            start_line: 1, start_column: 1, last_line: 1, last_column: 2,
            begin_pos: 0, end_pos: 2, replacement: "'a'"
          }]
        }
      )

      expect(frozen_string).to include(
        severity: 'convention',
        correctable: true,
        location: a_hash_including(start_line: 1, start_column: 1),
        correction: a_hash_including(safe: false)
      )

      expect(trailing_lines).to include(
        severity: 'convention',
        correctable: true,
        location: a_hash_including(start_line: 1, start_column: 3),
        correction: a_hash_including(safe: true)
      )
    end
  end

  describe 'tools/call to inspection of inline code with no offenses' do
    # Inline code skips the newline conversion `File.write` does on Windows, so
    # it has to arrive with native line endings to satisfy `Layout/EndOfLine`.
    let(:newline) { RuboCop::Platform.windows? ? "\r\n" : "\n" }
    let(:requests) do
      [{
        jsonrpc: '2.0',
        id: '42',
        method: 'tools/call',
        params: {
          name: 'rubocop_inspection',
          arguments: { source_code: "# frozen_string_literal: true#{newline}" }
        }
      }]
    end

    it 'reports it the way it reports a clean file' do
      expect(parsed_result).to eq(files: [], summary: { target_file_count: 1, offense_count: 0 })
    end
  end

  describe 'tools/call to inspection of an offense autocorrection leaves alone' do
    let(:requests) do
      [{
        jsonrpc: '2.0',
        id: '42',
        method: 'tools/call',
        params: {
          name: 'rubocop_inspection',
          arguments: { source_code: "def foo\n  x = 1\nend\n" }
        }
      }]
    end
    let(:useless_assignment) do
      parsed_result[:files].first[:offenses].find { |o| o[:cop_name] == 'Lint/UselessAssignment' }
    end

    # `AutoCorrect: contextual` corrections are not applied while code is being
    # edited, but the edit is still there for the agent to apply itself.
    it 'reports it as not correctable while keeping its correction' do
      expect(useless_assignment).to include(
        correctable: false,
        location: a_hash_including(start_line: 2, start_column: 3),
        correction: {
          safe: true,
          edits: [a_hash_including(start_line: 2, start_column: 3, replacement: '')]
        }
      )
    end
  end

  describe 'tools/call to inspection with file path only' do
    let(:file_path) { 'test_file.rb' }
    let(:requests) do
      [{
        jsonrpc: '2.0',
        id: '42',
        method: 'tools/call',
        params: { name: 'rubocop_inspection', arguments: { path: file_path } }
      }]
    end

    before do
      File.write(file_path, '?a')
    end

    it 'reads and inspects the file' do
      expect(stderr).to be_blank
      expect(messages.count).to eq(1)
      expect(response).to include(id: '42', jsonrpc: '2.0')
      expect(response[:result][:isError]).to be false
      expect(parsed_result[:files].first[:path]).to eq(file_path)
      expect(parsed_result[:files].first[:offenses]).to include(
        a_hash_including(
          cop_name: 'Style/CharacterLiteral',
          correctable: true,
          location: a_hash_including(start_line: 1, start_column: 1),
          correction: a_hash_including(safe: true)
        )
      )
    end
  end

  describe 'tools/call to inspection without arguments (directory inspection)' do
    let(:file_path) { 'test_file.rb' }
    let(:requests) do
      [{
        jsonrpc: '2.0',
        id: '42',
        method: 'tools/call',
        params: { name: 'rubocop_inspection', arguments: {} }
      }]
    end

    before do
      File.write(file_path, '?a')
    end

    it 'inspects all files in the current directory' do
      expect(stderr).to be_blank
      expect(messages.count).to eq(1)
      expect(response).to include(id: '42', jsonrpc: '2.0')
      expect(response[:result][:isError]).to be false
      expect(parsed_result[:files]).not_to be_empty
      expect(parsed_result[:summary][:target_file_count]).to eq(1)
      expect(parsed_result[:summary]).not_to have_key(:unreported_offenses)
    end
  end

  describe 'tools/call to inspection with `max_offenses_per_cop`' do
    let(:arguments) { { max_offenses_per_cop: 1 } }
    let(:requests) do
      [1, 2].map do |id|
        { jsonrpc: '2.0', id: id, method: 'tools/call',
          params: { name: 'rubocop_inspection', arguments: arguments } }
      end
    end
    let(:results) do
      messages.map do |message|
        JSON.parse(message[:result][:content].first[:text], symbolize_names: true)
      end
    end

    before do
      source = "# frozen_string_literal: true\n\nputs \"a\"\nputs \"b\"\n"
      File.write('a.rb', source)
      File.write('b.rb', source)
    end

    it 'caps each cop across the files and counts what it left out' do
      result = results.first

      expect(result[:files].map { |file| file[:path] }).to eq(['a.rb'])
      cop_names = result[:files].first[:offenses].map { |offense| offense[:cop_name] }
      expect(cop_names).to eq(['Style/StringLiterals'])
      expect(result[:summary]).to include(
        offense_count: 1, unreported_offenses: { 'Style/StringLiterals': 3 }
      )
    end

    it 'starts counting again for every request' do
      expect(results.last).to eq(results.first)
    end

    context 'with inline source code' do
      let(:arguments) { { max_offenses_per_cop: 1, source_code: "puts \"a\"\nputs \"b\"\n" } }

      it 'caps it the same way' do
        result = results.first
        string_literals = result[:files].first[:offenses].count do |offense|
          offense[:cop_name] == 'Style/StringLiterals'
        end

        expect(string_literals).to eq(1)
        expect(result[:summary][:unreported_offenses]).to eq('Style/StringLiterals': 1)
      end
    end

    context 'with a limit below one' do
      let(:arguments) { { max_offenses_per_cop: 0 } }

      it 'rejects it' do
        expect(messages.first[:result][:isError]).to be true
      end
    end
  end

  describe 'tools/call to autocorrection of files' do
    let(:arguments) { { safety: true } }
    let(:requests) do
      [{
        jsonrpc: '2.0',
        id: '42',
        method: 'tools/call',
        params: { name: 'rubocop_autocorrection', arguments: arguments }
      }]
    end
    let(:source) { "x = \"a\"\nputs [1].size == 0\n" }
    let(:offenses) { parsed_result[:files].first[:offenses] }

    def offense_of(cop_name)
      offenses.find { |offense| offense[:cop_name] == cop_name }
    end

    before do
      File.write('a.rb', source)
      File.write('clean.rb', "# frozen_string_literal: true\n\nputs 'a'\n")
    end

    it 'lists the offenses it left, in the inspection format, and only the files that matter' do
      expect(parsed_result[:files]).to match([include(path: 'a.rb', corrected: true)])
      expect(offenses.map { |offense| offense[:cop_name] }).to contain_exactly(
        'Lint/UselessAssignment', 'Style/FrozenStringLiteralComment',
        'Style/NumericPredicate', 'Style/ZeroLengthPredicate'
      )
      expect(parsed_result[:summary]).to eq(
        target_file_count: 2, offense_count: 4, corrected_file_count: 1
      )
    end

    it 'marks an unsafe correction left behind as needing `safety` set to false' do
      expect(offense_of('Style/ZeroLengthPredicate'))
        .to include(correctable: true, correction: include(safe: false))
    end

    it 'marks a correction held back while code is being edited as not correctable' do
      expect(offense_of('Lint/UselessAssignment'))
        .to include(correctable: false, correction: include(:edits))
    end

    context 'with unsafe corrections' do
      let(:arguments) { { safety: false } }

      it 'locates the offenses it left in the corrected file' do
        line = offense_of('Lint/UselessAssignment')[:location][:start_line]

        expect(line).to eq(3)
        expect(File.read('a.rb').lines[line - 1]).to eq("x = 'a'\n")
      end
    end

    context 'with more offenses left than the default cap' do
      let(:source) { (1..6).map { |n| "x#{n} = #{n}\n" }.join }

      it 'lists five of each cop and counts the rest' do
        expect(offenses.count { |offense| offense[:cop_name] == 'Lint/UselessAssignment' }).to eq(5)
        expect(parsed_result[:summary][:unreported_offenses]).to eq('Lint/UselessAssignment': 1)
      end
    end

    context 'with `max_offenses_per_cop`' do
      let(:arguments) { { safety: true, max_offenses_per_cop: 1 } }

      before { File.write('b.rb', "x = \"b\"\n") }

      it 'caps the offenses it lists, not the corrections it makes' do
        expect(parsed_result[:files].sum { |file| file[:offenses].size }).to eq(4)
        expect(parsed_result[:summary][:unreported_offenses]).to eq(
          'Lint/UselessAssignment': 1, 'Style/FrozenStringLiteralComment': 1
        )
        expect(File.read('b.rb')).to eq("x = 'b'\n")
      end
    end

    context 'with an argument it does not take' do
      let(:arguments) { { safety: true, path: 'a.rb', fix_everything: true } }

      # How much of the error the client sees depends on the version of the mcp gem.
      it 'refuses it without correcting anything' do
        expect(response).to have_key(:error)
        expect(File.read('a.rb')).to eq(source)
      end
    end
  end

  describe 'tools/call to inspection with no target files' do
    let(:requests) do
      [{
        jsonrpc: '2.0',
        id: '42',
        method: 'tools/call',
        params: { name: 'rubocop_inspection', arguments: {} }
      }]
    end

    it 'returns empty result without error' do
      expect(stderr).to be_blank
      expect(messages.count).to eq(1)
      expect(response).to include(id: '42', jsonrpc: '2.0')
      expect(response[:result][:isError]).to be false
      expect(parsed_result[:files]).to be_empty
      expect(parsed_result[:summary][:target_file_count]).to eq(0)
    end
  end

  describe 'tools/call to inspection with no offenses' do
    let(:file_path) { 'clean_file.rb' }
    let(:requests) do
      [{
        jsonrpc: '2.0',
        id: '42',
        method: 'tools/call',
        params: { name: 'rubocop_inspection', arguments: {} }
      }]
    end

    before do
      File.write(file_path, "# frozen_string_literal: true\n")
    end

    it 'returns empty files array but counts target files' do
      expect(stderr).to be_blank
      expect(messages.count).to eq(1)
      expect(response).to include(id: '42', jsonrpc: '2.0')
      expect(response[:result][:isError]).to be false
      expect(parsed_result[:files]).to be_empty
      expect(parsed_result[:summary][:target_file_count]).to eq(1)
      expect(parsed_result[:summary][:offense_count]).to eq(0)
    end
  end

  describe 'tools/call to autocorrection (safe)' do
    let(:requests) do
      [{
        jsonrpc: '2.0',
        id: '42',
        method: 'tools/call',
        params: {
          name: 'rubocop_autocorrection',
          arguments: { safety: true, source_code: '?a' }
        }
      }]
    end

    it 'handles requests' do
      expect(stderr).to be_blank
      expect(messages.count).to eq(1)
      expect(messages.first).to eq(
        id: '42',
        jsonrpc: '2.0',
        result: {
          content: [{ text: "'a'\n", type: 'text' }],
          isError: false
        }
      )
    end
  end

  describe 'tools/call to autocorrection (safe) with file path' do
    let(:file_path) { 'test_file.rb' }
    let(:requests) do
      [{
        jsonrpc: '2.0',
        id: '42',
        method: 'tools/call',
        params: {
          name: 'rubocop_autocorrection',
          arguments: { safety: true, source_code: '?a', path: file_path }
        }
      }]
    end

    it 'updates the file with autocorrected content' do
      expect(stderr).to be_blank
      expect(messages.count).to eq(1)
      expect(messages.first).to eq(
        id: '42',
        jsonrpc: '2.0',
        result: {
          content: [{ text: "'a'\n", type: 'text' }],
          isError: false
        }
      )

      expect(File.read(file_path)).to eq("'a'\n")
    end

    context 'when the file already holds the corrected code' do
      let(:modified_at) { Time.new(2020, 1, 1) }

      before do
        File.write(file_path, "'a'\n", mode: 'wb')
        File.utime(modified_at, modified_at, file_path)
      end

      it 'leaves it untouched' do
        expect(response[:result][:content]).to eq([{ text: "'a'\n", type: 'text' }])
        expect(File.mtime(file_path)).to eq(modified_at)
      end
    end
  end

  describe 'tools/call to autocorrection (unsafe)' do
    let(:requests) do
      [{
        jsonrpc: '2.0',
        id: '42',
        method: 'tools/call',
        params: {
          name: 'rubocop_autocorrection',
          arguments: { safety: false, source_code: '?a' }
        }
      }]
    end

    it 'handles requests' do
      expect(stderr).to be_blank
      expect(messages.count).to eq(1)
      expect(messages.first).to eq(
        id: '42',
        jsonrpc: '2.0',
        result: {
          content: [{ text: "# frozen_string_literal: true\n\n'a'\n", type: 'text' }],
          isError: false
        }
      )
    end
  end

  describe 'tools/call to autocorrection (unsafe) with file path' do
    let(:file_path) { 'test_file.rb' }
    let(:requests) do
      [{
        jsonrpc: '2.0',
        id: '42',
        method: 'tools/call',
        params: {
          name: 'rubocop_autocorrection',
          arguments: { safety: false, source_code: '?a', path: file_path }
        }
      }]
    end

    it 'updates the file with autocorrected content' do
      expect(stderr).to be_blank
      expect(messages.count).to eq(1)
      expect(messages.first).to eq(
        id: '42',
        jsonrpc: '2.0',
        result: {
          content: [{ text: "# frozen_string_literal: true\n\n'a'\n", type: 'text' }],
          isError: false
        }
      )

      expect(File.read(file_path)).to eq("# frozen_string_literal: true\n\n'a'\n")
    end
  end

  describe 'tools/call to autocorrection without arguments (directory autocorrection)' do
    let(:file_path) { 'test_file.rb' }
    let(:requests) do
      [{
        jsonrpc: '2.0',
        id: '42',
        method: 'tools/call',
        params: {
          name: 'rubocop_autocorrection',
          arguments: { safety: true }
        }
      }]
    end

    before do
      File.write(file_path, '?a')
    end

    it 'corrects all files in the current directory' do
      expect(stderr).to be_blank
      expect(messages.count).to eq(1)
      expect(response).to include(id: '42', jsonrpc: '2.0')
      expect(response[:result][:isError]).to be false
      expect(parsed_result[:files]).not_to be_empty
      expect(parsed_result[:summary][:target_file_count]).to eq(1)
      expect(File.read(file_path)).to include("'a'")
    end

    context 'with a file that has nothing to correct' do
      let(:clean_file_path) { 'clean.rb' }
      let(:modified_at) { Time.new(2020, 1, 1) }

      before do
        File.write(clean_file_path, "# frozen_string_literal: true\n\nputs 'a'\n")
        File.utime(modified_at, modified_at, clean_file_path)
      end

      it 'leaves it untouched' do
        expect(parsed_result[:summary]).to include(target_file_count: 2, corrected_file_count: 1)
        expect(File.mtime(clean_file_path)).to eq(modified_at)
      end
    end
  end

  context 'when a cop crashes' do
    let(:source) { "# frozen_string_literal: true\n\nputs ?a, \"b\"\n" }
    # One message for the cop, at the first string, though it crashed on both.
    let(:crashes) do
      ['An error occurred while Style/CharacterLiteral cop was inspecting a.rb:3:5.']
    end
    let(:requests) do
      [{
        jsonrpc: '2.0', id: '42', method: 'tools/call',
        params: { name: tool, arguments: arguments }
      }]
    end

    before do
      make_cop_fail(RuboCop::Cop::Style::CharacterLiteral, :on_str, NoMethodError, 'boom')
      File.write('a.rb', source)
    end

    describe 'tools/call to inspection' do
      let(:tool) { 'rubocop_inspection' }
      let(:arguments) { { path: 'a.rb' } }

      it 'lists the crash against its file and still reports the other cops' do
        file = parsed_result[:files].first

        expect(file[:errors]).to eq(crashes)
        expect(file[:offenses].map { |offense| offense[:cop_name] }).to eq(['Style/StringLiterals'])
        expect(parsed_result[:summary]).to include(offense_count: 1, error_count: 1)
      end
    end

    describe 'tools/call to autocorrection' do
      let(:tool) { 'rubocop_autocorrection' }
      let(:arguments) { { path: 'a.rb', safety: true } }

      it 'still corrects what the other cops can and lists the crash' do
        expect(parsed_result[:files]).to eq(
          [{ path: 'a.rb', corrected: true, offenses: [], errors: crashes }]
        )
        expect(File.read('a.rb')).to eq("# frozen_string_literal: true\n\nputs ?a, 'b'\n")
      end
    end

    describe 'tools/call to autocorrection of inline code' do
      let(:tool) { 'rubocop_autocorrection' }
      let(:arguments) { { source_code: source, path: 'a.rb', safety: true } }

      it 'fails without writing anything, since plain text has nowhere to list the crash' do
        expect(response[:result][:isError]).to be true
        expect(response[:result][:content].first[:text]).to eq(crashes.join("\n"))
        expect(File.read('a.rb')).to eq(source)
      end
    end
  end

  context 'when a cop raises a warning' do
    let(:requests) do
      [{
        jsonrpc: '2.0', id: '42', method: 'tools/call',
        params: { name: 'rubocop_inspection', arguments: { path: 'a.rb' } }
      }]
    end

    before do
      make_cop_fail(RuboCop::Cop::Style::CharacterLiteral, :on_str,
                    RuboCop::Warning, 'odd configuration')
      File.write('a.rb', "# frozen_string_literal: true\n\nputs ?a\n")
    end

    it 'lists the warning against its file' do
      expect(parsed_result[:files]).to eq(
        [{ path: 'a.rb', offenses: [], warnings: ['odd configuration (from file: a.rb:3:5)'] }]
      )
      expect(parsed_result[:summary]).to include(warning_count: 1)
    end
  end

  context 'with a scope' do
    let(:source) { "# frozen_string_literal: true\n\nputs ?a, \"b\"\n" }
    let(:requests) do
      [{
        jsonrpc: '2.0', id: '42', method: 'tools/call',
        params: { name: tool, arguments: arguments }
      }]
    end
    let(:tool) { 'rubocop_inspection' }
    let(:cop_names) do
      parsed_result[:files].flat_map { |file| file[:offenses].map { |offense| offense[:cop_name] } }
    end

    before { File.write('a.rb', source) }

    context 'with `only`' do
      let(:arguments) { { path: 'a.rb', only: ['Style/StringLiterals'] } }

      it 'runs only those cops' do
        expect(cop_names).to eq(['Style/StringLiterals'])
      end
    end

    context 'with `except`' do
      let(:arguments) { { path: 'a.rb', except: ['Style'] } }

      it 'runs every cop but those' do
        expect(cop_names).to be_empty
      end
    end

    context 'with a cop name that leaves out the department' do
      let(:arguments) { { path: 'a.rb', only: ['StringLiterals'] } }

      it 'finds the cop, as `--only` does' do
        expect(cop_names).to eq(['Style/StringLiterals'])
      end
    end

    context 'with an empty list' do
      let(:arguments) { { path: 'a.rb', only: [] } }

      it 'runs every cop rather than none' do
        expect(cop_names).to contain_exactly('Style/CharacterLiteral', 'Style/StringLiterals')
      end
    end

    context 'with a cop name that does not exist' do
      let(:arguments) { { path: 'a.rb', only: ['Style/StringLiteral'] } }

      it 'reports it with suggestions' do
        expect(response[:result][:isError]).to be true
        expect(response[:result][:content].first[:text]).to include('Style/StringLiterals')
      end
    end

    context 'with a selection the command line refuses' do
      let(:arguments) { { path: 'a.rb', except: ['Lint/Syntax'] } }

      it 'refuses it too' do
        expect(response[:result][:isError]).to be true
        expect(response[:result][:content].first[:text])
          .to eq('Syntax checking cannot be turned off.')
      end
    end

    context 'when autocorrecting with `only`' do
      let(:tool) { 'rubocop_autocorrection' }
      let(:arguments) { { path: 'a.rb', safety: true, only: ['Style/StringLiterals'] } }

      it 'applies only those cops\' corrections' do
        expect(parsed_result[:summary][:corrected_file_count]).to eq(1)
        expect(File.read('a.rb')).to eq("# frozen_string_literal: true\n\nputs ?a, 'b'\n")
      end
    end

    context 'with `changed`' do
      let(:arguments) { { changed: true } }

      def git(*args)
        _stdout, stderr, status = Open3.capture3('git', *args)
        raise "git #{args.join(' ')} failed: #{stderr}" unless status.success?
      end

      before do
        git('init')
        git('config', 'maintenance.auto', 'false')
        git('add', 'a.rb')
        git('-c', 'user.email=test@example.com', '-c', 'user.name=Test', 'commit', '-m', 'a')
        File.write('b.rb', source)
      end

      it 'checks only the files git says changed' do
        expect(parsed_result[:files].map { |file| file[:path] }).to eq(['b.rb'])
        expect(parsed_result[:summary][:target_file_count]).to eq(1)
      end
    end

    context 'with `changed` and inline source code' do
      let(:arguments) { { source_code: source, changed: true } }

      it 'refuses, since there are no files to choose from' do
        expect(response[:result][:isError]).to be true
        expect(response[:result][:content].first[:text])
          .to eq('`changed` only applies when checking files.')
      end
    end
  end

  context 'when corrections loop' do
    let(:source) { "puts 'a'\n" }
    let(:requests) do
      [{
        jsonrpc: '2.0', id: '42', method: 'tools/call',
        params: { name: 'rubocop_autocorrection', arguments: { path: 'a.rb', safety: true } }
      }]
    end

    # Stands in for two cops undoing each other: when correcting, the runner
    # gives up with the source part way through and reports the loop.
    before do
      File.write('a.rb', source)
      allow(RuboCop::Lsp::StdinRunner).to receive(:new).and_wrap_original do |new, *args|
        runner = new.call(*args)
        allow(runner).to receive(:file_offenses).and_wrap_original do |file_offenses, file|
          options = runner.instance_variable_get(:@options)
          next file_offenses.call(file) unless options[:autocorrect]

          options[:stdin] = 'half corrected'
          raise RuboCop::Runner::InfiniteCorrectionLoop.new(file, [[]])
        end
        runner
      end
    end

    it 'leaves the file alone and lists the loop, with the offenses it still has' do
      file = parsed_result[:files].first

      expect(file).to include(path: 'a.rb', corrected: false)
      expect(file[:errors]).to contain_exactly(start_with('Infinite loop detected in a.rb'))
      expect(file[:offenses].map { |offense| offense[:cop_name] })
        .to eq(['Style/FrozenStringLiteralComment'])
      expect(File.read('a.rb')).to eq(source)
    end
  end

  describe 'tools/call to autocorrection with permission denied' do
    let(:file_path) { 'readonly_file.rb' }
    let(:requests) do
      [{
        jsonrpc: '2.0',
        id: '42',
        method: 'tools/call',
        params: {
          name: 'rubocop_autocorrection',
          arguments: { safety: true, path: file_path }
        }
      }]
    end

    before do
      File.write(file_path, '?a')
      File.chmod(0o444, file_path)
    end

    after do
      File.chmod(0o644, file_path)
    end

    it 'returns permission denied error' do
      expect(messages.count).to eq(1)
      expect(response).to include(id: '42', jsonrpc: '2.0')
      expect(response[:result][:isError]).to be true
      expect(response[:result][:content].first[:text]).to include('Permission denied')
    end
  end

  describe 'tools/call to autocorrection with no space left on device' do
    let(:file_path) { 'test_file.rb' }
    let(:requests) do
      [{
        jsonrpc: '2.0',
        id: '42',
        method: 'tools/call',
        params: {
          name: 'rubocop_autocorrection',
          arguments: { safety: true, path: file_path }
        }
      }]
    end

    before do
      File.write(file_path, '?a')
      allow(File).to receive(:write).and_raise(Errno::ENOSPC)
    end

    it 'returns no space left error' do
      expect(messages.count).to eq(1)
      expect(response).to include(id: '42', jsonrpc: '2.0')
      expect(response[:result][:isError]).to be true
      expect(response[:result][:content].first[:text]).to include('No space left on device')
    end
  end

  describe 'tools/call to autocorrection with read-only file system' do
    let(:file_path) { 'test_file.rb' }
    let(:requests) do
      [{
        jsonrpc: '2.0',
        id: '42',
        method: 'tools/call',
        params: {
          name: 'rubocop_autocorrection',
          arguments: { safety: true, path: file_path }
        }
      }]
    end

    before do
      File.write(file_path, '?a')
      allow(File).to receive(:write).and_raise(Errno::EROFS)
    end

    it 'returns read-only file system error' do
      expect(messages.count).to eq(1)
      expect(response).to include(id: '42', jsonrpc: '2.0')
      expect(response[:result][:isError]).to be true
      expect(response[:result][:content].first[:text]).to include('Read-only file system')
    end
  end
end
