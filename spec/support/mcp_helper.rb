# frozen_string_literal: true

require 'rubocop/mcp/server'

module MCPHelper
  def run_server_on_requests(*requests)
    stdin = StringIO.new(requests.map(&:to_json).join)
    stdout = StringIO.new
    stderr = StringIO.new

    RuboCop::Server::Helper.redirect(stdin: stdin, stdout: stdout, stderr: stderr) do
      config_store = RuboCop::ConfigStore.new

      RuboCop::MCP::Server.new(config_store).start
    end

    messages = parse_jsonrpc_messages(stdout)

    [messages, stderr]
  end

  def parse_jsonrpc_messages(io)
    io.rewind
    io.each_line.with_object([]) do |message, messages|
      messages << JSON.parse(message, symbolize_names: true)
    end
  end
end
