# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::DoubleCopDisableDirective, :config do
  it 'registers an offense for duplicate disable directives' do
    expect_offense(<<~RUBY)
      def choose_move(who_to_move) # rubocop:disable Metrics/CyclomaticComplexity # rubocop:disable Metrics/AbcSize # rubocop:disable Metrics/MethodLength
                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ More than one disable comment on one line.
      end
    RUBY

    expect_correction(<<~RUBY)
      def choose_move(who_to_move) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength
      end
    RUBY
  end

  it 'registers an offense for duplicate todo directives' do
    expect_offense(<<~RUBY)
      def choose_move(who_to_move) # rubocop:todo Metrics/CyclomaticComplexity # rubocop:todo Metrics/AbcSize # rubocop:todo Metrics/MethodLength
                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ More than one disable comment on one line.
      end
    RUBY

    expect_correction(<<~RUBY)
      def choose_move(who_to_move) # rubocop:todo Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength
      end
    RUBY
  end

  it 'does not register an offense for cops with single cop directive' do
    expect_no_offenses(<<~RUBY)
      def choose_move(who_to_move) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize
      end
    RUBY
  end
end
