# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::MissingCopEnableDirective, :config do
  context 'when the maximum range size is infinite' do
    let(:cop_config) { { 'MaximumRangeSize' => Float::INFINITY } }
    let(:other_cops) { { 'Layout/SpaceAroundOperators' => { 'Enabled' => true } } }

    it 'registers an offense when a cop is disabled and never re-enabled' do
      expect_offense(<<~RUBY)
        # rubocop:disable Layout/SpaceAroundOperators
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Re-enable Layout/SpaceAroundOperators cop with `# rubocop:enable` after disabling it.
        x =   0
        # Some other code
      RUBY
    end

    it 'does not register an offense when the disable cop is re-enabled' do
      expect_no_offenses(<<~RUBY)
        # rubocop:disable Layout/SpaceAroundOperators
        x =   0
        # rubocop:enable Layout/SpaceAroundOperators
        # Some other code
      RUBY
    end

    it 'registers an offense when a department is disabled and never re-enabled' do
      expect_offense(<<~RUBY)
        # rubocop:disable Layout
        ^^^^^^^^^^^^^^^^^^^^^^^^ Re-enable Layout department with `# rubocop:enable` after disabling it.
        x =   0
        # Some other code
      RUBY
    end

    it 'does not register an offense when the disable department is re-enabled' do
      expect_no_offenses(<<~RUBY)
        # rubocop:disable Layout
        x =   0
        # rubocop:enable Layout
        # Some other code
      RUBY
    end
  end

  context 'when the maximum range size is finite' do
    let(:cop_config) { { 'MaximumRangeSize' => 2 } }

    it 'registers an offense when a cop is disabled for too many lines' do
      expect_offense(<<~RUBY)
        # rubocop:disable Layout/SpaceAroundOperators
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Re-enable Layout/SpaceAroundOperators cop within 2 lines after disabling it.
        x =   0
        y = 1
        # Some other code
        # rubocop:enable Layout/SpaceAroundOperators
      RUBY
    end

    it 'registers an offense when a cop is disabled and never re-enabled' do
      expect_offense(<<~RUBY)
        # rubocop:disable Layout/SpaceAroundOperators
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Re-enable Layout/SpaceAroundOperators cop within 2 lines after disabling it.
        x =   0
        # Some other code
      RUBY
    end

    it 'does not register an offense when the disable cop is re-enabled within the limit' do
      expect_no_offenses(<<~RUBY)
        # rubocop:disable Layout/SpaceAroundOperators
        x =   0
        y = 1
        # rubocop:enable Layout/SpaceAroundOperators
        # Some other code
      RUBY
    end

    it 'registers an offense when a department is disabled for too many lines' do
      expect_offense(<<~RUBY)
        # rubocop:disable Layout
        ^^^^^^^^^^^^^^^^^^^^^^^^ Re-enable Layout department within 2 lines after disabling it.
        x =   0
        y = 1
        # Some other code
        # rubocop:enable Layout
      RUBY
    end

    it 'registers an offense when a department is disabled and never re-enabled' do
      expect_offense(<<~RUBY)
        # rubocop:disable Layout
        ^^^^^^^^^^^^^^^^^^^^^^^^ Re-enable Layout department within 2 lines after disabling it.
        x =   0
        # Some other code
      RUBY
    end

    it 'does not register an offense when the disable department is re-enabled within the limit' do
      expect_no_offenses(<<~RUBY)
        # rubocop:disable Layout
        x =   0
        y = 1
        # rubocop:enable Layout
        # Some other code
      RUBY
    end
  end

  context 'when the cop is disabled in the config' do
    let(:other_cops) { { 'Layout/LineLength' => { 'Enabled' => false } } }

    it 'reports no offense when re-disabling it until EOF' do
      expect_no_offenses(<<~RUBY)
        # rubocop:enable Layout/LineLength
        # rubocop:disable Layout/LineLength
      RUBY
    end
  end

  context 'when AllowDisablesAtFileStart is true' do
    let(:cop_config) { { 'MaximumRangeSize' => Float::INFINITY, 'AllowDisablesAtFileStart' => true } }

    it 'does not register an offense when disable is on the first line' do
      expect_no_offenses(<<~RUBY)
        # rubocop:disable Layout/SpaceAroundOperators
        x =   0
        y = 1
      RUBY
    end

    it 'does not register an offense when disable is after blank lines' do
      expect_no_offenses(<<~RUBY)


        # rubocop:disable Layout/SpaceAroundOperators
        x =   0
        y = 1
      RUBY
    end

    it 'does not register an offense when disable is after comments' do
      expect_no_offenses(<<~RUBY)
        # frozen_string_literal: true
        # Some file comment
        # rubocop:disable Layout/SpaceAroundOperators
        x =   0
        y = 1
      RUBY
    end

    it 'does not register an offense when disable is after comments and blank lines' do
      expect_no_offenses(<<~RUBY)
        # frozen_string_literal: true

        # Some file comment

        # rubocop:disable Layout/SpaceAroundOperators
        x =   0
        y = 1
      RUBY
    end

    it 'registers an offense when disable is after code' do
      expect_offense(<<~RUBY)
        x = 1
        # rubocop:disable Layout/SpaceAroundOperators
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Re-enable Layout/SpaceAroundOperators cop with `# rubocop:enable` after disabling it.
        y =   2
      RUBY
    end

    it 'registers an offense when disable is in the middle of the file' do
      expect_offense(<<~RUBY)
        # frozen_string_literal: true
        x = 1
        # rubocop:disable Layout/SpaceAroundOperators
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Re-enable Layout/SpaceAroundOperators cop with `# rubocop:enable` after disabling it.
        y =   2
      RUBY
    end

    it 'does not register an offense for department disable at file start' do
      expect_no_offenses(<<~RUBY)
        # rubocop:disable Layout
        x =   0
        y = 1
      RUBY
    end

    it 'registers an offense for department disable after code' do
      expect_offense(<<~RUBY)
        x = 1
        # rubocop:disable Layout
        ^^^^^^^^^^^^^^^^^^^^^^^^ Re-enable Layout department with `# rubocop:enable` after disabling it.
        y =   2
      RUBY
    end
  end

  context 'when AllowDisablesAtFileStart is false' do
    let(:cop_config) { { 'MaximumRangeSize' => Float::INFINITY, 'AllowDisablesAtFileStart' => false } }

    it 'registers an offense when disable is on the first line' do
      expect_offense(<<~RUBY)
        # rubocop:disable Layout/SpaceAroundOperators
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Re-enable Layout/SpaceAroundOperators cop with `# rubocop:enable` after disabling it.
        x =   0
        y = 1
      RUBY
    end

    it 'registers an offense when disable is after comments' do
      expect_offense(<<~RUBY)
        # frozen_string_literal: true
        # rubocop:disable Layout/SpaceAroundOperators
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Re-enable Layout/SpaceAroundOperators cop with `# rubocop:enable` after disabling it.
        x =   0
        y = 1
      RUBY
    end
  end
end
