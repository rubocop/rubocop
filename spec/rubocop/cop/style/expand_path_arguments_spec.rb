# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ExpandPathArguments, :config do
  it "registers an offense when using `File.expand_path('..', __FILE__)`" do
    expect_offense(<<~RUBY)
      File.expand_path('..', __FILE__)
           ^^^^^^^^^^^ Use `expand_path(__dir__)` instead of `expand_path('..', __FILE__)`.
    RUBY

    expect_correction(<<~RUBY)
      File.expand_path(__dir__)
    RUBY
  end

  it "registers an offense when using `File.expand_path('../..', __FILE__)`" do
    expect_offense(<<~RUBY)
      File.expand_path('../..', __FILE__)
           ^^^^^^^^^^^ Use `expand_path('..', __dir__)` instead of `expand_path('../..', __FILE__)`.
    RUBY

    expect_correction(<<~RUBY)
      File.expand_path('..', __dir__)
    RUBY
  end

  it "registers an offense when using `File.expand_path('../../..', __FILE__)`" do
    expect_offense(<<~RUBY)
      File.expand_path('../../..', __FILE__)
           ^^^^^^^^^^^ Use `expand_path('../..', __dir__)` instead of `expand_path('../../..', __FILE__)`.
    RUBY

    expect_correction(<<~RUBY)
      File.expand_path('../..', __dir__)
    RUBY
  end

  it "registers an offense when using `File.expand_path('.', __FILE__)`" do
    expect_offense(<<~RUBY)
      File.expand_path('.', __FILE__)
           ^^^^^^^^^^^ Use `expand_path(__FILE__)` instead of `expand_path('.', __FILE__)`.
    RUBY

    expect_correction(<<~RUBY)
      File.expand_path(__FILE__)
    RUBY
  end

  it "registers an offense when using `File.expand_path('../../lib', __FILE__)`" do
    expect_offense(<<~RUBY)
      File.expand_path('../../lib', __FILE__)
           ^^^^^^^^^^^ Use `expand_path('../lib', __dir__)` instead of `expand_path('../../lib', __FILE__)`.
    RUBY

    expect_correction(<<~RUBY)
      File.expand_path('../lib', __dir__)
    RUBY
  end

  it "registers an offense when using `File.expand_path('./../..', __FILE__)`" do
    expect_offense(<<~RUBY)
      File.expand_path('./../..', __FILE__)
           ^^^^^^^^^^^ Use `expand_path('..', __dir__)` instead of `expand_path('./../..', __FILE__)`.
    RUBY

    expect_correction(<<~RUBY)
      File.expand_path('..', __dir__)
    RUBY
  end

  it "registers an offense when using `::File.expand_path('./../..', __FILE__)`" do
    expect_offense(<<~RUBY)
      ::File.expand_path('./../..', __FILE__)
             ^^^^^^^^^^^ Use `expand_path('..', __dir__)` instead of `expand_path('./../..', __FILE__)`.
    RUBY

    expect_correction(<<~RUBY)
      ::File.expand_path('..', __dir__)
    RUBY
  end

  it 'registers an offense when using `Pathname(__FILE__).parent.expand_path`' do
    expect_offense(<<~RUBY)
      Pathname(__FILE__).parent.expand_path
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Pathname(__dir__).expand_path` instead of `Pathname(__FILE__).parent.expand_path`.
    RUBY

    expect_correction(<<~RUBY)
      Pathname(__dir__).expand_path
    RUBY
  end

  it 'registers an offense when using `Pathname.new(__FILE__).parent.expand_path`' do
    expect_offense(<<~RUBY)
      Pathname.new(__FILE__).parent.expand_path
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Pathname.new(__dir__).expand_path` instead of `Pathname.new(__FILE__).parent.expand_path`.
    RUBY

    expect_correction(<<~RUBY)
      Pathname.new(__dir__).expand_path
    RUBY
  end

  it 'registers an offense when using `::Pathname.new(__FILE__).parent.expand_path`' do
    expect_offense(<<~RUBY)
      ::Pathname.new(__FILE__).parent.expand_path
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Pathname.new(__dir__).expand_path` instead of `Pathname.new(__FILE__).parent.expand_path`.
    RUBY

    expect_correction(<<~RUBY)
      ::Pathname.new(__dir__).expand_path
    RUBY
  end

  it 'does not register an offense when using `File.expand_path(__dir__)`' do
    expect_no_offenses(<<~RUBY)
      File.expand_path(__dir__)
    RUBY
  end

  it "does not register an offense when using `File.expand_path('..', __dir__)`" do
    expect_no_offenses(<<~RUBY)
      File.expand_path('..', __dir__)
    RUBY
  end

  it 'does not register an offense when using `File.expand_path(__FILE__)`' do
    expect_no_offenses(<<~RUBY)
      File.expand_path(__FILE__)
    RUBY
  end

  it 'does not register an offense when using `File.expand_path(path, __FILE__)`' do
    expect_no_offenses(<<~RUBY)
      File.expand_path(path, __FILE__)
    RUBY
  end

  it 'does not register an offense when using ' \
     '`File.expand_path("#{path_to_file}.png", __FILE__)`' do
    expect_no_offenses(<<~'RUBY')
      File.expand_path("#{path_to_file}.png", __FILE__)
    RUBY
  end

  it 'does not register an offense when using `Pathname(__dir__).expand_path`' do
    expect_no_offenses(<<~RUBY)
      Pathname(__dir__).expand_path
    RUBY
  end
end
