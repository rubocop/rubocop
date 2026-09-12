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

  context 'when todo entries contain glob patterns' do
    before do
      create_file('spec/nested/offending_spec.rb', <<~RUBY)
        # frozen_string_literal: true

        @@bad = 1
        puts @@bad
      RUBY
      create_file('.rubocop_todo.yml', <<~YAML)
        Style/ClassVars:
          Exclude:
            - 'offending.rb'
            - '#{pattern}'
      YAML
    end

    [
      '**/*_spec.rb',
      'spec/**/*.rb',
      'spec/nested/{clean,offending}_spec.rb',
      'spec/nested/offending_spec.?b',
      'spec/nested/[co]*_spec.rb'
    ].each do |glob|
      context "with #{glob.inspect}" do
        let(:pattern) { glob }

        it 'keeps an entry when a matching file still offends' do
          expect(cli.run(['--report-unused-todo-entries', '.'])).to eq(0)

          expect($stderr.string).not_to include('unused todo')
        end
      end
    end
  end

  context 'when glob patterns are stale for only some cops' do
    before do
      create_file('.rubocop_todo.yml', <<~YAML)
        Style/ClassVars:
          Exclude:
            - '*.rb'
            - 'missing/**/*.rb'
            - 'clean*.rb'
        Lint/UselessAssignment:
          Exclude:
            - '*.rb'
      YAML
    end

    it 'reports patterns only when no matching file needs that cop excluded' do
      expect(cli.run(['--report-unused-todo-entries', '.'])).to eq(1)
      expect($stderr.string).to include('3 unused todo entries found in `.rubocop_todo.yml`:')
      expect($stderr.string).to include('Style/ClassVars: missing/**/*.rb')
      expect($stderr.string).to include('Style/ClassVars: clean*.rb')
      expect($stderr.string).to include('Lint/UselessAssignment: *.rb')
      expect($stderr.string).not_to include('Style/ClassVars: *.rb')
    end
  end

  context 'when a literal filename contains glob characters' do
    before do
      create_file('offending[1].rb', "# frozen_string_literal: true\n\n@@bad = 1\nputs @@bad\n")
      create_file('.rubocop_todo.yml', <<~YAML)
        Style/ClassVars:
          Exclude:
            - 'offending.rb'
            - 'offending[1].rb'
      YAML
    end

    it 'also audits files matched by the pattern when the literal file is clean' do
      create_file('offending[1].rb', File.read('clean.rb'))
      create_file('offending1.rb', File.read('offending.rb'))

      expect(cli.run(['--report-unused-todo-entries', '--only', 'Style/ClassVars', '.'])).to eq(0)
      expect($stderr.string).not_to include('unused todo')
    end

    it 'still audits the literal file' do
      expect(cli.run(['--report-unused-todo-entries', '--only', 'Style/ClassVars', '.'])).to eq(0)

      expect($stderr.string).not_to include('unused todo')
    end
  end

  context 'when matching files are below a symlink directory' do
    before do
      create_file('external/offending.rb', File.read('offending.rb'))
      create_link('spec/link', '../external')
      create_file('.rubocop_todo.yml', <<~YAML)
        Style/ClassVars:
          Exclude:
            - 'offending.rb'
            - 'spec/**/*.rb'
            - 'external/**/*.rb'
      YAML
    end

    it 'keeps the pattern that excludes the symlinked source' do
      expect(cli.run(['--report-unused-todo-entries', '--only', 'Style/ClassVars', '.'])).to eq(0)
      expect($stderr.string).not_to include('unused todo')
    end
  end

  context 'when patterns refer to files outside the todo directory' do
    before do
      create_file('project/.rubocop.yml', "inherit_from: .rubocop_todo.yml\n")
      create_file('external/offending.rb', File.read('offending.rb'))
      create_file('project/.rubocop_todo.yml', <<~YAML)
        Style/ClassVars:
          Exclude:
            - '#{pattern}'
      YAML
    end

    shared_examples 'an external pattern' do
      it 'keeps the pattern when an external source still offends' do
        Dir.chdir('project') do
          expect(cli.run(['--report-unused-todo-entries', '--only', 'Style/ClassVars',
                          '--config', '.rubocop.yml', '../external'])).to eq(0)
          expect($stderr.string).not_to include('unused todo')
        end
      end
    end

    context 'with a relative path' do
      let(:pattern) { '../external/**/*.rb' }

      it_behaves_like 'an external pattern'
    end

    context 'with an absolute path' do
      let(:pattern) { File.join(Dir.pwd, 'external/**/*.rb') }

      it_behaves_like 'an external pattern'
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
