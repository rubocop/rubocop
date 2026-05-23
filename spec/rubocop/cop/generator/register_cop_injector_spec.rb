# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Generator::RegisterCopInjector do
  let(:stdout) { StringIO.new }
  let(:source_path) { 'lib/rubocop/cop/test/foo_cop.rb' }
  let(:root_dir) { 'lib' }
  let(:badge) { RuboCop::Cop::Badge.for('RuboCop::Cop::Test::FooCop') }
  let(:department_module_path) { 'lib/rubocop/cop/test.rb' }
  let(:injector) do
    described_class.new(source_path: source_path, root_dir: root_dir, badge: badge, output: stdout)
  end

  around do |example|
    Dir.mktmpdir('rubocop-register_cop_injector_spec-') do |dir|
      Dir.chdir(dir) do
        FileUtils.mkdir_p('lib/rubocop/cop')
        example.run
      end
    end
  end

  context 'when a `register_cop` entry does not exist from before' do
    before do
      File.write(department_module_path, <<~RUBY)
        # frozen_string_literal: true

        module RuboCop
          module Cop
            module Test
              extend CopLazyLoader

              register_cop :BarCop, 'rubocop/cop/test/bar_cop'
              register_cop :QuuxCop, 'rubocop/cop/test/quux_cop'
            end
          end
        end
      RUBY
    end

    it 'injects a `register_cop` directive in alphabetical order' do
      generated_source = <<~RUBY
        # frozen_string_literal: true

        module RuboCop
          module Cop
            module Test
              extend CopLazyLoader

              register_cop :BarCop, 'rubocop/cop/test/bar_cop'
              register_cop :FooCop, 'rubocop/cop/test/foo_cop'
              register_cop :QuuxCop, 'rubocop/cop/test/quux_cop'
            end
          end
        end
      RUBY

      injector.inject

      expect(File.read(department_module_path)).to eq generated_source
      expect(stdout.string).to eq(<<~MESSAGE)
        [modify] lib/rubocop/cop/test.rb - `register_cop :FooCop, 'rubocop/cop/test/foo_cop'` was injected.
      MESSAGE
    end
  end

  context 'when the new cop is last alphabetically in the department' do
    let(:source_path) { 'lib/rubocop/cop/test/quux_cop.rb' }
    let(:badge) { RuboCop::Cop::Badge.for('RuboCop::Cop::Test::QuuxCop') }

    before do
      File.write(department_module_path, <<~RUBY)
        # frozen_string_literal: true

        module RuboCop
          module Cop
            module Test
              extend CopLazyLoader

              register_cop :FooCop, 'rubocop/cop/test/foo_cop'
              register_cop :BarCop, 'rubocop/cop/test/bar_cop'
            end
          end
        end
      RUBY
    end

    it 'injects a `register_cop` directive after the last existing entry' do
      generated_source = <<~RUBY
        # frozen_string_literal: true

        module RuboCop
          module Cop
            module Test
              extend CopLazyLoader

              register_cop :FooCop, 'rubocop/cop/test/foo_cop'
              register_cop :BarCop, 'rubocop/cop/test/bar_cop'
              register_cop :QuuxCop, 'rubocop/cop/test/quux_cop'
            end
          end
        end
      RUBY

      injector.inject

      expect(File.read(department_module_path)).to eq generated_source
      expect(stdout.string).to eq(<<~MESSAGE)
        [modify] lib/rubocop/cop/test.rb - `register_cop :QuuxCop, 'rubocop/cop/test/quux_cop'` was injected.
      MESSAGE
    end
  end

  context 'when the department module has no `register_cop` entries yet' do
    before do
      File.write(department_module_path, <<~RUBY)
        # frozen_string_literal: true

        module RuboCop
          module Cop
            module Test
              extend CopLazyLoader
            end
          end
        end
      RUBY
    end

    it 'injects a `register_cop` directive before the first closing `end`' do
      generated_source = <<~RUBY
        # frozen_string_literal: true

        module RuboCop
          module Cop
            module Test
              extend CopLazyLoader
              register_cop :FooCop, 'rubocop/cop/test/foo_cop'
            end
          end
        end
      RUBY

      injector.inject

      expect(File.read(department_module_path)).to eq generated_source
      expect(stdout.string).to eq(<<~MESSAGE)
        [modify] lib/rubocop/cop/test.rb - `register_cop :FooCop, 'rubocop/cop/test/foo_cop'` was injected.
      MESSAGE
    end
  end

  context 'when a `register_cop` entry already exists' do
    let(:source) { <<~RUBY }
      # frozen_string_literal: true

      module RuboCop
        module Cop
          module Test
            extend CopLazyLoader

            register_cop :EvenOdd, 'rubocop/cop/test/even_odd'
            register_cop :FooCop, 'rubocop/cop/test/foo_cop'
            register_cop :FunName, 'rubocop/cop/test/fun_name'
          end
        end
      end
    RUBY

    before { File.write(department_module_path, source) }

    it 'does not write to any file' do
      injector.inject

      expect(File.read(department_module_path)).to eq(source)
      expect(stdout.string).to be_empty
    end
  end

  context 'when the department module does not exist yet' do
    it 'creates the department module with a `register_cop` directive' do
      expect(File).not_to exist(department_module_path)

      generated_source = <<~RUBY
        # frozen_string_literal: true

        module RuboCop
          module Cop
            module Test
              extend CopLazyLoader

              register_cop :FooCop, 'rubocop/cop/test/foo_cop'
            end
          end
        end
      RUBY

      injector.inject

      expect(File.read(department_module_path)).to eq generated_source
      expect(stdout.string).to eq(<<~MESSAGE)
        [create] lib/rubocop/cop/test.rb
      MESSAGE
    end
  end

  context 'when the nested department module does not exist yet' do
    let(:source_path) { 'lib/rubocop/cop/test/nested/foo_cop.rb' }
    let(:badge) { RuboCop::Cop::Badge.for('RuboCop::Cop::Test::Nested::FooCop') }
    let(:department_module_path) { 'lib/rubocop/cop/test/nested.rb' }

    before do
      FileUtils.mkdir_p('lib/rubocop/cop/test')
    end

    it 'creates the department module with a `register_cop` directive' do
      expect(File).not_to exist(department_module_path)

      generated_source = <<~RUBY
        # frozen_string_literal: true

        module RuboCop
          module Cop
            module Test::Nested
              extend CopLazyLoader

              register_cop :FooCop, 'rubocop/cop/test/nested/foo_cop'
            end
          end
        end
      RUBY

      injector.inject

      expect(File.read(department_module_path)).to eq generated_source
      expect(stdout.string).to eq(<<~MESSAGE)
        [create] lib/rubocop/cop/test/nested.rb
      MESSAGE
    end
  end
end
