# frozen_string_literal: true

RSpec.describe RuboCop::MCP::Server, :isolated_environment, :lsp do
  include MCPHelper

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
        method: 'initialize'
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
                         'Provide `source_code` to check inline code or `path` to check files.',
            inputSchema: {
              properties: {
                path: { type: 'string' },
                source_code: { type: 'string' }
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
            description: 'Autocorrect RuboCop offenses in Ruby code. ' \
                         'Provide `source_code` to correct inline code ' \
                         'or `path` to correct files. ' \
                         'Set `safety` to false to include unsafe corrections.',
            inputSchema: {
              properties: {
                path: { type: 'string' },
                safety: { type: 'boolean' },
                source_code: { type: 'string' }
              },
              required: ['safety'], type: 'object'
            },
            name: 'rubocop_autocorrection'
          }]
        }
      )
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
    let(:character_literal) { parsed_result.find { |o| o[:code] == 'Style/CharacterLiteral' } }
    let(:frozen_string) do
      parsed_result.find { |o| o[:code] == 'Style/FrozenStringLiteralComment' }
    end
    let(:trailing_lines) { parsed_result.find { |o| o[:code] == 'Layout/TrailingEmptyLines' } }

    it 'handles requests' do
      expect(stderr).to be_blank
      expect(messages.count).to eq(1)
      expect(response).to include(id: '42', jsonrpc: '2.0')
      expect(response[:result][:isError]).to be false
      if RuboCop::Platform.windows?
        expect(parsed_result.size).to eq(4)
      else
        expect(parsed_result.size).to eq(3)
      end

      expect(character_literal).to include(
        range: { start: { line: 0, character: 0 }, end: { line: 0, character: 2 } },
        severity: 3,
        source: 'RuboCop'
      )
      expect(character_literal[:codeDescription][:href]).to include('stylecharacterliteral')
      expect(character_literal[:data]).to include(correctable: true)

      expect(frozen_string).to include(
        range: { start: { line: 0, character: 0 }, end: { line: 0, character: 1 } },
        severity: 3,
        source: 'RuboCop'
      )
      expect(frozen_string[:codeDescription][:href]).to include('stylefrozenstringliteralcomment')
      expect(frozen_string[:data]).to include(correctable: true)

      expect(trailing_lines).to include(
        range: { start: { line: 0, character: 2 }, end: { line: 0, character: 2 } },
        severity: 3,
        source: 'RuboCop'
      )
      expect(trailing_lines[:codeDescription][:href]).to include('layouttrailingemptylines')
      expect(trailing_lines[:data]).to include(correctable: true)
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
      expect(parsed_result[:files].first[:offenses]).not_to be_empty
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
