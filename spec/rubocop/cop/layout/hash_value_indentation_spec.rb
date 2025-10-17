# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::HashValueIndentation, :config do
  shared_examples 'hash alignment, hash rocket style offense' do
    it 'registers an offense for table hash style' do
      expect_offense(<<~RUBY)
        {
          only             => 'Run only the given cop(s).',
          only_guide_cops  =>
                              'Run only cops for rules that link to a style guide.',
                              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Indent hash value 2 spaces relative to hash key.
        }
      RUBY

      expect_correction(<<~RUBY)
        {
          only             => 'Run only the given cop(s).',
          only_guide_cops  =>
            'Run only cops for rules that link to a style guide.',
        }
      RUBY
    end
  end

  shared_examples 'hash alignment, hash rocket style accepted' do
    it 'does not register an offense for table hash style' do
      expect_no_offenses(<<~RUBY)
        {
          only             => 'Run only the given cop(s).',
          only_guide_cops  =>
                              'Run only cops for rules that link to a style guide.',
        }
      RUBY
    end
  end

  shared_examples 'hash alignment, colon style offense' do
    it 'registers an offense for table hash style' do
      expect_offense(<<~RUBY)
        {
          only:            'Run only the given cop(s).',
          only_guide_cops:
                           'Run only cops for rules that link to a style guide.',
                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Indent hash value 2 spaces relative to hash key.
        }
      RUBY

      expect_correction(<<~RUBY)
        {
          only:            'Run only the given cop(s).',
          only_guide_cops:
            'Run only cops for rules that link to a style guide.',
        }
      RUBY
    end
  end

  shared_examples 'hash alignment, colon style accepted' do
    it 'does not register an offense for table hash style' do
      expect_no_offenses(<<~RUBY)
        {
          only:            'Run only the given cop(s).',
          only_guide_cops:
                           'Run only cops for rules that link to a style guide.',
        }
      RUBY
    end
  end

  it 'registers an offense for hash value without indentation' do
    expect_offense(<<~RUBY)
      {
        foo:
        bar
        ^^^ Indent hash value 2 spaces relative to hash key.
      }
    RUBY

    expect_correction(<<~RUBY)
      {
        foo:
          bar
      }
    RUBY
  end

  it 'registers an offense for hash value with too much indentation' do
    expect_offense(<<~RUBY)
      {
        foo:
            bar
            ^^^ Indent hash value 2 spaces relative to hash key.
      }
    RUBY

    expect_correction(<<~RUBY)
      {
        foo:
          bar
      }
    RUBY
  end

  it 'registers an offense for hash value with dedentation' do
    expect_offense(<<~RUBY)
      {
        foo:
      bar
      ^^^ Indent hash value 2 spaces relative to hash key.
      }
    RUBY

    expect_correction(<<~RUBY)
      {
        foo:
          bar
      }
    RUBY
  end

  it 'registers an offense for multiline hash values' do
    expect_offense(<<~RUBY)
      {
        foo:
        (
        ^ Indent hash value 2 spaces relative to hash key.
          if foo
            bar
          else
            baz
          end
        )
      }
    RUBY

    expect_correction(<<~RUBY)
      {
        foo:
          (
            if foo
              bar
            else
              baz
            end
          )
      }
    RUBY
  end

  it 'registers an offense for hash rocket style' do
    expect_offense(<<~RUBY)
      {
        foo =>
        bar
        ^^^ Indent hash value 2 spaces relative to hash key.
      }
    RUBY

    expect_correction(<<~RUBY)
      {
        foo =>
          bar
      }
    RUBY
  end

  it 'does not register an offense when hash value is indented' do
    expect_no_offenses(<<~RUBY)
      {
        foo:
          bar
      }
    RUBY
  end

  it 'does not register an offense when hash value is on the same line as key' do
    expect_no_offenses(<<~RUBY)
      {
        foo: bar
      }
    RUBY
  end

  it 'does not register an offense for a hash without braces' do
    expect_no_offenses(<<~RUBY)
      create(:foo, bar: baz, created_at:
             2.days.ago)
    RUBY
  end

  context 'when Layout/HashAlignment is disabled' do
    let(:config) do
      RuboCop::Config.new(
        'Layout/HashAlignment' => { 'Enabled' => false },
        'Layout/HashValueIndentation' => cop_config
      )
    end

    it_behaves_like 'hash alignment, hash rocket style offense'
    it_behaves_like 'hash alignment, colon style offense'
  end

  context 'when Layout/HashAlignment is enabled with EnforcedHashRocketStyle table as a string' do
    let(:config) do
      RuboCop::Config.new(
        'Layout/HashAlignment' => { 'Enabled' => true, 'EnforcedHashRocketStyle' => 'table' },
        'Layout/HashValueIndentation' => cop_config
      )
    end

    it_behaves_like 'hash alignment, hash rocket style accepted'
    it_behaves_like 'hash alignment, colon style offense'
  end

  context 'when Layout/HashAlignment is enabled with EnforcedHashRocketStyle table as an array' do
    let(:config) do
      RuboCop::Config.new(
        'Layout/HashAlignment' => { 'Enabled' => true, 'EnforcedHashRocketStyle' => ['table'] },
        'Layout/HashValueIndentation' => cop_config
      )
    end

    it_behaves_like 'hash alignment, hash rocket style accepted'
    it_behaves_like 'hash alignment, colon style offense'
  end

  context 'when Layout/HashAlignment is enabled with EnforcedColonStyle table as a string' do
    let(:config) do
      RuboCop::Config.new(
        'Layout/HashAlignment' => { 'Enabled' => true, 'EnforcedColonStyle' => 'table' },
        'Layout/HashValueIndentation' => cop_config
      )
    end

    it_behaves_like 'hash alignment, colon style accepted'
    it_behaves_like 'hash alignment, hash rocket style offense'
  end

  context 'when Layout/HashAlignment is enabled with EnforcedColonStyle table as an array' do
    let(:config) do
      RuboCop::Config.new(
        'Layout/HashAlignment' => { 'Enabled' => true, 'EnforcedColonStyle' => ['table'] },
        'Layout/HashValueIndentation' => cop_config
      )
    end

    it_behaves_like 'hash alignment, colon style accepted'
    it_behaves_like 'hash alignment, hash rocket style offense'
  end
end
