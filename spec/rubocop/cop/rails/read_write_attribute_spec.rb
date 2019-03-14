# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ReadWriteAttribute do
  subject(:cop) { described_class.new }

  context 'read_attribute' do
    it 'registers an offense and corrects a symbol' do
      expect_offense(<<-RUBY.strip_indent)
        res = read_attribute(:test)
              ^^^^^^^^^^^^^^ Prefer `self[:attr]` over `read_attribute(:attr)`.
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        res = self[:test]
      RUBY
    end

    it 'register an offense and corrects a string' do
      expect_offense(<<-RUBY.strip_indent)
        res = read_attribute('test')
              ^^^^^^^^^^^^^^ Prefer `self[:attr]` over `read_attribute(:attr)`.
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        res = self['test']
      RUBY
    end

    it 'autocorrects without parentheses' do
      expect_offense(<<-RUBY.strip_indent)
        res = read_attribute 'test'
              ^^^^^^^^^^^^^^ Prefer `self[:attr]` over `read_attribute(:attr)`.
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        res = self['test']
      RUBY
    end

    it 'corrects an expression' do
      expect_offense(<<-RUBY.strip_indent)
        res = read_attribute('test_' + postfix)
              ^^^^^^^^^^^^^^ Prefer `self[:attr]` over `read_attribute(:attr)`.
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        res = self['test_' + postfix]
      RUBY
    end

    it 'corrects multiline' do
      expect_offense(<<-RUBY.strip_indent)
        res = read_attribute(
              ^^^^^^^^^^^^^^ Prefer `self[:attr]` over `read_attribute(:attr)`.
        (
        'test_' + postfix
        ).to_sym
        )
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        res = self[(
        'test_' + postfix
        ).to_sym]
      RUBY
    end

    it 'registers no offense with explicit receiver' do
      expect_no_offenses('res = object.read_attribute(:test)')
    end
  end

  context 'write_attribute' do
    context 'when using a symbol for the attribute' do
      it 'registers an offense and corrects' do
        expect_offense(<<-RUBY.strip_indent)
          write_attribute(:test, val)
          ^^^^^^^^^^^^^^^ Prefer `self[:attr] = val` over `write_attribute(:attr, val)`.
        RUBY

        expect_correction(<<-RUBY.strip_indent)
          self[:test] = val
        RUBY
      end
    end

    context 'when using a string for the attribute' do
      it 'registers an offense and corrects' do
        expect_offense(<<-RUBY.strip_indent)
          write_attribute('attr', 'test')
          ^^^^^^^^^^^^^^^ Prefer `self[:attr] = val` over `write_attribute(:attr, val)`.
        RUBY

        expect_correction(<<-RUBY.strip_indent)
          self['attr'] = 'test'
        RUBY
      end
    end

    it 'registers an offense and corrects without parentheses' do
      expect_offense(<<-RUBY.strip_indent)
        write_attribute 'attr', 'test'
        ^^^^^^^^^^^^^^^ Prefer `self[:attr] = val` over `write_attribute(:attr, val)`.
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        self['attr'] = 'test'
      RUBY
    end

    it 'corrects assignment with chained methods' do
      expect_offense(<<-RUBY.strip_indent)
        write_attribute(:attr, 'test_' + postfix)
        ^^^^^^^^^^^^^^^ Prefer `self[:attr] = val` over `write_attribute(:attr, val)`.
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        self[:attr] = 'test_' + postfix
      RUBY
    end

    it 'autocorrects multiline' do
      expect_offense(<<-RUBY.strip_indent)
        write_attribute(
        ^^^^^^^^^^^^^^^ Prefer `self[:attr] = val` over `write_attribute(:attr, val)`.
        :attr,
        (
        'test_' + postfix
        ).to_sym
        )
      RUBY

      expect_correction(<<-RUBY.strip_indent)
        self[:attr] = (
        'test_' + postfix
        ).to_sym
      RUBY
    end

    it 'registers no offense with explicit receiver' do
      expect_no_offenses('object.write_attribute(:test, val)')
    end
  end
end
