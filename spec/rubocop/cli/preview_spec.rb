# frozen_string_literal: true

RSpec.describe 'RuboCop::CLI --preview', :isolated_environment do # rubocop:disable RSpec/DescribeClass
  subject(:cli) { RuboCop::CLI.new }

  include_context 'cli spec behavior'

  before do
    create_file('example.rb', <<~RUBY)
      # frozen_string_literal: true

      for x in [1, 2] do puts x end
    RUBY
  end

  context 'when a cop is `Enabled: preview`' do
    before do
      create_file('.rubocop.yml', <<~YAML)
        Style/For:
          Enabled: preview
      YAML
    end

    it 'leaves the cop out by default' do
      expect(cli.run(['--format', 'simple', 'example.rb'])).to eq(0)
      expect($stdout.string).not_to include('Style/For')
    end

    it 'runs the cop with --preview' do
      expect(cli.run(['--preview', '--format', 'simple', 'example.rb'])).to eq(1)
      expect($stdout.string).to include('Style/For')
    end

    it 'runs the cop when the config opts in' do
      create_file('.rubocop.yml', <<~YAML)
        AllCops:
          Preview: true
        Style/For:
          Enabled: preview
      YAML

      expect(cli.run(['--format', 'simple', 'example.rb'])).to eq(1)
      expect($stdout.string).to include('Style/For')
    end

    it 'lets --no-preview override the config' do
      create_file('.rubocop.yml', <<~YAML)
        AllCops:
          Preview: true
        Style/For:
          Enabled: preview
      YAML

      expect(cli.run(['--no-preview', '--format', 'simple', 'example.rb'])).to eq(0)
      expect($stdout.string).not_to include('Style/For')
    end

    it 'runs the cop when it is requested explicitly with --only' do
      expect(cli.run(['--only', 'Style/For', '--format', 'simple', 'example.rb'])).to eq(1)
      expect($stdout.string).to include('Style/For')
    end

    it 'is not turned on by `NewCops: enable`' do
      create_file('.rubocop.yml', <<~YAML)
        AllCops:
          NewCops: enable
        Style/For:
          Enabled: preview
      YAML

      expect(cli.run(['--format', 'simple', 'example.rb'])).to eq(0)
      expect($stdout.string).not_to include('Style/For')
    end

    it 'is left alone by --enable-all-cops, which only rewrites the defaults' do
      expect(cli.run(['--enable-all-cops', '--format', 'simple', 'example.rb'])).to eq(1)
      expect($stdout.string).not_to include('Style/For')
    end

    it 'does not nag about it the way pending cops do' do
      cli.run(['--format', 'simple', 'example.rb'])

      expect($stdout.string).not_to include('not configured')
      expect($stderr.string).not_to include('not configured')
    end
  end

  context 'when user configuration sets `AllCops: Exclude`' do
    before do
      create_file('vendor/bundle/gem.rb', 'x   =  1')
      create_file('.rubocop.yml', <<~YAML)
        AllCops:
          Exclude:
            - 'nothing/**/*'
      YAML
    end

    it 'replaces the default excludes without preview' do
      expect(cli.run(['--only', 'Layout/SpaceAroundOperators', '--format', 'simple', '.'])).to eq(1)
      expect($stdout.string).to include('vendor/bundle/gem.rb')
    end

    it 'merges with the default excludes with --preview' do
      expect(
        cli.run(['--preview', '--only', 'Layout/SpaceAroundOperators', '--format', 'simple', '.'])
      ).to eq(0)
      expect($stdout.string).not_to include('vendor/bundle/gem.rb')
    end

    it 'merges with the default excludes when the config opts in' do
      create_file('.rubocop.yml', <<~YAML)
        AllCops:
          Preview: true
          Exclude:
            - 'nothing/**/*'
      YAML

      expect(cli.run(['--only', 'Layout/SpaceAroundOperators', '--format', 'simple', '.'])).to eq(0)
      expect($stdout.string).not_to include('vendor/bundle/gem.rb')
    end

    it 'merges a cop `Exclude` inherited from another file' do
      create_file('legacy.rb', 'z   =  3')
      create_file('shared.yml', <<~YAML)
        Layout/SpaceAroundOperators:
          Exclude:
            - 'legacy.rb'
      YAML
      create_file('.rubocop.yml', <<~YAML)
        inherit_from: shared.yml

        AllCops:
          Preview: true

        Layout/SpaceAroundOperators:
          Exclude:
            - 'nothing.rb'
      YAML

      expect(cli.run(['--only', 'Layout/SpaceAroundOperators', '--format', 'simple', '.'])).to eq(0)
      expect($stdout.string).not_to include('legacy.rb')
    end

    it 'lets an explicit `inherit_mode` override win over preview' do
      create_file('.rubocop.yml', <<~YAML)
        inherit_mode:
          override:
            - Exclude

        AllCops:
          Preview: true
          Exclude:
            - 'nothing/**/*'
      YAML

      expect(cli.run(['--only', 'Layout/SpaceAroundOperators', '--format', 'simple', '.'])).to eq(1)
      expect($stdout.string).to include('vendor/bundle/gem.rb')
    end

    it 'lets --no-preview override the config' do
      create_file('.rubocop.yml', <<~YAML)
        AllCops:
          Preview: true
          Exclude:
            - 'nothing/**/*'
      YAML

      args = ['--no-preview', '--only', 'Layout/SpaceAroundOperators', '--format', 'simple', '.']

      expect(cli.run(args)).to eq(1)
      expect($stdout.string).to include('vendor/bundle/gem.rb')
    end
  end

  it 'rejects an unknown `Enabled` value' do
    create_file('.rubocop.yml', <<~YAML)
      Style/For:
        Enabled: previewing
    YAML

    expect(cli.run(['--format', 'simple', 'example.rb'])).to eq(2)
    expect($stderr.string).to include('is supposed to be a boolean')
  end
end
