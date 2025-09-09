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

  let(:path) { 'example.rb' }
  let(:uri) { path_to_uri(path) }
  let(:source) do
    <<~RUBY
      s = "hello"
      puts s
    RUBY
  end

  let(:request_id) { (1..).to_enum }
  let(:server) { create_server(source, uri) }

  after do
    RubyLsp::Addon.addons.each(&:deactivate)
    RubyLsp::Addon.addons.clear
  end

  context 'Add-on metadata' do
    let(:addon) do
      RubyLsp::RuboCop::Addon.new
    end

    it 'has a name' do
      expect(addon.name).to eq 'RuboCop'
    end

    it 'has a version' do
      expect(addon.version).to match(/\A\d+\.\d+\.\d+\z/)
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

    context 'when `.rubocop` points to a different config file' do
      before do
        create_file('.rubocop', '-c custom.yml')
        create_file('custom.yml', <<~YML)
          <%= warn "Hello from 'custom.yml'" %>
        YML
      end

      it 'uses the config file' do
        expect { result }.to output(/Hello from 'custom\.yml'/).to_stderr
      end
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

    context 'when an error occurs' do
      context 'when `.rubocop.yml` is invalid' do
        it 'handles it gracefully' do
          create_file('.rubocop.yml', 'Not valid YAML!')
          server.global_state.index.index_all(uris: [])

          init_response = server.pop_response
          expect(init_response).to be_an_instance_of(RubyLsp::Notification)
          expect(init_response.params.attributes[:message]).to match(
            /RuboCop configuration error: Malformed configuration/
          )

          process_message(
            'textDocument/formatting',
            textDocument: { uri: uri },
            position: { line: 0, character: 0 }
          )
          formatting_response = server.pop_response

          expect(formatting_response).to be_an_instance_of(RubyLsp::Result)
          expect(formatting_response.response).to be_nil

          create_empty_file('.rubocop.yml')
          expect do
            process_message(
              'workspace/didChangeWatchedFiles',
              changes: [{
                uri: path_to_uri('.rubocop.yml').to_s,
                type: RubyLsp::Constant::FileChangeType::CHANGED
              }]
            )
          end.to output.to_stderr

          process_message(
            'textDocument/formatting',
            textDocument: { uri: uri },
            position: { line: 0, character: 0 }
          )
          formatting_response = server.pop_response

          expect(formatting_response).to be_an_instance_of(RubyLsp::Result)
          expect(formatting_response.response).not_to be_nil
        end
      end

      context 'runtime error' do
        before do
          allow_any_instance_of(RuboCop::Cop::Style::StringLiterals) # rubocop:disable RSpec/AnyInstance
            .to receive(:on_str)
            .and_raise(RuntimeError, 'oops')
        end

        let(:source) { '""' }

        it 'handles infinite loop errors' do
          expect { result }.to output.to_stderr
          expect(result).to be_an_instance_of(RubyLsp::Notification)
          expect(result.params.attributes[:message]).to match(<<~MSG)
            Formatting error: An internal error occurred for the Style/StringLiterals cop.
          MSG
        end
      end

      context 'infinite loop error' do
        before do
          allow(RuboCop::Cop::Registry).to receive(:all).and_return([cop])
        end

        let(:cop) { RuboCop::Cop::Test::InfiniteLoopDuringAutocorrectWithChangeCop }

        let(:source) do
          <<~RUBY
            class Test
            end
          RUBY
        end

        it 'handles infinite loop errors' do
          expect { result }.to output.to_stderr
          expect(result).to be_an_instance_of(RubyLsp::Notification)
          expect(result.params.attributes[:message]).to match(<<~MSG)
            Formatting error: An internal error occurred - Infinite loop detected in #{uri} and caused by #{cop.badge}.
          MSG
        end
      end
    end
  end

  describe 'workspace/didChangeWatchedFiles' do
    before do
      # Ensure initial indexing is complete before trying to process did change watched file
      # notifications.
      server.global_state.index.index_all(uris: [])
    end

    context 'when `.rubocop.yml` changes' do
      let(:source) do
        <<~RUBY
          # frozen_string_literal: true

          ""
        RUBY
      end

      it 'reloads the addon and uses the updated config' do
        create_file('.rubocop.yml', <<~YML)
          Style/StringLiterals:
            EnforcedStyle: single_quotes
        YML
        process_message('textDocument/diagnostic', textDocument: { uri: uri })
        diagnostics_result = server.pop_response
        expect(diagnostics_result).to be_an_instance_of(RubyLsp::Result)
        rubocop_diagnostics = diagnostics_result.response.items.select do |diag|
          diag.source == 'RuboCop'
        end
        expect(rubocop_diagnostics.size).to eq(1)
        expect(rubocop_diagnostics[0].code).to eq('Style/StringLiterals')

        create_file('.rubocop.yml', <<~YML)
          Style/StringLiterals:
            EnforcedStyle: double_quotes
        YML
        expect do
          process_message(
            'workspace/didChangeWatchedFiles',
            changes: [{
              uri: path_to_uri('.rubocop.yml').to_s,
              type: RubyLsp::Constant::FileChangeType::CHANGED
            }]
          )
        end.to output.to_stderr

        process_message('textDocument/diagnostic', textDocument: { uri: uri })
        diagnostics_result = server.pop_response
        expect(diagnostics_result).to be_an_instance_of(RubyLsp::Result)
        rubocop_diagnostics = diagnostics_result.response.items.select do |diag|
          diag.source == 'RuboCop'
        end
        expect(rubocop_diagnostics).to be_empty
      end
    end

    %w[.rubocop.yml .rubocop_todo.yml .rubocop].each do |path|
      context "when `#{path}` changes" do
        it 'logs a message that the add-on got re-initialized' do
          expect do
            process_message(
              'workspace/didChangeWatchedFiles',
              changes: [{
                uri: path_to_uri(path).to_s,
                type: RubyLsp::Constant::FileChangeType::CHANGED
              }]
            )
          end.to output(/Re-initialized RuboCop LSP addon/).to_stderr
        end
      end
    end

    context 'when `test.rb` file changes' do
      let(:path) { 'test.rb' }

      it "doesn't log a message about re-initializing the addon" do
        expect do
          process_message(
            'workspace/didChangeWatchedFiles',
            changes: [{
              uri: uri.to_s,
              type: RubyLsp::Constant::FileChangeType::CHANGED
            }]
          )
        end.not_to output.to_stderr
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

  def path_to_uri(path)
    URI(File.absolute_path(path))
  end
end
