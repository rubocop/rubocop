# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::NumblockHandler, :config do
  it 'registers an offense for cops with forgotten numblock handlers' do
    expect_offense <<~RUBY
      class Cop < Base
        def on_block(node)
        ^^^^^^^^^^^^^^^^^^ Define on_numblock to handle blocks with numbered arguments.
        end
      end
    RUBY
  end

  it 'does not register an offense for cops with on_numblock alias' do
    expect_no_offenses <<~RUBY
      class Cop < Base
        def on_block(node)
        end

        alias on_numblock on_block
      end
    RUBY
  end

  it 'does not register an offense for cops with on_numblock alias_method' do
    expect_no_offenses <<~RUBY
      class Cop < Base
        def on_block(node)
        end

        alias_method :on_numblock, :on_block
      end
    RUBY
  end

  it 'does not register an offense for cops with on_numblock method' do
    expect_no_offenses <<~RUBY
      class Cop < Base
        def on_block(node)
        end

        def on_numblock(node)
        end
      end
    RUBY
  end
end
