# frozen_string_literal: true

describe RuboCop::Cop::Lint::DeprecatedClassMethods do
  subject(:cop) { described_class.new }

  it 'registers an offense for File.exists?' do
    expect_offense(<<-RUBY.strip_indent)
      File.exists?(o)
           ^^^^^^^ `File.exists?` is deprecated in favor of `File.exist?`.
    RUBY
  end

  it 'registers an offense for ::File.exists?' do
    expect_offense(<<-RUBY.strip_indent)
      ::File.exists?(o)
             ^^^^^^^ `File.exists?` is deprecated in favor of `File.exist?`.
    RUBY
  end

  it 'does not register an offense for File.exist?' do
    expect_no_offenses('File.exist?(o)')
  end

  it 'registers an offense for Dir.exists?' do
    expect_offense(<<-RUBY.strip_indent)
      Dir.exists?(o)
          ^^^^^^^ `Dir.exists?` is deprecated in favor of `Dir.exist?`.
    RUBY
  end

  it 'auto-corrects File.exists? with File.exist?' do
    new_source = autocorrect_source('File.exists?(something)')
    expect(new_source).to eq('File.exist?(something)')
  end

  it 'auto-corrects Dir.exists? with Dir.exist?' do
    new_source = autocorrect_source('Dir.exists?(something)')
    expect(new_source).to eq('Dir.exist?(something)')
  end
end
