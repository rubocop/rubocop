# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::CreateEmptyFile, :config do
  it "registers an offense when using `create_file(path, '')" do
    expect_offense(<<~RUBY)
      create_file(path, '')
      ^^^^^^^^^^^^^^^^^^^^^ Use `create_empty_file(path)`.
    RUBY

    expect_correction(<<~RUBY)
      create_empty_file(path)
    RUBY
  end

  it 'registers an offense when using `create_file(path, "")' do
    expect_offense(<<~RUBY)
      create_file(path, "")
      ^^^^^^^^^^^^^^^^^^^^^ Use `create_empty_file(path)`.
    RUBY

    expect_correction(<<~RUBY)
      create_empty_file(path)
    RUBY
  end

  it "does not register an offense when using `create_file(path, 'hello')`" do
    expect_no_offenses(<<~RUBY)
      create_file(path, 'hello')
    RUBY
  end

  it "does not register an offense when using `create_file(path, ['foo', 'bar'])`" do
    expect_no_offenses(<<~RUBY)
      create_file(path, ['foo', 'bar'])
    RUBY
  end

  it 'does not register an offense when using `create_file(path)`' do
    expect_no_offenses(<<~RUBY)
      create_file(path)
    RUBY
  end

  it "does not register an offense when using `receiver.create_file(path, '')`" do
    expect_no_offenses(<<~RUBY)
      receiver.create_file(path, '')
    RUBY
  end
end
