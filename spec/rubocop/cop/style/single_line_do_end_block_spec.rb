# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SingleLineDoEndBlock, :config do
  it 'registers an offense when using single line `do`...`end`' do
    expect_offense(<<~RUBY)
      foo do bar end
      ^^^^^^^^^^^^^^ Prefer multiline `do`...`end` block.
    RUBY

    expect_correction(<<~RUBY)
      foo do
       bar#{' '}
      end
    RUBY
  end

  it 'registers an offense when using single line `do`...`end` with no body' do
    expect_offense(<<~RUBY)
      foo do end
      ^^^^^^^^^^ Prefer multiline `do`...`end` block.
    RUBY

    expect_correction(<<~RUBY)
      foo do
      #{' '}
      end
    RUBY
  end

  it 'registers an offense when using single line `do`...`end` with block argument' do
    expect_offense(<<~RUBY)
      foo do |arg| bar(arg) end
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer multiline `do`...`end` block.
    RUBY

    expect_correction(<<~RUBY)
      foo do |arg|
       bar(arg)#{' '}
      end
    RUBY
  end

  it 'registers an offense when using single line `do`...`end` with numbered block argument' do
    expect_offense(<<~RUBY)
      foo do bar(_1) end
      ^^^^^^^^^^^^^^^^^^ Prefer multiline `do`...`end` block.
    RUBY

    expect_correction(<<~RUBY)
      foo do
       bar(_1)#{' '}
      end
    RUBY
  end

  it 'registers an offense when using single line `do`...`end` with `it` block argument', :ruby34 do
    expect_offense(<<~RUBY)
      foo do bar(it) end
      ^^^^^^^^^^^^^^^^^^ Prefer multiline `do`...`end` block.
    RUBY

    expect_correction(<<~RUBY)
      foo do
       bar(it)#{' '}
      end
    RUBY
  end

  it 'registers an offense when using single line `do`...`end` with heredoc body' do
    expect_offense(<<~RUBY)
      foo do <<~EOS end
      ^^^^^^^^^^^^^^^^^ Prefer multiline `do`...`end` block.
        text
      EOS
    RUBY

    expect_correction(<<~RUBY)
      foo do
       <<~EOS#{' '}
        text
      EOS
      end
    RUBY
  end

  it 'registers an offense when using single line `do`...`end` with `->` block' do
    expect_offense(<<~RUBY)
      ->(arg) do foo arg end
      ^^^^^^^^^^^^^^^^^^^^^^ Prefer multiline `do`...`end` block.
    RUBY

    expect_correction(<<~RUBY)
      ->(arg) do
       foo arg#{' '}
      end
    RUBY
  end

  it 'registers an offense when using single line `do`...`end` with `lambda` block' do
    expect_offense(<<~RUBY)
      lambda do |arg| foo(arg) end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer multiline `do`...`end` block.
    RUBY

    expect_correction(<<~RUBY)
      lambda do |arg|
       foo(arg)#{' '}
      end
    RUBY
  end

  it 'does not register an offense when using multiline `do`...`end`' do
    expect_no_offenses(<<~RUBY)
      foo do
        bar
      end
    RUBY
  end

  it 'does not register an offense when using single line `{`...`}`' do
    expect_no_offenses(<<~RUBY)
      foo { bar }
    RUBY
  end

  context 'when `Layout/LineLength` is disabled' do
    let(:other_cops) { { 'Layout/LineLength' => { 'Enabled' => false } } }

    it 'registers an offense when using single line `do`...`end`' do
      expect_offense(<<~RUBY)
        foo do bar end
        ^^^^^^^^^^^^^^ Prefer multiline `do`...`end` block.
      RUBY

      expect_correction(<<~RUBY)
        foo do
         bar#{' '}
        end
      RUBY
    end
  end

  context 'when `Layout/RedundantLineBreak` is enabled with `InspectBlocks: true`' do
    let(:other_cops) do
      {
        'Layout/RedundantLineBreak' => { 'Enabled' => true, 'InspectBlocks' => true },
        'Layout/LineLength' => { 'Max' => 20 }
      }
    end

    context 'when a block fits on a single line' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          a do b end
        RUBY
      end
    end

    context 'when the block does not fit on a single line' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          aaaaaaaaaaaa do bbbbbbbbbbbbb end
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer multiline `do`...`end` block.
        RUBY

        expect_correction(<<~RUBY)
          aaaaaaaaaaaa do
           bbbbbbbbbbbbb#{' '}
          end
        RUBY
      end
    end
  end
end
