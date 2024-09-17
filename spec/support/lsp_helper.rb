# frozen_string_literal: true

require 'rubocop/lsp/server'

module LSPHelper
  def run_server_on_requests(*requests)
    stdin = StringIO.new(requests.map { |request| to_jsonrpc(request) }.join)

    RuboCop::Server::Helper.redirect(stdin: stdin) do
      config_store = RuboCop::ConfigStore.new

      RuboCop::LSP::Server.new(config_store).start
    end

    messages = parse_jsonrpc_messages($stdout)

    [messages, $stderr]
  end

  def to_jsonrpc(hash)
    hash_str = hash.to_json

    "Content-Length: #{hash_str.bytesize}\r\n\r\n#{hash_str}"
  end

  def parse_jsonrpc_messages(io)
    io.rewind
    reader = LanguageServer::Protocol::Transport::Io::Reader.new(io)
    messages = []
    reader.read { |message| messages << message }
    messages
  end
end
