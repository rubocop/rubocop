# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Generator::RegistrationInjector do
  let(:stdout) { StringIO.new }
  let(:source_path) { 'lib/rubocop/cop/test/foo_cop.rb' }
  let(:badge) { RuboCop::Cop::Badge.for('RuboCop::Cop::Test::FooCop') }
  let(:department_file_path) { 'lib/rubocop/cop/test.rb' }
  let(:injector) do
    described_class.new(source_path: source_path, badge: badge, output: stdout)
  end

  around do |example|
    Dir.mktmpdir('rubocop-registration_injector_spec-') do |dir|
      Dir.chdir(dir) do
        FileUtils.mkdir_p('lib/rubocop/cop')
        example.run
      end
    end
  end

  context 'when the new directive belongs in the middle of the block' do
    before do
      File.write(department_file_path, <<~'RUBY')
        # frozen_string_literal: true

        module RuboCop
          module Cop
            # Cops for the `Test` department.
            module Test
              extend LazyLoader

              register_cop :BarCop, "#{__dir__}/test/bar_cop"
              register_cop :QuuxCop, "#{__dir__}/test/quux_cop"
            end
          end
        end
      RUBY
    end

    it 'injects the directive in alphabetical order' do
      injector.inject

      expect(File.read(department_file_path)).to eq(<<~'RUBY')
        # frozen_string_literal: true

        module RuboCop
          module Cop
            # Cops for the `Test` department.
            module Test
              extend LazyLoader

              register_cop :BarCop, "#{__dir__}/test/bar_cop"
              register_cop :FooCop, "#{__dir__}/test/foo_cop"
              register_cop :QuuxCop, "#{__dir__}/test/quux_cop"
            end
          end
        end
      RUBY
      expect(stdout.string).to eq(<<~'MESSAGE')
        [modify] lib/rubocop/cop/test.rb - `register_cop :FooCop, "#{__dir__}/test/foo_cop"` was injected.
      MESSAGE
    end
  end

  context 'when the new directive belongs at the end of the block' do
    let(:source_path) { 'lib/rubocop/cop/test/zoo_cop.rb' }
    let(:badge) { RuboCop::Cop::Badge.for('RuboCop::Cop::Test::ZooCop') }

    before do
      File.write(department_file_path, <<~'RUBY')
        # frozen_string_literal: true

        module RuboCop
          module Cop
            # Cops for the `Test` department.
            module Test
              extend LazyLoader

              register_cop :BarCop, "#{__dir__}/test/bar_cop"
              register_cop :FooCop, "#{__dir__}/test/foo_cop"
            end
          end
        end
      RUBY
    end

    it 'injects the directive after the last entry' do
      injector.inject

      expect(File.read(department_file_path)).to include(<<~'RUBY'.gsub(/^/, '      '))
        register_cop :BarCop, "#{__dir__}/test/bar_cop"
        register_cop :FooCop, "#{__dir__}/test/foo_cop"
        register_cop :ZooCop, "#{__dir__}/test/zoo_cop"
      RUBY
    end
  end

  context 'when the block keeps a non-alphabetical legacy order' do
    before do
      File.write(department_file_path, <<~'RUBY')
        # frozen_string_literal: true

        module RuboCop
          module Cop
            # Cops for the `Test` department.
            module Test
              extend LazyLoader

              register_cop :QuuxCop, "#{__dir__}/test/quux_cop"
              register_cop :BarCop, "#{__dir__}/test/bar_cop"
              register_cop :ZooCop, "#{__dir__}/test/zoo_cop"
            end
          end
        end
      RUBY
    end

    it 'inserts before the first alphabetically greater entry without reordering' do
      injector.inject

      expect(File.read(department_file_path)).to include(<<~'RUBY'.gsub(/^/, '      '))
        register_cop :FooCop, "#{__dir__}/test/foo_cop"
        register_cop :QuuxCop, "#{__dir__}/test/quux_cop"
        register_cop :BarCop, "#{__dir__}/test/bar_cop"
        register_cop :ZooCop, "#{__dir__}/test/zoo_cop"
      RUBY
    end
  end

  context 'when the directive already exists' do
    let(:source) { <<~'RUBY' }
      # frozen_string_literal: true

      module RuboCop
        module Cop
          # Cops for the `Test` department.
          module Test
            extend LazyLoader

            register_cop :FooCop, "#{__dir__}/test/foo_cop"
          end
        end
      end
    RUBY

    before { File.write(department_file_path, source) }

    it 'does not modify the file' do
      injector.inject

      expect(File.read(department_file_path)).to eq(source)
      expect(stdout.string).to be_empty
    end
  end

  context 'when the department module has no directives yet' do
    before do
      File.write(department_file_path, <<~RUBY)
        # frozen_string_literal: true

        module RuboCop
          module Cop
            # Cops for the `Test` department.
            module Test
              extend LazyLoader
            end
          end
        end
      RUBY
    end

    it 'injects the directive after `extend LazyLoader`' do
      injector.inject

      expect(File.read(department_file_path)).to include(<<~'RUBY'.gsub(/^/, '      '))
        extend LazyLoader
        register_cop :FooCop, "#{__dir__}/test/foo_cop"
      RUBY
    end
  end

  context 'when a `register_cop` line is commented out' do
    before do
      File.write(department_file_path, <<~'RUBY')
        # frozen_string_literal: true

        module RuboCop
          module Cop
            # Cops for the `Test` department.
            module Test
              extend LazyLoader

              # register_cop :BarCop, "#{__dir__}/test/bar_cop"
              register_cop :QuuxCop, "#{__dir__}/test/quux_cop"
            end
          end
        end
      RUBY
    end

    it 'raises an error instead of guessing' do
      expect { injector.inject }.to raise_error(RuboCop::Error, /unexpected `register_cop` line/)
    end
  end

  context 'when a `register_cop` line has a trailing comment' do
    before do
      File.write(department_file_path, <<~'RUBY')
        # frozen_string_literal: true

        module RuboCop
          module Cop
            # Cops for the `Test` department.
            module Test
              extend LazyLoader

              register_cop :BarCop, "#{__dir__}/test/bar_cop" # a comment
            end
          end
        end
      RUBY
    end

    it 'raises an error instead of guessing' do
      expect { injector.inject }.to raise_error(RuboCop::Error, /unexpected `register_cop` line/)
    end
  end

  context 'when the department module lacks `extend LazyLoader`' do
    before do
      File.write(department_file_path, <<~RUBY)
        # frozen_string_literal: true

        module RuboCop
          module Cop
            # Cops for the `Test` department.
            module Test
            end
          end
        end
      RUBY
    end

    it 'raises an error' do
      expect { injector.inject }.to raise_error(RuboCop::Error, /expected `extend LazyLoader`/)
    end
  end

  context 'when the department module does not exist yet' do
    before do
      File.write('lib/rubocop.rb', <<~RUBY)
        # frozen_string_literal: true

        require_relative 'rubocop/cop/utils/format_string'

        require_relative 'rubocop/cop/bundler'
        require_relative 'rubocop/cop/style'

        require_relative 'rubocop/cop/team'
      RUBY
    end

    it 'creates the department module and requires it from the root file' do
      injector.inject

      expect(File.read(department_file_path)).to eq(<<~'RUBY')
        # frozen_string_literal: true

        module RuboCop
          module Cop
            # Cops for the `Test` department. The department's cops are
            # registered for lazy loading and their files are loaded on demand.
            module Test
              extend LazyLoader

              register_cop :FooCop, "#{__dir__}/test/foo_cop"
            end
          end
        end
      RUBY

      expect(File.read('lib/rubocop.rb')).to eq(<<~RUBY)
        # frozen_string_literal: true

        require_relative 'rubocop/cop/utils/format_string'

        require_relative 'rubocop/cop/bundler'
        require_relative 'rubocop/cop/style'
        require_relative 'rubocop/cop/test'

        require_relative 'rubocop/cop/team'
      RUBY

      expect(stdout.string).to eq(<<~MESSAGE)
        [create] lib/rubocop/cop/test.rb
        [modify] lib/rubocop.rb - `require_relative 'rubocop/cop/test'` was injected.
      MESSAGE
    end
  end

  context 'when a nested department module does not exist yet' do
    let(:source_path) { 'lib/rubocop/cop/test/nested/foo_cop.rb' }
    let(:badge) { RuboCop::Cop::Badge.for('RuboCop::Cop::Test::Nested::FooCop') }
    let(:department_file_path) { 'lib/rubocop/cop/test/nested.rb' }

    before do
      FileUtils.mkdir_p('lib/rubocop/cop/test')
      File.write('lib/rubocop.rb', <<~RUBY)
        # frozen_string_literal: true

        require_relative 'rubocop/cop/style'

        require_relative 'rubocop/cop/team'
      RUBY
    end

    it 'creates the department module with properly nested modules' do
      injector.inject

      expect(File.read(department_file_path)).to eq(<<~'RUBY')
        # frozen_string_literal: true

        module RuboCop
          module Cop
            module Test
              # Cops for the `Test/Nested` department. The department's cops are
              # registered for lazy loading and their files are loaded on demand.
              module Nested
                extend LazyLoader

                register_cop :FooCop, "#{__dir__}/nested/foo_cop"
              end
            end
          end
        end
      RUBY

      expect(File.read('lib/rubocop.rb')).to include("require_relative 'rubocop/cop/test/nested'\n")
    end
  end
end
