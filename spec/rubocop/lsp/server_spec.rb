# frozen_string_literal: true

RSpec.describe RuboCop::LSP::Server, :isolated_environment do
  include LSPHelper

  subject(:result) { run_server_on_requests(*requests) }

  after do
    RuboCop::LSP.disable
  end

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
      [{
        jsonrpc: '2.0',
        id: 2,
        method: 'initialize',
        params: { probably: "Don't need real params for this test?" }
      }]
    end

    it 'handles requests' do
      expect(stderr).to eq('')
      expect(messages.count).to eq(1)
      expect(messages.first).to eq(
        jsonrpc: '2.0',
        id: 2,
        result: {
          capabilities: {
            textDocumentSync: { openClose: true, change: 2 },
            documentFormattingProvider: true
          }
        }
      )
    end
  end

  describe 'did open' do
    let(:requests) do
      [{
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
      }]
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
              codeDescription: {
                href: 'https://docs.rubocop.org/rubocop/cops_style.html#stylefrozenstringliteralcomment'
              },
              data: {
                code_actions: [
                  {
                    edit: {
                      documentChanges: [{
                        edits: [
                          {
                            newText: "# frozen_string_literal: true\n",
                            range: {
                              start: { character: 0, line: 0 },
                              end: { character: 0, line: 0 }
                            }
                          }
                        ],
                        textDocument: { uri: 'file:///path/to/file.rb', version: nil }
                      }]
                    },
                    kind: 'quickfix',
                    title: 'Autocorrect Style/FrozenStringLiteralComment',
                    isPreferred: true
                  }, {
                    edit: {
                      documentChanges: [{
                        edits: [
                          {
                            newText: ' # rubocop:disable Style/FrozenStringLiteralComment',
                            range: {
                              start: { character: 6, line: 0 },
                              end: { character: 6, line: 0 }
                            }
                          }
                        ],
                        textDocument: { uri: 'file:///path/to/file.rb', version: nil }
                      }]
                    },
                    kind: 'quickfix',
                    title: 'Disable Style/FrozenStringLiteralComment for this line'
                  }
                ],
                correctable: true
              },
              message: 'Style/FrozenStringLiteralComment: Missing frozen string literal comment.',
              range: {
                start: { character: 0, line: 0 },
                end: { character: 1, line: 0 }
              },
              severity: 3,
              source: 'RuboCop'
            }, {
              code: 'Layout/SpaceInsideArrayLiteralBrackets',
              codeDescription: {
                href: 'https://docs.rubocop.org/rubocop/cops_layout.html#layoutspaceinsidearrayliteralbrackets'
              },
              data: {
                code_actions: [
                  {
                    edit: {
                      documentChanges: [{
                        edits: [{
                          newText: '', range: {
                            end: { character: 6, line: 2 },
                            start: { character: 4, line: 2 }
                          }
                        }],
                        textDocument: { uri: 'file:///path/to/file.rb', version: nil }
                      }]
                    },
                    kind: 'quickfix',
                    title: 'Autocorrect Layout/SpaceInsideArrayLiteralBrackets',
                    isPreferred: true
                  }, {
                    edit: {
                      documentChanges: [{
                        edits: [{
                          newText: ' # rubocop:disable Layout/SpaceInsideArrayLiteralBrackets',
                          range: {
                            end: { character: 7, line: 2 },
                            start: {
                              character: 7, line: 2
                            }
                          }
                        }],
                        textDocument: { uri: 'file:///path/to/file.rb', version: nil }
                      }]
                    },
                    kind: 'quickfix',
                    title: 'Disable Layout/SpaceInsideArrayLiteralBrackets for this line'
                  }
                ],
                correctable: true
              },
              message: 'Layout/SpaceInsideArrayLiteralBrackets: Do not use space inside array brackets.', # rubocop:disable Layout/LineLength
              range: {
                start: { character: 4, line: 2 },
                end: { character: 6, line: 2 }
              },
              severity: 3,
              source: 'RuboCop'
            }
          ], uri: 'file:///path/to/file.rb'
        }
      )
    end
  end

  describe 'did open with multiline literal offense' do
    let(:long_line) { 'a' * 130 }
    let(:requests) do
      [{
        jsonrpc: '2.0',
        method: 'textDocument/didOpen',
        params: {
          textDocument: {
            languageId: 'ruby',
            text: [
              '# frozen_string_literal: true',
              '',
              'values = %w[',
              "  #{long_line}",
              ']',
              'puts values',
              ''
            ].join(eol),
            uri: 'file:///path/to/file.rb',
            version: 0
          }
        }
      }]
    end

    it 'uses block comments for disable quickfix inside multiline literals' do
      expect(stderr).to eq('')
      diagnostics = messages.first.dig(:params, :diagnostics)
      diagnostic = diagnostics.find { |diag| diag[:code] == 'Layout/LineLength' }
      expect(diagnostic).not_to be_nil

      code_actions = diagnostic[:data][:code_actions]
      disable_action = code_actions.find do |action|
        action[:title] == 'Disable Layout/LineLength for this line'
      end
      expect(disable_action).not_to be_nil

      edits = disable_action[:edit][:documentChanges].first[:edits]
      expect(edits).to eq(
        [
          {
            newText: "# rubocop:disable Layout/LineLength\n",
            range: {
              start: { line: 2, character: 0 },
              end: { line: 2, character: 0 }
            }
          },
          {
            newText: "\n# rubocop:enable Layout/LineLength",
            range: {
              start: { line: 4, character: 1 },
              end: { line: 4, character: 1 }
            }
          }
        ]
      )
    end
  end

  describe 'did open with multibyte character(utf-16)' do
    let(:requests) do
      [{
        jsonrpc: '2.0',
        method: 'textDocument/didOpen',
        params: {
          textDocument: {
            languageId: 'ruby',
            text: "'☃🍣🍺' x",
            uri: 'file:///path/to/file.rb',
            version: 0
          }
        }
      }]
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
              code: 'Lint/Syntax',
              codeDescription: {
                href: 'https://docs.rubocop.org/rubocop/cops_lint.html#lintsyntax'
              },
              data: {
                code_actions: [
                  {
                    edit: {
                      documentChanges: [
                        {
                          edits: [
                            {
                              newText: ' # rubocop:disable Lint/Syntax',
                              range: {
                                start: { character: 9, line: 0 },
                                end: { character: 9, line: 0 }
                              }
                            }
                          ],
                          textDocument: { uri: 'file:///path/to/file.rb', version: nil }
                        }
                      ]
                    },
                    kind: 'quickfix',
                    title: 'Disable Lint/Syntax for this line'
                  }
                ],
                correctable: false
              },
              message: "Lint/Syntax: unexpected token tIDENTIFIER\n\nThis offense is not autocorrectable.\n", # rubocop:disable Layout/LineLength
              range: {
                start: { character: 8, line: 0 },
                end: { character: 9, line: 0 }
              },
              severity: 1,
              source: 'RuboCop'
            }
          ],
          uri: 'file:///path/to/file.rb'
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
        result: [{
          newText: "puts 'bye'\n",
          range: {
            start: { line: 0, character: 0 }, end: { line: 1, character: 0 }
          }
        }]
      )
    end
  end

  describe 'format by default (safe autocorrect) with an `AutoCorrect: contextual` cop' do
    let(:empty_comment) { "##{eol}" }

    let(:requests) do
      [
        {
          jsonrpc: '2.0',
          method: 'textDocument/didOpen',
          params: {
            textDocument: {
              languageId: 'ruby',
              text: empty_comment,
              uri: 'file:///path/to/file.rb',
              version: 0
            }
          }
        }, {
          jsonrpc: '2.0',
          method: 'textDocument/didChange',
          params: {
            contentChanges: [{ text: empty_comment }],
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

    it 'handles requests, but does not autocorrect with `Layout/EmptyComment` as an `AutoCorrect: contextual` cop' do
      expect(stderr).to eq('')
      format_result = messages.last
      expect(format_result).to eq(jsonrpc: '2.0', id: 20, result: [])
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
        result: [{
          newText: "puts 'bye'\n",
          range: {
            start: { line: 0, character: 0 }, end: { line: 1, character: 0 }
          }
        }]
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
        result: [{
          newText: "# frozen_string_literal: true\n\nputs 'bye'\n",
          range: {
            start: { line: 0, character: 0 }, end: { line: 1, character: 0 }
          }
        }]
      )
    end
  end

  describe 'format without `lintMode` option' do
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
                puts foo.object_id == bar.object_id
                  puts 'hi'
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
                  puts foo.object_id == bar.object_id
                    puts "hi"
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
        result: [{
          newText: <<~RUBY,
            puts foo.equal?(bar)
            puts 'hi'
          RUBY
          range: {
            start: { line: 0, character: 0 }, end: { line: 3, character: 0 }
          }
        }]
      )
    end
  end

  describe 'format with `lintMode: true`' do
    let(:requests) do
      [
        {
          jsonrpc: '2.0',
          id: 2,
          method: 'initialize',
          params: {
            probably: "Don't need real params for this test?",
            initializationOptions: {
              lintMode: true
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
                puts foo.object_id == bar.object_id
                  puts 'hi'
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
                  puts foo.object_id == bar.object_id
                    puts "hi"
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
        result: [{
          newText: <<~RUBY,
            puts foo.equal?(bar)
              puts "hi"
          RUBY
          range: {
            start: { line: 0, character: 0 }, end: { line: 3, character: 0 }
          }
        }]
      )
    end
  end

  describe 'format with `lintMode: false`' do
    let(:requests) do
      [
        {
          jsonrpc: '2.0',
          id: 2,
          method: 'initialize',
          params: {
            probably: "Don't need real params for this test?",
            initializationOptions: {
              lintMode: false
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
                puts foo.object_id == bar.object_id
                  puts 'hi'
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
                  puts foo.object_id == bar.object_id
                    puts "hi"
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
        result: [{
          newText: <<~RUBY,
            puts foo.equal?(bar)
            puts 'hi'
          RUBY
          range: {
            start: { line: 0, character: 0 }, end: { line: 3, character: 0 }
          }
        }]
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
        result: [{
          newText: <<~RUBY,
            puts 'hi'
            puts 'bye'
          RUBY
          range: {
            start: { line: 0, character: 0 }, end: { line: 3, character: 0 }
          }
        }]
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
        result: [{
          newText: <<~RUBY,
            puts "hi"
            puts 'bye'
          RUBY
          range: {
            start: { line: 0, character: 0 }, end: { line: 3, character: 0 }
          }
        }]
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
        result: [{
          newText: <<~RUBY,
            puts 'hi'
            puts 'bye'
          RUBY
          range: {
            start: { line: 0, character: 0 }, end: { line: 3, character: 0 }
          }
        }]
      )
    end
  end

  describe 'format with `lintMode: true` and `layoutMode: true`' do
    let(:requests) do
      [
        {
          jsonrpc: '2.0',
          id: 2,
          method: 'initialize',
          params: {
            probably: "Don't need real params for this test?",
            initializationOptions: {
              lintMode: true,
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
                puts foo.object_id == bar.object_id
                  puts 'hi'
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
                  puts foo.object_id == bar.object_id
                    puts "hi"
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
        result: [{
          newText: <<~RUBY,
            puts foo.equal?(bar)
            puts "hi"
          RUBY
          range: {
            start: { line: 0, character: 0 }, end: { line: 3, character: 0 }
          }
        }]
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
        { jsonrpc: '2.0', id: 1, method: 'initialized', params: {} }
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
      [{
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
      }]
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
        { jsonrpc: '2.0', id: 1, result: {} }
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
        { jsonrpc: '2.0', result: {} }
      ]
    end

    it 'handles requests' do
      expect(stderr).to eq('')
      expect(messages).to be_empty
    end
  end

  describe 'execute command safe formatting' do
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
            arguments: [{ uri: 'file:///path/to/file.rb' }]
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
              'file:///path/to/file.rb': [{
                newText: "puts 'hi'\n",
                range: {
                  start: { line: 0, character: 0 }, end: { line: 1, character: 0 }
                }
              }]
            }
          }
        }
      )
    end
  end

  describe 'execute command safe formatting with `Lint/UnusedBlockArgument` cop (`AutoCorrect: contextual`)' do
    let(:requests) do
      [
        {
          jsonrpc: '2.0',
          method: 'textDocument/didOpen',
          params: {
            textDocument: {
              languageId: 'ruby',
              text: 'foo { |unused_variable| 42 }',
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
            arguments: [{ uri: 'file:///path/to/file.rb' }]
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
              'file:///path/to/file.rb': [{
                newText: "foo { |_unused_variable| 42 }\n",
                range: {
                  start: { line: 0, character: 0 }, end: { line: 1, character: 0 }
                }
              }]
            }
          }
        }
      )
    end
  end

  describe 'execute command unsafe formatting' do
    let(:requests) do
      [
        {
          jsonrpc: '2.0',
          method: 'textDocument/didOpen',
          params: {
            textDocument: {
              languageId: 'ruby',
              text: 'something.map { |s| s.upcase }',
              uri: 'file:///path/to/file.rb',
              version: 0
            }
          }
        }, {
          jsonrpc: '2.0',
          id: 99,
          method: 'workspace/executeCommand',
          params: {
            command: 'rubocop.formatAutocorrectsAll',
            arguments: [{ uri: 'file:///path/to/file.rb' }]
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
          label: 'Format all with RuboCop autocorrects',
          edit: {
            changes: {
              'file:///path/to/file.rb': [{
                newText: <<~RUBY,
                  # frozen_string_literal: true

                  something.map(&:upcase)
                RUBY
                range: {
                  start: { line: 0, character: 0 }, end: { line: 1, character: 0 }
                }
              }]
            }
          }
        }
      )
    end
  end

  describe 'execute command with unsupported command' do
    let(:requests) do
      [{
        jsonrpc: '2.0',
        id: 99,
        method: 'workspace/executeCommand',
        params: {
          command: 'rubocop.somethingElse',
          arguments: [{ uri: 'file:///path/to/file.rb' }]
        }
      }]
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
      [{
        jsonrpc: '2.0',
        method: 'textDocument/didOpen',
        params: {
          textDocument: {
            languageId: 'ruby',
            text: "puts 'neat'",
            # Depends on this project's .rubocop.yml ignoring `tmp/**/*`
            uri: "file://#{Dir.pwd}/tmp/foo/bar.rb",
            version: 0
          }
        }
      }]
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
    end
  end

  describe 'formatting via multiple entries of `contentChanges`' do
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
            contentChanges: [{ text: "puts 'first'" }, { text: "puts 'last'" }],
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
      expect(messages.count).to eq(3)
      expect(messages.last).to eq(
        jsonrpc: '2.0', id: 20, result: [
          {
            newText: "puts 'last'\n",
            range: {
              end: { character: 0, line: 1 }, start: { character: 0, line: 0 }
            }
          }
        ]
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
              # Depends on this project's .rubocop.yml ignoring `tmp/**/*`
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
    end
  end

  describe 'did change with multibyte character' do
    let(:requests) do
      [
        {
          jsonrpc: '2.0',
          method: 'textDocument/didOpen',
          params: {
            textDocument: {
              languageId: 'ruby',
              text: "puts '🍣🍺'",
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
                text: '💎',
                range: {
                  start: { line: 0, character: 6 },
                  end: { line: 0, character: 10 }
                }
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
      expect(messages.count).to eq(3)
      expect(messages.last).to eq(
        jsonrpc: '2.0', id: 20, result: [
          {
            newText: "puts '💎'\n",
            range: {
              end: { character: 0, line: 1 }, start: { character: 0, line: 0 }
            }
          }
        ]
      )
    end
  end

  context 'when an internal error occurs' do
    before do
      allow_any_instance_of(RuboCop::LSP::Routes).to receive(:for).with('initialize').and_raise # rubocop:disable RSpec/AnyInstance
    end

    let(:requests) do
      [{
        jsonrpc: '2.0',
        id: 2,
        method: 'initialize',
        params: { probably: "Don't need real params for this test?" }
      }]
    end

    it 'logs an internal server error message' do
      expect(stderr).to start_with('[server] Error RuntimeError')
      expect(messages.count).to eq(0)
    end
  end

  describe 'when URI includes spaces' do
    let(:requests) do
      [
        {
          jsonrpc: '2.0',
          method: 'textDocument/didOpen',
          params: {
            textDocument: {
              languageId: 'ruby',
              text: "puts 'hi'",
              uri: 'file:///path/with%20spaces/file.rb',
              version: 0
            }
          }
        }
      ]
    end

    it 'decodes URI-encoded paths for file system operations' do
      # rubocop:disable RSpec/AnyInstance
      expect_any_instance_of(RuboCop::Runner).to receive(:run).with(
        ['/path/with spaces/file.rb']
      ).and_call_original
      # rubocop:enable RSpec/AnyInstance

      result
    end
  end
end
