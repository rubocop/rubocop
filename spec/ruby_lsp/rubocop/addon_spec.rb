# frozen_string_literal: true

# NOTE: These don't work in Ruby LSP.
return if RUBY_VERSION < '3.0' || RUBY_ENGINE == 'jruby' || RuboCop::Platform.windows?

require 'ruby_lsp/internal'
require 'ruby_lsp/rubocop/addon'

describe 'RubyLSP::RuboCop::Addon', :isolated_environment, :lsp do
  let(:addon) do
    RubyLsp::RuboCop::Addon.new
  end

  let(:source) do
    <<~RUBY
      s = "hello"
      puts s
    RUBY
  end

  before do
    # Suppress Ruby LSP's add-on logging.
    allow(RuboCop::LSP::Logger).to receive(:log)
  end

  describe 'Add-on name' do
    it 'is RuboCop' do
      expect(addon.name).to eq 'RuboCop'
    end
  end

  describe 'textDocument/diagnostic' do
    subject(:result) do
      with_server(source, 'example.rb') do |server, uri|
        server.process_message(
          id: 2,
          method: 'textDocument/diagnostic',
          params: {
            textDocument: {
              uri: uri
            }
          }
        )

        server.pop_response
      end
    end

    let(:first_item) { result.response.items.first }
    let(:second_item) { result.response.items[1] }

    it 'has basic result information' do
      expect(result).to be_an_instance_of(RubyLsp::Result)
      expect(result.response.kind).to eq 'full'
      expect(result.response.items.size).to eq 2
    end

    it 'has first diagnostic information' do
      expect(first_item.range.start.to_hash).to eq({ line: 0, character: 0 })
      expect(first_item.range.end.to_hash).to eq({ line: 0, character: 1 })
      expect(first_item.severity).to eq RubyLsp::Constant::DiagnosticSeverity::INFORMATION
      expect(first_item.code).to eq 'Style/FrozenStringLiteralComment'
      expect(first_item.code_description.href).to eq 'https://docs.rubocop.org/rubocop/cops_style.html#stylefrozenstringliteralcomment'
      expect(first_item.source).to eq 'RuboCop'
      expect(first_item.message).to eq 'Missing frozen string literal comment.'
    end

    it 'has second diagnostic information' do
      second_item = result.response.items[1]
      expect(second_item.range.start.to_hash).to eq({ line: 0, character: 4 })
      expect(second_item.range.end.to_hash).to eq({ line: 0, character: 11 })
      expect(second_item.severity).to eq RubyLsp::Constant::DiagnosticSeverity::INFORMATION
      expect(second_item.code).to eq 'Style/StringLiterals'
      expect(second_item.code_description.href).to eq 'https://docs.rubocop.org/rubocop/cops_style.html#stylestringliterals'
      expect(second_item.source).to eq 'RuboCop'
      expect(second_item.message).to eq <<~MESSAGE.chop
        Prefer single-quoted strings when you don't need string interpolation or special symbols.
      MESSAGE
    end
  end

  describe 'textDocument/formatting' do
    subject(:result) do
      with_server(source, 'example.rb') do |server, uri|
        server.process_message(
          id: 2,
          method: 'textDocument/formatting',
          params: {
            textDocument: { uri: uri },
            position: { line: 0, character: 0 }
          }
        )

        server.pop_response
      end
    end

    it 'has basic result information' do
      expect(result).to be_an_instance_of(RubyLsp::Result)
      expect(result.response.size).to eq 1
    end

    it 'has autocorrected code' do
      expect(result.response.first.new_text).to eq <<~RUBY
        s = 'hello'
        puts s
      RUBY
    end
  end

  private

  # Lifted from here, because we need to override the formatter to RuboCop in the spec helper:
  # https://github.com/Shopify/ruby-lsp/blob/4c1906172add4d5c39c35d3396aa29c768bfb898/lib/ruby_lsp/test_helper.rb#L20
  #
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def with_server(
    source = nil, path = 'fake.rb', pwd: '..', stub_no_typechecker: false, load_addons: true
  )
    Dir.chdir(pwd) do
      server = RubyLsp::Server.new(test_mode: true)
      uri = URI(File.join(server.global_state.workspace_path, path))
      server.global_state.formatter = 'rubocop'
      server.global_state.instance_variable_set(:@linters, ['rubocop'])
      server.global_state.stubs(:typechecker).returns(false) if stub_no_typechecker

      if source
        server.process_message(
          method: 'textDocument/didOpen',
          params: {
            textDocument: {
              uri: uri,
              text: source,
              version: 1
            }
          }
        )
      end

      server.global_state.index.index_single(
        RubyIndexer::IndexablePath.new(nil, uri.to_standardized_path), source
      )
      server.load_addons if load_addons

      yield server, uri
    end
  ensure
    if load_addons
      RubyLsp::Addon.addons.each(&:deactivate)
      RubyLsp::Addon.addons.clear
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
