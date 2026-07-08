# frozen_string_literal: true

RSpec.describe 'cop lazy loading' do # rubocop:disable RSpec/DescribeClass
  let(:repo_root) { File.expand_path('../..', __dir__) }

  let(:cop_file_pattern) do
    '%r{/rubocop/cop/(bundler|gemspec|layout|lint|metrics|migration|naming|security|style)/}'
  end

  def run_script(source)
    Dir.mktmpdir do |dir|
      script = File.join(dir, 'script.rb')
      File.write(script, source)
      output = `#{RbConfig.ruby} -I#{File.join(repo_root, 'lib')} #{script} 2>&1`
      raise "script failed:\n#{output}" unless $CHILD_STATUS.success?

      output
    end
  end

  it 'registers all cops without loading their files' do
    output = run_script(<<~RUBY)
      require 'rubocop'
      require 'yaml'

      registry = RuboCop::Cop::Registry.global
      loaded = $LOADED_FEATURES.grep(#{cop_file_pattern})
      configured_cops = YAML.unsafe_load_file('#{repo_root}/config/default.yml').keys - ['AllCops']

      puts "length=\#{registry.length}"
      puts "names=\#{registry.names.size}"
      puts "configured=\#{configured_cops.size}"
      puts "loaded_cop_files=\#{loaded.size}"
    RUBY

    values = output.scan(/^(\w+)=(\d+)$/).to_h
    expect(values['loaded_cop_files']).to eq('0')
    expect(values['length']).to eq(values['names'])
    expect(values['length']).to eq(values['configured'])
  end

  it 'does not register a cop twice when its file is required directly' do
    output = run_script(<<~RUBY)
      require 'rubocop'

      before = RuboCop::Cop::Registry.global.length
      require 'rubocop/cop/style/hash_syntax'
      after = RuboCop::Cop::Registry.global.length

      puts "before=\#{before}"
      puts "after=\#{after}"
      puts "class=\#{RuboCop::Cop::Registry.global.find_by_cop_name('Style/HashSyntax')}"
    RUBY

    values = output.scan(/^(\w+)=(.+)$/).to_h
    expect(values['after']).to eq(values['before'])
    expect(values['class']).to eq('RuboCop::Cop::Style::HashSyntax')
  end

  it 'loads only the cops needed when running a single cop' do
    output = run_script(<<~RUBY)
      require 'rubocop'
      require 'tmpdir'

      Dir.mktmpdir do |dir|
        file = File.join(dir, 'example.rb')
        File.write(file, "x = { :a => 1 }\\nputs x\\n")
        RuboCop::CLI.new.run(['--only', 'Style/HashSyntax', '--force-default-config',
                              '--cache', 'false', '--format', 'quiet', file])
      end

      loaded = $LOADED_FEATURES.grep(#{cop_file_pattern})
      puts "loaded_cop_files=\#{loaded.size}"
      puts "files=\#{loaded.map { |file| File.basename(file) }.sort.join(',')}"
    RUBY

    values = output.scan(/^(\w+)=(.*)$/).to_h
    expect(values['files']).to include('hash_syntax.rb')
    expect(values['loaded_cop_files'].to_i).to be < 10
  end

  it 'does not load cops disabled in the config on a default run' do
    output = run_script(<<~RUBY)
      require 'rubocop'
      require 'tmpdir'

      Dir.mktmpdir do |dir|
        file = File.join(dir, 'example.rb')
        File.write(file, <<~SRC)
          # frozen_string_literal: true

          # rubocop:disable Style/Alias
          alias foo bar
          # rubocop:enable Style/Alias
        SRC
        RuboCop::CLI.new.run(['--force-default-config', '--cache', 'false',
                              '--format', 'quiet', file])
      end

      loaded = $LOADED_FEATURES.grep(#{cop_file_pattern})
      puts "alias_loaded=\#{loaded.any? { |file| file.end_with?('style/alias.rb') }}"
      puts "copyright_loaded=\#{loaded.any? { |file| file.end_with?('style/copyright.rb') }}"
    RUBY

    values = output.scan(/^(\w+)=(.+)$/).to_h
    expect(values['alias_loaded']).to eq('true')
    expect(values['copyright_loaded']).to eq('false')
  end
end
