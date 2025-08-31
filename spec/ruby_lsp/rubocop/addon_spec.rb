# frozen_string_literal: true

# NOTE: These don't work in Ruby LSP.
return if RUBY_VERSION < '3.0' || RUBY_ENGINE == 'jruby' || RuboCop::Platform.windows?

require 'ruby_lsp/internal'
require 'ruby_lsp/rubocop/addon'
# NOTE: ruby-lsp enables LSP mode. Ideally the two requires should happen in isolation, but
# for now this prevents it from failing unrelated tests.
RuboCop::LSP.disable

describe 'RubyLSP::RuboCop::Addon', :isolated_environment, :lsp do
  include FileHelper

  include_context 'mock console output'

  let(:addon) do
    RubyLsp::RuboCop::Addon.new
  end

  let(:path) { 'example.rb' }
  let(:uri) { URI(File.absolute_path(path)) }
  let(:source) do
    <<~RUBY
      s = "hello"
      puts s
    RUBY
  end

  let(:request_id) { (1..).to_enum }
  let(:server) { create_server(source, uri) }

  before do
    # Suppress Ruby LSP's add-on logging.
    allow(RuboCop::LSP::Logger).to receive(:log)
  end

  after do
    RubyLsp::Addon.addons.each(&:deactivate)
    RubyLsp::Addon.addons.clear
  end

  describe 'Add-on name' do
    it 'is RuboCop' do
      expect(addon.name).to eq 'RuboCop'
    end
  end

  describe 'textDocument/diagnostic' do
    subject(:result) do
      process_message('textDocument/diagnostic', textDocument: { uri: uri })
      server.pop_response
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
      expect(first_item.message).to eq <<~MESSAGE.chop
        Style/FrozenStringLiteralComment: Missing frozen string literal comment.
      MESSAGE
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
        Style/StringLiterals: Prefer single-quoted strings when you don't need string interpolation or special symbols.
      MESSAGE
    end
  end

  describe 'textDocument/formatting' do
    subject(:result) do
      process_message(
        'textDocument/formatting',
        textDocument: { uri: uri },
        position: { line: 0, character: 0 }
      )
      server.pop_response
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

    context 'with prism as the parser' do
      before do
        create_file('.rubocop.yml', <<~YML)
          AllCops:
            TargetRubyVersion: 3.4
        YML
      end

      context 'with a `Layout/DefEndAlignment` offense' do
        let(:source) do
          <<~RUBY
            class Foo
                def bar
              end
            end
          RUBY
        end

        it 'has autocorrected code' do
          expect(result).to be_an_instance_of(RubyLsp::Result)
          expect(result.response.size).to eq 1
          expect(result.response.first.new_text).to eq <<~RUBY
            class Foo
              def bar
              end
            end
          RUBY
        end
      end
    end
  end

  describe 'workspace/didChangeWatchedFiles' do
    context 'when `.rubocop.yml` changes' do
      let(:path) { '.rubocop.yml' }

      it 'creates new runtime adapter' do
        # Ensure initial indexing is complete before trying to process did change watched file
        # notifications
        server.global_state.index.index_all(uris: [])

        addon = RubyLsp::Addon.addons.find { |a| a.name == 'RuboCop' }
        expect(addon).to be_an_instance_of(RubyLsp::RuboCop::Addon)
        original_runtime_adapter = addon.instance_variable_get(:@runtime_adapter)

        process_message(
          'workspace/didChangeWatchedFiles',
          changes: [{
            uri: uri.to_s,
            type: RubyLsp::Constant::FileChangeType::CHANGED
          }]
        )

        new_runtime_adapter = addon.instance_variable_get(:@runtime_adapter)
        expect(new_runtime_adapter).not_to eq original_runtime_adapter
      end
    end
  end

  private

  # rubocop:disable Metrics/MethodLength
  def create_server(source, uri)
    server = RubyLsp::Server.new(test_mode: true)
    server.global_state.formatter = 'rubocop'
    server.global_state.instance_variable_set(:@linters, ['rubocop'])

    if source
      server.process_message(
        id: request_id.next,
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
      URI::Generic.from_path(path: uri.to_standardized_path), source
    )
    server.load_addons
    server
  end
  # rubocop:enable Metrics/MethodLength

  def process_message(method, **params)
    server.process_message(id: request_id.next, method: method, params: params)
  end
end
