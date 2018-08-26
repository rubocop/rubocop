# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NilComparison, :config do
  subject(:cop) { described_class.new(config) }

  context 'configured with predicate preferred' do
    let(:cop_config) { { 'EnforcedStyle' => 'predicate' } }

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

  context 'configured with comparison preferred' do
    let(:cop_config) { { 'EnforcedStyle' => 'comparison' } }

    it 'registers an offense for nil?' do
      expect_offense(<<-RUBY.strip_indent)
        x.nil?
          ^^^^ Prefer the use of the `==` comparison.
      RUBY
    end

    it 'autocorrects by replacing.nil? with == nil' do
      corrected = autocorrect_source('x.nil?')
      expect(corrected).to eq 'x == nil'
    end
  end
end
