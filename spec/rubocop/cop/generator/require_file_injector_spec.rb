# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Generator::RequireFileInjector do
  let(:stdout) { StringIO.new }
  let(:root_file_path) { 'lib/root.rb' }
  let(:injector) do
    described_class.new(
      source_path: source_path,
      root_file_path: root_file_path,
      output: stdout
    )
  end

  around do |example|
    Dir.mktmpdir('rubocop-require_file_injector_spec-') do |dir|
      Dir.chdir(dir) do
        Dir.mkdir('lib')
        example.run
      end
    end
  end

  context 'when a `require_relative` entry does not exist from before' do
    let(:source_path) { 'lib/rubocop/cop/style/fake_cop.rb' }

    before do
      File.write(root_file_path, <<-RUBY.strip_indent)
        # frozen_string_literal: true

        require 'parser'
        require 'rainbow'

        require 'English'
        require 'set'
        require 'forwardable'

        require_relative 'rubocop/version'

        require_relative 'rubocop/cop/style/end_block'
        require_relative 'rubocop/cop/style/even_odd'
        require_relative 'rubocop/cop/style/file_name'
        require_relative 'rubocop/cop/style/flip_flop'

        require_relative 'rubocop/cop/rails/action_filter'

        require_relative 'rubocop/cop/team'
      RUBY
    end

    it 'injects a `require_relative` statement ' \
       'on the right line in the root file' do
      generated_source = <<-RUBY.strip_indent
        # frozen_string_literal: true

        require 'parser'
        require 'rainbow'

        require 'English'
        require 'set'
        require 'forwardable'

        require_relative 'rubocop/version'

        require_relative 'rubocop/cop/style/end_block'
        require_relative 'rubocop/cop/style/even_odd'
        require_relative 'rubocop/cop/style/fake_cop'
        require_relative 'rubocop/cop/style/file_name'
        require_relative 'rubocop/cop/style/flip_flop'

        require_relative 'rubocop/cop/rails/action_filter'

        require_relative 'rubocop/cop/team'
      RUBY

      injector.inject

      expect(File.read(root_file_path)).to eq generated_source
      expect(stdout.string).to eq(<<-MESSAGE.strip_indent)
        [modify] lib/root.rb - `require_relative 'rubocop/cop/style/fake_cop'` was injected.
      MESSAGE
    end
  end

  context 'when a cop of style department already exists' do
    let(:source_path) { 'lib/rubocop/cop/style/the_end_of_style.rb' }

    before do
      File.write(root_file_path, <<-RUBY.strip_indent)
        # frozen_string_literal: true

        require 'parser'
        require 'rainbow'

        require 'English'
        require 'set'
        require 'forwardable'

        require_relative 'rubocop/version'

        require_relative 'rubocop/cop/style/end_block'
        require_relative 'rubocop/cop/style/even_odd'
        require_relative 'rubocop/cop/style/file_name'
        require_relative 'rubocop/cop/style/flip_flop'

        require_relative 'rubocop/cop/rails/action_filter'

        require_relative 'rubocop/cop/team'
      RUBY
    end

    it 'injects a `require_relative` statement ' \
       'on the end of style department' do
      generated_source = <<-RUBY.strip_indent
        # frozen_string_literal: true

        require 'parser'
        require 'rainbow'

        require 'English'
        require 'set'
        require 'forwardable'

        require_relative 'rubocop/version'

        require_relative 'rubocop/cop/style/end_block'
        require_relative 'rubocop/cop/style/even_odd'
        require_relative 'rubocop/cop/style/file_name'
        require_relative 'rubocop/cop/style/flip_flop'
        require_relative 'rubocop/cop/style/the_end_of_style'

        require_relative 'rubocop/cop/rails/action_filter'

        require_relative 'rubocop/cop/team'
      RUBY

      injector.inject

      expect(File.read(root_file_path)).to eq generated_source
      expect(stdout.string).to eq(<<-MESSAGE.strip_indent)
        [modify] lib/root.rb - `require_relative 'rubocop/cop/style/the_end_of_style'` was injected.
      MESSAGE
    end
  end

  context 'when a `require` entry already exists' do
    let(:source_path) { 'lib/rubocop/cop/style/fake_cop.rb' }
    let(:source) { <<-RUBY.strip_indent }
      # frozen_string_literal: true

      require 'parser'
      require 'rainbow'

      require 'English'
      require 'set'
      require 'forwardable'

      require_relative 'rubocop/version'

      require_relative 'rubocop/cop/style/end_block'
      require_relative 'rubocop/cop/style/even_odd'
      require_relative 'rubocop/cop/style/fake_cop'
      require_relative 'rubocop/cop/style/file_name'
      require_relative 'rubocop/cop/style/flip_flop'

      require_relative 'rubocop/cop/rails/action_filter'

      require_relative 'rubocop/cop/team'
    RUBY

    before do
      File.write(root_file_path, source)
    end

    it 'does not write to any file' do
      injector.inject

      expect(File.read(root_file_path)).to eq source
      expect(stdout.string.empty?).to be(true)
    end
  end

  context 'when using an unknown department' do
    let(:source_path) { 'lib/rubocop/cop/unknown/fake_cop.rb' }

    let(:source) { <<-RUBY }
      # frozen_string_literal: true

      require 'parser'
      require 'rainbow'

      require 'English'
      require 'set'
      require 'forwardable'

      require_relative 'rubocop/version'

      require_relative 'rubocop/cop/style/end_block'
      require_relative 'rubocop/cop/style/even_odd'
      require_relative 'rubocop/cop/style/fake_cop'
      require_relative 'rubocop/cop/style/file_name'
      require_relative 'rubocop/cop/style/flip_flop'

      require_relative 'rubocop/cop/rails/action_filter'

      require_relative 'rubocop/cop/team'
    RUBY

    before do
      File.write(root_file_path, source)
    end

    it 'does not write to any file' do
      injector.inject

      expect(File.read(root_file_path)).to eq source
      expect(stdout.string.empty?).to be(true)
    end
  end
end
