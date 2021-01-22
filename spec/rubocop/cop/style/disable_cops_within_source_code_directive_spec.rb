# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::DisableCopsWithinSourceCodeDirective, :config do
  it 'registers an offense for disabled cop within source code' do
    expect_offense(<<~RUBY)
      def foo # rubocop:disable Metrics/CyclomaticComplexity
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Rubocop disable/enable directives are not permitted.
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo#{trailing_whitespace}
      end
    RUBY
  end

  it 'registers an offense for enabled cop within source code' do
    expect_offense(<<~RUBY)
      def foo # rubocop:enable Metrics/CyclomaticComplexity
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Rubocop disable/enable directives are not permitted.
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo#{trailing_whitespace}
      end
    RUBY
  end

  it 'registers an offense for disabling all cops' do
    expect_offense(<<~RUBY)
      def foo # rubocop:enable all
              ^^^^^^^^^^^^^^^^^^^^ Rubocop disable/enable directives are not permitted.
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo#{trailing_whitespace}
      end
    RUBY
  end

  context 'with AllowedCops' do
    let(:cop_config) { { 'AllowedCops' => ['Metrics/CyclomaticComplexity', 'Metrics/AbcSize'] } }

    context 'when an allowed cop is disabled' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          def foo # rubocop:disable Metrics/CyclomaticComplexity
          end
        RUBY
      end
    end

    context 'when an non-allowed cop is disabled' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          def foo # rubocop:disable Layout/LineLength
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Rubocop disable/enable directives for `Layout/LineLength` are not permitted.
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo#{trailing_whitespace}
          end
        RUBY
      end
    end

    context 'when an mix of cops are disabled' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          def foo # rubocop:disable Metrics/AbcSize, Layout/LineLength, Metrics/CyclomaticComplexity, Style/AndOr
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Rubocop disable/enable directives for `Layout/LineLength`, `Style/AndOr` are not permitted.
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
          end
        RUBY
      end
    end
  end
end
