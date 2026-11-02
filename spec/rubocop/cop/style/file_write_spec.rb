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

  it 'registers an offense for and corrects the `File.open` with a numbered parameter write block', :ruby27 do
    expect_offense(<<~RUBY)
      File.open(filename, 'w') { _1.write(content) }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.write`.
    RUBY

    expect_correction(<<~RUBY)
      File.write(filename, content)
    RUBY
  end

  it 'registers an offense for and corrects the `File.open` with an `it` write block', :ruby34 do
    expect_offense(<<~RUBY)
      File.open(filename, 'w') { it.write(content) }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.write`.
    RUBY

    expect_correction(<<~RUBY)
      File.write(filename, content)
    RUBY
  end

  it 'registers an offense for and corrects the `File.open` with multiline write block with heredoc followed by code on the same line' do
    expect_offense(<<~RUBY)
      foo(File.open(filename, 'w') do |f|
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.write`.
        f.write(<<~EOS)
          content
        EOS
      end, bar) if condition
    RUBY

    expect_correction(<<~RUBY)
      foo(File.write(filename, <<~EOS), bar) if condition
          content
        EOS
    RUBY
  end

  it 'registers an offense for and corrects the `File.open` with heredoc as a filename followed by code with a heredoc on the same line' do
    expect_offense(<<~RUBY)
      File.open(<<~PATH, 'w') do |f|
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.write`.
        path/to/file
      PATH
        f.write(content)
      end; foo(<<~EOS)
        bar
      EOS
    RUBY

    expect_correction(<<~RUBY)
      File.write(<<~PATH, content); foo(<<~EOS)
        path/to/file
      PATH
        bar
      EOS
    RUBY
  end

  it 'registers an offense for and corrects two `File.open` with heredocs on the same line' do
    expect_offense(<<~RUBY)
      foo(File.open(a, 'w') do |f|
          ^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.write`.
        f.write(<<~X)
          x
        X
      end, File.open(b, 'w') do |g|
           ^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.write`.
        g.write(<<~Y)
          y
        Y
      end)
    RUBY

    expect_correction(<<~RUBY, loop: true)
      foo(File.write(a, <<~X), File.write(b, <<~Y))
          x
        X
          y
        Y
    RUBY
  end

  it 'registers an offense for and corrects `File.open` with a heredoc followed by `File.open` without a heredoc on the same line' do
    expect_offense(<<~RUBY)
      foo(File.open(a, 'w') do |f|
          ^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.write`.
        f.write(<<~X)
          x
        X
      end, File.open(b, 'w') { |g| g.write(content) })
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.write`.
    RUBY

    expect_correction(<<~RUBY, loop: true)
      foo(File.write(a, <<~X), File.write(b, content))
          x
        X
    RUBY
  end

  it 'registers an offense for and corrects `File.open` nested in the content of another `File.open`' do
    expect_offense(<<~RUBY)
      File.open(a, 'w') do |f|
      ^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.write`.
        f.write((File.open(b, 'w') do |g|
                 ^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.write`.
          g.write(<<~X)
            x
          X
        end).to_s)
      end
    RUBY

    expect_correction(<<~RUBY, loop: true)
      File.write(a, (File.write(b, <<~X)).to_s)
            x
          X
    RUBY
  end

  it 'registers an offense for and corrects the `File.open` with a heredoc whose body is inside the content' do
    expect_offense(<<~RUBY)
      foo(File.open(filename, 'w') do |f|
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.write`.
        f.write(<<~EOS +
          content
        EOS
          bar)
      end, baz)
    RUBY

    expect_correction(<<~RUBY)
      foo(File.write(filename, <<~EOS +
          content
        EOS
          bar), baz)
    RUBY
  end

  it 'registers an offense for and corrects the `File.open` with a heredoc nested in the body of another heredoc' do
    expect_offense(<<~'RUBY')
      foo(File.open(filename, 'w') do |f|
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.write`.
        f.write(<<~OUTER)
          content #{<<~INNER}
            inner
          INNER
        OUTER
      end, bar)
    RUBY

    expect_correction(<<~'RUBY')
      foo(File.write(filename, <<~OUTER), bar)
          content #{<<~INNER}
            inner
          INNER
        OUTER
    RUBY
  end

  it 'registers an offense but does not correct when a literal after the `File.open` with a heredoc continues on the next line' do
    expect_offense(<<~RUBY)
      foo(File.open(filename, 'w') do |f|
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.write`.
        f.write(<<~EOS)
          content
        EOS
      end, %w[
        bar baz
      ])
    RUBY

    expect_no_corrections
  end

  it 'registers an offense for and corrects the `File.open` with a heredoc in an interpolation of a multiline string' do
    expect_offense(<<~'RUBY')
      x = "a #{
        File.open(filename, 'w') do |f|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.write`.
          f.write(<<~EOS)
            content
          EOS
        end
      } b"
    RUBY

    expect_correction(<<~'RUBY')
      x = "a #{
        File.write(filename, <<~EOS)
            content
          EOS
      } b"
    RUBY
  end

  it 'registers an offense but does not correct when the string around the `File.open` with a heredoc continues on the next line' do
    expect_offense(<<~'RUBY')
      x = "a #{File.open(filename, 'w') do |f|
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.write`.
        f.write(<<~EOS)
          content
        EOS
      end} b
      c"
    RUBY

    expect_no_corrections
  end

  it 'registers an offense but does not correct when the `File.open` contains the body of a heredoc opened before it' do
    expect_offense(<<~RUBY)
      foo(<<~A, File.open(filename, 'w') do |f|
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `File.write`.
        a
      A
        f.write(content)
      end)
    RUBY

    expect_no_corrections
  end
end
