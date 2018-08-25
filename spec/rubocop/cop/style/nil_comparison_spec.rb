# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NilComparison, :config do
  subject(:cop) { described_class.new(config) }

  context 'configured with predicate_method preferred' do
    let(:cop_config) { { 'EnforcedStyle' => 'predicate_method' } }

    it 'registers an offense for == nil' do
      expect_offense(<<-RUBY.strip_indent)
        x == nil
          ^^ Prefer the use of the `nil?` predicate.
      RUBY
    end

    it 'registers an offense for === nil' do
      expect_offense(<<-RUBY.strip_indent)
        x === nil
          ^^^ Prefer the use of the `nil?` predicate.
      RUBY
    end

    it 'autocorrects by replacing == nil with .nil?' do
      corrected = autocorrect_source('x == nil')
      expect(corrected).to eq 'x.nil?'
    end

    it 'autocorrects by replacing === nil with .nil?' do
      corrected = autocorrect_source('x === nil')
      expect(corrected).to eq 'x.nil?'
    end
  end

  context 'configured with explicit_comparison preferred' do
    let(:cop_config) { { 'EnforcedStyle' => 'explicit_comparison' } }

    it 'registers an offense for nil?' do
      expect_offense(<<-RUBY.strip_indent)
        x.nil?
          ^^^^ Prefer the use of the explicit `==` comparison.
      RUBY
    end

    it 'autocorrects by replacing.nil? with == nil' do
      corrected = autocorrect_source('x.nil?')
      expect(corrected).to eq 'x == nil'
    end
  end
end
