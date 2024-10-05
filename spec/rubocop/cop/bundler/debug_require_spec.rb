# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Bundler::DebugRequire, :config do
  it 'registers an offense and corrects gem "debug" without require option' do
    expect_offense(<<~RUBY)
      gem "debug"
      ^^^^^^^^^^^ Specify `require: "debug/prelude"` or `require: false` when depending on the `debug` gem.
    RUBY

    expect_correction(<<~RUBY)
      gem "debug", require: "debug/prelude"
    RUBY
  end

  it 'registers an offense and corrects gem "debug" with incorrect require option' do
    expect_offense(<<~RUBY)
      gem "debug", require: "debug"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Specify `require: "debug/prelude"` or `require: false` when depending on the `debug` gem.
    RUBY

    expect_correction(<<~RUBY)
      gem "debug", require: "debug/prelude"
    RUBY
  end

  it 'does not register an offense for gem "debug" with require: "debug/prelude"' do
    expect_no_offenses(<<~RUBY)
      gem "debug", require: "debug/prelude"
    RUBY
  end

  it 'does not register an offense for gem "debug" with a version and require: "debug/prelude"' do
    expect_no_offenses(<<~RUBY)
      gem "debug", "1.0.0", require: "debug/prelude"
    RUBY
  end

  it 'does not register an offense for gem "debug" with require: false' do
    expect_no_offenses(<<~RUBY)
      gem "debug", require: false
    RUBY
  end

  it 'does not register an offense for gem "debug" with a version and require: false' do
    expect_no_offenses(<<~RUBY)
      gem "debug", "1.0.0", require: false
    RUBY
  end

  it 'does not register an offense for other gems' do
    expect_no_offenses(<<~RUBY)
      gem "rails"
      gem "rspec"
    RUBY
  end

  it 'registers an offense and corrects gem "debug" with version specified' do
    expect_offense(<<~RUBY)
      gem "debug", "1.0.0"
      ^^^^^^^^^^^^^^^^^^^^ Specify `require: "debug/prelude"` or `require: false` when depending on the `debug` gem.
    RUBY

    expect_correction(<<~RUBY)
      gem "debug", "1.0.0", require: "debug/prelude"
    RUBY
  end

  it 'registers an offense and corrects gem "debug" with other options' do
    expect_offense(<<~RUBY)
      gem "debug", group: :development
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Specify `require: "debug/prelude"` or `require: false` when depending on the `debug` gem.
    RUBY

    expect_correction(<<~RUBY)
      gem "debug", require: "debug/prelude", group: :development
    RUBY
  end

  it 'registers an offense and corrects gem "debug" with multiple options' do
    expect_offense(<<~RUBY)
      gem "debug", "1.0.0", group: :development, require: "debug"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Specify `require: "debug/prelude"` or `require: false` when depending on the `debug` gem.
    RUBY

    expect_correction(<<~RUBY)
      gem "debug", "1.0.0", group: :development, require: "debug/prelude"
    RUBY
  end

  it 'registers an offense and corrects gem "debug" with multiple versions and multiple options' do
    expect_offense(<<~RUBY)
      gem "debug", ">= 1.0", "< 2.0", group: :development, require: "debug"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Specify `require: "debug/prelude"` or `require: false` when depending on the `debug` gem.
    RUBY

    expect_correction(<<~RUBY)
      gem "debug", ">= 1.0", "< 2.0", group: :development, require: "debug/prelude"
    RUBY
  end

  it 'does not register an offense for gem "debug" with require: "debug/prelude" and other options' do
    expect_no_offenses(<<~RUBY)
      gem "debug", "1.0.0", group: :development, require: "debug/prelude"
    RUBY
  end

  it 'does not register an offense for gem "debug" with require: false and other options' do
    expect_no_offenses(<<~RUBY)
      gem "debug", "1.0.0", group: :development, require: false
    RUBY
  end

  it 'registers an offense and corrects incorrect multiline gem "debug" declaration' do
    expect_offense(<<~RUBY)
      gem "debug",
      ^^^^^^^^^^^^ Specify `require: "debug/prelude"` or `require: false` when depending on the `debug` gem.
          ">= 1.0.0",
          group: :development
    RUBY

    expect_correction(<<~RUBY)
      gem "debug",
          ">= 1.0.0",
          require: "debug/prelude",
          group: :development
    RUBY
  end

  it 'registers an offense and corrects incorrect multiline gem "debug" declaration with require as the last option' do
    expect_offense(<<~RUBY)
      gem "debug",
      ^^^^^^^^^^^^ Specify `require: "debug/prelude"` or `require: false` when depending on the `debug` gem.
          ">= 1.0.0",
          group: :development,
          require: "debug"
    RUBY

    expect_correction(<<~RUBY)
      gem "debug",
          ">= 1.0.0",
          group: :development,
          require: "debug/prelude"
    RUBY
  end

  it 'registers an offense and corrects incorrect multiline gem "debug" declaration with multiple version specifiers' do
    expect_offense(<<~RUBY)
      gem "debug",
      ^^^^^^^^^^^^ Specify `require: "debug/prelude"` or `require: false` when depending on the `debug` gem.
          ">= 1.0",
          "< 2.0",
          group: :development
    RUBY

    expect_correction(<<~RUBY)
      gem "debug",
          ">= 1.0",
          "< 2.0",
          require: "debug/prelude",
          group: :development
    RUBY
  end

  it 'registers an offense for debug gem when multiple gems are declared on the same line' do
    expect_offense(<<~RUBY)
      gem "rails"; gem "debug"; gem "rspec"
                   ^^^^^^^^^^^ Specify `require: "debug/prelude"` or `require: false` when depending on the `debug` gem.
    RUBY

    expect_correction(<<~RUBY)
      gem "rails"; gem "debug", require: "debug/prelude"; gem "rspec"
    RUBY
  end

  context 'copy-pasted test suite' do
    context 'when handling multiline declarations' do
      it 'registers an offense for multiline debug gem declaration' do
        expect_offense(<<~RUBY)
          gem "debug",
          ^^^^^^^^^^^^ Specify `require: "debug/prelude"` or `require: false` when depending on the `debug` gem.
              ">= 1.0.0",
              group: :development
        RUBY

        expect_correction(<<~RUBY)
          gem "debug",
              ">= 1.0.0",
              require: "debug/prelude",
              group: :development
        RUBY
      end

      it 'correctly handles multiline declarations with require as the last option' do
        expect_offense(<<~RUBY)
          gem "debug",
          ^^^^^^^^^^^^ Specify `require: "debug/prelude"` or `require: false` when depending on the `debug` gem.
              ">= 1.0.0",
              group: :development,
              require: "debug"
        RUBY

        expect_correction(<<~RUBY)
          gem "debug",
              ">= 1.0.0",
              group: :development,
              require: "debug/prelude"
        RUBY
      end

      it 'handles multiple version specifiers in multiline declarations' do
        expect_offense(<<~RUBY)
          gem "debug",
          ^^^^^^^^^^^^ Specify `require: "debug/prelude"` or `require: false` when depending on the `debug` gem.
              ">= 1.0",
              "< 2.0",
              group: :development
        RUBY

        expect_correction(<<~RUBY)
          gem "debug",
              ">= 1.0",
              "< 2.0",
              require: "debug/prelude",
              group: :development
        RUBY
      end
    end

    context 'when handling multiple gem declarations' do
      it 'registers an offense for debug gem when multiple gems are declared on the same line' do
        expect_offense(<<~RUBY)
          gem "rails"; gem "debug"; gem "rspec"
                       ^^^^^^^^^^^ Specify `require: "debug/prelude"` or `require: false` when depending on the `debug` gem.
        RUBY

        expect_correction(<<~RUBY)
          gem "rails"; gem "debug", require: "debug/prelude"; gem "rspec"
        RUBY
      end
    end
  end
end
