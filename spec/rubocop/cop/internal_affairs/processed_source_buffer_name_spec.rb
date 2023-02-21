# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::ProcessedSourceBufferName, :config do
  it 'registers an offense and corrects when using `processed_source.buffer.name` and `processed_source` is a method call' do
    expect_offense(<<~RUBY)
      processed_source.buffer.name
                       ^^^^^^^^^^^ Use `file_path` instead.
    RUBY

    expect_correction(<<~RUBY)
      processed_source.file_path
    RUBY
  end

  it 'registers an offense and corrects when using `processed_source.buffer.name` and `processed_source` is a variable' do
    expect_offense(<<~RUBY)
      processed_source = create_processed_source
      processed_source.buffer.name
                       ^^^^^^^^^^^ Use `file_path` instead.
    RUBY

    expect_correction(<<~RUBY)
      processed_source = create_processed_source
      processed_source.file_path
    RUBY
  end

  it 'does not register an offense when using `processed_source.file_path`' do
    expect_no_offenses(<<~RUBY)
      processed_source.file_path
    RUBY
  end
end
