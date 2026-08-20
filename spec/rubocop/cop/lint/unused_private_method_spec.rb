# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UnusedPrivateMethod, :config do
  it 'does not register an offense without a project index' do
    expect_no_offenses(<<~RUBY)
      class Service
        private

        def helper
        end
      end
    RUBY
  end

  context 'with a project index', :project_index do
    def index_with_current(sources = {})
      build_index(sources.merge('file:///lib/current.rb' => current_source))
    end

    let(:current_source) do
      <<~RUBY
        class Service
          def call
          end

          private

          def helper
          end
        end
      RUBY
    end

    it 'registers an offense for a private method never referenced in the project' do
      cop.project_index = index_with_current

      expect_offense(<<~RUBY, '/lib/current.rb')
        class Service
          def call
          end

          private

          def helper
          ^^^^^^^^^^ Private method `helper` appears to be unused.
          end
        end
      RUBY
    end

    it 'does not register an offense for a public method' do
      cop.project_index = index_with_current

      expect_no_offenses(<<~RUBY, '/lib/current.rb')
        class Service
          def call
          end
        end
      RUBY
    end

    it 'does not register an offense when the method is called in the same file' do
      source = <<~RUBY
        class Service
          def call
            helper
          end

          private

          def helper
          end
        end
      RUBY
      cop.project_index = build_index('file:///lib/current.rb' => source)

      expect_no_offenses(source, '/lib/current.rb')
    end

    it 'does not register an offense when a call with the same name exists in another file' do
      cop.project_index = index_with_current(
        'file:///lib/other.rb' => "class Other\n  def go(service)\n    service.helper\n  end\nend\n"
      )

      expect_no_offenses(current_source, '/lib/current.rb')
    end

    it 'does not register an offense when the method name appears as a symbol in the same file' do
      source = <<~RUBY
        class Service
          before_action :helper

          private

          def helper
          end
        end
      RUBY
      cop.project_index = build_index('file:///lib/current.rb' => source)

      expect_no_offenses(source, '/lib/current.rb')
    end

    it 'does not register an offense when the method is the source of an alias' do
      source = <<~RUBY
        class Service
          alias_method :run, :helper

          private

          def helper
          end
        end
      RUBY
      cop.project_index = build_index('file:///lib/current.rb' => source)

      expect_no_offenses(source, '/lib/current.rb')
    end

    it 'does not register an offense when the class has descendants' do
      cop.project_index = index_with_current(
        'file:///lib/sub.rb' => "class SubService < Service\nend\n"
      )

      expect_no_offenses(current_source, '/lib/current.rb')
    end

    it 'does not register an offense for implicitly invoked methods' do
      source = <<~RUBY
        class Service
          private

          def initialize
          end

          def respond_to_missing?(name, include_private = false)
          end
        end
      RUBY
      cop.project_index = build_index('file:///lib/current.rb' => source)

      expect_no_offenses(source, '/lib/current.rb')
    end

    it 'does not register an offense for runtime hook methods' do
      source = <<~RUBY
        class Service
          private

          def inherited(subclass)
          end

          def const_missing(name)
          end

          def method_added(name)
          end

          def singleton_method_undefined(name)
          end

          def coerce(other)
          end
        end
      RUBY
      cop.project_index = build_index('file:///lib/current.rb' => source)

      expect_no_offenses(source, '/lib/current.rb')
    end

    it 'does not register an offense for a singleton method' do
      source = <<~RUBY
        class Service
          class << self
            private

            def helper
            end
          end
        end
      RUBY
      cop.project_index = build_index('file:///lib/current.rb' => source)

      expect_no_offenses(source, '/lib/current.rb')
    end

    it 'does not register an offense for an override of an inherited private method' do
      source = <<~RUBY
        class Child < Base
          private

          def hook
          end
        end
      RUBY
      cop.project_index = build_index(
        'file:///lib/current.rb' => source,
        'file:///lib/base.rb' => "class Base\n  private\n\n  def hook\n  end\nend\n"
      )

      expect_no_offenses(source, '/lib/current.rb')
    end

    it 'registers an offense when the file contains a binary string literal' do
      source = <<~'RUBY'
        class Service
          DATA = "\xFF\xFE".b

          private

          def helper
          end
        end
      RUBY
      cop.project_index = build_index('file:///lib/current.rb' => source)

      expect_offense(<<~'RUBY', '/lib/current.rb')
        class Service
          DATA = "\xFF\xFE".b

          private

          def helper
          ^^^^^^^^^^ Private method `helper` appears to be unused.
          end
        end
      RUBY
    end

    it 'does not register an offense when the method name appears inside a string literal' do
      source = <<~RUBY
        class Service
          PATTERN = '(send nil? :require #helper)'

          private

          def helper
          end
        end
      RUBY
      cop.project_index = build_index('file:///lib/current.rb' => source)

      expect_no_offenses(source, '/lib/current.rb')
    end

    it 'does not register an offense when an interpolated symbol provides the name prefix' do
      source = <<~'RUBY'
        class Service
          def call(type)
            send(:"format_#{type}")
          end

          private

          def format_octal
          end

          def format_hex
          end
        end
      RUBY
      cop.project_index = build_index('file:///lib/current.rb' => source)

      expect_no_offenses(source, '/lib/current.rb')
    end

    it 'does not register an offense when an interpolated string provides the name prefix' do
      source = <<~'RUBY'
        class Service
          def call(action)
            send("do_#{action}")
          end

          private

          def do_start
          end
        end
      RUBY
      cop.project_index = build_index('file:///lib/current.rb' => source)

      expect_no_offenses(source, '/lib/current.rb')
    end

    it 'registers an offense for a private method not matching an interpolated prefix' do
      source = <<~'RUBY'
        class Service
          def call(type)
            send(:"format_#{type}")
          end

          private

          def render_html
          end
        end
      RUBY
      cop.project_index = build_index('file:///lib/current.rb' => source)

      expect_offense(<<~'RUBY', '/lib/current.rb')
        class Service
          def call(type)
            send(:"format_#{type}")
          end

          private

          def render_html
          ^^^^^^^^^^^^^^^ Private method `render_html` appears to be unused.
          end
        end
      RUBY
    end

    it 'registers an offense when the interpolated name has no literal prefix' do
      source = <<~'RUBY'
        class Service
          def call(type)
            send(:"#{type}_format")
          end

          private

          def octal_format
          end
        end
      RUBY
      cop.project_index = build_index('file:///lib/current.rb' => source)

      expect_offense(<<~'RUBY', '/lib/current.rb')
        class Service
          def call(type)
            send(:"#{type}_format")
          end

          private

          def octal_format
          ^^^^^^^^^^^^^^^^ Private method `octal_format` appears to be unused.
          end
        end
      RUBY
    end

    it 'does not treat a mid-string fragment as a name prefix' do
      source = <<~'RUBY'
        class Service
          def call(type, suffix)
            send(:"#{type}format_#{suffix}")
          end

          private

          def format_octal
          end
        end
      RUBY
      cop.project_index = build_index('file:///lib/current.rb' => source)

      expect_offense(<<~'RUBY', '/lib/current.rb')
        class Service
          def call(type, suffix)
            send(:"#{type}format_#{suffix}")
          end

          private

          def format_octal
          ^^^^^^^^^^^^^^^^ Private method `format_octal` appears to be unused.
          end
        end
      RUBY
    end

    # Symbol-based references from other files cannot be detected; this is
    # the documented reason the cop is disabled by default.
    it 'registers an offense (known limitation) when the method is referenced only ' \
       'by a symbol in another file' do
      cop.project_index = index_with_current(
        'file:///lib/config.rb' => "HOOKS = [:helper].freeze\n"
      )

      expect_offense(<<~RUBY, '/lib/current.rb')
        class Service
          def call
          end

          private

          def helper
          ^^^^^^^^^^ Private method `helper` appears to be unused.
          end
        end
      RUBY
    end

    context 'with AllowedNames' do
      let(:cop_config) { { 'AllowedNames' => ['attribute?'] } }

      it 'does not register an offense for an allowed name' do
        source = <<~RUBY
          class Contact
            private

            def attribute?
            end
          end
        RUBY
        cop.project_index = build_index('file:///lib/current.rb' => source)

        expect_no_offenses(source, '/lib/current.rb')
      end

      it 'registers an offense for a name that is not allowed' do
        cop.project_index = index_with_current

        expect_offense(<<~RUBY, '/lib/current.rb')
          class Service
            def call
            end

            private

            def helper
            ^^^^^^^^^^ Private method `helper` appears to be unused.
            end
          end
        RUBY
      end
    end

    context 'with AllowedPatterns' do
      let(:cop_config) { { 'AllowedPatterns' => ['_hook\z'] } }

      it 'does not register an offense for a name matching an allowed pattern' do
        source = <<~RUBY
          class Service
            private

            def before_save_hook
            end
          end
        RUBY
        cop.project_index = build_index('file:///lib/current.rb' => source)

        expect_no_offenses(source, '/lib/current.rb')
      end

      it 'registers an offense for a name not matching any allowed pattern' do
        cop.project_index = index_with_current

        expect_offense(<<~RUBY, '/lib/current.rb')
          class Service
            def call
            end

            private

            def helper
            ^^^^^^^^^^ Private method `helper` appears to be unused.
            end
          end
        RUBY
      end
    end

    describe 'the reference-name cache' do
      it 'is computed once per index and shared across cop instances' do
        index = index_with_current

        first_cop = cop
        first_cop.project_index = index
        first_cop_names = first_cop.send(:referenced_names)

        second_cop = described_class.new
        second_cop.project_index = index
        second_cop_names = second_cop.send(:referenced_names)

        expect(second_cop_names).to be(first_cop_names)
      end

      it 'replaces the cached entry when the index changes, rather than accumulating it' do
        other_source = <<~RUBY
          class Other
            def go(service)
              service.helper
            end
          end
        RUBY

        first_cop = cop
        first_cop.project_index = index_with_current('file:///lib/other.rb' => other_source)
        first_cop_names = first_cop.send(:referenced_names)

        second_cop = described_class.new
        second_cop.project_index = index_with_current
        second_cop_names = second_cop.send(:referenced_names)

        expect(second_cop_names).not_to eq(first_cop_names)

        index, cached = described_class.cached_reference_names
        expect(index).to be(second_cop.project_index)
        expect(cached).to be(second_cop_names)
      end
    end
  end
end
