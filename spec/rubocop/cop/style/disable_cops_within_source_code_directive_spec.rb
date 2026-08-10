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

    context 'when the same disallowed cop is named twice in one directive' do
      it 'reports it once and removes the whole directive' do
        expect_offense(<<~RUBY)
          foo # rubocop:disable Lint/Void, Lint/Void
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RuboCop disable/enable directives for `Lint/Void` are not permitted.
        RUBY

        expect_correction(<<~RUBY)
          foo#{trailing_whitespace}
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

    context 'when disabling all cops' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          foo # rubocop:disable all
              ^^^^^^^^^^^^^^^^^^^^^ RuboCop disable/enable directives for `all` are not permitted.
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

  context 'when both AllowedCops and DisallowedCops are set' do
    let(:cop_config) do
      { 'AllowedCops' => ['Lint/Void'], 'DisallowedCops' => ['Security/Eval'] }
    end

    it 'gives DisallowedCops precedence and ignores AllowedCops' do
      expect_offense(<<~RUBY)
        foo # rubocop:disable Lint/Void, Security/Eval
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RuboCop disable/enable directives for `Security/Eval` are not permitted.
      RUBY

      expect_correction(<<~RUBY)
        foo # rubocop:disable Lint/Void
      RUBY
    end
  end

  context 'when a directive tries to disable this cop' do
    it 'registers an offense for the self-disabling directive and remains active' do
      expect_offense(<<~RUBY)
        # rubocop:disable Style/DisableCopsWithinSourceCodeDirective
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RuboCop disable/enable directives are not permitted.
        def foo # rubocop:disable Metrics/CyclomaticComplexity
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RuboCop disable/enable directives are not permitted.
        end
      RUBY

      expect_correction(<<~RUBY)

        def foo#{trailing_whitespace}
        end
      RUBY
    end

    it 'registers an offense when disabling all cops and remains active' do
      expect_offense(<<~RUBY)
        # rubocop:disable all
        ^^^^^^^^^^^^^^^^^^^^^ RuboCop disable/enable directives are not permitted.
        def foo # rubocop:disable Metrics/CyclomaticComplexity
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RuboCop disable/enable directives are not permitted.
        end
      RUBY

      expect_correction(<<~RUBY)

        def foo#{trailing_whitespace}
        end
      RUBY
    end

    it 'registers an offense for disabling via department directive and remains active' do
      expect_offense(<<~RUBY)
        # rubocop:disable Style
        ^^^^^^^^^^^^^^^^^^^^^^^ RuboCop disable/enable directives are not permitted.
        def foo # rubocop:disable Metrics/CyclomaticComplexity
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RuboCop disable/enable directives are not permitted.
        end
      RUBY

      expect_correction(<<~RUBY)

        def foo#{trailing_whitespace}
        end
      RUBY
    end
  end

  it 'registers an offense and corrects a `disable-next` directive' do
    expect_offense(<<~RUBY)
      # rubocop:disable-next Metrics/AbcSize
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RuboCop disable/enable directives are not permitted.
      def foo
      end
    RUBY

    expect_correction(<<~RUBY)

      def foo
      end
    RUBY
  end

  context 'when AllowTrailingComment is true' do
    let(:cop_config) { { 'AllowTrailingComment' => true } }

    it 'does not register an offense for a `disable-next` with a justification' do
      expect_no_offenses(<<~RUBY)
        # rubocop:disable-next Metrics/AbcSize -- legacy method
        def foo
        end
      RUBY
    end

    it 'registers an offense for a disable directive without a justification' do
      expect_offense(<<~RUBY)
        x = 0 # rubocop:disable Layout/SpaceAroundOperators
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RuboCop disable directives without a `--` justification comment are not permitted.
      RUBY

      expect_correction(<<~RUBY)
        x = 0#{trailing_whitespace}
      RUBY
    end

    it 'does not register an offense for a disable directive with a justification' do
      expect_no_offenses(<<~RUBY)
        x = 0 # rubocop:disable Layout/SpaceAroundOperators -- aligning with the table below
      RUBY
    end

    it 'does not register an offense for an enable directive closing a justified disable' do
      expect_no_offenses(<<~RUBY)
        # rubocop:disable Metrics/AbcSize -- legacy method, tracked in JIRA-123
        def foo
        end
        # rubocop:enable Metrics/AbcSize
      RUBY
    end

    it 'registers an offense for a `todo` directive without a justification' do
      expect_offense(<<~RUBY)
        x = 0 # rubocop:todo Layout/SpaceAroundOperators
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RuboCop disable directives without a `--` justification comment are not permitted.
      RUBY
    end

    context 'combined with AllowedCops' do
      let(:cop_config) do
        { 'AllowTrailingComment' => true, 'AllowedCops' => ['Metrics/AbcSize'] }
      end

      it 'does not register an offense for an allowed cop without a justification' do
        expect_no_offenses(<<~RUBY)
          # rubocop:disable Metrics/AbcSize
          def foo
          end
          # rubocop:enable Metrics/AbcSize
        RUBY
      end

      it 'registers an offense for a non-allowed cop without a justification' do
        expect_offense(<<~RUBY)
          def foo # rubocop:disable Metrics/CyclomaticComplexity
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RuboCop disable directives without a `--` justification comment are not permitted.
          end
        RUBY
      end
    end
  end
end
