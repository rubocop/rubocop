# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::FileWrite, :config do
  it 'does not register an offense for the `File.open` with multiline write block when not writing to the block variable' do
    expect_no_offenses(<<~RUBY)
      File.open(filename, 'w') do |f|
        something.write(content)
      end
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
  end
end
