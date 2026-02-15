# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::DataDefineOverride, :config do
  it 'registers an offense using `Data.define(symbol)`' do
    expect_offense(<<~RUBY)
      Bad = Data.define(:members)
                        ^^^^^^^^ `:members` member overrides `Data#members` and it may be unexpected.
    RUBY
  end

  it 'registers an offense using `::Data.define(symbol)`' do
    expect_offense(<<~RUBY)
      Bad = ::Data.define(:members)
                          ^^^^^^^^ `:members` member overrides `Data#members` and it may be unexpected.
    RUBY
  end

  it 'registers an offense using `Data.define(...symbols)`' do
    expect_offense(<<~RUBY)
      Bad = Data.define(:name, :members, :address)
                               ^^^^^^^^ `:members` member overrides `Data#members` and it may be unexpected.
    RUBY
  end

  it 'registers an offense using `Data.define(symbol, string)`' do
    expect_offense(<<~RUBY)
      Bad = Data.define(:name, "members")
                               ^^^^^^^^^ `"members"` member overrides `Data#members` and it may be unexpected.
    RUBY
  end

  it 'registers an offense using `Data.define(...)` with a block' do
    expect_offense(<<~RUBY)
      Data.define(:members) do
                  ^^^^^^^^ `:members` member overrides `Data#members` and it may be unexpected.
        def members?
          !members.empty?
        end
      end
    RUBY
  end

  it 'registers an offense using `Data.define(...)` with multiple overrides' do
    expect_offense(<<~RUBY)
      Data.define(:members, :clone, :to_s)
                                    ^^^^^ `:to_s` member overrides `Data#to_s` and it may be unexpected.
                            ^^^^^^ `:clone` member overrides `Data#clone` and it may be unexpected.
                  ^^^^^^^^ `:members` member overrides `Data#members` and it may be unexpected.
    RUBY
  end

  it 'does not register an offense with no overrides' do
    expect_no_offenses(<<~RUBY)
      Good = Data.define(:id, :name)
    RUBY
  end

  it 'does not register an offense with an override within a given block' do
    expect_no_offenses(<<~RUBY)
      Good = Data.define(:id, :name) do
        def members
          super.tap { |ret| pp "members: " + ret.to_s }
        end
      end
    RUBY
  end
end
