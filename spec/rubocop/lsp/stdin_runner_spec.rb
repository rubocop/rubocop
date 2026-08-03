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
end
