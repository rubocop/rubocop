# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::RedundantSourceRange, :config do
  it 'registers an offense when using `node.source_range.source`' do
    expect_offense(<<~RUBY)
      node.source_range.source
           ^^^^^^^^^^^^ Remove the redundant `source_range`.
    RUBY

    expect_correction(<<~RUBY)
      node.source
    RUBY
  end

  it 'does not register an offense when using `node.source`' do
    expect_no_offenses(<<~RUBY)
      node.source
    RUBY
  end

  it 'registers an offense when using `corrector.replace(node.source_range, content)`' do
    expect_offense(<<~RUBY)
      add_offense do |corrector|
        corrector.replace(node.source_range, content)
                               ^^^^^^^^^^^^ Remove the redundant `source_range`.
      end
    RUBY

    expect_correction(<<~RUBY)
      add_offense do |corrector|
        corrector.replace(node, content)
      end
    RUBY
  end

  it 'registers an offense when using `corrector.remove(node.source_range)`' do
    expect_offense(<<~RUBY)
      add_offense do |corrector|
        corrector.remove(node.source_range)
                              ^^^^^^^^^^^^ Remove the redundant `source_range`.
      end
    RUBY

    expect_correction(<<~RUBY)
      add_offense do |corrector|
        corrector.remove(node)
      end
    RUBY
  end

  it 'registers an offense when using `corrector.insert_before(node.source_range, content)`' do
    expect_offense(<<~RUBY)
      add_offense do |corrector|
        corrector.insert_before(node.source_range, content)
                                     ^^^^^^^^^^^^ Remove the redundant `source_range`.
      end
    RUBY

    expect_correction(<<~RUBY)
      add_offense do |corrector|
        corrector.insert_before(node, content)
      end
    RUBY
  end

  it 'registers an offense when using `corrector.insert_before_multi(node.source_range, content)`' do
    expect_offense(<<~RUBY)
      add_offense do |corrector|
        corrector.insert_before_multi(node.source_range, content)
                                           ^^^^^^^^^^^^ Remove the redundant `source_range`.
      end
    RUBY

    expect_correction(<<~RUBY)
      add_offense do |corrector|
        corrector.insert_before_multi(node, content)
      end
    RUBY
  end

  it 'registers an offense when using `corrector.insert_after(node.source_range, content)`' do
    expect_offense(<<~RUBY)
      add_offense do |corrector|
        corrector.insert_after(node.source_range, content)
                                    ^^^^^^^^^^^^ Remove the redundant `source_range`.
      end
    RUBY

    expect_correction(<<~RUBY)
      add_offense do |corrector|
        corrector.insert_after(node, content)
      end
    RUBY
  end

  it 'registers an offense when using `corrector.insert_after_multi(node.source_range, content)`' do
    expect_offense(<<~RUBY)
      add_offense do |corrector|
        corrector.insert_after_multi(node.source_range, content)
                                          ^^^^^^^^^^^^ Remove the redundant `source_range`.
      end
    RUBY

    expect_correction(<<~RUBY)
      add_offense do |corrector|
        corrector.insert_after_multi(node, content)
      end
    RUBY
  end

  it 'registers an offense when using `corrector.swap(node.source_range, before, after)`' do
    expect_offense(<<~RUBY)
      add_offense do |corrector|
        corrector.swap(node.source_range, before, after)
                            ^^^^^^^^^^^^ Remove the redundant `source_range`.
      end
    RUBY

    expect_correction(<<~RUBY)
      add_offense do |corrector|
        corrector.swap(node, before, after)
      end
    RUBY
  end

  it 'registers an offense when using `lvar.source_range`' do
    expect_offense(<<~RUBY)
      def foo(corrector, lvar)
        corrector.insert_after(lvar.source_range, content)
                                    ^^^^^^^^^^^^ Remove the redundant `source_range`.
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo(corrector, lvar)
        corrector.insert_after(lvar, content)
      end
    RUBY
  end

  it 'does not register an offense when using `corrector.replace(node, content)`' do
    expect_no_offenses(<<~RUBY)
      add_offense do |corrector|
        corrector.replace(node, content)
      end
    RUBY
  end

  it 'does not register an offense when using `processed_source.buffer.source_range`' do
    expect_no_offenses(<<~RUBY)
      add_offense do |corrector|
        corrector.insert_before(processed_source.buffer.source_range, preceding_comment)
      end
    RUBY
  end
end
