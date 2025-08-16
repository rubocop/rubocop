# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::RakeMethodDefinition, :config do
  it 'registers an offense for method definition in a .rake file' do
    expect_offense(<<~RUBY, 'lib/tasks/foo.rake')
      namespace :foo do
        task :foo do
          helper_thing
        end
      end

      def helper_thing
      ^^^^^^^^^^^^^^^^ Methods defined in Rake tasks are global and loaded for all tasks. If multiple methods share the same name, later method definitions will overwrite earlier ones, even across different tasks.
        puts 'hi'
      end
    RUBY
  end

  it 'registers an offense for method definition in a .rake file inside a :namespace block' do
    expect_offense(<<~RUBY, 'lib/tasks/foo.rake')
      namespace :foo do
        task :foo do
          helper_thing
        end

        def helper_thing
        ^^^^^^^^^^^^^^^^ Methods defined in Rake tasks are global and loaded for all tasks. If multiple methods share the same name, later method definitions will overwrite earlier ones, even across different tasks.
          puts 'hi'
        end
      end
    RUBY
  end

  it 'registers an offense for method definition in a .rake file inside a :task block' do
    expect_offense(<<~RUBY, 'lib/tasks/foo.rake')
      namespace :foo do
        task :foo do
          helper_thing

          def helper_thing
          ^^^^^^^^^^^^^^^^ Methods defined in Rake tasks are global and loaded for all tasks. If multiple methods share the same name, later method definitions will overwrite earlier ones, even across different tasks.
            puts 'hi'
          end
        end
      end
    RUBY
  end

  it 'does not register an offense for method definition in a .rake file inside a module' do
    expect_no_offenses(<<~RUBY, 'lib/tasks/foo.rake')
      module FooHelper
        module_function

        def helper_thing
          puts 'hi'
        end
      end

      namespace :foo do
        task :foo do
          FooHelper.helper_thing
        end
      end
    RUBY
  end

  it 'does not register an offense for method definition in a .rake file inside a module inside a :namespace block' do
    expect_no_offenses(<<~RUBY, 'lib/tasks/foo.rake')
      namespace :foo do
        module FooHelper
          module_function

          def helper_thing
            puts 'hi'
          end
        end

        task :foo do
          FooHelper.helper_thing
        end
      end
    RUBY
  end

  it 'does not register an offense for method definition in a .rake file inside a module inside a :task block' do
    expect_no_offenses(<<~RUBY, 'lib/tasks/foo.rake')
      namespace :foo do
        task :foo do
          module FooHelper
            module_function

            def helper_thing
              puts 'hi'
            end
          end

          FooHelper.helper_thing
        end
      end
    RUBY
  end

  it 'does not register an offense for method definition in a .rake file inside a class' do
    expect_no_offenses(<<~RUBY, 'lib/tasks/foo.rake')
      class FooHelper
        def self.helper_thing
          puts 'hi'
        end
      end

      namespace :foo do
        task :foo do
          FooHelper.helper_thing
        end
      end
    RUBY
  end

  it 'does not register an offense for method definition in a non-.rake file' do
    expect_no_offenses(<<~RUBY, 'app/models/user.rb')
      def helper_thing
        puts 'hi'
      end
    RUBY
  end
end
