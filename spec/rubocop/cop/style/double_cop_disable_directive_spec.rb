# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::DoubleCopDisableDirective do
  subject(:cop) { described_class.new }

  it 'registers an offense when using `#bad_method`' do
    expect_offense(<<~RUBY)
      def choose_move(who_to_move) # rubocop:disable Metrics/CyclomaticComplexity # rubocop:disable Metrics/AbcSize # rubocop:disable Metrics/MethodLength
                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ More than one disable comment on one line.
      end
    RUBY
    expect_correction(<<~RUBY)
      def choose_move(who_to_move) # rubocop:disable Metrics/CyclomaticComplexity
      end
    RUBY
  end

  it 'does not register an offense when using `#good_method`' do
    expect_no_offenses(<<~RUBY)
      def choose_move(who_to_move) # rubocop:disable Metrics/CyclomaticComplexity
      end
    RUBY
  end
end
