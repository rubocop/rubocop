# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MultilineBlockChain, :config do
  context 'with multi-line block chaining' do
    it 'registers an offense for a simple case' do
      expect_offense(<<~RUBY)
        a do
          b
        end.c do
        ^^^^^ Avoid multi-line chains of blocks.
          d
        end
      RUBY
    end

    it 'registers an offense for a slightly more complicated case' do
      expect_offense(<<~RUBY)
        a do
          b
        end.c1.c2 do
        ^^^^^^^^^ Avoid multi-line chains of blocks.
          d
        end
      RUBY
    end

    context 'Ruby 2.7', :ruby27 do
      it 'registers an offense for a slightly more complicated case' do
        expect_offense(<<~RUBY)
          a do
            _1
          end.c1.c2 do
          ^^^^^^^^^ Avoid multi-line chains of blocks.
            _1
          end
        RUBY
      end
    end

    it 'registers two offenses for a chain of three blocks' do
      expect_offense(<<~RUBY)
        a do
          b
        end.c do
        ^^^^^ Avoid multi-line chains of blocks.
          d
        end.e do
        ^^^^^ Avoid multi-line chains of blocks.
          f
        end
      RUBY
    end

    it 'registers an offense for a chain where the second block is single-line' do
      expect_offense(<<~RUBY)
        Thread.list.find_all { |t|
          t.alive?
        }.map { |thread| thread.object_id }
        ^^^^^ Avoid multi-line chains of blocks.
      RUBY
    end

    it 'accepts a chain where the first block is single-line' do
      expect_no_offenses(<<~RUBY)
        Thread.list.find_all { |t| t.alive? }.map { |t|
          t.object_id
        }
      RUBY
    end
  end

  it 'accepts a chain of blocks spanning one line' do
    expect_no_offenses(<<~RUBY)
      a { b }.c { d }
      w do x end.y do z end
    RUBY
  end

  it 'accepts a multi-line block chained with calls on one line' do
    expect_no_offenses(<<~RUBY)
      a do
        b
      end.c.d
    RUBY
  end

  it 'accepts a chain of calls followed by a multi-line block' do
    expect_no_offenses(<<~RUBY)
      a1.a2.a3 do
        b
      end
    RUBY
  end
end
