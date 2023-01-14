# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::RedundantLetRuboCopConfigNew, :config do
  it 'registers an offense when using `let(:config)` and `:config` is not specified in `describe`' do
    expect_offense(<<~RUBY)
      RSpec.describe RuboCop::Cop::Layout::SpaceAfterComma do
        subject(:cop) { described_class.new(config) }

        let(:config) { RuboCop::Config.new }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove `let` that is `RuboCop::Config.new` with no arguments and specify `:config` in `describe`.
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe RuboCop::Cop::Layout::SpaceAfterComma, :config do
        subject(:cop) { described_class.new(config) }

      end
    RUBY
  end

  it 'registers an offense when using `let(:config)` and `:config` is already specified in `describe`' do
    expect_offense(<<~RUBY)
      RSpec.describe RuboCop::Cop::Layout::SpaceAfterComma, :config do
        subject(:cop) { described_class.new(config) }

        let(:config) { RuboCop::Config.new }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove `let` that is `RuboCop::Config.new` with no arguments.
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe RuboCop::Cop::Layout::SpaceAfterComma, :config do
        subject(:cop) { described_class.new(config) }

      end
    RUBY
  end

  it 'registers an offense when using `let(:config)` with no argument `RuboCop::Config.new` and `:config` is specified' do
    expect_offense(<<~RUBY)
      RSpec.describe RuboCop::Cop::Layout::SpaceAfterComma, :config do
        subject(:cop) { described_class.new }

        let(:config) { RuboCop::Config.new }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove `let` that is `RuboCop::Config.new` with no arguments.
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe RuboCop::Cop::Layout::SpaceAfterComma, :config do
        subject(:cop) { described_class.new }

      end
    RUBY
  end

  it 'registers an offense when using `let(:config) { RuboCop::Config.new(described_class.badge.to_s => cop_config) }` ' \
     'and `:config` is specified' do
    expect_offense(<<~RUBY)
      RSpec.describe RuboCop::Cop::Layout::SpaceAfterComma, :config do
        subject(:cop) { described_class.new(config) }

        let(:config) { RuboCop::Config.new(described_class.badge.to_s => cop_config) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove `let` that is `RuboCop::Config.new` with no arguments.

        let(:cop_config) { { 'Parameter' => 'Value' } }
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe RuboCop::Cop::Layout::SpaceAfterComma, :config do
        subject(:cop) { described_class.new(config) }


        let(:cop_config) { { 'Parameter' => 'Value' } }
      end
    RUBY
  end

  it 'does not register an offense when using `let(:config)` with arguments to `RuboCop::Config.new`' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe RuboCop::Cop::Layout::SpaceAfterComma do
        let(:config) { RuboCop::Config.new('Layout/SpaceInsideHashLiteralBraces' => brace_config) }
      end
    RUBY
  end
end
