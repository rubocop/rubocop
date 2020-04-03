# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::DisableCopsWithinSourceCodeDirective do
  subject(:cop) { described_class.new }

  it 'registers an offense for disabled cop within source code' do
    expect_offense(<<~RUBY)
      def choose_move(who_to_move)# rubocop:disable Metrics/CyclomaticComplexity
                                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Comment to disable/enable RuboCop.
      end
    RUBY
    expect_correction(<<~RUBY)
      def choose_move(who_to_move)
      end
    RUBY
  end

  it 'registers an offense for enabled cop within source code' do
    expect_offense(<<~RUBY)
      def choose_move(who_to_move)# rubocop:enable Metrics/CyclomaticComplexity
                                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Comment to disable/enable RuboCop.
      end
    RUBY
    expect_correction(<<~RUBY)
      def choose_move(who_to_move)
      end
    RUBY
  end
end
