# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::NonAtomicFileOperation, :config do
  %i[makedirs mkdir mkdir_p mkpath].each do |make_method|
    it 'registers an offense when use `FileTest.exist?` before creating file' do
      expect_offense(<<~RUBY)
        unless FileTest.exist?(path)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove unnecessary existence checks `FileTest.exist?`.
          FileUtils.#{make_method}(path)
        end
      RUBY

      expect_correction(<<~RUBY)

        #{trailing_whitespace}#{trailing_whitespace}FileUtils.mkdir_p(path)

      RUBY
    end
  end

  %i[remove remove_dir remove_entry remove_entry_secure delete unlink
     remove_file rm rm_f rm_r rm_rf rmdir rmtree safe_unlink].each do |remove_method|
    it 'registers an offense when use `FileTest.exist?` before remove file' do
      expect_offense(<<~RUBY)
        if FileTest.exist?(path)
        ^^^^^^^^^^^^^^^^^^^^^^^^ Remove unnecessary existence checks `FileTest.exist?`.
          FileUtils.#{remove_method}(path)
        end
      RUBY

      expect_correction(<<~RUBY)

        #{trailing_whitespace}#{trailing_whitespace}FileUtils.rm_rf(path)

      RUBY
    end
  end

  it 'registers an offense when use `FileTest.exist?` before creating file with an option `force: true`' do
    expect_offense(<<~RUBY)
      unless FileTest.exists?(path)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove unnecessary existence checks `FileTest.exists?`.
        FileUtils.makedirs(path, force: true)
      end
    RUBY

    expect_correction(<<~RUBY)

      #{trailing_whitespace}#{trailing_whitespace}FileUtils.makedirs(path, force: true)

    RUBY
  end

  it 'does not register an offense when use `FileTest.exist?` before creating file with an option `force: false`' do
    expect_no_offenses(<<~RUBY)
      unless FileTest.exists?(path)
        FileUtils.makedirs(path, force: false)
      end
    RUBY
  end

  it 'registers an offense when use `FileTest.exist?` before creating file with an option not `force`' do
    expect_offense(<<~RUBY)
      unless FileTest.exists?(path)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove unnecessary existence checks `FileTest.exists?`.
        FileUtils.makedirs(path, verbose: true)
      end
    RUBY

    expect_correction(<<~RUBY)

      #{trailing_whitespace}#{trailing_whitespace}FileUtils.mkdir_p(path, verbose: true)

    RUBY
  end

  it 'registers an offense when use `FileTest.exists?` before creating file' do
    expect_offense(<<~RUBY)
      unless FileTest.exists?(path)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove unnecessary existence checks `FileTest.exists?`.
        FileUtils.makedirs(path)
      end
    RUBY

    expect_correction(<<~RUBY)

      #{trailing_whitespace}#{trailing_whitespace}FileUtils.mkdir_p(path)

    RUBY
  end

  it 'registers an offense when use `FileTest.exist?` with negated `if` before creating file' do
    expect_offense(<<~RUBY)
      if !FileTest.exist?(path)
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Remove unnecessary existence checks `FileTest.exist?`.
        FileUtils.makedirs(path)
      end
    RUBY

    expect_correction(<<~RUBY)

      #{trailing_whitespace}#{trailing_whitespace}FileUtils.mkdir_p(path)

    RUBY
  end

  it 'registers an offense when use file existence checks `unless` by postfix before creating file' do
    expect_offense(<<~RUBY)
      FileUtils.makedirs(path) unless FileTest.exist?(path)
                               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove unnecessary existence checks `FileTest.exist?`.
    RUBY

    expect_correction(<<~RUBY)
      FileUtils.mkdir_p(path)#{trailing_whitespace}
    RUBY
  end

  it 'registers an offense when use file existence checks `if` by postfix before removing file' do
    expect_offense(<<~RUBY)
      FileUtils.remove(path) if FileTest.exist?(path)
                             ^^^^^^^^^^^^^^^^^^^^^^^^ Remove unnecessary existence checks `FileTest.exist?`.
    RUBY

    expect_correction(<<~RUBY)
      FileUtils.rm_rf(path)#{trailing_whitespace}
    RUBY
  end

  it 'does not register an offense when not checking for the existence' do
    expect_no_offenses(<<~RUBY)
      FileUtils.mkdir_p(path)
    RUBY
  end

  it 'does not register an offense when checking for the existence of different files' do
    expect_no_offenses(<<~RUBY)
      FileUtils.mkdir_p(y) unless FileTest.exist?(path)
    RUBY
  end

  it 'does not register an offense when not a method of file operation' do
    expect_no_offenses(<<~RUBY)
      unless FileUtils.exist?(path)
        FileUtils.options_of(:rm)
      end
      unless FileUtils.exist?(path)
        NotFile.remove(path)
      end
    RUBY
  end

  it 'does not register an offense when not an exist check' do
    expect_no_offenses(<<~RUBY)
      unless FileUtils.options_of(:rm)
        FileUtils.mkdir_p(path)
      end
      if FileTest.executable?(path)
        FileUtils.remove(path)
      end
    RUBY
  end

  it 'does not register an offense when processing other than file operations' do
    expect_no_offenses(<<~RUBY)
      unless FileTest.exist?(path)
        FileUtils.makedirs(path)
        do_something
      end

      unless FileTest.exist?(path)
        do_something
        FileUtils.makedirs(path)
      end
    RUBY
  end

  it 'does not register an offense when using `FileTest.exist?` with `if` condition that has `else` branch' do
    expect_no_offenses(<<~RUBY)
      if FileTest.exist?(path)
        FileUtils.mkdir(path)
      else
        do_something
      end
    RUBY
  end
end
