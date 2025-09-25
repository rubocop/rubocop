# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::OnSendWithoutOnCSend, :config do
  it 'registers an offense when `on_send` is defined without `on_csend`' do
    expect_offense(<<~RUBY)
      class MyCop < RuboCop::Cop:Base
        def on_send(node)
        ^^^^^^^^^^^^^^^^^ Cop defines `on_send` but not `on_csend`.
          # ...
        end
      end
    RUBY
  end

  it 'does not register an offense when `on_send` is not defined' do
    expect_no_offenses(<<~RUBY)
      class MyCop < RuboCop::Cop:Base
        def on_def(node)
          # ...
        end
      end
    RUBY
  end

  it 'does not register an offense when `on_csend` is defined but `on_send` is not' do
    expect_no_offenses(<<~RUBY)
      class MyCop < RuboCop::Cop:Base
        def on_csend(node)
          # ...
        end
      end
    RUBY
  end

  it 'does not register an offense when `on_csend` is defined explicitly' do
    expect_no_offenses(<<~RUBY)
      class MyCop < RuboCop::Cop:Base
        def on_send(node)
          # ...
        end

        def on_csend(node)
          # ...
        end
      end
    RUBY
  end

  it 'does not register an offense when `on_csend` is defined with `alias`' do
    expect_no_offenses(<<~RUBY)
      class MyCop < RuboCop::Cop:Base
        def on_send(node)
          # ...
        end
        alias on_csend on_send
      end
    RUBY
  end

  it 'does not register an offense when `on_csend` is defined with `alias_method`' do
    expect_no_offenses(<<~RUBY)
      class MyCop < RuboCop::Cop:Base
        def on_send(node)
          # ...
        end
        alias_method :on_csend, :on_send
      end
    RUBY
  end

  it 'registers an offense when `alias_method` takes no arguments' do
    expect_offense(<<~RUBY)
      class MyCop < RuboCop::Cop:Base
        def on_send(node)
        ^^^^^^^^^^^^^^^^^ Cop defines `on_send` but not `on_csend`.
          # ...
        end
        alias_method
      end
    RUBY
  end
end
