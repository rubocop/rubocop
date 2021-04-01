# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::RedundantDescribedClassAsSubject, :config do
  it 'registers an offense when using `subject(:cop)` and `:config` is not specified in `describe`' do
    expect_offense(<<~RUBY)
      RSpec.describe RuboCop::Cop::Lint::RegexpAsCondition do
        subject(:cop) { described_class.new(config) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove the redundant `subject` and specify `:config` in `describe`.

        let(:config) { RuboCop::Config.new }
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe RuboCop::Cop::Lint::RegexpAsCondition, :config do

        let(:config) { RuboCop::Config.new }
      end
    RUBY
  end

  it 'registers an offense when using `subject(:cop)` and `:config` is already specified in `describe`' do
    expect_offense(<<~RUBY)
      RSpec.describe RuboCop::Cop::Lint::RegexpAsCondition, :config do
        subject(:cop) { described_class.new(config) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove the redundant `subject`.

        let(:config) { RuboCop::Config.new }
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe RuboCop::Cop::Lint::RegexpAsCondition, :config do

        let(:config) { RuboCop::Config.new }
      end
    RUBY
  end

  it 'registers an offense when using `subject(:cop)` with no argument `described_class.new` and `:config` is specified' do
    expect_offense(<<~RUBY)
      RSpec.describe RuboCop::Cop::Lint::RegexpAsCondition, :config do
        subject(:cop) { described_class.new }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove the redundant `subject`.

        let(:config) { RuboCop::Config.new }
      end
    RUBY

    expect_correction(<<~RUBY)
      RSpec.describe RuboCop::Cop::Lint::RegexpAsCondition, :config do

        let(:config) { RuboCop::Config.new }
      end
    RUBY
  end

  it 'does not register an offense when using `subject(:cop)` with multiple arguments to `described_class.new`' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe RuboCop::Cop::Lint::RegexpAsCondition do
        subject(:cop) { described_class.new(config, options) }
      end
    RUBY
  end
end
