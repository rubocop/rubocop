# frozen_string_literal: true

require 'rubocop/lsp/runtime'

RSpec.describe RuboCop::LSP::Runtime, :isolated_environment, :lsp do
  include FailingCopHelper

  subject(:runtime) { described_class.new(RuboCop::ConfigStore.new) }

  # The runtime runs RuboCop against the process's own streams, and a cop that
  # fails reports itself on stderr.
  include_context 'mock console output'

  # Inline code skips the newline conversion `File.write` does on Windows, so
  # it needs native line endings to satisfy `Layout/EndOfLine`.
  let(:newline) { RuboCop::Platform.windows? ? "\r\n" : "\n" }
  let(:source) { "# frozen_string_literal: true\n\nputs ?a, \"b\"\n".gsub("\n", newline) }

  context 'when a cop crashes' do
    before { make_cop_fail(RuboCop::Cop::Style::CharacterLiteral, :on_str, NoMethodError, 'boom') }

    it 'raises the error by default' do
      expect { runtime.raw_offenses('example.rb', source) }
        .to raise_error(RuboCop::ErrorWithAnalyzedFileLocation)
    end

    context 'when cop errors are collected' do
      before { runtime.raise_cop_error = false }

      it 'still reports the cops that did not crash' do
        offenses = runtime.raw_offenses('example.rb', source)

        expect(offenses.map(&:cop_name)).to eq(['Style/StringLiterals'])
        expect(runtime.errors).to all(include('Style/CharacterLiteral'))
      end

      it 'still applies the corrections of the cops that did not crash' do
        corrected = runtime.format('example.rb', source, command: 'rubocop.formatAutocorrects')

        # Line by line, since on Windows the corrected source comes back with
        # plain newlines whatever the input used.
        expect(corrected.lines(chomp: true))
          .to eq(['# frozen_string_literal: true', '', "puts ?a, 'b'"])
        expect(runtime.errors).not_to be_empty
      end
    end
  end

  describe '#uncorrected_offenses' do
    let(:source) { "puts \"a\"\nx = 1\n".gsub("\n", newline) }

    # On Windows the corrected source comes back with LF line endings, which
    # `Layout/EndOfLine` would report.
    it 'lists what the last format left, located in the source it returned' do
      corrected = runtime.format('example.rb', source, command: 'rubocop.formatAutocorrectsAll',
                                                       cops: { except: ['Layout/EndOfLine'] })

      expect(corrected.lines(chomp: true))
        .to eq(['# frozen_string_literal: true', '', "puts 'a'", 'x = 1'])
      expect(runtime.uncorrected_offenses.map { |offense| [offense.cop_name, offense.line] })
        .to eq([['Lint/UselessAssignment', 4]])
    end
  end

  # The runner caches the cops it mobilizes, and the same runtime serves call
  # after call, so a selection must not stick past the call that made it.
  it 'runs the cops each call selects' do
    cop_names = ->(**cops) { runtime.raw_offenses('example.rb', source, **cops).map(&:cop_name) }

    expect(cop_names.call(cops: { only: ['Style/StringLiterals'] })).to eq(['Style/StringLiterals'])
    expect(cop_names.call).to contain_exactly('Style/CharacterLiteral', 'Style/StringLiterals')
    expect(cop_names.call(cops: { except: ['Style/StringLiterals'] }))
      .to eq(['Style/CharacterLiteral'])
  end
end
