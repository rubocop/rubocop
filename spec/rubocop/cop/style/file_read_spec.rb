# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::FileRead, :config do
  it 'does not register an offense when not reading from the block variable' do
    expect_no_offenses(<<~RUBY)
      File.open(filename) do |f|
        something_else.read
      end
    RUBY
  end

  it 'registers an offense for and corrects `File.open(filename).read`' do
    expect_offense(<<~RUBY)
      File.open(filename).read
      ^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.read`.
    RUBY

    expect_correction(<<~RUBY)
      File.read(filename)
    RUBY
  end

  it 'registers an offense for and corrects `::File.open(filename).read`' do
    expect_offense(<<~RUBY)
      ::File.open(filename).read
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.read`.
    RUBY

    expect_correction(<<~RUBY)
      ::File.read(filename)
    RUBY
  end

  it 'registers an offense for and corrects the `File.open` with symbolic read proc (implicit text mode)' do
    expect_offense(<<~RUBY)
      File.open(filename, &:read)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.read`.
    RUBY

    expect_correction(<<~RUBY)
      File.read(filename)
    RUBY
  end

  it 'registers an offense for and corrects the `File.open` with inline read block (implicit text mode)' do
    expect_offense(<<~RUBY)
      File.open(filename) { |f| f.read }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.read`.
    RUBY

    expect_correction(<<~RUBY)
      File.read(filename)
    RUBY
  end

  it 'registers an offense for and corrects the `File.open` with multiline read block (implicit text mode)' do
    expect_offense(<<~RUBY)
      File.open(filename) do |f|
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.read`.
        f.read
      end
    RUBY

    expect_correction(<<~RUBY)
      File.read(filename)
    RUBY
  end

  it 'does not autocorrect when the heredoc body would be removed with the block' do
    expect_offense(<<~RUBY)
      publish(File.open(<<~PATH.chomp) do |file|
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.read`.
        settings.yml
      PATH
        file.read
      end)
    RUBY

    expect_no_corrections
  end

  it 'does not autocorrect when the block contains a comment' do
    expect_offense(<<~RUBY)
      File.open(filename) do |file|
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.read`.
        # Keep this note.
        file.read
      end
    RUBY

    expect_no_corrections
  end

  it 'autocorrects when the heredoc body follows the read call' do
    expect_offense(<<~RUBY)
      File.open(<<~PATH.chomp).read
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.read`.
        settings.yml
      PATH
    RUBY

    expect_correction(<<~RUBY)
      File.read(<<~PATH.chomp)
        settings.yml
      PATH
    RUBY
  end

  described_class::READ_FILE_START_TO_FINISH_MODES.each do |mode|
    it "registers an offense for and corrects `File.open(filename, '#{mode}').read`" do
      read_method = mode.end_with?('b') ? :binread : :read

      expect_offense(<<~RUBY)
        File.open(filename, '#{mode}').read
        ^^^^^^^^^^^^^^^^^^^^^#{'^' * mode.length}^^^^^^^ Use `File.#{read_method}`.
      RUBY

      expect_correction(<<~RUBY)
        File.#{read_method}(filename)
      RUBY
    end

    it "registers an offense for and corrects the `File.open` with symbolic read proc (mode '#{mode}')" do
      read_method = mode.end_with?('b') ? :binread : :read

      expect_offense(<<~RUBY)
        File.open(filename, '#{mode}', &:read)
        ^^^^^^^^^^^^^^^^^^^^^#{'^' * mode.length}^^^^^^^^^^ Use `File.#{read_method}`.
      RUBY

      expect_correction(<<~RUBY)
        File.#{read_method}(filename)
      RUBY
    end

    it "registers an offense for and corrects the `File.open` with inline read block (mode '#{mode}')" do
      read_method = mode.end_with?('b') ? :binread : :read

      expect_offense(<<~RUBY)
        File.open(filename, '#{mode}') { |f| f.read }
        ^^^^^^^^^^^^^^^^^^^^^#{'^' * mode.length}^^^^^^^^^^^^^^^^^ Use `File.#{read_method}`.
      RUBY

      expect_correction(<<~RUBY)
        File.#{read_method}(filename)
      RUBY
    end

    it "registers an offense for and corrects the `File.open` with multiline read block (mode '#{mode}')" do
      read_method = mode.end_with?('b') ? :binread : :read

      expect_offense(<<~RUBY)
        File.open(filename, '#{mode}') do |f|
        ^^^^^^^^^^^^^^^^^^^^^#{'^' * mode.length}^^^^^^^^^ Use `File.#{read_method}`.
          f.read
        end
      RUBY

      expect_correction(<<~RUBY)
        File.#{read_method}(filename)
      RUBY
    end
  end

  it 'registers an offense for and corrects the `File.open` with a numbered parameter read block', :ruby27 do
    expect_offense(<<~RUBY)
      File.open(filename) { _1.read }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.read`.
    RUBY

    expect_correction(<<~RUBY)
      File.read(filename)
    RUBY
  end

  it 'registers an offense for and corrects the `File.open` with an `it` read block', :ruby34 do
    expect_offense(<<~RUBY)
      File.open(filename) { it.read }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.read`.
    RUBY

    expect_correction(<<~RUBY)
      File.read(filename)
    RUBY
  end

  it 'does not register an offense when reading from another numbered parameter', :ruby27 do
    expect_no_offenses(<<~RUBY)
      File.open(filename) { _2.read }
    RUBY
  end
end
