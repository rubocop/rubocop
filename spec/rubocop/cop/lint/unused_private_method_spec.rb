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
