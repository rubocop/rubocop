# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::MissingCopDisableReason, :config do
  it 'registers an offense when a `disable` directive has no reason' do
    expect_offense(<<~RUBY)
      # rubocop:disable Style/For
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add a `--` comment explaining why the cops are disabled.
      for x in [1, 2] do puts x end
      # rubocop:enable Style/For
    RUBY
  end

  it 'registers an offense for a trailing `disable` directive with no reason' do
    expect_offense(<<~RUBY)
      x = 1 # rubocop:disable Style/For
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add a `--` comment explaining why the cops are disabled.
    RUBY
  end

  it 'registers an offense when disabling all cops without a reason' do
    expect_offense(<<~RUBY)
      # rubocop:disable all
      ^^^^^^^^^^^^^^^^^^^^^ Add a `--` comment explaining why the cops are disabled.
      x = 1
      # rubocop:enable all
    RUBY
  end

  it 'registers an offense when a `disable-next` directive has no reason' do
    expect_offense(<<~RUBY)
      # rubocop:disable-next Style/For
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add a `--` comment explaining why the cops are disabled.
      for x in [1, 2] do puts x end
    RUBY
  end

  it 'registers an offense when a `next` directive disables a cop without a reason' do
    expect_offense(<<~RUBY)
      # rubocop:next -Style/For
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Add a `--` comment explaining why the cops are disabled.
      for x in [1, 2] do puts x end
    RUBY
  end

  it 'registers an offense when a `push` directive disables a cop without a reason' do
    expect_offense(<<~RUBY)
      # rubocop:push -Style/For
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Add a `--` comment explaining why the cops are disabled.
      for x in [1, 2] do puts x end
      # rubocop:pop
    RUBY
  end

  it 'registers an offense for each directive that is missing a reason' do
    expect_offense(<<~RUBY)
      # rubocop:disable Style/For
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add a `--` comment explaining why the cops are disabled.
      for x in [1, 2] do puts x end
      # rubocop:enable Style/For
      # rubocop:disable Style/While
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add a `--` comment explaining why the cops are disabled.
      while false do puts 1 end
      # rubocop:enable Style/While
    RUBY
  end

  it 'does not register an offense when the directive has a reason' do
    expect_no_offenses(<<~RUBY)
      # rubocop:disable Style/For -- the index is used after the loop
      for x in [1, 2] do puts x end
      # rubocop:enable Style/For
    RUBY
  end

  it 'does not register an offense for a `disable-next` directive with a reason' do
    expect_no_offenses(<<~RUBY)
      # rubocop:disable-next Style/For -- the index is used after the loop
      for x in [1, 2] do puts x end
    RUBY
  end

  it 'does not register an offense for `todo` directives' do
    expect_no_offenses(<<~RUBY)
      # rubocop:todo Style/For
      for x in [1, 2] do puts x end
      # rubocop:enable Style/For
    RUBY
  end

  it 'does not register an offense for `todo-next` directives' do
    expect_no_offenses(<<~RUBY)
      # rubocop:todo-next Style/For
      for x in [1, 2] do puts x end
    RUBY
  end

  it 'does not register an offense for a `pop` directive' do
    expect_no_offenses(<<~RUBY)
      # rubocop:push +Style/For -- re-enable it for this section
      x = 1
      # rubocop:pop
    RUBY
  end

  it 'does not register an offense for a `push` directive that only enables cops' do
    expect_no_offenses(<<~RUBY)
      # rubocop:push +Style/For
      x = 1
      # rubocop:pop
    RUBY
  end

  it 'leaves malformed directives to `Lint/CopDirectiveSyntax`' do
    expect_no_offenses(<<~RUBY)
      # rubocop:disable Style/For this is not a reason
      for x in [1, 2] do puts x end
    RUBY
  end

  it 'is not silenced by a directive that disables its own department' do
    expect_offense(<<~RUBY)
      # rubocop:disable Lint
      ^^^^^^^^^^^^^^^^^^^^^^ Add a `--` comment explaining why the cops are disabled.
      x = 1
      # rubocop:enable Lint
    RUBY
  end

  context 'with AllowedCops' do
    let(:cop_config) { { 'AllowedCops' => ['Metrics', 'Style/For'] } }

    it 'does not register an offense when every disabled cop is exempt by department' do
      expect_no_offenses(<<~RUBY)
        def parse(input) # rubocop:disable Metrics/AbcSize
        end
      RUBY
    end

    it 'does not register an offense when every disabled cop is exempt by name' do
      expect_no_offenses(<<~RUBY)
        # rubocop:disable Style/For
        for x in [1, 2] do puts x end
        # rubocop:enable Style/For
      RUBY
    end

    it 'does not register an offense for a whole exempt department' do
      expect_no_offenses(<<~RUBY)
        def parse(input) # rubocop:disable Metrics
        end
      RUBY
    end

    it 'registers an offense when a whole department is disabled but only one of its cops is exempt' do
      cop_config['AllowedCops'] = ['Metrics/AbcSize']

      expect_offense(<<~RUBY)
        # rubocop:disable Metrics
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Add a `--` comment explaining why the cops are disabled.
        def parse(input)
        end
        # rubocop:enable Metrics
      RUBY
    end

    it 'registers an offense when one of the disabled cops is not exempt' do
      expect_offense(<<~RUBY)
        def parse(input) # rubocop:disable Metrics/AbcSize, Style/While
                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add a `--` comment explaining why the cops are disabled.
        end
      RUBY
    end

    it 'registers an offense for a blanket disable, which is never exempt' do
      expect_offense(<<~RUBY)
        # rubocop:disable all
        ^^^^^^^^^^^^^^^^^^^^^ Add a `--` comment explaining why the cops are disabled.
        x = 1
        # rubocop:enable all
      RUBY
    end

    it 'exempts a `next` directive that only disables exempt cops' do
      expect_no_offenses(<<~RUBY)
        # rubocop:next -Style/For
        for x in [1, 2] do puts x end
      RUBY
    end

    it 'registers an offense for a `next` directive disabling a cop that is not exempt' do
      expect_offense(<<~RUBY)
        # rubocop:next -Style/While
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add a `--` comment explaining why the cops are disabled.
        while false do puts 1 end
      RUBY
    end
  end

  it 'does not register an offense for ordinary comments' do
    expect_no_offenses(<<~RUBY)
      # This mentions rubocop but disables nothing.
      x = 1
    RUBY
  end
end
