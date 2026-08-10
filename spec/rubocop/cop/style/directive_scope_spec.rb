# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::DirectiveScope, :config do
  it 'registers an offense and corrects a `disable`/`enable` pair around one statement' do
    expect_offense(<<~RUBY)
      # rubocop:disable Metrics/AbcSize
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `disable-next` instead of a `disable`/`enable` pair around a single statement.
      def foo
        bar
      end
      # rubocop:enable Metrics/AbcSize
    RUBY

    expect_correction(<<~RUBY)
      # rubocop:disable-next Metrics/AbcSize
      def foo
        bar
      end
    RUBY
  end

  it 'registers an offense and corrects a `todo`/`enable` pair, keeping the reason' do
    expect_offense(<<~RUBY)
      # rubocop:todo Metrics/AbcSize, Metrics/MethodLength -- legacy method
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `todo-next` instead of a `todo`/`enable` pair around a single statement.
      def foo
        bar
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    RUBY

    expect_correction(<<~RUBY)
      # rubocop:todo-next Metrics/AbcSize, Metrics/MethodLength -- legacy method
      def foo
        bar
      end
    RUBY
  end

  it 'registers an offense and corrects a disable-only `push`/`pop` around one statement' do
    expect_offense(<<~RUBY)
      # rubocop:push -Metrics/AbcSize -- special case
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `disable-next` instead of `push`/`pop` around a single statement.
      def foo
        bar
      end
      # rubocop:pop
    RUBY

    expect_correction(<<~RUBY)
      # rubocop:disable-next Metrics/AbcSize -- special case
      def foo
        bar
      end
    RUBY
  end

  it 'does not register an offense when the pair wraps several statements' do
    expect_no_offenses(<<~RUBY)
      # rubocop:disable Metrics/AbcSize
      def foo
      end

      def bar
      end
      # rubocop:enable Metrics/AbcSize
    RUBY
  end

  it 'does not register an offense when the `enable` closes only some of the cops' do
    expect_no_offenses(<<~RUBY)
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def foo
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
    RUBY
  end

  it 'does not register an offense for an end-of-line disable' do
    expect_no_offenses(<<~RUBY)
      foo # rubocop:disable Metrics/AbcSize
    RUBY
  end

  it 'does not register an offense for an unclosed disable' do
    expect_no_offenses(<<~RUBY)
      # rubocop:disable Metrics/AbcSize
      def foo
      end
    RUBY
  end

  it 'does not register an offense for a `push` that also enables cops' do
    expect_no_offenses(<<~RUBY)
      # rubocop:push -Metrics/AbcSize +Style/For
      def foo
      end
      # rubocop:pop
    RUBY
  end

  it 'does not register an offense for a bare `push`' do
    expect_no_offenses(<<~RUBY)
      # rubocop:push
      # rubocop:disable Metrics/AbcSize
      def foo
      end
      # rubocop:pop
    RUBY
  end

  it 'does not register an offense for an already tight `disable-next`' do
    expect_no_offenses(<<~RUBY)
      # rubocop:disable-next Metrics/AbcSize
      def foo
      end
    RUBY
  end

  it 'does not register an offense when other lines sit inside the region' do
    expect_no_offenses(<<~RUBY)
      # rubocop:disable Metrics/AbcSize
      def foo
        bar
      end

      # rubocop:enable Metrics/AbcSize
    RUBY
  end

  it 'does not register an offense when a comment sits between the directive and the statement' do
    expect_no_offenses(<<~RUBY)
      # rubocop:disable Layout/LineLength
      # some comment the pair may be protecting
      def foo
        bar
      end
      # rubocop:enable Layout/LineLength
    RUBY
  end
end
