# frozen_string_literal: true

RSpec.describe 'RuboCop::CLI --report-unused-todo-entries', :isolated_environment do # rubocop:disable RSpec/DescribeClass
  subject(:cli) { RuboCop::CLI.new }

  include_context 'cli spec behavior'

  before do
    create_file('.rubocop.yml', <<~YAML)
      inherit_from: .rubocop_todo.yml
    YAML
    create_file('clean.rb', <<~RUBY)
      # frozen_string_literal: true

      x = 1
      puts x
    RUBY
    create_file('offending.rb', <<~RUBY)
      # frozen_string_literal: true

      @@bad = 1
      puts @@bad
    RUBY
  end

  context 'when the todo file has stale and live entries' do
    before do
      create_file('.rubocop_todo.yml', <<~YAML)
        Style/ClassVars:
          Exclude:
            - 'clean.rb'
            - 'offending.rb'
            - 'deleted.rb'
        Lint/UselessAssignment:
          Exclude:
            - 'offending.rb'
      YAML
    end

    it 'reports only the stale entries and fails' do
      expect(cli.run(['--report-unused-todo-entries', '.'])).to eq(1)
      expect($stderr.string).to include('3 unused todo entries found in `.rubocop_todo.yml`:')
      expect($stderr.string).to include('Style/ClassVars: clean.rb')
      expect($stderr.string).to include('Style/ClassVars: deleted.rb')
      expect($stderr.string).to include('Lint/UselessAssignment: offending.rb')
      expect($stderr.string).not_to include('Style/ClassVars: offending.rb')
    end
  end

  context 'when every todo entry is still needed' do
    before do
      create_file('.rubocop_todo.yml', <<~YAML)
        Style/ClassVars:
          Exclude:
            - 'offending.rb'
      YAML
    end

    it 'reports nothing and passes' do
      expect(cli.run(['--report-unused-todo-entries', '.'])).to eq(0)
      expect($stderr.string).not_to include('unused todo')
    end
  end

  context 'when the todo file lists a cop that is not loaded' do
    before do
      create_file('.rubocop_todo.yml', <<~YAML)
        Unloaded/ExtensionCop:
          Exclude:
            - 'clean.rb'
        Style/ClassVars:
          Exclude:
            - 'offending.rb'
      YAML
    end

    it 'does not judge entries of the unknown cop' do
      expect(cli.run(['--report-unused-todo-entries', '--ignore-unrecognized-cops', '.'])).to eq(0)
      expect($stderr.string).not_to include('unused todo')
    end
  end

  context 'when there is no todo file' do
    before { create_empty_file('.rubocop.yml') }

    it 'notes there is nothing to audit' do
      expect(cli.run(['--report-unused-todo-entries', 'clean.rb'])).to eq(0)
      expect($stderr.string).to include('No `.rubocop_todo.yml` found; nothing to audit.')
    end
  end
end
