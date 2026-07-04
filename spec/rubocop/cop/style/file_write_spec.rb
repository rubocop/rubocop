# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::FileWrite, :config do
  it 'does not register an offense for the `File.open` with multiline write block when not writing to the block variable' do
    expect_no_offenses(<<~RUBY)
      File.open(filename, 'w') do |f|
        something.write(content)
      end
    RUBY
  end

  it 'registers an offense and corrects when a local variable is passed to `f.write`' do
    expect_offense(<<~RUBY)
      content = 'hello'
      File.open(filename, 'w') { |f| f.write(content) }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.write`.
    RUBY

    expect_correction(<<~RUBY)
      content = 'hello'
      File.write(filename, content)
    RUBY
  end

  it 'does not register an offense when a splat argument is passed to `f.write`' do
    expect_no_offenses(<<~RUBY)
      File.open(filename, 'w') do |f|
        f.write(*objects)
      end
    RUBY
  end

  described_class::TRUNCATING_WRITE_MODES.each do |mode|
    it "registers an offense for and corrects `File.open(filename, '#{mode}').write(content)`" do
      write_method = mode.end_with?('b') ? :binwrite : :write

      expect_offense(<<~RUBY)
        File.open(filename, '#{mode}').write(content)
        ^^^^^^^^^^^^^^^^^^^^^#{'^' * mode.length}^^^^^^^^^^^^^^^^^ Use `File.#{write_method}`.
      RUBY

      expect_correction(<<~RUBY)
        File.#{write_method}(filename, content)
      RUBY
    end

    it "registers an offense for and corrects `::File.open(filename, '#{mode}').write(content)`" do
      write_method = mode.end_with?('b') ? :binwrite : :write

      expect_offense(<<~RUBY)
        ::File.open(filename, '#{mode}').write(content)
        ^^^^^^^^^^^^^^^^^^^^^^^#{'^' * mode.length}^^^^^^^^^^^^^^^^^ Use `File.#{write_method}`.
      RUBY

      expect_correction(<<~RUBY)
        ::File.#{write_method}(filename, content)
      RUBY
    end

    it "registers an offense for and corrects the `File.open` with inline write block (mode '#{mode}')" do
      write_method = mode.end_with?('b') ? :binwrite : :write

      expect_offense(<<~RUBY)
        File.open(filename, '#{mode}') { |f| f.write(content) }
        ^^^^^^^^^^^^^^^^^^^^^#{'^' * mode.length}^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.#{write_method}`.
      RUBY

      expect_correction(<<~RUBY)
        File.#{write_method}(filename, content)
      RUBY
    end

    it "registers an offense for and corrects the `File.open` with multiline write block (mode '#{mode}')" do
      write_method = mode.end_with?('b') ? :binwrite : :write

      expect_offense(<<~RUBY)
        File.open(filename, '#{mode}') do |f|
        ^^^^^^^^^^^^^^^^^^^^^#{'^' * mode.length}^^^^^^^^^ Use `File.#{write_method}`.
          f.write(content)
        end
      RUBY

      expect_correction(<<~RUBY)
        File.#{write_method}(filename, content)
      RUBY
    end

    it "registers an offense for and corrects the `File.open` with inline write block (mode '#{mode}') with string literal" do
      write_method = mode.end_with?('b') ? :binwrite : :write

      expect_offense(<<~RUBY)
        File.open(filename, '#{mode}') { |f| f.write('hello') }
        ^^^^^^^^^^^^^^^^^^^^^#{'^' * mode.length}^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.#{write_method}`.
      RUBY

      expect_correction(<<~RUBY)
        File.#{write_method}(filename, 'hello')
      RUBY
    end

    it "registers an offense for and corrects the `File.open` with multiline write block (mode '#{mode}') with heredoc" do
      write_method = mode.end_with?('b') ? :binwrite : :write

      expect_offense(<<~RUBY)
        File.open(filename, '#{mode}') do |f|
        ^^^^^^^^^^^^^^^^^^^^^#{'^' * mode.length}^^^^^^^^^ Use `File.#{write_method}`.
          f.write(<<~EOS)
            content
          EOS
        end
      RUBY

      expect_correction(<<~RUBY)
        File.#{write_method}(filename, <<~EOS)
            content
          EOS
      RUBY
    end

    it "registers an offense for and corrects the `File.open` with multiline write block (mode '#{mode}') with heredoc chained method call" do
      write_method = mode.end_with?('b') ? :binwrite : :write

      expect_offense(<<~RUBY)
        File.open(filename, '#{mode}') do |f|
        ^^^^^^^^^^^^^^^^^^^^^#{'^' * mode.length}^^^^^^^^^ Use `File.#{write_method}`.
          f.write(<<~EOS.gsub(/^/, ''))
            content
          EOS
        end
      RUBY

      expect_correction(<<~RUBY)
        File.#{write_method}(filename, <<~EOS.gsub(/^/, ''))
            content
          EOS
      RUBY
    end
  end

  it 'registers an offense for and corrects the `File.open` with multiline write block with heredoc as an operand' do
    expect_offense(<<~RUBY)
      File.open(filename, 'w') do |f|
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.write`.
        f.write('prefix' + <<~EOS)
          content
        EOS
      end
    RUBY

    expect_correction(<<~RUBY)
      File.write(filename, 'prefix' + <<~EOS)
          content
        EOS
    RUBY
  end

  it 'registers an offense for and corrects the `File.open` with multiline write block with heredoc as a method argument' do
    expect_offense(<<~RUBY)
      File.open(filename, 'w') do |f|
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.write`.
        f.write(process(<<~EOS))
          content
        EOS
      end
    RUBY

    expect_correction(<<~RUBY)
      File.write(filename, process(<<~EOS))
          content
        EOS
    RUBY
  end

  it 'registers an offense for and corrects the `File.open` with multiline write block with multiple heredocs' do
    expect_offense(<<~RUBY)
      File.open(filename, 'w') do |f|
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.write`.
        f.write(<<~HEAD + <<~TAIL)
          head
        HEAD
          tail
        TAIL
      end
    RUBY

    expect_correction(<<~RUBY)
      File.write(filename, <<~HEAD + <<~TAIL)
          head
        HEAD
          tail
        TAIL
    RUBY
  end

  it 'registers an offense for and corrects the `File.open` with inline write block with heredoc' do
    expect_offense(<<~RUBY)
      File.open(filename, 'w') { |f| f.write(<<~EOS) }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.write`.
        content
      EOS
    RUBY

    expect_correction(<<~RUBY)
      File.write(filename, <<~EOS)
        content
      EOS
    RUBY
  end

  it 'registers an offense for and corrects the `File.open` with multiline write block with heredoc as a filename' do
    expect_offense(<<~RUBY)
      File.open(<<~PATH.strip, 'w') do |f|
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.write`.
        path/to/file
      PATH
        f.write(content)
      end
    RUBY

    expect_correction(<<~RUBY)
      File.write(<<~PATH.strip, content)
        path/to/file
      PATH
    RUBY
  end
end
