# frozen_string_literal: true

RSpec.describe RuboCop::Lsp::Server, :isolated_environment do
  include LspHelper

  subject(:result) { run_server_on_requests(*requests) }

  let(:messages) { result[0] }
  let(:stderr) { result[1].string }

  let(:eol) do
    if RuboCop::Platform.windows?
      "\r\n"
    else
      "\n"
    end
  end

  include_context 'cli spec behavior'

  describe 'server initializes and responds with proper capabilities' do
    let(:requests) do
      [
        jsonrpc: '2.0',
        id: 2,
        method: 'initialize',
        params: { probably: "Don't need real params for this test?" }
      ]
    end

    it 'handles requests' do
      expect(stderr).to eq('')
      expect(messages.count).to eq(1)
      expect(messages.first).to eq(
        jsonrpc: '2.0',
        id: 2,
        result: {
          capabilities: {
            textDocumentSync: { openClose: true, change: 1 },
            documentFormattingProvider: true,
            diagnosticProvider: true
          }
        }
      )
    end
  end

  describe 'did open' do
    let(:requests) do
      [
        jsonrpc: '2.0',
        method: 'textDocument/didOpen',
        params: {
          textDocument: {
            languageId: 'ruby',
            text: "def hi#{eol}  [1, 2,#{eol}   3  ]#{eol}end#{eol}",
            uri: 'file:///path/to/file.rb',
            version: 0
          }
        }
      ]
    end

    it 'handles requests' do
      expect(stderr).to eq('')
      expect(messages.count).to eq(1)
      expect(messages.first).to eq(
        jsonrpc: '2.0',
        method: 'textDocument/publishDiagnostics',
        params: {
          diagnostics: [
            {
              code: 'Style/FrozenStringLiteralComment',
              message: 'Missing frozen string literal comment.',
              range: {
                start: { character: 0, line: 0 }, end: { character: 0, line: 0 }
              },
              severity: 3,
              source: 'rubocop'
            }, {
              code: 'Layout/SpaceInsideArrayLiteralBrackets',
              message: 'Do not use space inside array brackets.',
              range: {
                start: { character: 4, line: 2 }, end: { character: 5, line: 2 }
              },
              severity: 3,
              source: 'rubocop'
            }
          ], uri: 'file:///path/to/file.rb'
        }
      )
    end
  end

  describe 'diagnotic route' do
    let(:requests) do
      [
        jsonrpc: '2.0',
        method: 'textDocument/diagnostic',
        params: {
          textDocument: {
            languageId: 'ruby',
            text: "def hi#{eol}  [1, 2,#{eol}   3  ]#{eol}end#{eol}",
            uri: 'file:///path/to/file.rb',
            version: 0
          }
        }
      ]
    end

    it 'handles requests' do
      expect(stderr).to eq('')
      expect(messages.count).to eq(1)
      expect(messages.first).to eq(
        jsonrpc: '2.0',
        method: 'textDocument/publishDiagnostics',
        params: {
          diagnostics: [
            {
              code: 'Style/FrozenStringLiteralComment',
              message: 'Missing frozen string literal comment.',
              range: {
                start: { character: 0, line: 0 }, end: { character: 0, line: 0 }
              },
              severity: 3,
              source: 'rubocop'
            }, {
              code: 'Layout/SpaceInsideArrayLiteralBrackets',
              message: 'Do not use space inside array brackets.',
              range: {
                start: { character: 4, line: 2 }, end: { character: 5, line: 2 }
              },
              severity: 3,
              source: 'rubocop'
            }
          ], uri: 'file:///path/to/file.rb'
        }
      )
    end
  end

  describe 'format by default (safe autocorrect)' do
    let(:requests) do
      [
        {
          jsonrpc: '2.0',
          method: 'textDocument/didOpen',
          params: {
            textDocument: {
              languageId: 'ruby',
              text: "puts 'hi'",
              uri: 'file:///path/to/file.rb',
              version: 0
            }
          }
        }, {
          jsonrpc: '2.0',
          method: 'textDocument/didChange',
          params: {
            contentChanges: [{ text: "puts 'bye'" }],
            textDocument: {
              uri: 'file:///path/to/file.rb',
              version: 10
            }
          }
        }, {
          jsonrpc: '2.0',
          id: 20,
          method: 'textDocument/formatting',
          params: {
            options: { insertSpaces: true, tabSize: 2 },
            textDocument: { uri: 'file:///path/to/file.rb' }
          }
        }
      ]
    end

    it 'handles requests' do
      expect(stderr).to eq('')
      format_result = messages.last
      expect(format_result).to eq(
        jsonrpc: '2.0',
        id: 20,
        result: [
          newText: "puts 'bye'\n",
          range: {
            start: { line: 0, character: 0 }, end: { line: 1, character: 0 }
          }
        ]
      )
    end
  end

  describe 'format with `safeAutocorrect: true`' do
    let(:requests) do
      [
        {
          jsonrpc: '2.0',
          id: 2,
          method: 'initialize',
          params: {
            probably: "Don't need real params for this test?",
            initializationOptions: {
              safeAutocorrect: true
            }
          }
        },
        {
          jsonrpc: '2.0',
          method: 'textDocument/didOpen',
          params: {
            textDocument: {
              languageId: 'ruby',
              text: "puts 'hi'",
              uri: 'file:///path/to/file.rb',
              version: 0
            }
          }
        }, {
          jsonrpc: '2.0',
          method: 'textDocument/didChange',
          params: {
            contentChanges: [{ text: "puts 'bye'" }],
            textDocument: {
              uri: 'file:///path/to/file.rb',
              version: 10
            }
          }
        }, {
          jsonrpc: '2.0',
          id: 20,
          method: 'textDocument/formatting',
          params: {
            options: { insertSpaces: true, tabSize: 2 },
            textDocument: { uri: 'file:///path/to/file.rb' }
          }
        }
      ]
    end

    it 'handles requests' do
      expect(stderr).to eq('')
      format_result = messages.last
      expect(format_result).to eq(
        jsonrpc: '2.0',
        id: 20,
        result: [
          newText: "puts 'bye'\n",
          range: {
            start: { line: 0, character: 0 }, end: { line: 1, character: 0 }
          }
        ]
      )
    end
  end

  describe 'format with `safeAutocorrect: false`' do
    let(:requests) do
      [
        {
          jsonrpc: '2.0',
          id: 2,
          method: 'initialize',
          params: {
            probably: "Don't need real params for this test?",
            initializationOptions: {
              safeAutocorrect: false
            }
          }
        },
        {
          jsonrpc: '2.0',
          method: 'textDocument/didOpen',
          params: {
            textDocument: {
              languageId: 'ruby',
              text: "puts 'hi'",
              uri: 'file:///path/to/file.rb',
              version: 0
            }
          }
        }, {
          jsonrpc: '2.0',
          method: 'textDocument/didChange',
          params: {
            contentChanges: [{ text: "puts 'bye'" }],
            textDocument: {
              uri: 'file:///path/to/file.rb',
              version: 10
            }
          }
        }, {
          jsonrpc: '2.0',
          id: 20,
          method: 'textDocument/formatting',
          params: {
            options: { insertSpaces: true, tabSize: 2 },
            textDocument: { uri: 'file:///path/to/file.rb' }
          }
        }
      ]
    end

    it 'handles requests' do
      expect(stderr).to eq('')
      format_result = messages.last
      expect(format_result).to eq(
        jsonrpc: '2.0',
        id: 20,
        result: [
          newText: "# frozen_string_literal: true\n\nputs 'bye'\n",
          range: {
            start: { line: 0, character: 0 }, end: { line: 1, character: 0 }
          }
        ]
      )
    end
  end

  describe 'format without `layoutMode` option' do
    let(:requests) do
      [
        {
          jsonrpc: '2.0',
          id: 2,
          method: 'initialize',
          params: {
            probably: "Don't need real params for this test?"
          }
        },
        {
          jsonrpc: '2.0',
          method: 'textDocument/didOpen',
          params: {
            textDocument: {
              languageId: 'ruby',
              text: <<~RUBY,
                puts "hi"
                  puts 'bye'
              RUBY
              uri: 'file:///path/to/file.rb',
              version: 0
            }
          }
        }, {
          jsonrpc: '2.0',
          method: 'textDocument/didChange',
          params: {
            contentChanges: [
              {
                text: <<~RUBY
                  puts "hi"
                    puts 'bye'
                RUBY
              }
            ],
            textDocument: {
              uri: 'file:///path/to/file.rb',
              version: 10
            }
          }
        }, {
          jsonrpc: '2.0',
          id: 20,
          method: 'textDocument/formatting',
          params: {
            options: { insertSpaces: true, tabSize: 2 },
            textDocument: { uri: 'file:///path/to/file.rb' }
          }
        }
      ]
    end

    it 'handles requests' do
      expect(stderr).to eq('')
      format_result = messages.last
      expect(format_result).to eq(
        jsonrpc: '2.0',
        id: 20,
        result: [
          newText: <<~RUBY,
            puts 'hi'
            puts 'bye'
          RUBY
          range: {
            start: { line: 0, character: 0 }, end: { line: 3, character: 0 }
          }
        ]
      )
    end
  end

  describe 'format with `layoutMode: true`' do
    let(:requests) do
      [
        {
          jsonrpc: '2.0',
          id: 2,
          method: 'initialize',
          params: {
            probably: "Don't need real params for this test?",
            initializationOptions: {
              layoutMode: true
            }
          }
        },
        {
          jsonrpc: '2.0',
          method: 'textDocument/didOpen',
          params: {
            textDocument: {
              languageId: 'ruby',
              text: <<~RUBY,
                puts "hi"
                  puts 'bye'
              RUBY
              uri: 'file:///path/to/file.rb',
              version: 0
            }
          }
        }, {
          jsonrpc: '2.0',
          method: 'textDocument/didChange',
          params: {
            contentChanges: [
              {
                text: <<~RUBY
                  puts "hi"
                    puts 'bye'
                RUBY
              }
            ],
            textDocument: {
              uri: 'file:///path/to/file.rb',
              version: 10
            }
          }
        }, {
          jsonrpc: '2.0',
          id: 20,
          method: 'textDocument/formatting',
          params: {
            options: { insertSpaces: true, tabSize: 2 },
            textDocument: { uri: 'file:///path/to/file.rb' }
          }
        }
      ]
    end

    it 'handles requests' do
      expect(stderr).to eq('')
      format_result = messages.last
      expect(format_result).to eq(
        jsonrpc: '2.0',
        id: 20,
        result: [
          newText: <<~RUBY,
            puts "hi"
            puts 'bye'
          RUBY
          range: {
            start: { line: 0, character: 0 }, end: { line: 3, character: 0 }
          }
        ]
      )
    end
  end

  describe 'format with `layoutMode: false`' do
    let(:requests) do
      [
        {
          jsonrpc: '2.0',
          id: 2,
          method: 'initialize',
          params: {
            probably: "Don't need real params for this test?",
            initializationOptions: {
              layoutMode: false
            }
          }
        },
        {
          jsonrpc: '2.0',
          method: 'textDocument/didOpen',
          params: {
            textDocument: {
              languageId: 'ruby',
              text: <<~RUBY,
                puts "hi"
                  puts 'bye'
              RUBY
              uri: 'file:///path/to/file.rb',
              version: 0
            }
          }
        }, {
          jsonrpc: '2.0',
          method: 'textDocument/didChange',
          params: {
            contentChanges: [
              {
                text: <<~RUBY
                  puts "hi"
                    puts 'bye'
                RUBY
              }
            ],
            textDocument: {
              uri: 'file:///path/to/file.rb',
              version: 10
            }
          }
        }, {
          jsonrpc: '2.0',
          id: 20,
          method: 'textDocument/formatting',
          params: {
            options: { insertSpaces: true, tabSize: 2 },
            textDocument: { uri: 'file:///path/to/file.rb' }
          }
        }
      ]
    end

    it 'handles requests' do
      expect(stderr).to eq('')
      format_result = messages.last
      expect(format_result).to eq(
        jsonrpc: '2.0',
        id: 20,
        result: [
          newText: <<~RUBY,
            puts 'hi'
            puts 'bye'
          RUBY
          range: {
            start: { line: 0, character: 0 }, end: { line: 3, character: 0 }
          }
        ]
      )
    end
  end

  describe 'no op commands' do
    let(:requests) do
      [
        {
          jsonrpc: '2.0',
          id: 1,
          method: '$/cancelRequest',
          params: {}
        }, {
          jsonrpc: '2.0',
          id: 1,
          method: '$/setTrace',
          params: {}
        }
      ]
    end

    it 'does not handle requests' do
      expect(stderr).to eq('')
    end
  end

  describe 'initialized' do
    let(:requests) do
      [
        jsonrpc: '2.0', id: 1, method: 'initialized', params: {}
      ]
    end

    it 'logs the RuboCop version' do
      expect(stderr).to match(/RuboCop \d+.\d+.\d+ language server initialized, PID \d+/)
    end
  end

  describe 'format with unsynced file' do
    let(:requests) do
      [
        {
          jsonrpc: '2.0',
          method: 'textDocument/didOpen',
          params: {
            textDocument: {
              languageId: 'ruby',
              text: "def hi\n  [1, 2,\n   3  ]\nend\n",
              uri: 'file:///path/to/file.rb',
              version: 0
            }
          }
        },
        # didClose should cause the file to be unsynced
        {
          jsonrpc: '2.0',
          method: 'textDocument/didClose',
          params: {
            textDocument: {
              uri: 'file:///path/to/file.rb'
            }
          }
        }, {
          id: 20,
          jsonrpc: '2.0',
          method: 'textDocument/formatting',
          params: {
            options: { insertSpaces: true, tabSize: 2 },
            textDocument: { uri: 'file:///path/to/file.rb' }
          }
        }
      ]
    end

    it 'handles requests' do
      expect(stderr.chomp).to eq(
        '[server] Format request arrived before text synchronized; ' \
        "skipping: `file:///path/to/file.rb'"
      )
      format_result = messages.last
      expect(format_result).to eq(jsonrpc: '2.0', id: 20, result: [])
    end
  end

  describe 'unknown commands' do
    let(:requests) do
      [
        id: 18,
        jsonrpc: '2.0',
        method: 'textDocument/didMassage',
        params: {
          textDocument: {
            languageId: 'ruby',
            text: "def hi\n  [1, 2,\n   3  ]\nend\n",
            uri: 'file:///path/to/file.rb',
            version: 0
          }
        }
      ]
    end

    it 'handles requests' do
      expect(stderr.chomp).to eq('[server] Unsupported Method: textDocument/didMassage')
      expect(messages.last).to eq(
        jsonrpc: '2.0',
        id: 18,
        error: {
          code: LanguageServer::Protocol::Constant::ErrorCodes::METHOD_NOT_FOUND,
          message: 'Unsupported Method: textDocument/didMassage'
        }
      )
    end
  end

  describe 'methodless requests are acked' do
    let(:requests) do
      [
        jsonrpc: '2.0', id: 1, result: {}
      ]
    end

    it 'handles requests' do
      expect(stderr).to eq('')
      expect(messages.last).to eq(jsonrpc: '2.0', id: 1, result: nil)
    end
  end

  describe 'methodless and idless requests are dropped' do
    let(:requests) do
      [
        jsonrpc: '2.0', result: {}
      ]
    end

    it 'handles requests' do
      expect(stderr).to eq('')
      expect(messages.empty?).to be(true)
    end
  end

  describe 'execute command formatting' do
    let(:requests) do
      [
        {
          jsonrpc: '2.0',
          method: 'textDocument/didOpen',
          params: {
            textDocument: {
              languageId: 'ruby',
              text: "puts 'hi'",
              uri: 'file:///path/to/file.rb',
              version: 0
            }
          }
        }, {
          jsonrpc: '2.0',
          id: 99,
          method: 'workspace/executeCommand',
          params: {
            command: 'rubocop.formatAutocorrects',
            arguments: [uri: 'file:///path/to/file.rb']
          }
        }
      ]
    end

    it 'handles requests' do
      expect(stderr).to eq('')
      expect(messages.last).to eq(
        jsonrpc: '2.0',
        id: 99,
        method: 'workspace/applyEdit',
        params: {
          label: 'Format with RuboCop autocorrects',
          edit: {
            changes: {
              'file:///path/to/file.rb': [
                newText: "puts 'hi'\n",
                range: {
                  start: { line: 0, character: 0 }, end: { line: 1, character: 0 }
                }
              ]
            }
          }
        }
      )
    end
  end

  describe 'execute command with unsupported command' do
    let(:requests) do
      [
        jsonrpc: '2.0',
        id: 99,
        method: 'workspace/executeCommand',
        params: {
          command: 'rubocop.somethingElse',
          arguments: [uri: 'file:///path/to/file.rb']
        }
      ]
    end

    it 'handles requests' do
      expect(stderr.chomp).to eq('[server] Unsupported Method: rubocop.somethingElse')
      expect(messages.last).to eq(
        jsonrpc: '2.0',
        id: 99,
        error: {
          code: -32_601,
          message: 'Unsupported Method: rubocop.somethingElse'
        }
      )
    end
  end

  describe 'did open on ignored path' do
    let(:requests) do
      [
        jsonrpc: '2.0',
        method: 'textDocument/didOpen',
        params: {
          textDocument: {
            languageId: 'ruby',
            text: "puts 'neat'",
            # Depends on this project's .standard.yml ignoring `tmp/**/*`
            uri: "file://#{Dir.pwd}/tmp/foo/bar.rb",
            version: 0
          }
        }
      ]
    end

    it 'handles requests' do
      expect(messages.count).to eq(1)
      expect(messages.first).to eq(
        jsonrpc: '2.0',
        method: 'textDocument/publishDiagnostics',
        params: {
          diagnostics: [],
          uri: "file://#{Dir.pwd}/tmp/foo/bar.rb"
        }
      )
      expect(stderr.chomp).to eq(
        "[server] Ignoring file, per configuration: #{Dir.pwd}/tmp/foo/bar.rb"
      )
    end
  end

  describe 'formatting via execute command on ignored path' do
    let(:requests) do
      [
        {
          jsonrpc: '2.0',
          method: 'textDocument/didOpen',
          params: {
            textDocument: {
              languageId: 'ruby',
              text: "puts 'hi'",
              # Depends on this project's .rubocop.yml ignoring `tmp/**/*`
              uri: "file://#{Dir.pwd}/tmp/baz.rb",
              version: 0
            }
          }
        }, {
          jsonrpc: '2.0',
          id: 99,
          method: 'workspace/executeCommand',
          params: {
            command: 'rubocop.formatAutocorrects',
            arguments: [{ uri: "file://#{Dir.pwd}/tmp/baz.rb" }]
          }
        }
      ]
    end

    it 'handles requests' do
      expect(messages.last).to eq(
        jsonrpc: '2.0',
        id: 99,
        method: 'workspace/applyEdit',
        params: {
          label: 'Format with RuboCop autocorrects',
          edit: {
            changes: {
              "file://#{Dir.pwd}/tmp/baz.rb": []
            }
          }
        }
      )
      expect(stderr.chomp).to eq(
        "[server] Ignoring file, per configuration: #{Dir.pwd}/tmp/baz.rb"
      )
    end
  end

  describe 'formatting via formatting path on ignored path' do
    let(:requests) do
      [
        {
          jsonrpc: '2.0',
          method: 'textDocument/didOpen',
          params: {
            textDocument: {
              languageId: 'ruby',
              text: "puts 'hi'",
              # Depends on this project's .standard.yml ignoring `tmp/**/*`
              uri: "file://#{Dir.pwd}/tmp/zzz.rb",
              version: 0
            }
          }
        }, {
          jsonrpc: '2.0',
          method: 'textDocument/didChange',
          params: {
            contentChanges: [{ text: "puts 'bye'" }],
            textDocument: {
              uri: "file://#{Dir.pwd}/tmp/zzz.rb",
              version: 10
            }
          }
        }, {
          jsonrpc: '2.0',
          id: 20,
          method: 'textDocument/formatting',
          params: {
            options: { insertSpaces: true, tabSize: 2 },
            textDocument: { uri: "file://#{Dir.pwd}/tmp/zzz.rb" }
          }
        }
      ]
    end

    it 'handles requests' do
      format_result = messages.last
      expect(format_result).to eq(jsonrpc: '2.0', id: 20, result: [])
      expect(stderr.chomp).to eq(
        "[server] Ignoring file, per configuration: #{Dir.pwd}/tmp/zzz.rb"
      )
    end
  end

  context 'when an internal error occurs' do
    before do
      allow_any_instance_of(RuboCop::Lsp::Routes).to receive(:for).with('initialize').and_raise # rubocop:disable RSpec/AnyInstance
    end

    let(:requests) do
      [
        jsonrpc: '2.0',
        id: 2,
        method: 'initialize',
        params: { probably: "Don't need real params for this test?" }
      ]
    end

    it 'logs an internal server error message' do
      expect(stderr).to start_with('[server] Error RuntimeError')
      expect(messages.count).to eq(0)
    end
  end
end
