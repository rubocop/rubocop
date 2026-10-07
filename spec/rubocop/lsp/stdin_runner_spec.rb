# frozen_string_literal: true

RSpec.describe RuboCop::Lsp::StdinRunner do
  # Exercise the caching logic in isolation, without the heavy runner setup
  # that a full `new` would trigger.
  let(:runner) { described_class.allocate }

  describe 'project index caching' do
    before do
      allow(runner).to receive_messages(project_index_enabled?: true, project_index_files: [])
    end

    it 'builds the project index once and reuses it across runs' do
      expect(RuboCop::ProjectIndexLoader).to receive(:build_index).once.and_return(:index)

      3.times { runner.send(:build_project_index, ['a.rb']) }
    end

    it 'rebuilds the project index after it is reset' do
      expect(RuboCop::ProjectIndexLoader).to receive(:build_index).twice.and_return(:index)

      runner.send(:build_project_index, ['a.rb'])
      runner.reset_project_index
      runner.send(:build_project_index, ['a.rb'])
    end
  end

  describe '#run', :isolated_environment do
    include_context 'mock console output'

    let(:runner) { described_class.new(RuboCop::ConfigStore.new) }

    # Inline code skips the newline conversion `File.write` does on Windows, so
    # it needs native line endings to satisfy `Layout/EndOfLine`.
    let(:newline) { RuboCop::Platform.windows? ? "\r\n" : "\n" }

    # Removing the directive is followed by another inspection of the
    # corrected source, which the runner is handed explicitly.
    it 'removes a disable directive that no longer suppresses anything' do
      source = <<~RUBY.gsub("\n", newline)
        # frozen_string_literal: true

        x = 1 # rubocop:disable Style/Documentation
        puts x
      RUBY

      runner.run('example.rb', source, { autocorrect: true, safe_autocorrect: true })

      expect(runner.formatted_source.lines(chomp: true))
        .to eq(['# frozen_string_literal: true', '', 'x = 1', 'puts x'])
    end
  end
end
