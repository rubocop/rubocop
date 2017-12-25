# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SingleLineMethods do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new('Style/SingleLineMethods' => cop_config,
                        'Layout/IndentationWidth' => { 'Width' => 2 })
  end
  let(:cop_config) { { 'AllowIfMethodIsEmpty' => true } }

  it 'registers an offense for a single-line method' do
    expect_offense(<<-RUBY.strip_indent)
      def some_method; body end
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
      def link_to(name, url); {:name => name}; end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
      def @table.columns; super; end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
    RUBY
  end

  context 'when AllowIfMethodIsEmpty is disabled' do
    let(:cop_config) { { 'AllowIfMethodIsEmpty' => false } }

    it 'registers an offense for an empty method' do
      expect_offense(<<-RUBY.strip_indent)
        def no_op; end
        ^^^^^^^^^^^^^^ Avoid single-line method definitions.
        def self.resource_class=(klass); end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
        def @table.columns; end
        ^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
      RUBY
    end

    it 'auto-corrects an empty method' do
      corrected = autocorrect_source('def x; end')
      expect(corrected).to eq(['def x; ',
                               'end'].join("\n"))
    end
  end

  context 'when AllowIfMethodIsEmpty is enabled' do
    let(:cop_config) { { 'AllowIfMethodIsEmpty' => true } }

    it 'accepts a single-line empty method' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def no_op; end
        def self.resource_class=(klass); end
        def @table.columns; end
      RUBY
    end
  end

  it 'accepts a multi-line method' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def some_method
        body
      end
    RUBY
  end

  it 'does not crash on an method with a capitalized name' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def NoSnakeCase
      end
    RUBY
  end

  it 'auto-corrects def with semicolon after method name' do
    corrected = autocorrect_source(['  def some_method; body end # Cmnt'])
    expect(corrected).to eq ['  # Cmnt',
                             '  def some_method; ',
                             '    body ',
                             '  end '].join("\n")
  end

  it 'auto-corrects defs with parentheses after method name' do
    corrected = autocorrect_source(['  def self.some_method() body end'])
    expect(corrected).to eq ['  def self.some_method() ',
                             '    body ',
                             '  end'].join("\n")
  end

  it 'auto-corrects def with argument in parentheses' do
    corrected = autocorrect_source(['  def some_method(arg) body end'])
    expect(corrected).to eq ['  def some_method(arg) ',
                             '    body ',
                             '  end'].join("\n")
  end

  it 'auto-corrects def with argument and no parentheses' do
    corrected = autocorrect_source(['  def some_method arg; body end'])
    expect(corrected).to eq ['  def some_method arg; ',
                             '    body ',
                             '  end'].join("\n")
  end

  it 'auto-corrects def with semicolon before end' do
    corrected = autocorrect_source(['  def some_method; b1; b2; end'])
    expect(corrected).to eq ['  def some_method; ',
                             '    b1; ',
                             '    b2; ',
                             '  end'].join("\n")
  end
end
