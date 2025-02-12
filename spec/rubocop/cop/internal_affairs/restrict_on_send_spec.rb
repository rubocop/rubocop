# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::RestrictOnSend, :config do
  it 'registers an offense when `on_send` is defined but `RESTRICT_ON_SEND` is missing' do
    expect_offense(<<~RUBY)
      class FooCop < Base
      ^^^^^^^^^^^^^^^^^^^ Missing `RESTRICT_ON_SEND` declaration when using `on_send` or `after_send`.
        def on_send(node)
          # ...
        end
      end
    RUBY
  end

  it 'registers an offense when `after_send` is defined but `RESTRICT_ON_SEND` is missing' do
    expect_offense(<<~RUBY)
      class FooCop < Base
      ^^^^^^^^^^^^^^^^^^^ Missing `RESTRICT_ON_SEND` declaration when using `on_send` or `after_send`.
        def after_send(node)
          # ...
        end
      end
    RUBY
  end

  it 'does not register an offense when `RESTRICT_ON_SEND` is defined and `on_send` is defined' do
    expect_no_offenses(<<~RUBY)
      class FooCop < Base
        RESTRICT_ON_SEND = %i[bad_method].freeze
        def on_send(node)
          # ...
        end
      end
    RUBY
  end

  it 'does not register an offense when `RESTRICT_ON_SEND` is defined and `on_send` is defined with alias' do
    expect_no_offenses(<<~RUBY)
      class FooCop < Base
        RESTRICT_ON_SEND = %i[bad_method].freeze
        def on_def(node)
          # ...
        end
        alias on_send on_def
      end
    RUBY
  end

  it 'does not register an offense when `RESTRICT_ON_SEND` is defined and `on_send` is defined with alias_method' do
    expect_no_offenses(<<~RUBY)
      class FooCop < Base
        RESTRICT_ON_SEND = %i[bad_method].freeze
        def on_def(node)
          # ...
        end
        alias_method :on_send, :on_def
      end
    RUBY
  end

  it 'does not register an offense when `RESTRICT_ON_SEND` is defined and `after_send` is defined' do
    expect_no_offenses(<<~RUBY)
      class FooCop < Base
        RESTRICT_ON_SEND = %i[bad_method].freeze
        def after_send(node)
          # ...
        end
      end
    RUBY
  end

  it 'does not register an offense when `RESTRICT_ON_SEND` is defined and `after_send` is defined with alias' do
    expect_no_offenses(<<~RUBY)
      class FooCop < Base
        RESTRICT_ON_SEND = %i[bad_method].freeze
        def after_send(node)
          # ...
        end
        alias after_send any
      end
    RUBY
  end

  it 'does not register an offense when `RESTRICT_ON_SEND` is defined and `after_send` is defined with alias_method' do
    expect_no_offenses(<<~RUBY)
      class FooCop < Base
        RESTRICT_ON_SEND = %i[bad_method].freeze
        def after_send(node)
          # ...
        end
        self.alias_method "after_send", "any"
      end
    RUBY
  end

  it 'does not register an offense in empty class or non-cop class that complies' do
    expect_no_offenses(<<~RUBY)
      class FooCop
        RESTRICT_ON_SEND = %i[bad_method].freeze
        def after_send(node)
          # ...
        end
        self.alias_method "after_send", "any"
      end

      class BarCop
      end
    RUBY
  end

  it 'does not register an offense for non-cop class with on_send' do
    expect_no_offenses(<<~RUBY)
      class NotACop
        def on_send(node)
          do_something
        end
      end
    RUBY
  end

  it 'does not register an offense for class without cop parent with on_send' do
    expect_no_offenses(<<~RUBY)
      class SomeClass < OtherClass
        def on_send(node)
          do_something
        end
      end
    RUBY
  end

  it 'does not register an offense in non-cop classes with hook method names' do
    expect_no_offenses(<<~RUBY)
      class Witz::Baz < ActiveSupport::Concern
        def on_send(node)
          # ...
        end
        def after_send(node)
          # ...
        end
        self.alias_method "after_send", "any"
      end
      module Fang
        class Witz::Baz < ActiveSupport::Concern
          def on_send(node)
            # ...
          end
          def after_send(node)
            # ...
          end
          self.alias_method "after_send", "any"
        end
      end
    RUBY
  end
end
