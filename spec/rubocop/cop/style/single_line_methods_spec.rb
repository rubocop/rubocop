# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SingleLineMethods do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new('Style/SingleLineMethods' => cop_config,
                        'Layout/IndentationWidth' => { 'Width' => 2 })
  end
  let(:cop_config) { { 'AllowIfMethodIsEmpty' => true } }

  it 'registers an offense for a single-line method' do
    expect_offense(<<~RUBY)
      def some_method; body end
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
      def link_to(name, url); {:name => name}; end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
      def @table.columns; super; end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
    RUBY

    expect_correction(<<~RUBY)
      def some_method;#{trailing_whitespace}
        body#{trailing_whitespace}
      end
      def link_to(name, url);#{trailing_whitespace}
        {:name => name};#{trailing_whitespace}
      end
      def @table.columns;#{trailing_whitespace}
        super;#{trailing_whitespace}
      end
    RUBY
  end

  context 'when AllowIfMethodIsEmpty is disabled' do
    let(:cop_config) { { 'AllowIfMethodIsEmpty' => false } }

    it 'registers an offense for an empty method' do
      expect_offense(<<~RUBY)
        def no_op; end
        ^^^^^^^^^^^^^^ Avoid single-line method definitions.
        def self.resource_class=(klass); end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
        def @table.columns; end
        ^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
      RUBY

      expect_correction(<<~RUBY)
        def no_op;#{trailing_whitespace}
        end
        def self.resource_class=(klass);#{trailing_whitespace}
        end
        def @table.columns;#{trailing_whitespace}
        end
      RUBY
    end
  end

  context 'when AllowIfMethodIsEmpty is enabled' do
    let(:cop_config) { { 'AllowIfMethodIsEmpty' => true } }

    it 'accepts a single-line empty method' do
      expect_no_offenses(<<~RUBY)
        def no_op; end
        def self.resource_class=(klass); end
        def @table.columns; end
      RUBY
    end
  end

  it 'accepts a multi-line method' do
    expect_no_offenses(<<~RUBY)
      def some_method
        body
      end
    RUBY
  end

  it 'does not crash on an method with a capitalized name' do
    expect_no_offenses(<<~RUBY)
      def NoSnakeCase
      end
    RUBY
  end

  it 'auto-corrects def with semicolon after method name' do
    expect_offense(<<-RUBY.strip_margin('|'))
      |  def some_method; body end # Cmnt
      |  ^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
    RUBY

    expect_correction(<<-RUBY.strip_margin('|'))
      |  # Cmnt
      |  def some_method;#{trailing_whitespace}
      |    body#{trailing_whitespace}
      |  end#{trailing_whitespace}
    RUBY
  end

  it 'auto-corrects defs with parentheses after method name' do
    expect_offense(<<-RUBY.strip_margin('|'))
      |  def self.some_method() body end
      |  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
    RUBY

    expect_correction(<<-RUBY.strip_margin('|'))
      |  def self.some_method()#{trailing_whitespace}
      |    body#{trailing_whitespace}
      |  end
    RUBY
  end

  it 'auto-corrects def with argument in parentheses' do
    expect_offense(<<-RUBY.strip_margin('|'))
      |  def some_method(arg) body end
      |  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
    RUBY

    expect_correction(<<-RUBY.strip_margin('|'))
      |  def some_method(arg)#{trailing_whitespace}
      |    body#{trailing_whitespace}
      |  end
    RUBY
  end

  it 'auto-corrects def with argument and no parentheses' do
    expect_offense(<<-RUBY.strip_margin('|'))
      |  def some_method arg; body end
      |  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
    RUBY

    expect_correction(<<-RUBY.strip_margin('|'))
      |  def some_method arg;#{trailing_whitespace}
      |    body#{trailing_whitespace}
      |  end
    RUBY
  end

  it 'auto-corrects def with semicolon before end' do
    expect_offense(<<-RUBY.strip_margin('|'))
      |  def some_method; b1; b2; end
      |  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
    RUBY

    expect_correction(<<-RUBY.strip_margin('|'))
      |  def some_method;#{trailing_whitespace}
      |    b1;#{trailing_whitespace}
      |    b2;#{trailing_whitespace}
      |  end
    RUBY
  end
end
