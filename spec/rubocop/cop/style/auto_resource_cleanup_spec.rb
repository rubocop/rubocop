# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::AutoResourceCleanup do
  subject(:cop) { described_class.new }

  it 'registers an offense for File.open without block' do
    expect_offense(<<-RUBY.strip_indent)
      File.open("filename")
      ^^^^^^^^^^^^^^^^^^^^^ Use the block version of `File.open`.
    RUBY
  end

  it 'does not register an offense for File.open with block' do
    expect_no_offenses('File.open("file") { |f| something }')
  end

  it 'does not register an offense for File.open with block-pass' do
    expect_no_offenses('File.open("file", &:read)')
  end

  it 'does not register an offense for File.open with immediate close' do
    expect_no_offenses('File.open("file", "w", 0o777).close')
  end
end
