# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::DisableCopsWithinSourceCodeDirective, :config do
  it 'registers an offense for disabled cop within source code' do
    expect_offense(<<~RUBY)
      def foo # rubocop:disable Metrics/CyclomaticComplexity
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RuboCop disable/enable directives are not permitted.
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
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RuboCop disable/enable directives are not permitted.
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
              ^^^^^^^^^^^^^^^^^^^^ RuboCop disable/enable directives are not permitted.
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

    context 'when a non-allowed cop is disabled' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          def foo # rubocop:disable Layout/LineLength
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RuboCop disable/enable directives for `Layout/LineLength` are not permitted.
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo#{trailing_whitespace}
          end
        RUBY
      end
    end

    context 'when a mix of cops are disabled' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          def foo # rubocop:disable Metrics/AbcSize, Layout/LineLength, Metrics/CyclomaticComplexity, Style/AndOr
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RuboCop disable/enable directives for `Layout/LineLength`, `Style/AndOr` are not permitted.
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
          end
        RUBY
      end
    end

    context 'when using leading source comment' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          # comment

          class Foo
          end
        RUBY
      end
    end
  end

  context 'with DisallowedCops' do
    let(:cop_config) { { 'DisallowedCops' => ['Lint/Void', 'Security/Eval'] } }

    context 'when a disallowed cop is disabled' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          foo # rubocop:disable Lint/Void
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^ RuboCop disable/enable directives for `Lint/Void` are not permitted.
        RUBY

        expect_correction(<<~RUBY)
          foo#{trailing_whitespace}
        RUBY
      end
    end

    context 'when a non-disallowed cop is disabled' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          def foo # rubocop:disable Metrics/AbcSize
          end
        RUBY
      end
    end

    context 'when enabling all cops' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          foo # rubocop:enable all
              ^^^^^^^^^^^^^^^^^^^^ RuboCop disable/enable directives for `all` are not permitted.
        RUBY

        expect_correction(<<~RUBY)
          foo#{trailing_whitespace}
        RUBY
      end
    end

    context 'when a mix of disallowed and non-disallowed cops are disabled' do
      it 'registers an offense only for the disallowed cops and corrects' do
        expect_offense(<<~RUBY)
          foo # rubocop:disable Metrics/AbcSize, Lint/Void, Style/AndOr
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RuboCop disable/enable directives for `Lint/Void` are not permitted.
        RUBY

        expect_correction(<<~RUBY)
          foo # rubocop:disable Metrics/AbcSize, Style/AndOr
        RUBY
      end
    end

    context 'when multiple disallowed cops are disabled along with allowed ones' do
      it 'registers an offense for all disallowed cops and corrects' do
        expect_offense(<<~RUBY)
          foo # rubocop:disable Lint/Void, Metrics/AbcSize, Security/Eval
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RuboCop disable/enable directives for `Lint/Void`, `Security/Eval` are not permitted.
        RUBY

        expect_correction(<<~RUBY)
          foo # rubocop:disable Metrics/AbcSize
        RUBY
      end
    end

    context 'when a non-disallowed cop is enabled' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          # rubocop:enable Metrics/AbcSize
        RUBY
      end
    end

    context 'when using leading source comment' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          # comment

          class Foo
          end
        RUBY
      end
    end
  end
end
