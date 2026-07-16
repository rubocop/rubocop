# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::DeprecatedReference, :config do
  it 'does not register an offense without a project index' do
    expect_no_offenses(<<~RUBY)
      class Client
        def call
          old_method
        end
      end
    RUBY
  end

  context 'with a project index', :project_index do
    def index_with_current(sources = {})
      build_index(sources.merge('file:///lib/current.rb' => current_source))
    end

    let(:api_source) do
      <<~RUBY
        class Api
          # @deprecated Use `#new_method` instead.
          def old_method
          end

          def new_method
          end

          # @deprecated
          def bare_deprecation
          end

          # @deprecated Use `.modern_build` instead.
          def self.legacy_build
          end

          # @deprecated Use `NEW_TIMEOUT` instead.
          OLD_TIMEOUT = 10
        end
      RUBY
    end

    context 'for method calls' do
      let(:current_source) do
        <<~RUBY
          class Client < Api
            def call
              old_method
            end
          end
        RUBY
      end

      it 'registers an offense for a call to an inherited deprecated method' do
        cop.project_index = index_with_current('file:///lib/api.rb' => api_source)

        expect_offense(<<~RUBY, '/lib/current.rb')
          class Client < Api
            def call
              old_method
              ^^^^^^^^^^ Method `old_method` is deprecated: Use `#new_method` instead.
            end
          end
        RUBY
      end

      it 'registers an offense for a `self` call to a deprecated method' do
        cop.project_index = index_with_current('file:///lib/api.rb' => api_source)

        expect_offense(<<~RUBY, '/lib/current.rb')
          class Client < Api
            def call
              self.old_method
                   ^^^^^^^^^^ Method `old_method` is deprecated: Use `#new_method` instead.
            end
          end
        RUBY
      end

      it 'registers an offense without extra detail for a bare `@deprecated` tag' do
        cop.project_index = index_with_current('file:///lib/api.rb' => api_source)

        expect_offense(<<~RUBY, '/lib/current.rb')
          class Client < Api
            def call
              bare_deprecation
              ^^^^^^^^^^^^^^^^ Method `bare_deprecation` is deprecated.
            end
          end
        RUBY
      end

      it 'registers an offense for a call to a deprecated singleton method via constant' do
        cop.project_index = index_with_current('file:///lib/api.rb' => api_source)

        expect_offense(<<~RUBY, '/lib/current.rb')
          Api.legacy_build
              ^^^^^^^^^^^^ Method `legacy_build` is deprecated: Use `.modern_build` instead.
        RUBY
      end

      it 'registers an offense for a call to a deprecated singleton method from a class body' do
        cop.project_index = index_with_current('file:///lib/api.rb' => api_source)

        expect_offense(<<~RUBY, '/lib/current.rb')
          class Client < Api
            legacy_build
            ^^^^^^^^^^^^ Method `legacy_build` is deprecated: Use `.modern_build` instead.
          end
        RUBY
      end

      it 'does not register an offense for a call to a regular method' do
        cop.project_index = index_with_current('file:///lib/api.rb' => api_source)

        expect_no_offenses(<<~RUBY, '/lib/current.rb')
          class Client < Api
            def call
              new_method
            end
          end
        RUBY
      end

      it 'does not register an offense for a call on an arbitrary receiver' do
        cop.project_index = index_with_current('file:///lib/api.rb' => api_source)

        expect_no_offenses(<<~RUBY, '/lib/current.rb')
          class Client < Api
            def call(api)
              api.old_method
            end
          end
        RUBY
      end

      it 'does not register an offense for a call from a deprecated method' do
        cop.project_index = index_with_current('file:///lib/api.rb' => api_source)

        expect_no_offenses(<<~RUBY, '/lib/current.rb')
          class Client < Api
            # @deprecated Use `#modern_call` instead.
            def call
              old_method
            end
          end
        RUBY
      end
    end

    context 'for constant references' do
      let(:current_source) do
        <<~RUBY
          class Client < Api
            def timeout
              OLD_TIMEOUT
            end
          end
        RUBY
      end

      it 'registers an offense for a reference to a deprecated constant' do
        cop.project_index = index_with_current('file:///lib/api.rb' => api_source)

        expect_offense(<<~RUBY, '/lib/current.rb')
          class Client < Api
            def timeout
              Api::OLD_TIMEOUT
              ^^^^^^^^^^^^^^^^ Constant `Api::OLD_TIMEOUT` is deprecated: Use `NEW_TIMEOUT` instead.
            end
          end
        RUBY
      end

      it 'registers an offense for a reference to a deprecated class' do
        cop.project_index = index_with_current(
          'file:///lib/legacy.rb' => "# @deprecated Use `Modern` instead.\nclass Legacy\nend\n"
        )

        expect_offense(<<~RUBY, '/lib/current.rb')
          Legacy.new
          ^^^^^^ Constant `Legacy` is deprecated: Use `Modern` instead.
        RUBY
      end

      it 'does not register an offense when defining a deprecated class' do
        cop.project_index = index_with_current(
          'file:///lib/legacy.rb' => "# @deprecated\nclass Legacy\nend\n"
        )

        expect_no_offenses(<<~RUBY, '/lib/current.rb')
          # @deprecated
          class Legacy
            def helper
            end
          end
        RUBY
      end

      it 'does not register an offense for a regular constant' do
        cop.project_index = index_with_current('file:///lib/api.rb' => api_source)

        expect_no_offenses(<<~RUBY, '/lib/current.rb')
          class Client < Api
            def timeout
              Api
            end
          end
        RUBY
      end
    end
  end
end
