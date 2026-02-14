# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::ItblockHandler, :config do
  it 'registers an offense for cops with forgotten itblock handlers' do
    expect_offense <<~RUBY
      class Cop < Base
        def on_block(node)
        ^^^^^^^^^^^^^^^^^^ Define on_itblock to handle blocks with the `it` parameter.
        end
      end
    RUBY
  end

  it 'does not register an offense for cops with on_itblock alias' do
    expect_no_offenses <<~RUBY
      class Cop < Base
        def on_block(node)
        end

        alias on_itblock on_block
      end
    RUBY
  end

  it 'does not register an offense for cops with on_itblock alias_method' do
    expect_no_offenses <<~RUBY
      class Cop < Base
        def on_block(node)
        end

        alias_method :on_itblock, :on_block
      end
    RUBY
  end

  it 'does not register an offense for cops with on_itblock method' do
    expect_no_offenses <<~RUBY
      class Cop < Base
        def on_block(node)
        end

        def on_itblock(node)
        end
      end
    RUBY
  end
end
